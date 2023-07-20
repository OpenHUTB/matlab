

classdef MaskEditorInstance<handle

    properties(SetAccess=private,GetAccess=public)
        m_Context;
        m_MessageService;
        m_Dialog;
        m_ConfigLoader;
        m_SaveLoadFactory;
        m_Model;
        m_MF0Model;
        m_MEData;
        m_ConstraintManagerInterface;
    end

    properties(Constant)
        ConfigConstants=maskeditor.internal.loadsave.ConfigConstants();
    end

    methods(Access=public)
        function obj=MaskEditorInstance(aContext,debugFlag)
            obj.m_Context=aContext;

            obj.m_MessageService=maskeditor.internal.MessageService();


            obj.m_MessageService.subscribe('dataModelOperation',@(data)handleDataModelOperation(obj,data));
            obj.m_MessageService.subscribe('closeMaskEditorOperation',@(data)handleCloseMaskEditorOperation(obj,data));


            obj.m_Model=maskeditor.internal.MaskEditorModel(aContext,obj.m_MessageService.m_ChannelId);

            obj.m_MF0Model=obj.m_Model.DataModel;


            obj.m_MEData=simulink.maskeditor.MaskEditorModel(obj.m_MF0Model);


            obj.m_ConfigLoader=maskeditor.internal.loadsave.ConfigLoader(obj.m_MF0Model,aContext);
            [success,configMF0Object]=obj.m_ConfigLoader.loadConfigAndDataFiles();

            if success

                obj.m_MEData.appConfig=configMF0Object;

                if obj.m_ConfigLoader.isDocumentSupported(obj.ConfigConstants.CONSTRAINT_MANAGER)
                    obj.m_ConstraintManagerInterface=maskeditor.internal.ConstraintManagerInterface(aContext.blockHandle,...
                    obj.m_Model.DataModel,obj.m_MEData);
                end


                obj.m_SaveLoadFactory=maskeditor.internal.loadsave.DataSaveLoadFactory(obj);
                obj.m_SaveLoadFactory.loadAppData();
            end

            if(~success)
                obj.close();
                return;
            end


            if(debugFlag)
                web(obj.m_MessageService.getDebugURL(),'-browser');
            end

            obj.m_Dialog=maskeditor.internal.BrowserDialogFactory.create('CEF',obj.m_MessageService.getURL());


            obj.m_Dialog.addOnCloseFcn(@(varargin)obj.close);

            if obj.isSaveOnEdit()
                obj.m_Model.attachModelListener();
            end



        end

        function setTitleIfEmpty(this)
            aTitle=this.m_Dialog.getTitle();
            if~isempty(aTitle)
                return;
            end

            if(this.m_Context.isMaskOnModel)
                aTitle=getString(message('maskeditor:Editor:SystemMaskDialogTitle'));
            else
                aTitle=getString(message('maskeditor:Editor:DialogTitle'));
            end

            aTitle=[aTitle,': ',get_param(this.m_Context.blockHandle,'Name')];

            if(this.m_Context.isReadOnly)
                aTitle=[aTitle,getString(message('maskeditor:Editor:ReadOnlyText'))];
            end

            this.m_Dialog.setTitle(aTitle);
        end

        function createParameterPromotionDataInDataModel(this,args)
            this.m_SaveLoadFactory.loadParameterPromotionData(args);
            if this.isSaveOnEdit()
                this.m_Model.attachModelListener();
            end
        end

        function bSaveOnEdit=isSaveOnEdit(this)
            config=jsondecode(this.m_MEData.appConfig.config);
            bSaveOnEdit=eval(config.saveOnEdit);
        end

        function bSuccess=save(this)
            bSuccess=this.m_SaveLoadFactory.saveAppData();
        end

        function refreshModelMaskEditor(this,aSystemHandle,aData)
            this.m_SaveLoadFactory.refreshModelMaskEditor(aSystemHandle,aData);
        end

        function importMaskedBlock(this,aBlockPathToImport)

            aLibName=split(aBlockPathToImport,'/');
            load_system(aLibName{1});
            aMaskObjToImport=get_param(aBlockPathToImport,"MaskObject");

            aTransaction=this.m_Model.DataModel.beginRevertibleTransaction;

            this.m_ConstraintManagerInterface.onImportMask(aMaskObjToImport);
            this.m_SaveLoadFactory.importMask(aMaskObjToImport);

            aTransaction.commit('refreshmaskeditor');
        end

        function createMaskOnLink(this)
            this.m_Context.isReadOnly=false;
            this.m_Context.isMaskOnMask=true;

            aTransaction=this.m_Model.DataModel.beginTransaction;

            this.m_ConstraintManagerInterface=maskeditor.internal.ConstraintManagerInterface(...
            this.m_Context.blockHandle,this.m_Model.DataModel,this.m_MEData);

            this.m_SaveLoadFactory.createMaskOnLink();

            aTransaction.commit('maskonmaskcreated');
        end

        function evaluateBlock(this)
            aBlkHdl=maskeditor('GetBlockHandle',this.m_Context.blockHandle);
            aMaskObj=Simulink.Mask.get(aBlkHdl);
            if isempty(aMaskObj)
                return;
            end

            aExp=[];
            aSelfModifiable=aMaskObj.SelfModifiable;
            aInitialization=aMaskObj.Initialization;
            aMaskCallbacks=get_param(aBlkHdl,'MaskCallbacks');

            try
                if this.m_MEData.selfModifiable
                    aMaskObj.SelfModifiable='on';
                else
                    aMaskObj.SelfModifiable='off';
                end

                aMaskObj.Initialization=this.m_MEData.initialization;

                aWidgets=this.m_MEData.widgets;
                for i=1:aWidgets.Size()
                    aCallbackProperty=aWidgets(i).getPropertyByKey('Callback');
                    if~isempty(aCallbackProperty)
                        aName=aWidgets(i).getPropertyByKey('Name').value;
                        aParameter=aMaskObj.getParameter(aName);
                        if~isempty(aParameter)
                            aParameter.Callback=aCallbackProperty.value;
                        end
                    end
                end

                Simulink.Block.eval(aBlkHdl);
            catch exp
                aExp=MException('',slprivate('getExceptionMsgReport',exp));
            end

            aMaskObj.SelfModifiable=aSelfModifiable;
            aMaskObj.Initialization=aInitialization;
            set_param(aBlkHdl,'MaskCallbacks',aMaskCallbacks);

            if~isempty(aExp)
                throw(aExp);
            end
        end

        function constraintManagerModelObj=getConstraintManagerModelObject(this)
            constraintManagerModelObj=this.m_MEData.constraintManagerTopObject;
        end

        function addSharedConstraintToModel(this,haredConstraintList,product,matFileName,matFilePath)
            this.m_ConstraintManagerInterface.addMATFileAndConstraintsToModel(haredConstraintList,product,matFileName,matFilePath);
        end

        function sendMessage(this,aMsgData)
            this.m_MessageService.publish('UIInteractionAPIs',aMsgData);
        end

        function showDiagnosticMessage(this,aDiagnosticInfo)
            aMsgData=struct('Action','showDiagnostics','diagnosticInfo',aDiagnosticInfo);
            this.m_MessageService.publish('UIInteractionAPIs',aMsgData);
        end

        function delete(this)
            try
                aNonce=regexp(this.m_MessageService.m_URL,'snc\=([a-zA-Z0-9]+)','tokens');
                instanceId=aNonce{1}{1};
                Simulink.IconEditor.deleteEmbeddedInstance(instanceId);
                this.m_MessageService.delete();
                this.m_Dialog.delete();
            catch
            end
        end

        function show(this)
            this.m_Dialog.show();
        end

        function hide(this)
            this.m_Dialog.hide();
        end

        function close(this)
            try
                maskeditor('Delete',this.m_Context.blockHandle);
            catch
                this.delete();
            end
        end

        function[bIsVisible]=isVisible(this)
            bIsVisible=this.m_Dialog.isVisible();
        end

        function[aWindowPosition,bIsMaximized]=getWindowState(this)
            [aWindowPosition,bIsMaximized]=this.m_Dialog.getWindowState();
        end

        function setWindowState(this,aWindowState)
            this.m_Dialog.setWindowState(aWindowState);
        end

        function handleDataModelOperation(this,aCommandData)
            if strcmp(aCommandData.eventType,'loadParameterPromotionData')
                if~this.m_MEData.context.readOnly&&isempty(this.m_MEData.blockPromotableData)
                    this.createParameterPromotionDataInDataModel(aCommandData.args);
                    this.m_MessageService.publish('dataModelOperation','parameterPromotionDataReady');
                end
            elseif strcmp(aCommandData.eventType,'loadParameterPromototionDataForSubsystem')
                this.m_SaveLoadFactory.loadParameterPromotionDataForASubsystem(aCommandData.args);
            elseif strcmp(aCommandData.eventType,'loadAllParameterPromotionData')
                this.m_SaveLoadFactory.loadAllParameterPromotionData();
            end
        end

        function isAppReady=isAppReady(this)
            isAppReady=this.m_MEData.isAppReady;
        end

        function closeMaskEditorReqestFromTest(this)
            aMsgData=struct('Action','closemaskeditor');
            maskeditor('SendMessage',this.m_Context.blockHandle,aMsgData);
        end

        function handleCloseMaskEditorOperation(this,aCommandData)
            if strcmp(aCommandData.eventType,'closeMaskEditor')
                this.close();
            end
        end
    end

end
