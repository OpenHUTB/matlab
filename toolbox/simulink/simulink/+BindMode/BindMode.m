

classdef(Sealed)BindMode<handle
    properties(Constant)
        DIALOG_MIN_WIDTH=300;
        DIALOG_MAX_WIDTH=600;
        DIALOG_INITIAL_HEIGHT=30;
        DIALOG_PADDING=4;
    end

    properties(SetAccess=protected,GetAccess=public)
        modelObj;
        childModelObjects={};


        bindModeSourceDataObj;
        bindModeSelectionDataObj;
        styler;
        sourceHierarchyId;
        rootModelListeners={};
        childModelListeners={};
        studioSet={};
        editorChangeCallbackSet=[];
        windowActivatedCallbackSet=[];
        dialogHandle=[];
        dialogReady=false;
        dialogTransientProperty=true;
        showedHelpText=false;
        helpTextEditor;
        helpNotificationTimerObj;
        helpNotificationTimerDuration=5;
    end

    properties(Access=private)
        messagingRoot='/bindModeDialog/';
        messagingSubscriptions={};
        currentDropDownValue='';
    end

    methods(Access=private)

        function obj=BindMode(modelObj,bindModeSourceDataObj)
            obj.modelObj=modelObj;
            obj.bindModeSourceDataObj=bindModeSourceDataObj;
            if bindModeSourceDataObj.requiresDropDownMenu
                obj.currentDropDownValue=bindModeSourceDataObj.dropDownElements{1};
            else
                obj.currentDropDownValue='';
            end
        end

        function addStylingAndSelectionListeners(this)
            rootModelHandle=this.modelObj.Handle;


            childModelHandles=cellfun(@(ob)ob.Handle,this.childModelObjects);
            allStudios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
            for idx=1:numel(allStudios)
                studio=allStudios(idx);
                if~isempty(studio)
                    mdlH=studio.App.blockDiagramHandle;
                    csRefBlkH=getSimulinkBlockHandle(get_param(mdlH,'CoSimContext'));
                    isInCtxMdl=csRefBlkH~=-1&&bdroot(csRefBlkH)==rootModelHandle;
                    if mdlH==rootModelHandle||isInCtxMdl
                        this.studioSet{end+1}=studio;
                        c=studio.getService('GLUE2:ActiveEditorChanged');
                        registerCallbackId=c.registerServiceCallback(@this.handleEditorChanged);
                        this.editorChangeCallbackSet(end+1)=registerCallbackId;
                        if isInCtxMdl
                            childModelHandles(end+1)=mdlH;%#ok<AGROW>
                            this.childModelObjects{end+1}=get_param(mdlH,'Object');
                        end
                    end
                end
            end



            hierarchyId=SLM3I.HierarchyServiceUtils.getDefaultHIDForGraph(rootModelHandle);
            this.styler=SLStudio.AttentionStyler;
            this.styler.applyGreyEverything(rootModelHandle,'HierarchyID',hierarchyId);
            if(~isempty(childModelHandles))
                for idx=1:numel(childModelHandles)
                    childHierarchyId=SLM3I.HierarchyServiceUtils.getDefaultHIDForGraph(childModelHandles(idx));
                    this.styler.applyGreyEverything(childModelHandles(idx),'HierarchyID',childHierarchyId);
                end
            end


            if(this.bindModeSourceDataObj.isGraphical)



                this.sourceHierarchyId=hierarchyId;
                sourceDiagramHandle=bdroot(this.bindModeSourceDataObj.sourceElementHandle);
                if(sourceDiagramHandle~=this.modelObj.Handle)
                    editor=BindMode.utils.getLastActiveEditor();
                    if(~isempty(editor))
                        this.sourceHierarchyId=editor.getHierarchyId;
                    end
                end
                this.styler.removeCurrentHighlight(this.modelObj.Handle,'HierarchyID',this.sourceHierarchyId);
                this.styler.applyNoGrey(this.bindModeSourceDataObj.sourceElementHandle,'HierarchyID',this.sourceHierarchyId);
                this.styler.applyHighlight(this.bindModeSourceDataObj.sourceElementHandle,'HierarchyID',this.sourceHierarchyId);
            end




            r{1}=Simulink.listener(this.modelObj,'SelectionChangeEvent',...
            @(bd,evt)this.handleEmptyCanvasAreaClick());
            r{2}=Simulink.listener(this.modelObj,'CloseEvent',...
            @(bd,evt)BindMode.BindMode.disableBindMode(this.modelObj));
            this.rootModelListeners=r;


            cListeners={};
            for idx=1:numel(this.childModelObjects)
                cListeners{end+1}=Simulink.listener(this.childModelObjects{idx},'SelectionChangeEvent',...
                @(bd,evt)this.handleEmptyCanvasAreaClick());%#ok<AGROW>
                cListeners{end+1}=Simulink.listener(this.childModelObjects{idx},'CloseEvent',...
                @(bd,evt)this.handleChildModelClosed(bd));%#ok<AGROW>
            end
            this.childModelListeners=cListeners;


            allModelObjects=[this.modelObj,this.childModelObjects{:}];

            for idx=1:numel(allModelObjects)
                editors=BindMode.utils.getAllEditorsForModel(allModelObjects(idx).Handle);
                for e=1:numel(editors)
                    editors(e).sendMessageToTools('SLInitiateBindMode');
                end
            end


            if(this.bindModeSourceDataObj.shouldShowHelpNotification()&&...
                ~this.showedHelpText)
                this.showHelp();
                this.showedHelpText=true;
            end
        end

        function handleWindowActivated(this,~)
            this.reevaluateBindModeStatus();
        end

        function handleEditorChanged(this,~)


            if(this.dialogTransientProperty)
                this.hideDialog();
            end

            studios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive();
            studio=studios(1);
            editor=studio.App.getActiveEditor();
            if(strcmp(editor.getType(),'InterfaceEditor:Editor'))
                BindMode.BindMode.disableBindMode(this.modelObj);
                return;
            end

            BindMode.utils.AlertBindModeTool(this.modelObj.Handle);
        end

        function reevaluateBindModeStatus(this)


            allStudios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
            spawningInfo=allStudios(1).App.studioSpawningInfo;
            if(spawningInfo.parentBdHandle~=-1)
                currentBdHandle=allStudios(1).App.blockDiagramHandle;
                try
                    parentBdObj=get_param(spawningInfo.parentBdHandle,'Object');
                catch ME
                    if(strcmp(ME.identifier,'Simulink:Commands:InvSimulinkObjHandle'))


                        BindMode.BindMode.exitBindModeForModel(currentBdHandle);
                        return;
                    end
                end
                currentBdObj=get_param(currentBdHandle,'Object');
                if(currentBdObj~=this.modelObj)
                    if(BindMode.BindMode.isEnabled(currentBdObj)&&...
                        ~BindMode.BindMode.isEnabled(parentBdObj))

                        BindMode.BindMode.exitBindModeForModel(currentBdHandle);
                    elseif(BindMode.BindMode.isEnabled(parentBdObj)&&...
                        ~BindMode.BindMode.isEnabled(currentBdObj))

                        BindMode.BindMode.addChildModel(currentBdHandle);
                    end
                end
            end
        end

        function handleEmptyCanvasAreaClick(this)



            activeEditor=BindMode.utils.getLastActiveEditor();
            assert(~isempty(activeEditor));
            currentModel=activeEditor.getStudio().App.blockDiagramHandle;
            if(BindMode.BindMode.isEnabled(get_param(currentModel,'Object')))


                selectedBlock=gsb(gcs,1);
                selectedSignal=gsl(gcs,1);
                if(isempty(selectedBlock)&&isempty(selectedSignal))

                    this.hideDialog();

                    hierarchyId=SLM3I.HierarchyServiceUtils.getDefaultHIDForGraph(this.modelObj.Handle);
                    this.styler.applyGreyEverything(this.modelObj.Handle,'HierarchyID',hierarchyId);
                    if(this.bindModeSourceDataObj.isGraphical)
                        this.styler.applyNoGrey(this.bindModeSourceDataObj.sourceElementHandle,'HierarchyID',this.sourceHierarchyId);
                    end
                end


                BindMode.utils.AlertBindModeTool(this.modelObj.Handle);
            end
        end

        function handleChildModelClosed(this,bd)


            if isequal(this.bindModeSourceDataObj.clientName,BindMode.ClientNameEnum.INJECTORS)&&...
                strcmp(this.bindModeSourceDataObj.injectorBindModeHandler.injMdlName,bd.Name)
                BindMode.BindMode.disableBindMode(this.modelObj);
                return;
            end

            for idx=1:numel(this.childModelObjects)
                if(this.childModelObjects{idx}==bd)
                    this.childModelObjects{idx}=[];
                end
            end
            this.childModelObjects=this.childModelObjects(~cellfun('isempty',this.childModelObjects));
        end

        function result=isValidSLElement(~,handle)



            result=SLM3I.SLDomain.handle2DiagramElement(handle).isvalid;
        end

        function setDialogTransientPropertyHelper(this,isTransient)


            this.dialogTransientProperty=isTransient;
        end

        function prepareDialog(this)

            this.messagingSubscriptions{end+1}=message.subscribe(...
            [this.messagingRoot,'ready'],@(msg)this.handleDialogReady());
            this.messagingSubscriptions{end+1}=message.subscribe(...
            [this.messagingRoot,'setSize'],@(msg)this.handleDialogSize(msg));
            this.messagingSubscriptions{end+1}=message.subscribe(...
            [this.messagingRoot,'dropDownChange'],@(msg)this.handleDropDownChange(msg));
            this.messagingSubscriptions{end+1}=message.subscribe(...
            [this.messagingRoot,'selectAllChange'],@(msg)this.handleSelectAllChange(msg));
            this.messagingSubscriptions{end+1}=message.subscribe(...
            [this.messagingRoot,'radioSelectionChange'],@(msg)this.handleRadioSelectionChange(msg));
            this.messagingSubscriptions{end+1}=message.subscribe(...
            [this.messagingRoot,'checkboxSelectionChange'],@(msg)this.handleCheckboxSelectionChange(msg));
            this.messagingSubscriptions{end+1}=message.subscribe(...
            [this.messagingRoot,'tableElementClick'],@(msg)this.handleTableElementClick(msg));
            this.messagingSubscriptions{end+1}=message.subscribe(...
            [this.messagingRoot,'inputFieldChange'],@(msg)this.handleInputFieldChange(msg));
            this.messagingSubscriptions{end+1}=message.subscribe(...
            [this.messagingRoot,'updateDiagram'],@(msg)this.handleUpdateDiagram(msg));
            this.messagingSubscriptions{end+1}=message.subscribe(...
            [this.messagingRoot,'blur'],@(msg)this.hideDialog());

            dialogSource=BindMode.BindingTableDialog(this.bindModeSourceDataObj);
            this.dialogHandle=DAStudio.Dialog(dialogSource);
        end

        function reloadDialog(this,reposition)
            if(this.dialogReady&&~isempty(this.bindModeSelectionDataObj))







                if(reposition&&~this.dialogHandle.isVisible())
                    pos=Simulink.harness.internal.calcDialogGeometry(...
                    BindMode.BindMode.DIALOG_MIN_WIDTH,...
                    BindMode.BindMode.DIALOG_INITIAL_HEIGHT,...
                    'GlobalPoint',...
                    this.bindModeSelectionDataObj.selectionPosition);
                    this.dialogHandle.position=pos;
                end

                data=BindMode.utils.getBindableData(this.bindModeSourceDataObj.modelName,this.currentDropDownValue);
                message.publish([this.messagingRoot,'setData'],data);
            end
        end

        function bindableRows=getDialogBindableRows(this)



            bindableRowsJson=this.dialogHandle.evalBrowserJS('DDGWebBrowser','bindModeDialog.getRowsAsJson();');
            bindableRows=jsondecode(bindableRowsJson);
        end

        function replaceDialogBindableRows(this,bindableRows)

            data.bindableRows=bindableRows;
            message.publish([this.messagingRoot,'setData'],data);
        end

        function setDialogInputFieldValid(this,valid,errorMessage)
            config.valid=valid;
            config.validationErrorMessage=errorMessage;
            message.publish([this.messagingRoot,'setInputField'],config);
        end

        function handleDialogReady(this,~)
            this.dialogReady=true;
            this.reloadDialog(true);
        end

        function handleDialogSize(this,msg)

            width=min(max(msg.width,...
            BindMode.BindMode.DIALOG_MIN_WIDTH),...
            BindMode.BindMode.DIALOG_MAX_WIDTH);
            pos=Simulink.harness.internal.calcDialogGeometry(...
            width+BindMode.BindMode.DIALOG_PADDING,...
            msg.height+BindMode.BindMode.DIALOG_PADDING,...
            'GlobalPoint',...
            this.bindModeSelectionDataObj.selectionPosition);
            this.dialogHandle.position=pos;
            this.dialogHandle.show();
        end

        function handleDropDownChange(this,msg)
            this.currentDropDownValue=msg.dropDownValue;
            if msg.shouldReload
                this.reloadDialog(false);
            end
        end

        function handleSelectAllChange(this,msg)
            result=this.bindModeSourceDataObj.onSelectAllChange(...
            this.currentDropDownValue,...
            msg.rows,...
            msg.checked);
            if result
                rowCount=numel(msg.rows);
                rowCountStr=[int2str(rowCount),' rows'];
                if msg.checked
                    SLM3I.SLDomain.showEphemeralMessage(DAStudio.message('simulink_ui:bind_mode:resources:ConnectedFeedbackMessage')," "+rowCountStr+" ");
                else
                    SLM3I.SLDomain.showEphemeralMessage(DAStudio.message('simulink_ui:bind_mode:resources:DisconnectedFeedbackMessage')," "+rowCountStr+" ");
                end
            end
        end

        function handleRadioSelectionChange(this,msg)
            bindableMetaData=BindMode.utils.processForSelectionInCtxModel(...
            msg.row.bindableMetaData,this.modelObj.Name);
            result=this.bindModeSourceDataObj.onRadioSelectionChange(...
            this.currentDropDownValue,...
            msg.row.bindableTypeChar,...
            msg.row.bindableName,...
            bindableMetaData,...
            msg.row.isConnected);
            if(msg.row.isConnected&&result)
                SLM3I.SLDomain.showEphemeralMessage(DAStudio.message('simulink_ui:bind_mode:resources:ConnectedFeedbackMessage')," "+msg.row.bindableName+" ");
            end
        end

        function handleCheckboxSelectionChange(this,msg)
            bindableMetaData=BindMode.utils.processForSelectionInCtxModel(...
            msg.row.bindableMetaData,this.modelObj.Name);
            result=this.bindModeSourceDataObj.onCheckBoxSelectionChange(...
            this.currentDropDownValue,...
            msg.row.bindableTypeChar,...
            msg.row.bindableName,...
            bindableMetaData,...
            msg.row.isConnected);
            if(result)
                if(msg.row.isConnected)
                    SLM3I.SLDomain.showEphemeralMessage(DAStudio.message('simulink_ui:bind_mode:resources:ConnectedFeedbackMessage')," "+msg.row.bindableName+" ");
                else
                    SLM3I.SLDomain.showEphemeralMessage(DAStudio.message('simulink_ui:bind_mode:resources:DisconnectedFeedbackMessage')," "+msg.row.bindableName+" ");
                end
            end
        end

        function handleTableElementClick(this,msg)
            bindableRow=msg.row;
            this.bindModeSourceDataObj.onTableElementClick(...
            bindableRow.bindableTypeChar,...
            bindableRow.bindableMetaData);
        end

        function handleInputFieldChange(this,msg)
            [valid,errorMessage]=this.bindModeSourceDataObj.onInputFieldChange(msg.row);
            config.valid=valid;
            config.validationErrorMessage=errorMessage;
            message.publish([this.messagingRoot,'setInputField'],config);
        end

        function handleUpdateDiagram(this,~)

            if(this.dialogTransientProperty)
                this.dialogHandle.hide();
            end


            try
                set_param(this.bindModeSourceDataObj.modelName,'SimulationCommand','update');
            catch me
                Simulink.output.Stage(...
                message('Simulink:SLMsgViewer:Update_Diagram_Stage_Name').getString(),...
                'ModelName',modelName);
                Simulink.output.error(me);
            end

            this.reloadDialog(false);
        end

        function hideDialog(this,~)
            if(this.dialogTransientProperty&&this.dialogHandle.isVisible())
                this.dialogHandle.hide();



                message.publish([this.messagingRoot,'clearData'],[]);

                hierarchyId=SLM3I.HierarchyServiceUtils.getDefaultHIDForGraph(this.modelObj.Handle);
                this.styler.applyGreyEverything(this.modelObj.Handle,'HierarchyID',hierarchyId);
                if(this.bindModeSourceDataObj.isGraphical)
                    this.styler.applyNoGrey(this.bindModeSourceDataObj.sourceElementHandle,'HierarchyID',this.sourceHierarchyId);
                end
            end
        end

        function setHelpNotificationTimerDurationHelper(this,duration)

            this.helpNotificationTimerDuration=duration;
        end

        function showHelp(this)
            editors=BindMode.utils.getAllEditorsForModel(get_param(this.bindModeSourceDataObj.modelName,'Handle'));
            if(numel(editors)>=1)
                prefName='ShowGuidanceText';
                BindModePrefs=getpref('BindModePrefs');
                if(isfield(BindModePrefs,prefName))
                    shouldNotify=BindModePrefs.(prefName);
                else
                    shouldNotify=true;
                    addpref('BindModePrefs',prefName,true);
                end
                if(shouldNotify)
                    codeToRun=['setpref(''BindModePrefs'',''',prefName,''',false)'];
                    disableMsg=['<a href="matlab: ',codeToRun,'">',message('simulink_ui:bind_mode:resources:DoNotShowAgain').getString(),'</a>'];
                    studio=editors(1).getStudio;
                    this.helpTextEditor=studio.App.getActiveEditor();
                    this.helpTextEditor.deliverInfoNotification('simulink_ui:bind_mode:resources:BindModeGuidanceText',[message('simulink_ui:bind_mode:resources:BindModeGuidanceText').getString(),' ',disableMsg]);
                    this.helpNotificationTimerObj=timer('TimerFcn',@(x,y)this.closeHelp(),'StartDelay',this.helpNotificationTimerDuration,'BusyMode','drop');
                    this.helpNotificationTimerObj.start();
                end
            end
        end

        function closeHelp(this)
            try
                this.helpTextEditor.closeNotificationByMsgID('simulink_ui:bind_mode:resources:BindModeGuidanceText');
            catch
            end
        end

        function closeClientNotifications(this)
            editors=BindMode.utils.getAllEditorsForModel(this.modelObj.Handle);
            try

                for idx=1:numel(editors)
                    editors(idx).closeNotificationByMsgID('simulink_ui:bind_mode:resources:BindModeNotifications');
                end
            catch
            end
        end
    end

    methods(Static)

        function enableBindMode(bindModeSourceDataObj)

            modelObj=get_param(bindModeSourceDataObj.modelName,'Object');
            bindModeObj=BindMode.BindMode.getInstance(modelObj,bindModeSourceDataObj);
            if(isprop(bindModeSourceDataObj,'helpNotificationTimerDuration'))
                duration=bindModeSourceDataObj.helpNotificationTimerDuration;
                bindModeObj.setHelpNotificationTimerDurationHelper(duration);
            end
            bindModeObj.addStylingAndSelectionListeners();

            bindModeObj.prepareDialog();

            if bindModeSourceDataObj.allowStateflowBinding()
                BindMode.utils.notifySFSymbolsOfBindModeStateChange(modelObj.Handle,true);
            end
        end

        function enableBindModeWithoutStyling(bindModeSourceDataObj)


            BindMode.BindMode.getInstance(bindModeSourceDataObj);
        end

        function bindableRows=getCurrentBindableRows()


            bindableRows=[];
            bindModeObj=BindMode.BindMode.getInstance();
            if(~isempty(bindModeObj)&&isvalid(bindModeObj))
                bindableRows=bindModeObj.getDialogBindableRows();
            end
        end

        function replaceBindableRows(bindableRows)





            bindModeObj=BindMode.BindMode.getInstance();
            if(~isempty(bindModeObj)&&isvalid(bindModeObj))
                bindModeObj.replaceDialogBindableRows(bindableRows);
            end
        end

        function setInputFieldValid(valid,errorMessage)




            bindModeObj=BindMode.BindMode.getInstance();
            if(~isempty(bindModeObj)&&isvalid(bindModeObj))
                bindModeObj.setDialogInputFieldValid(valid,errorMessage);
            end
        end

        function disableBindMode(modelObj)



            SLStudio.Utils.RemoveHighlighting(modelObj.Handle);
        end

        function result=isEnabled(modelObj)

            result=false;
            if isa(modelObj,'double')
                modelObj=get_param(modelObj,'Object');
            end
            bindModeObj=BindMode.BindMode.getInstance();
            if(~isempty(bindModeObj)&&isvalid(bindModeObj)&&...
                ((bindModeObj.modelObj==modelObj)||ismember(modelObj,cell2mat(bindModeObj.childModelObjects))))
                result=true;
            end
        end

        function result=isEnabledForEditor(editor)

            result=false;
            modelObj=get_param(editor.getStudio().App.blockDiagramHandle,'Object');
            bindModeObj=BindMode.BindMode.getInstance();
            if(~isempty(bindModeObj)&&isvalid(bindModeObj)&&...
                ((bindModeObj.modelObj==modelObj)||ismember(modelObj,cell2mat(bindModeObj.childModelObjects))))
                result=true;
            end
        end
    end

    methods(Static,Hidden)
        function bindModeObj=getInstance(varargin)














            mlock;
            persistent bindModeGlobalObject;


            numvarargs=length(varargin);
            if(numvarargs>2)
                error(message('simulink_ui:bind_mode:resources:BindModeGetInstanceTooManyInputs'));
            elseif(numvarargs==0)


                bindModeObj=BindMode.BindMode.empty();
                if(~isempty(bindModeGlobalObject)&&isvalid(bindModeGlobalObject))
                    bindModeObj=bindModeGlobalObject;
                end
                return;
            else

                if(~isempty(bindModeGlobalObject)&&...
                    isvalid(bindModeGlobalObject)&&...
                    isa(bindModeGlobalObject.modelObj,'Simulink.BlockDiagram'))
                    BindMode.BindMode.disableBindMode(bindModeGlobalObject.modelObj);
                end
                if(numvarargs==1)

                    bindModeSourceDataObj=varargin{:};
                    bindModeObj=BindMode.BindMode([],bindModeSourceDataObj);
                    bindModeGlobalObject=bindModeObj;
                else

                    [modelObj,bindModeSourceDataObj]=varargin{:};
                    bindModeObj=BindMode.BindMode(modelObj,bindModeSourceDataObj);
                    bindModeGlobalObject=bindModeObj;
                end
            end
        end

        function cleanUpBindMode(modelObj)










            bindModeObj=BindMode.BindMode.getInstance();
            if(~isempty(bindModeObj))


                SLM3I.SLDomain.notifyWebManagerOfBindModeStateChange(bindModeObj.modelObj.Handle,false);

                if bindModeObj.bindModeSourceDataObj.allowStateflowBinding()
                    BindMode.utils.notifySFSymbolsOfBindModeStateChange(bindModeObj.modelObj.Handle,false);
                end

                allModelObjects=[bindModeObj.modelObj,bindModeObj.childModelObjects{:}];
                styler=bindModeObj.styler;



                delete(bindModeObj);
                for idx=1:numel(allModelObjects)

                    hierarchyId=SLM3I.HierarchyServiceUtils.getDefaultHIDForGraph(allModelObjects(idx).Handle);
                    styler.clearAllStylers(allModelObjects(idx).Handle,'HierarchyID',hierarchyId);

                    editors=BindMode.utils.getAllEditorsForModel(allModelObjects(idx).Handle);
                    for e=1:numel(editors)
                        editors(e).sendMessageToTools('SLDeactivateBindMode');
                    end

                    if(allModelObjects(idx)~=modelObj)
                        BindMode.BindMode.disableBindMode(allModelObjects(idx));
                    end
                end
            end
        end

        function changeSelectionData(bindModeSelectionDataObj)

            bindModeObj=BindMode.BindMode.getInstance();
            if(~isempty(bindModeObj))

                bindModeObj.bindModeSelectionDataObj=bindModeSelectionDataObj;

                hierarchyId=SLM3I.HierarchyServiceUtils.getDefaultHIDForGraph(bindModeObj.modelObj.Handle);
                bindModeObj.styler.applyGreyEverything(bindModeObj.modelObj.Handle,'HierarchyID',hierarchyId);
                for idx=1:numel(bindModeObj.childModelObjects)
                    childHierarchyId=SLM3I.HierarchyServiceUtils.getDefaultHIDForGraph(bindModeObj.childModelObjects{idx}.Handle);
                    bindModeObj.styler.applyGreyEverything(bindModeObj.childModelObjects{idx}.Handle,'HierarchyID',childHierarchyId);
                end
                if(bindModeObj.bindModeSourceDataObj.isGraphical)
                    bindModeObj.styler.applyNoGrey(bindModeObj.bindModeSourceDataObj.sourceElementHandle,'HierarchyID',bindModeObj.sourceHierarchyId);
                end

                if(bindModeObj.bindModeSourceDataObj.isGraphical==false||...
                    bindModeObj.isValidSLElement(bindModeObj.bindModeSourceDataObj.sourceElementHandle)||...
                    isBlockInWebPanel(bindModeObj.bindModeSourceDataObj.sourceElementHandle))

                    selectionHandles=bindModeObj.bindModeSelectionDataObj.selectionHandles;
                    selectionBackendIds=bindModeObj.bindModeSelectionDataObj.selectionBackendIds;
                    selectionTypes=bindModeObj.bindModeSelectionDataObj.selectionTypes;




                    stylableHandles=zeros(size(selectionHandles));
                    for i=1:numel(selectionHandles)
                        if(selectionTypes{i}==BindMode.SelectionTypeEnum.SLBLOCK)
                            stylableHandles(i)=selectionHandles(i);
                        end
                    end
                    stylableHandles(stylableHandles==0)=[];
                    stylableHandles=[stylableHandles,gsl'];


                    stylableBackendIds=zeros(size(selectionBackendIds));
                    for i=1:numel(selectionBackendIds)
                        if selectionTypes{i}==BindMode.SelectionTypeEnum.SFSTATE||...
                            selectionTypes{i}==BindMode.SelectionTypeEnum.SFTRANSITION
                            stylableBackendIds(i)=selectionBackendIds(i);
                        end
                    end
                    stylableBackendIds(stylableBackendIds==0)=[];
                    stylableElements=[stylableHandles,stylableBackendIds];



                    selectionHierarchyId=hierarchyId;
                    editor=BindMode.utils.getLastActiveEditor();
                    if~isempty(editor)
                        selectionHierarchyId=editor.getHierarchyId;
                    end
                    bindModeObj.styler.applyNoGrey(stylableElements,'HierarchyID',selectionHierarchyId);

                    bindableElements=[stylableHandles,selectionBackendIds];
                    if numel(bindableElements)>0
                        bindModeObj.reloadDialog(true);
                    end
                end
            end
        end

        function styler=getStyler()
            bindModeObj=BindMode.BindMode.getInstance();
            if(~isempty(bindModeObj))
                styler=bindModeObj.styler;
            end
        end

        function oldValue=setDialogTransientProperty(isTransient)


            bindModeObj=BindMode.BindMode.getInstance();
            if(~isempty(bindModeObj))
                oldValue=bindModeObj.dialogTransientProperty;
                bindModeObj.setDialogTransientPropertyHelper(isTransient);
            end
        end

        function value=getHelpNotificationTimerDuration()

            bindModeObj=BindMode.BindMode.getInstance();
            if(~isempty(bindModeObj))
                value=bindModeObj.helpNotificationTimerDuration;
            end
        end

        function addChildModel(modelHandle)
            bindModeObj=BindMode.BindMode.getInstance();
            if(isempty(bindModeObj))
                return;
            end
            if(~isempty(get_param(modelHandle,'CoSimContext')))

                childModelHandles=cellfun(@(ob)ob.Handle,bindModeObj.childModelObjects);
                if~isempty(get_param(modelHandle,'CoSimContext'))
                    csRefBlkH=getSimulinkBlockHandle(get_param(modelHandle,'CoSimContext'));
                    if csRefBlkH~=-1&&bdroot(csRefBlkH)~=bindModeObj.modelObj.Handle


                        return;
                    end
                end
                if((modelHandle~=bindModeObj.modelObj.Handle)&&~ismember(modelHandle,childModelHandles))


                    hierarchyId=SLM3I.HierarchyServiceUtils.getDefaultHIDForGraph(modelHandle);
                    bindModeObj.styler.applyGreyEverything(modelHandle,'HierarchyID',hierarchyId);


                    bindModeObj.childModelListeners{end+1}=Simulink.listener(modelHandle,'SelectionChangeEvent',...
                    @(bd,evt)bindModeObj.handleEmptyCanvasAreaClick());
                    bindModeObj.childModelListeners{end+1}=Simulink.listener(modelHandle,'CloseEvent',...
                    @(bd,evt)bindModeObj.handleChildModelClosed(bd));


                    editors=BindMode.utils.getAllEditorsForModel(modelHandle);
                    assert(numel(editors)>=1);
                    for i=1:numel(editors)
                        studio=editors(i).getStudio();
                        if(~isempty(studio)&&~any(cellfun(@(x)x==studio,bindModeObj.studioSet,'UniformOutput',1)))
                            bindModeObj.studioSet{end+1}=studio;
                            c=studio.getService('WindowActivatedEvents');
                            registerCallbackId=c.registerServiceCallback(@bindModeObj.handleWindowActivated);
                            bindModeObj.windowActivatedCallbackSet(end+1)=registerCallbackId;
                            c=studio.getService('GLUE2:ActiveEditorChanged');
                            registerCallbackId=c.registerServiceCallback(@bindModeObj.handleEditorChanged);
                            bindModeObj.editorChangeCallbackSet(end+1)=registerCallbackId;
                        end
                        editors(i).sendMessageToTools('SLInitiateBindMode');
                    end



                    bindModeObj.childModelObjects{end+1}=get_param(modelHandle,'Object');
                end
            else




                bindModeObj.rootModelListeners{end+1}=Simulink.listener(modelHandle,'SelectionChangeEvent',...
                @(bd,evt)bindModeObj.handleEmptyCanvasAreaClick());
                apps=SLM3I.SLDomain.getAllStudioAppsWith(modelHandle);
                assert(~isempty(apps));
                for i=1:numel(apps)
                    app=apps(i);
                    studio=app.getStudio();
                    if(~isempty(studio)&&~any(cellfun(@(x)x==studio,bindModeObj.studioSet,'UniformOutput',1)))
                        bindModeObj.studioSet{end+1}=studio;
                        c=studio.getService('GLUE2:ActiveEditorChanged');
                        registerCallbackId=c.registerServiceCallback(@bindModeObj.handleEditorChanged);
                        bindModeObj.editorChangeCallbackSet(end+1)=registerCallbackId;
                    end
                end

                BindMode.utils.AlertBindModeTool(bindModeObj.modelObj.Handle);
            end
        end
    end

    methods
        function delete(obj)
            munlock;






            delete(obj.bindModeSourceDataObj);
            delete(obj.bindModeSelectionDataObj);

            for idx=1:numel(obj.studioSet)
                studio=obj.studioSet{idx};

                if(studio.isvalid)
                    c=studio.getService('GLUE2:ActiveEditorChanged');
                    c.unRegisterServiceCallback(obj.editorChangeCallbackSet(idx));
                end
            end

            for idx=1:numel(obj.messagingSubscriptions)
                message.unsubscribe(obj.messagingSubscriptions{idx});
            end


            if(isa(obj.dialogHandle,'DAStudio.Dialog'))
                delete(obj.dialogHandle);
            end

            obj.closeHelp();
            if(~isempty(obj.helpNotificationTimerObj)&&isvalid(obj.helpNotificationTimerObj))
                obj.helpNotificationTimerObj.stop();
                delete(obj.helpNotificationTimerObj);
            end
            obj.closeClientNotifications();
        end
    end
end
