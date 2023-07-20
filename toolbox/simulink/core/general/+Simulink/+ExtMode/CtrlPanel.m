classdef CtrlPanel<handle


































    properties(Access=public)





        m_modelName='';


        m_modelObj=[];
        m_mcosModelObj=[];





        ShowSimplifiedControlPanel=false;




        m_modelPostSaveListener=[];
        m_modelCloseListener=[];





        m_parameterChangeEventListener=[];





        m_configsetParameterChangeEventListener=[];




        m_theDialog=[];
        m_theDialogPos=[];





        m_sigAndTrigDlg=[];
        m_dataArchivingDlg=[];
    end

    properties(Constant,Access=public)



        m_EMCP_Dialog_Tag='ExtModeCtrlPanel_Dialog_Tag';
        m_EMCP_Connect_Disconnect_Tag='ExtModeCtrlPanel_Connect_Disconnect_Tag';
        m_EMCP_Start_Stop_Tag='ExtModeCtrlPanel_Start_Stop_Tag';
        m_EMCP_Arm_Cancel_Trigger_Tag='ExtModeCtrlPanel_Arm_Cancel_Trigger_Tag';
        m_EMCP_ConnectAndTriggering_Tag='ExtModeCtrlPanel_ConnectAndTriggering_Tag';
        m_EMCP_FloatUpload_Tag='ExtModeCtrlPanel_FloatUpload_Tag';
        m_EMCP_FloatDuration_Tag='ExtModeCtrlPanel_FloatDuration_Tag';
        m_EMCP_FloatScope_Tag='ExtModeCtrlPanel_FloatScope_Tag';
        m_EMCP_BatchDownloadCheckbox_Tag='ExtModeCtrlPanel_BatchDownloadCheckbox_Tag';
        m_EMCP_BatchDownloadButton_Tag='ExtModeCtrlPanel_BatchDownloadButton_Tag';
        m_EMCP_ParamChangesPending_Tag='ExtModeCtrlPanel_ParamChangesPending_Tag';
        m_EMCP_ParamTuning_Tag='ExtModeCtrlPanel_ParamTuning_Tag';
        m_EMCP_SigAndTrig_Tag='ExtModeCtrlPanel_SigAndTrig_Tag';
        m_EMCP_DataArchiving_Tag='ExtModeCtrlPanel_DataArchiving_Tag';
        m_EMCP_Configuration_Tag='ExtModeCtrlPanel_Configuration_Tag';
    end

    properties(Constant,Access=private)







        m_modelToCtrlPanelMap=containers.Map;
    end






























    methods(Access=private)
        function obj=CtrlPanel(modelName)
            obj.m_modelName=modelName;

            assert(~isempty(obj.m_modelName));
            obj.m_modelObj=get_param(modelName,'Object');
            obj.m_mcosModelObj=get_param(modelName,'InternalObject');

            obj.ShowSimplifiedControlPanel=coder.oneclick.Utils.isFeaturedOn&&...
            ~coder.oneclick.Utils.isSimulinkCoderInstalledAndLicensed&&...
            coder.oneclick.Utils.isRTTInstalled;
            obj.createModelListeners();
        end
        function isopen=isSigAndTrigDlgOpen(obj)
            isopen=~isempty(obj.m_sigAndTrigDlg)&&...
            ~isempty(obj.m_sigAndTrigDlg.m_theDialog);
        end
    end
    methods(Static,Access=private)
        function modelName=parseModelArgument(model)




            if~isempty(model)
                if ischar(model)
                    modelName=model;
                elseif isnumeric(model)
                    try
                        modelName=get(model,'Name');
                    catch ME
                        DAStudio.error('Simulink:dialog:ExtModeControlPanelInputArgError');
                    end
                else
                    DAStudio.error('Simulink:dialog:ExtModeControlPanelInputArgError');
                end
            else
                DAStudio.error('Simulink:dialog:ExtModeControlPanelInputArgError');
            end
        end
    end
    methods(Static,Access=public)
        function obj=createExtModeCtrlPanelForModel(model)



            modelName=Simulink.ExtMode.CtrlPanel.parseModelArgument(model);
            assert(~isempty(modelName));





            obj=Simulink.ExtMode.CtrlPanel.getCtrlPanelForModel(modelName);
            if isempty(obj)




                obj=Simulink.ExtMode.CtrlPanel(modelName);
                assert(~isempty(obj));
                Simulink.ExtMode.CtrlPanel.setCtrlPanelForModel(modelName,obj);
            end





            if isempty(obj.m_theDialog)
                obj.m_theDialog=DAStudio.Dialog(obj);
                assert(~isempty(obj.m_theDialog));
                if~isempty(obj.m_theDialogPos)
                    obj.m_theDialog.position=obj.m_theDialogPos;
                end

                obj.createParameterChangeEventListener;
            end





            obj.m_theDialog.show;
        end

        function obj=refreshExtModeCtrlPanelForModel(model,~)



            modelName=Simulink.ExtMode.CtrlPanel.parseModelArgument(model);
            assert(~isempty(modelName));

            coder.internal.toolstrip.HardwareBoardContextManager.refresh(model);







            obj=Simulink.ExtMode.CtrlPanel.getCtrlPanelForModel(modelName);
            if~isempty(obj)&&~isempty(obj.m_theDialog)



                obj.m_theDialog.refresh();





                if obj.isSigAndTrigDlgOpen



                    obj.updateSigAndTrigDialog();
                end
                if~isempty(obj.m_dataArchivingDlg)&&...
                    ~isempty(obj.m_dataArchivingDlg.m_theDialog)



                    obj.updateDataArchivingDialog();
                end
            end
        end
        function obj=destroyExtModeCtrlPanelForModel(model)



            modelName=Simulink.ExtMode.CtrlPanel.parseModelArgument(model);
            assert(~isempty(modelName));




            obj=Simulink.ExtMode.CtrlPanel.getCtrlPanelForModel(modelName);
            if~isempty(obj)
                obj.deleteDialog();
            end
        end
    end




    methods(Static,Access=private)
        function obj=getCtrlPanelForModel(modelName)
            obj=[];
            map=Simulink.ExtMode.CtrlPanel.m_modelToCtrlPanelMap;
            if isKey(map,modelName)
                obj=map(modelName);
            end
        end
        function setCtrlPanelForModel(modelName,obj)
            map=Simulink.ExtMode.CtrlPanel.m_modelToCtrlPanelMap;
            map(modelName)=obj;%#ok
        end
        function removeCtrlPanelForModel(modelName)
            map=Simulink.ExtMode.CtrlPanel.m_modelToCtrlPanelMap;
            remove(map,modelName);
        end
    end




    methods(Access=public)
        function reportError(obj,ME)%#ok<INUSL>
            [~,msg]=slprivate('getAllErrorIdsAndMsgs',ME,'concatenateIdsAndMsgs',true);
            errordlg(slprivate('removeHyperLinksFromMessage',msg),...
            DAStudio.message('Simulink:dialog:ExtModeControlPanelError'),...
            'modal');
        end

        function modelName=getModelName(obj)
            modelName=obj.m_modelName;
        end
        function setModelName(obj,modelName)
            obj.m_modelName=modelName;
        end

        function title=createDialogTitle(obj)
            title=DAStudio.message('Simulink:dialog:ExtModeControlPanel',obj.getModelName());
        end
        function setDialogTitle(obj,title)
            if~isempty(obj.m_theDialog)
                obj.m_theDialog.setTitle(title);
            end
        end

        function deleteDialog(obj)
            obj.destroyParameterChangeEventListener();
            if~isempty(obj.m_theDialog)
                obj.m_theDialogPos=obj.m_theDialog.position;
                obj.m_theDialog.delete;
                obj.m_theDialog=[];
            end
        end

        function updateSigAndTrigDialog(obj)


            cs=getActiveConfigSet(obj.getModelName());
            if(((coder.internal.xcp.isXCPTransport(cs)&&...
                isa(obj.m_sigAndTrigDlg,'Simulink.ExtMode.XCPSigAndTrigDlg'))||...
                ((~coder.internal.xcp.isXCPTransport(cs)&&...
                isa(obj.m_sigAndTrigDlg,'Simulink.ExtMode.SigAndTrigDlg')))))


                obj.m_sigAndTrigDlg.m_theDialog.refresh();
            else


                obj.m_sigAndTrigDlg.deleteDialog();

                if coder.internal.xcp.isXCPTransport(cs)
                    obj.m_sigAndTrigDlg=Simulink.ExtMode.XCPSigAndTrigDlg(obj);
                else
                    obj.m_sigAndTrigDlg=Simulink.ExtMode.SigAndTrigDlg(obj);
                end
            end
        end

        function updateDataArchivingDialog(obj)


            cs=getActiveConfigSet(obj.getModelName());
            if coder.internal.xcp.isXCPTransport(cs)


                obj.m_dataArchivingDlg.deleteDialog();
            else

                obj.m_dataArchivingDlg.m_theDialog.refresh();
            end
        end

        function createModelListeners(obj)
            obj.m_modelPostSaveListener=Simulink.listener(obj.m_modelObj,'PostSaveEvent',@(src,eventData)obj.modelPostSaveListener(src,eventData,obj));
            obj.m_modelCloseListener=Simulink.listener(obj.m_modelObj,'CloseEvent',@(src,eventData)obj.modelCloseListener(src,eventData,obj));
        end

        function createParameterChangeEventListener(obj)


            obj.m_parameterChangeEventListener=...
            obj.m_mcosModelObj.addlistener('SLGraphicalEvent::MODEL_PARAMETER_CHANGE_EVENT',...
            @(src,eventData)obj.parameterChangeEventListener(src,eventData,obj));



            obj.m_configsetParameterChangeEventListener=configset.ParamListener(obj.m_modelObj.Handle,...
            'ExtModeMexFile',...
            @Simulink.ExtMode.CtrlPanel.configsetParameterChangeEventListener);
        end

        function destroyModelListeners(obj)
            delete(obj.m_modelPostSaveListener);
            obj.m_modelPostSaveListener=[];
            delete(obj.m_modelCloseListener);
            obj.m_modelCloseListener=[];
        end

        function destroyParameterChangeEventListener(obj)
            delete(obj.m_parameterChangeEventListener);
            obj.m_parameterChangeEventListener=[];
            delete(obj.m_configsetParameterChangeEventListener);
            obj.m_configsetParameterChangeEventListener=[];
        end
    end




    methods(Access=public)
        function val=isExtModeMexFileDefined(obj)
            val=~isempty(get_param(obj.m_modelName,'ExtModeMexFile'));
        end

        function isConnected=isExtModeConnected(obj)
            isConnected=strcmp(get_param(obj.m_modelName,'ExtModeConnected'),'on');
        end

        function isStarted=isExtModeTargetStarted(obj)
            isStarted=false;
            if obj.isExtModeConnected()
                tgtSimStatus=get_param(obj.getModelName(),'ExtModeTargetSimStatus');

                if strcmp(tgtSimStatus,'running')||...
                    strcmp(tgtSimStatus,'startPending')||...
                    strcmp(tgtSimStatus,'paused')
                    isStarted=true;
                end
            end
        end

        function isArmed=isExtModeArmed(obj)
            isArmed=false;
            if obj.isExtModeConnected()
                upStatus=get_param(obj.getModelName(),'ExtModeUploadStatus');

                if strcmp(upStatus,'armed')||strcmp(upStatus,'uploading')
                    isArmed=true;
                end
            end
        end

        function val=isExtModeConnectButtonVisible(obj)
            val=~obj.isExtModeMexFileDefined()||~obj.isExtModeConnected();
        end

        function isEnabled=isExtModeConnectDisconnectButtonEnabled(obj)
            isEnabled=strcmp(get_param(obj.m_modelName,'ExtModeConnectButtonEnabled'),'on');
        end

        function val=isExtModeStartButtonVisible(obj)
            val=~obj.isExtModeMexFileDefined()||~isExtModeTargetStarted(obj);
        end

        function isEnabled=isExtModeStartStopButtonEnabled(obj)
            isEnabled=strcmp(get_param(obj.m_modelName,'ExtModeStartButtonEnabled'),'on');
        end

        function val=isExtModeArmTriggerButtonVisible(obj)
            val=~obj.isExtModeMexFileDefined()||~obj.isExtModeArmed();
        end

        function isEnabled=isExtModeArmTriggerButtonEnabled(obj)
            isEnabled=strcmp(get_param(obj.m_modelName,'ExtModeArmButtonEnabled'),'on');
        end

        function isEnabled=isExtModeFloatingEnabled(obj)
            isEnabled=strcmp(get_param(obj.getModelName(),'ExtModeEnableFloating'),'on');
        end
    end




    methods(Static,Access=public)
        function modelPostSaveListener(source,~,obj)
            oldModelName=obj.getModelName();
            newModelName=source.Name;

            if~strcmp(oldModelName,newModelName)






                Simulink.ExtMode.CtrlPanel.removeCtrlPanelForModel(oldModelName);
                obj.setModelName(newModelName);
                Simulink.ExtMode.CtrlPanel.setCtrlPanelForModel(newModelName,obj);





                obj.setDialogTitle(obj.createDialogTitle());
                if~isempty(obj.m_sigAndTrigDlg)
                    obj.m_sigAndTrigDlg.setDialogTitle(obj.m_sigAndTrigDlg.createDialogTitle());
                end
                if~isempty(obj.m_dataArchivingDlg)
                    obj.m_dataArchivingDlg.setDialogTitle(obj.m_dataArchivingDlg.createDialogTitle());
                end
            end
        end

        function modelCloseListener(~,~,obj)
            Simulink.ExtMode.CtrlPanel.removeCtrlPanelForModel(obj.getModelName());
            obj.deleteDialog();
            obj.setModelName('');
            obj.destroyModelListeners();
        end

        function parameterChangeEventListener(~,eventData,obj)



            assert(~isempty(obj)&&~isempty(obj.m_theDialog),...
            'MODEL_PARAMETER_CHANGE_EVENT listener should have been destroyed when dialog was closed');

            switch eventData.ParameterName
            case 'ExtModeEnableFloating'
                obj.refreshCheckboxWidget(...
                obj.m_theDialog,...
                obj.m_EMCP_FloatUpload_Tag,...
                obj.getModelName(),...
                'ExtModeEnableFloating');

            case 'ExtModeTrigDurationFloating'
                obj.refreshEditWidget(...
                obj.m_theDialog,...
                obj.m_EMCP_FloatDuration_Tag,...
                obj.getModelName(),...
                'ExtModeTrigDurationFloating');

            case 'ExtModeBatchMode'
                extModeBatchModeUpdated=obj.refreshCheckboxWidget(...
                obj.m_theDialog,...
                obj.m_EMCP_BatchDownloadCheckbox_Tag,...
                obj.getModelName(),...
                'ExtModeBatchMode');

                if extModeBatchModeUpdated


                    obj.m_theDialog.refresh();
                end
            otherwise


            end
        end




        function configsetParameterChangeEventListener(model,~,~)


            Simulink.ExtMode.CtrlPanel.refreshExtModeCtrlPanelForModel(model,'ChangeTransport');
        end
    end



    methods(Static,Access=private)
        function toUpdate=refreshCheckboxWidget(dialog,tag,modelName,parameterName)

            modelParamValue=...
            slprivate('onoff',get_param(modelName,parameterName));
            widgetValue=dialog.getWidgetValue(tag);

            toUpdate=(modelParamValue~=widgetValue);
            if toUpdate



                dialog.setWidgetValue(...
                tag,...
                modelParamValue);
            end
        end

        function refreshEditWidget(dialog,tag,modelName,parameterName)

            modelParamValue=get_param(modelName,parameterName);
            widgetValue=dialog.getWidgetValue(tag);
            toUpdate=~strcmp(modelParamValue,widgetValue);
            if toUpdate
                dialog.setWidgetValue(...
                tag,...
                modelParamValue);
            end
        end
    end




    methods(Access=public)
        function val=connectDisconnectButtonName(obj)
            val=DAStudio.message('Simulink:dialog:ExtModeConnect');
            if~obj.isExtModeConnectButtonVisible()
                val=DAStudio.message('Simulink:dialog:ExtModeDisconnect');
            end
        end

        function val=connectDisconnectButtonTooltip(obj)
            val=DAStudio.message('Simulink:dialog:ExtModeConnectTooltip',obj.getModelName());
            if~obj.isExtModeConnectButtonVisible()
                val=DAStudio.message('Simulink:dialog:ExtModeDisconnectTooltip',obj.getModelName());
            end
        end

        function val=connectDisconnectButtonEnabled(obj)
            val=obj.isExtModeMexFileDefined()&&...
            obj.isExtModeConnectDisconnectButtonEnabled();
        end

        function connectDisconnectButtonCB(obj)
            try
                modelName=obj.getModelName();
                if obj.isExtModeConnectButtonVisible()
                    assert(~obj.isExtModeConnected());

                    if~strcmp(get_param(modelName,'SimulationMode'),'external')
                        set_param(modelName,'SimulationMode','External');
                    end



                    if obj.ShowSimplifiedControlPanel&&...
                        ~(strcmp(get_param(modelName,...
                        'SystemTargetFile'),'realtime.tlc')||...
                        codertarget.target.isCoderTarget(modelName))
                        DAStudio.error('realtime:build:WrongSystemTargetFileMdlRef',...
                        modelName);
                    end


                    obj.m_theDialog.setEnabled(obj.m_EMCP_Connect_Disconnect_Tag,false);
                    set_param(modelName,'SimulationCommand','connect');
                else
                    assert(obj.isExtModeConnected());
                    set_param(modelName,'SimulationCommand','disconnect');
                end
            catch ME
                obj.reportError(ME);
            end
        end

        function val=startStopButtonName(obj)
            val=DAStudio.message('Simulink:dialog:ExtModeStartRealTimeCode');
            if~obj.isExtModeStartButtonVisible()
                val=DAStudio.message('Simulink:dialog:ExtModeStopRealTimeCode');
            end
        end

        function val=startStopButtonTooltip(obj)
            val=DAStudio.message('Simulink:dialog:ExtModeStartRealTimeCodeTooltip');
            if~obj.isExtModeStartButtonVisible()
                val=DAStudio.message('Simulink:dialog:ExtModeStopRealTimeCodeTooltip');
            end
        end

        function val=startStopButtonEnabled(obj)
            val=obj.isExtModeMexFileDefined()&&...
            obj.isExtModeConnected()&&...
            obj.isExtModeStartStopButtonEnabled();
        end

        function startStopButtonCB(obj)
            try
                if obj.isExtModeStartButtonVisible()
                    set_param(obj.getModelName(),'SimulationCommand','start');
                else
                    set_param(obj.getModelName(),'SimulationCommand','stop');
                end
            catch ME
                obj.reportError(ME);
            end
        end

        function val=armCancelTriggerButtonName(obj)
            val=DAStudio.message('Simulink:dialog:ExtModeArmTrigger');
            if~obj.isExtModeArmTriggerButtonVisible()
                val=DAStudio.message('Simulink:dialog:ExtModeCancelTrigger');
            end
        end

        function val=armCancelTriggerButtonTooltip(obj)
            val=DAStudio.message('Simulink:dialog:ExtModeArmTriggerTooltip');
            if~obj.isExtModeArmTriggerButtonVisible()
                val=DAStudio.message('Simulink:dialog:ExtModeCancelTriggerTooltip');
            end
        end

        function val=armCancelTriggerButtonEnabled(obj)
            val=obj.isExtModeMexFileDefined()&&...
            obj.isExtModeConnected()&&...
            obj.isExtModeArmTriggerButtonEnabled();
        end

        function armCancelTriggerButtonCB(obj)
            try
                if obj.isExtModeArmTriggerButtonVisible()
                    set_param(obj.getModelName(),'ExtModeCommand','armWired');
                else
                    set_param(obj.getModelName(),'ExtModeCommand','cancelWired');
                end
            catch ME
                obj.reportError(ME);
            end
        end

        function val=floatUploadCheckboxEnabled(obj)
            val=obj.isExtModeMexFileDefined();
        end

        function floatUploadCheckBoxCB(obj)
            try
                bd=obj.getModelName();

                val=obj.m_theDialog.getWidgetValue(obj.m_EMCP_FloatUpload_Tag);
                set_param(bd,'ExtModeEnableFloating',slprivate('onoff',val));

                if obj.isExtModeConnected()
                    if val
                        set_param(bd,'ExtModeCommand','armFloating');
                    else
                        set_param(bd,'ExtModeCommand','cancelFloating');
                    end
                end
            catch ME
                obj.reportError(ME);
            end
        end

        function val=floatDurationEditEnabled(obj)
            cs=getActiveConfigSet(obj.getModelName());
            val=obj.isExtModeMexFileDefined()&&...
            (~obj.isExtModeConnected()||...
            ~obj.isExtModeFloatingEnabled())&&...
            ~coder.internal.xcp.isXCPTransport(cs);
        end

        function floatDurationEditCB(obj)
            try
                bd=obj.getModelName();

                val=obj.m_theDialog.getWidgetValue(obj.m_EMCP_FloatDuration_Tag);
                if~strcmpi(val,'auto')&&(slResolve(val,bd,'expression','base')<=0)
                    msgid='Simulink:dialog:ExtModeFloatDurationError';
                    ME=MException(message(msgid));
                    obj.reportError(ME);
                    orig_val=get_param(bd,'ExtModeTrigDurationFloating');
                    obj.m_theDialog.setWidgetValue(obj.m_EMCP_FloatDuration_Tag,orig_val);
                else
                    set_param(bd,'ExtModeTrigDurationFloating',val);
                end
            catch ME
                obj.reportError(ME);
                orig_val=get_param(bd,'ExtModeTrigDurationFloating');
                obj.m_theDialog.setWidgetValue(obj.m_EMCP_FloatDuration_Tag,orig_val);
            end
        end

        function val=batchDownloadCheckboxEnabled(obj)
            val=obj.isExtModeMexFileDefined();
        end

        function batchDownloadCheckBoxCB(obj)
            try
                val=obj.m_theDialog.getWidgetValue(obj.m_EMCP_BatchDownloadCheckbox_Tag);



                Simulink.ExtMode.setBatchModeAndUpdate(obj.getModelName(),slprivate('onoff',val));
            catch ME
                obj.reportError(ME);
            end
        end

        function val=batchDownloadButtonEnabled(obj)
            val=obj.isExtModeMexFileDefined()&&...
            strcmp(get_param(obj.getModelName(),'ExtModeBatchMode'),'on');
        end

        function batchDownloadButtonCB(obj)
            try
                set_param(obj.getModelName(),'SimulationCommand','update');
            catch ME
                obj.reportError(ME);
            end
        end

        function val=paramChangesPendingTextVisible(obj)
            val=obj.isExtModeMexFileDefined()&&...
            strcmp(get_param(obj.getModelName(),'ExtModeChangesPending'),'on');
        end

        function val=sigAndTrigButtonEnabled(obj)
            val=obj.isExtModeMexFileDefined();
        end

        function sigAndTrigButtonCB(obj)
            try
                if~obj.isSigAndTrigDlgOpen
                    cs=getActiveConfigSet(obj.getModelName());
                    if coder.internal.xcp.isXCPTransport(cs)
                        obj.m_sigAndTrigDlg=Simulink.ExtMode.XCPSigAndTrigDlg(obj);
                    else
                        obj.m_sigAndTrigDlg=Simulink.ExtMode.SigAndTrigDlg(obj);
                    end

                else
                    obj.m_sigAndTrigDlg.showDialog();
                end
            catch ME
                obj.reportError(ME);
            end
        end

        function val=dataArchivingButtonEnabled(obj)
            cs=getActiveConfigSet(obj.getModelName());
            val=obj.isExtModeMexFileDefined()&&...
            ~coder.internal.xcp.isXCPTransport(cs);
        end

        function dataArchivingButtonCB(obj)
            try
                if isempty(obj.m_dataArchivingDlg)
                    obj.m_dataArchivingDlg=Simulink.ExtMode.DataArchivingDlg(obj);
                else
                    obj.m_dataArchivingDlg.showDialog();
                end
            catch ME
                obj.reportError(ME);
            end
        end

        function closeCB(obj)
            obj.m_theDialogPos=obj.m_theDialog.position;
            obj.m_theDialog=[];
            obj.destroyParameterChangeEventListener;
            if~isempty(obj.m_sigAndTrigDlg)
                obj.m_sigAndTrigDlg.deleteDialog();
            end
            if~isempty(obj.m_dataArchivingDlg)
                obj.m_dataArchivingDlg.deleteDialog();
            end
        end
    end

    methods



        function dlg=getDialogSchema(obj,~)



            widget=[];
            widget.Name=obj.connectDisconnectButtonName();
            widget.Type='pushbutton';
            widget.Tag=obj.m_EMCP_Connect_Disconnect_Tag;
            widget.ToolTip=obj.connectDisconnectButtonTooltip();
            widget.ObjectMethod='connectDisconnectButtonCB';
            widget.Enabled=obj.connectDisconnectButtonEnabled();
            widget.RowSpan=[1,1];
            widget.ColSpan=[1,1];
            widget.DialogRefresh=true;

            ConnectDisconnectButton=widget;




            widget=[];
            widget.Name=obj.startStopButtonName();
            widget.Type='pushbutton';
            widget.Tag=obj.m_EMCP_Start_Stop_Tag;
            widget.ToolTip=obj.startStopButtonTooltip();
            widget.ObjectMethod='startStopButtonCB';
            widget.Enabled=obj.startStopButtonEnabled();
            widget.RowSpan=[1,1];
            widget.ColSpan=[2,2];
            widget.DialogRefresh=true;

            StartStopButton=widget;




            widget=[];
            widget.Name=obj.armCancelTriggerButtonName();
            widget.Type='pushbutton';
            widget.Tag=obj.m_EMCP_Arm_Cancel_Trigger_Tag;
            widget.ToolTip=obj.armCancelTriggerButtonTooltip();
            widget.ObjectMethod='armCancelTriggerButtonCB';
            widget.Enabled=obj.armCancelTriggerButtonEnabled();
            widget.RowSpan=[1,1];
            widget.ColSpan=[3,3];
            widget.DialogRefresh=true;

            ArmCancelButton=widget;




            widget=[];
            widget.Name=DAStudio.message('Simulink:dialog:ExtModeConnectionAndTriggering');
            widget.Tag=obj.m_EMCP_ConnectAndTriggering_Tag;
            widget.Type='group';
            if obj.ShowSimplifiedControlPanel
                widget.Items={ConnectDisconnectButton,StartStopButton};
            else
                widget.Items={ConnectDisconnectButton,StartStopButton,ArmCancelButton};
            end
            widget.LayoutGrid=[1,3];

            ConnectAndTriggerGroup=widget;

            if~obj.ShowSimplifiedControlPanel



                widget=[];
                widget.Name=DAStudio.message('Simulink:dialog:ExtModeEnableDataUploading');
                widget.Type='checkbox';
                widget.Tag=obj.m_EMCP_FloatUpload_Tag;
                widget.ToolTip=DAStudio.message('Simulink:dialog:ExtModeEnableDataUploadingTooltip');
                widget.Value=slprivate('onoff',get_param(obj.getModelName(),'ExtModeEnableFloating'));
                widget.ObjectMethod='floatUploadCheckBoxCB';
                widget.Enabled=obj.floatUploadCheckboxEnabled();
                widget.RowSpan=[1,1];
                widget.ColSpan=[1,1];
                widget.DialogRefresh=true;
                widget.Graphical=true;

                FloatUploadCheckBox=widget;




                widget=[];
                widget.Name=DAStudio.message('Simulink:dialog:ExtModeDuration');
                widget.Type='edit';
                widget.Tag=obj.m_EMCP_FloatDuration_Tag;
                widget.ToolTip=DAStudio.message('Simulink:dialog:ExtModeDurationTooltip');
                widget.Value=get_param(obj.getModelName(),'ExtModeTrigDurationFloating');
                widget.ObjectMethod='floatDurationEditCB';
                widget.Enabled=obj.floatDurationEditEnabled();
                widget.RowSpan=[2,2];
                widget.ColSpan=[1,1];
                widget.DialogRefresh=true;
                widget.Graphical=true;

                FloatDurationEdit=widget;




                widget=[];
                widget.Name=DAStudio.message('Simulink:dialog:ExtModeFloatingScope');
                widget.Tag=obj.m_EMCP_FloatScope_Tag;
                widget.Type='group';
                widget.Items={FloatUploadCheckBox,FloatDurationEdit};
                widget.LayoutGrid=[2,1];

                FloatScopeGroup=widget;
            end




            widget=[];
            widget.Name=DAStudio.message('Simulink:dialog:ExtModeBatchDownload');
            widget.Type='checkbox';
            widget.Tag=obj.m_EMCP_BatchDownloadCheckbox_Tag;
            widget.ToolTip=DAStudio.message('Simulink:dialog:ExtModeBatchDownloadTooltip',obj.getModelName());
            widget.Value=slprivate('onoff',get_param(obj.getModelName(),'ExtModeBatchMode'));
            widget.ObjectMethod='batchDownloadCheckBoxCB';
            widget.Enabled=obj.batchDownloadCheckboxEnabled();
            widget.RowSpan=[1,1];
            widget.ColSpan=[1,3];
            widget.DialogRefresh=true;
            widget.Graphical=true;


            BatchDownloadCheckBox=widget;




            widget=[];
            widget.Name=DAStudio.message('Simulink:dialog:ExtModeDownload');
            widget.Type='pushbutton';
            widget.Tag=obj.m_EMCP_BatchDownloadButton_Tag;
            widget.ToolTip=DAStudio.message('Simulink:dialog:ExtModeDownloadTooltip');
            widget.ObjectMethod='batchDownloadButtonCB';
            widget.Enabled=obj.batchDownloadButtonEnabled();
            widget.RowSpan=[2,2];
            widget.ColSpan=[1,1];
            widget.DialogRefresh=true;

            BatchDownloadButton=widget;




            widget=[];
            widget.Name=DAStudio.message('Simulink:dialog:ExtModeParameterChangesPending');
            widget.Type='text';
            widget.Tag=obj.m_EMCP_ParamChangesPending_Tag;
            widget.ForegroundColor=[0,0,255];
            widget.Visible=obj.paramChangesPendingTextVisible;
            widget.RowSpan=[2,2];
            widget.ColSpan=[2,3];

            ParamChangesPendingText=widget;




            widget=[];
            widget.Name=DAStudio.message('Simulink:dialog:ExtModeParameterTuning');
            widget.Tag=obj.m_EMCP_ParamTuning_Tag;
            widget.Type='group';
            widget.Items={BatchDownloadCheckBox,BatchDownloadButton,ParamChangesPendingText};
            widget.LayoutGrid=[2,3];

            ParamTuningGroup=widget;

            if~obj.ShowSimplifiedControlPanel



                widget=[];
                widget.Name=DAStudio.message('Simulink:dialog:ExtModeSigAndTrigButtonTitle');
                widget.Type='pushbutton';
                widget.Tag=obj.m_EMCP_SigAndTrig_Tag;
                widget.ToolTip=DAStudio.message('Simulink:dialog:ExtModeSigAndTrigButtonTitleTooltip',obj.getModelName());
                widget.ObjectMethod='sigAndTrigButtonCB';
                widget.Enabled=obj.sigAndTrigButtonEnabled();
                widget.RowSpan=[1,1];
                widget.ColSpan=[1,1];

                SigAndTrigButton=widget;




                widget=[];
                widget.Name=DAStudio.message('Simulink:dialog:ExtModeDataArchiving');
                widget.Type='pushbutton';
                widget.Tag=obj.m_EMCP_DataArchiving_Tag;
                widget.ToolTip=DAStudio.message('Simulink:dialog:ExtModeDataArchivingTooltip',obj.getModelName());
                widget.ObjectMethod='dataArchivingButtonCB';
                widget.Enabled=obj.dataArchivingButtonEnabled();
                widget.RowSpan=[1,1];
                widget.ColSpan=[2,2];

                DataArchivingButton=widget;




                widget=[];
                widget.Name=DAStudio.message('Simulink:dialog:ExtModeConfiguration');
                widget.Tag=obj.m_EMCP_Configuration_Tag;
                widget.Type='group';
                widget.Items={SigAndTrigButton,DataArchivingButton};
                widget.LayoutGrid=[1,2];

                ConfigurationGroup=widget;
            end




            dlg.DialogTitle=obj.createDialogTitle();
            dlg.DialogTag=obj.m_EMCP_Dialog_Tag;
            dlg.HelpMethod='helpview';
            if obj.ShowSimplifiedControlPanel
                dlg.HelpArgs={fullfile(docroot,'simulink','helptargets.map'),'simulink_external_mode_control_panel'};
                dlg.Items={ConnectAndTriggerGroup,ParamTuningGroup};
            else
                dlg.HelpArgs={fullfile(docroot,'rtw','helptargets.map'),'rtw_external_mode_control_panel'};
                dlg.Items={ConnectAndTriggerGroup,FloatScopeGroup,ParamTuningGroup,ConfigurationGroup};
            end
            dlg.StandaloneButtonSet={'OK','Help'};
            dlg.CloseMethod='closeCB';
            dlg.Sticky=false;
        end
    end
end
