





classdef StudioWidgetManager<simulink.notes.internal.RTCRequestHandler
    properties(Access=public)

        m_preCloseSaveStatus='';
    end

    properties(Access=protected)
        m_studio=[];
        m_router=[];


        m_bindingWidget=[];
        m_contentWidget=[];




        m_isEditMode=false;
        m_sysDocID=simulink.sysdoc.internal.SysDocID.empty();
        m_treeStatus=[];
        m_bindingType=[];
        m_inmodelreuse=[];


        m_tokenActiveEditorChanged=[];
        m_tokenBlockDiagramChanged=[];
        m_tokenPreClose=false;
        m_tokenPostNameChange=false;

        m_saveProcessTimeOut=[];

        m_saveTimeOutAsyncFuncMgr=[];
        m_hSaveTimer=[];
    end

    properties(Constant,Hidden)
        BROWSER_TITLE=message('simulink_ui:sysdoc:resources:SystemDocumentation').getString();
        DEFAULT_DOCK_SIDE='Right';

        SAVE_PROCESS_RUN='Run';
        SAVE_PROCESS_DONE='Done';
        SAVE_PROCESS_TIMEOUT=5;
    end

    methods(Static)



        function onContentWidgetDialogClose(studio,closeAction)
            import simulink.sysdoc.internal.SysDocUtil;
            if~SysDocUtil.isNotEmptyAndValid(studio)
                return;
            end
            studioWidgetMgr=SysDocUtil.getStudioWidgetManager(studio);
            if isempty(studioWidgetMgr)
                return;
            end
            studioWidgetMgr.contentWidgetDialogClose(closeAction);
        end




        function onToggleEditMode(~)
            import simulink.sysdoc.internal.SysDocUtil;
            studioWidgetMgr=SysDocUtil.getCurrentStudioWidgetManager();
            studioWidgetMgr.actionToggleEditMode();
        end


        function onSaveAll(studio)
            import simulink.sysdoc.internal.SysDocUtil;
            studioWidgetMgr=SysDocUtil.getStudioWidgetManager(studio);
            assert(~isempty(studioWidgetMgr),'SystemDocumentation::saveAll - saveAll must be triggered by binding widgets.');



            studioWidgetMgr.saveAll();
        end

        function onChangeBinding(studioWidgetMgr,type)
            studioWidgetMgr.actionChangeBinding(type);
        end

        function onGotoRoot(studioWidgetMgr)
            studioWidgetMgr.gotoRoot();
        end

        function onRTCEditAction(studioWidgetMgr,actionTag,isToggleButton)
            studioWidgetMgr.rtcEditAction(actionTag,isToggleButton);
        end

        function onGearButtonToggled(studioWidgetMgr)
            studioWidgetMgr.gearButtonToggled();
        end

        function onExitOptions()
            import simulink.sysdoc.internal.SysDocUtil;
            studioWidgetMgr=SysDocUtil.getCurrentStudioWidgetManager();
            if isempty(studioWidgetMgr)

                return;
            end



            studioWidgetMgr.makeSureOptionsOff();
        end

        function onFixErrorModelLink()
            import simulink.sysdoc.internal.SysDocUtil;
            studioWidgetMgr=SysDocUtil.getCurrentStudioWidgetManager();
            if isempty(studioWidgetMgr)

                return;
            end
            studioWidgetMgr.fixErrorModelLink();
        end
    end

    methods(Access=public)
        function obj=StudioWidgetManager(studio,router)
            sysDocApp=simulink.SystemDocumentationApplication.getInstance();
            obj=obj@simulink.notes.internal.RTCRequestHandler(studio.getStudioTag(),...
            sysDocApp.getRTCRequestFrontController().getDispatcher());

            obj.m_studio=studio;
            obj.m_isEditMode=false;





            obj.m_router=router;
            obj.m_preCloseSaveStatus=StudioWidgetManager.SAVE_PROCESS_DONE;

            import simulink.sysdoc.internal.StudioWidgetManager;
            import simulink.SystemDocumentationApplication;
            obj.m_saveProcessTimeOut=StudioWidgetManager.SAVE_PROCESS_TIMEOUT;
            sysDocApp=simulink.SystemDocumentationApplication.getInstance();
            if sysDocApp.isDebugMode()
                obj.m_saveProcessTimeOut=10;
            end
            if sysDocApp.isTestMode()
                obj.m_saveProcessTimeOut=sysDocApp.getTestSaveTimeOut();
            end

            import simulink.sysdoc.internal.MixedMapRouter;
            obj.m_bindingType=MixedMapRouter.BINDING_TYPE_INVALID;

            obj.m_saveTimeOutAsyncFuncMgr=dastudio_util.cooperative.AsyncFunctionRepeaterTask;
        end




        function resetWidgets(this)
            this.m_isEditMode=false;
            if~isempty(this.m_contentWidget)
                this.setContentWidgetTitle();
                this.m_contentWidget.updateTitle();
                this.m_contentWidget.reset();

                if this.m_router.linkToWrongFile()
                    this.showErrorLinkWarnMessage();
                end
            end
            this.activeEditorChanged();
        end


        function setRouter(this,router)
            this.m_router=router;
            this.resetWidgets();
        end


        function updateSysDocID(this)
            this.updateSysDocIDForActiveEditor();
        end




        function router=getRouter(this)
            router=this.m_router;
        end

        function curView=getContentWidget(this)
            curView=this.m_contentWidget;
        end

        function bindingWidget=getBindingWidget(this)
            bindingWidget=this.m_bindingWidget;
        end






        function updateActiveEditor(this)



            if~this.m_router.isEnabled()||isempty(this.m_contentWidget)
                this.m_sysDocID=simulink.sysdoc.internal.SysDocID.empty();
                return;
            end
            assert(~isempty(this.m_sysDocID));


            hasParent=~isempty(this.m_sysDocID.Parent);
            import simulink.sysdoc.internal.MixedMapRouter;
            [type,url,content,rootType]=this.getRouterInfo();

            this.m_bindingType=type;

            if this.m_inmodelreuse
                type=MixedMapRouter.BINDING_TYPE_MODELREUSE;
            end


            lastBindUrl='';
            switch type
            case MixedMapRouter.BINDING_TYPE_HTTP
                if this.m_isEditMode
                    lastBindUrl=this.m_router.getLastBindingUrl(this.m_sysDocID);
                end
            case MixedMapRouter.BINDING_TYPE_NODOC
                type=MixedMapRouter.BINDING_TYPE_NODOC;
                this.m_contentWidget.setZipFileStatus(this.m_router.getZipFileStatus());
            case MixedMapRouter.BINDING_TYPE_INVALID

                error(message('simulink_ui:sysdoc:resources:BoundToInvalidType'));
            end



            hasExistRTCFile=this.m_router.fileExists(this.m_sysDocID.SysDocIDString);


            this.m_contentWidget.setLastBoundUri(lastBindUrl);
            this.m_contentWidget.setEditMode(this.m_isEditMode);
            this.m_contentWidget.setHasParent(hasParent);
            this.m_contentWidget.setHasExistRTCFile(hasExistRTCFile);


            this.m_contentWidget.setWidgetContent(type,...
            url,...
            content,...
            rootType);
        end


        function activeEditorChanged(this)
            this.saveAll();
            this.updateSysDocIDForActiveEditor();
            this.m_inmodelreuse=this.inModelRef()||this.inLinkedLibrary;
            if~this.setEditMode(false)
                this.updateActiveEditor();
            end
        end





        function blockDiagramChanged(this,sysdocObj)
            import simulink.sysdoc.internal.SysDocUtil;
            assert(SysDocUtil.isNotEmptyAndValid(this.m_studio));

            sysdocObj.handlePostNameChanged(this.m_studio);


            this.m_tokenBlockDiagramChanged=unSubscribeStudioService(this.m_studio,...
            'GLUE2:BlockDiagramChanged',...
            this.m_tokenBlockDiagramChanged);

            import simulink.sysdoc.internal.SysDocUtil;
            newSysdocObj=SysDocUtil.getSystemDocumentation(this.m_studio);
            this.m_tokenBlockDiagramChanged=subscribeStudioService(this.m_studio,...
            'GLUE2:BlockDiagramChanged',...
            this.m_tokenBlockDiagramChanged,...
            @(~)this.blockDiagramChanged(newSysdocObj));
        end


        function saveAll(this)
            this.saveDirty();
        end

        function handlePreClose(this)
            this.saveAll();
            this.waitforRTCSaving();




            this.setEditMode(false);
        end

        function contentWidgetDialogClose(this,~)
            if this.isVisible()
                return;
            end
            this.saveAll();
            this.m_tokenActiveEditorChanged=unSubscribeStudioService(this.m_studio,...
            'GLUE2:ActiveEditorChanged',...
            this.m_tokenActiveEditorChanged);
            this.m_tokenBlockDiagramChanged=unSubscribeStudioService(this.m_studio,...
            'GLUE2:BlockDiagramChanged',...
            this.m_tokenBlockDiagramChanged);
        end


        function changeBinding(this,type,url)
            import simulink.sysdoc.internal.MixedMapRouter;
            if this.m_bindingType==MixedMapRouter.BINDING_TYPE_RTC||this.m_bindingType==MixedMapRouter.BINDING_TYPE_HTTP
                this.saveDirty();
            end
            changed=this.m_router.changeBinding(this.m_sysDocID.SysDocIDString,type,url);
            if~changed
                this.makeSureOptionsOff();
                return;
            end



            this.updateActiveEditor();
        end

        function actionChangeBinding(this,type)


            import simulink.sysdoc.internal.MixedMapRouter;



            this.changeBinding(type,'');
        end

        function gotoRoot(this)
            import simulink.sysdoc.internal.MixedMapRouter;
            assert(~isempty(this.m_sysDocID));

            rootSysDocID=this.m_router.getDocRoot(this.m_sysDocID);
            assert(~isempty(rootSysDocID));

            rootSID=rootSysDocID.SID;

            hOrSFUDD=Simulink.ID.getHandle(rootSID);

            isSimulink=isnumeric(hOrSFUDD);
            isStateflow=isa(hOrSFUDD,'Stateflow.Object');

            if isSimulink
                h=hOrSFUDD;
                rootFullPath=getfullname(h);
                diagramInfo=SLM3I.Util.getDiagram(rootFullPath);
                diagram=diagramInfo.diagram;
                assert(~isempty(diagram))
                this.m_studio.App.openEditor(diagram);
            elseif isStateflow












                sfObjToView=hOrSFUDD;

                subviewerStruct=StateflowDI.Util.getSubviewer(sfObjToView.ID);
                subviewer=subviewerStruct.diagram;
                assert(~isempty(subviewer));


                slParentSID=Simulink.ID.getSimulinkParent(rootSID);
                slParentH=Simulink.ID.getHandle(slParentSID);
                assert(is_simulink_handle(slParentH));

                slHID=SLM3I.HierarchyServiceUtils.getDefaultHIDForBlock(slParentH);
                assert(GLUE2.HierarchyService.isValid(slHID));






                parentChart=sfObjToView.Chart;
                parentChartHID=StateflowDI.HierarchyServiceUtils.getHIDWithParent(parentChart.ID,slHID);
                assert(GLUE2.HierarchyService.isValid(parentChartHID));




                elementHID=StateflowDI.HierarchyServiceUtils.getElementHIDWithChartAncestor(sfObjToView.ID,parentChartHID);
                assert(GLUE2.HierarchyService.isValid(elementHID));


                sfObjToViewHID=StateflowDI.HierarchyServiceUtils.getHIDWithParent(sfObjToView.ID,elementHID);
                assert(GLUE2.HierarchyService.isValid(sfObjToViewHID));


                this.m_studio.App.openEditorWithHID(subviewer,sfObjToViewHID);
            else
                error('Unknown domain')
            end

        end

        function copyBindingFromRoot(this)
            import simulink.sysdoc.internal.MixedMapRouter;
            assert(this.m_bindingType==MixedMapRouter.BINDING_TYPE_INHERIT);
            assert(~isempty(this.m_sysDocID));

            assert(~isempty(this.m_contentWidget));
            this.m_contentWidget.invalidate();
            [type,url,content]=this.m_router.getURLAndContent(this.m_sysDocID,true);
            if type==MixedMapRouter.BINDING_TYPE_RTC
                this.saveContent(this.m_sysDocID.SysDocIDString,content);
                this.updateActiveEditor();
                return;
            end
            if type==MixedMapRouter.BINDING_TYPE_INHERIT
                type=MixedMapRouter.BINDING_TYPE_NONE;
            end
            this.m_router.changeBinding(this.m_sysDocID.SysDocIDString,type,url);
            this.updateActiveEditor();
        end

        function applyBindingLink(this)
            import simulink.sysdoc.internal.MixedMapRouter;
            assert(this.m_bindingType==MixedMapRouter.BINDING_TYPE_HTTP);
            assert(~isempty(this.m_contentWidget));

            browserUrl=this.m_contentWidget.getLoadingBrowserUrl();
            import simulink.sysdoc.internal.MixedContentWidget;

            this.m_router.updateHttpBinding(this.m_sysDocID,browserUrl);

            this.m_contentWidget.clearUriCache();
        end


        function rtcEditAction(this,actionTag,isToggleButton)
            assert(~isempty(this.m_contentWidget));
            assert(~isempty(this.m_isEditMode));
            if isToggleButton


                this.m_contentWidget.undoToggleButtonChange(actionTag);
            end
            this.m_contentWidget.setRTCFocus();
            import simulink.sysdoc.internal.JSClientRTCProxy;
            JSClientRTCProxy.onRTCEditAction(this.m_studio.getStudioTag(),actionTag);
        end

        function gearButtonToggled(this)
            assert(~isempty(this.m_contentWidget));



            if~this.m_contentWidget.isOptionsOn()
                this.exitOptions();
                return;
            end


            import simulink.sysdoc.internal.MixedMapRouter;
            if this.m_bindingType==MixedMapRouter.BINDING_TYPE_RTC
                this.saveDirty();
            end
            this.m_contentWidget.showOptions(true);
        end

        function makeSureOptionsOff(this)
            assert(~isempty(this.m_contentWidget));
            if this.m_contentWidget.isOptionsOn()
                this.exitOptions();
            end
        end

        function exitOptions(this)
            if isempty(this.m_contentWidget)
                return;
            end







            this.m_contentWidget.setDocSetGearButton(false);
            this.updateActiveEditor();
        end

        function printBySID(this,sid)
            import simulink.sysdoc.internal.MixedMapRouter;
            import simulink.sysdoc.internal.JSClientRTCProxy;
            import simulink.sysdoc.internal.SysDocID;
            import simulink.sysdoc.internal.SysDocUtil;

            if isempty(this.m_router)||~this.m_router.isEnabled()
                return;
            end

            [type,~,content]=this.m_router.getURLAndContent(SysDocID.getSysDocIDFromSID(sid),false);
            if type~=MixedMapRouter.BINDING_TYPE_RTC
                return;
            end
            JSClientRTCProxy.onPrintJSONContent(this.m_studio.getStudioTag(),...
            sid,...
            SysDocUtil.getModelName(this.m_studio),...
            content);
        end

        function helperPageAction(this,actionID)
            assert(~isempty(this.m_contentWidget));
            import simulink.sysdoc.internal.MixedMapRouter;
            import simulink.sysdoc.internal.SystemDocumentation;
            switch actionID
            case 'boundToLink'
                this.changeBinding(MixedMapRouter.BINDING_TYPE_HTTP,'');
            case 'boundToRTC'
                this.changeBinding(MixedMapRouter.BINDING_TYPE_RTC,'');
            case 'duplicateParent'
                this.copyBindingFromRoot();
            case 'useParent'
                this.changeBinding(MixedMapRouter.BINDING_TYPE_INHERIT,'');
            case 'boundToNone'
                this.changeBinding(MixedMapRouter.BINDING_TYPE_NONE,'');
            case 'gotoRootAndEdit'
                this.gotoRoot();
                this.setEditMode(true);
            case 'exitOptions'
                this.makeSureOptionsOff();
            case 'openSysDoc'
                SystemDocumentation.onOpenSysDoc();
            case 'newSysDoc'
                SystemDocumentation.onNewSysDoc();
            end
        end

        function fixErrorModelLink(this)
            this.m_router.fixErrorModelLink();
            this.m_contentWidget.hideNotification();
        end





        function rtcContent=onRTCEditorLoaded(this)
            import simulink.sysdoc.internal.JSClientRTCProxy;
            JSClientRTCProxy.setRTCEditMode(this.m_studio.getStudioTag(),this.isEditMode());
            if~isempty(this.m_contentWidget)
                this.m_contentWidget.invalidate();
                this.m_contentWidget.setRTCLoaded(true);
            end


            import simulink.sysdoc.internal.MixedMapRouter;
            [type,~,rtcContent,rootType]=this.getRouterInfo();


            switch type
            case MixedMapRouter.BINDING_TYPE_RTC
            case MixedMapRouter.BINDING_TYPE_INHERIT
                if rootType~=MixedMapRouter.BINDING_TYPE_RTC
                    assert(isempty(rtcContent));
                end
            otherwise
                assert(isempty(rtcContent));
            end
        end






        function saveJSONContentFromRTC(this,sysDocIDString,content)
            assert(~isempty(this.m_router),'saveJSONContentFromRTC: Invalid content proxy');
            assert(~isempty(sysDocIDString));

            if isempty(this.m_contentWidget)
                return;
            end

            newContent=~this.m_router.fileExists(sysDocIDString);


            import simulink.sysdoc.internal.StudioWidgetManager;
            import simulink.sysdoc.internal.JSClientRTCProxy;
            if newContent&&strcmp(JSClientRTCProxy.RTC_EMPTY_CONTENT,content)
                this.m_preCloseSaveStatus=StudioWidgetManager.SAVE_PROCESS_DONE;
                return;
            end

            this.m_router.saveJSONContent(sysDocIDString,content);


            import simulink.sysdoc.internal.MixedContentWidget;
            if newContent
                this.m_router.addRTCBinding(sysDocIDString);

            end
            this.m_preCloseSaveStatus=StudioWidgetManager.SAVE_PROCESS_DONE;
        end

        function saveContent(this,sysDocIDString,content)
            assert(~isempty(this.m_router));
            assert(~isempty(this.m_contentWidget));


            this.m_router.saveJSONContent(sysDocIDString,content);


            import simulink.sysdoc.internal.MixedMapRouter;
            this.m_router.changeBinding(sysDocIDString,MixedMapRouter.BINDING_TYPE_RTC,sysDocIDString);
        end






















        function visible=isVisible(this)
            import simulink.sysdoc.internal.SysDocUtil;
            visible=SysDocUtil.isNotEmptyAndValid(this.m_studio)...
            &&((SysDocUtil.isNotEmptyAndValid(this.m_contentWidget)&&this.m_contentWidget.isVisible())...
            ||((SysDocUtil.isNotEmptyAndValid(this.m_bindingWidget)&&this.m_bindingWidget.isVisible())));
        end


        function show(this)


            this.m_tokenActiveEditorChanged=subscribeStudioService(this.m_studio,...
            'GLUE2:ActiveEditorChanged',...
            this.m_tokenActiveEditorChanged,...
            @(~)this.activeEditorChanged());

            import simulink.sysdoc.internal.SysDocUtil;
            sysdocObj=SysDocUtil.getSystemDocumentation(this.m_studio);
            this.m_tokenBlockDiagramChanged=subscribeStudioService(this.m_studio,...
            'GLUE2:BlockDiagramChanged',...
            this.m_tokenBlockDiagramChanged,...
            @(~)this.blockDiagramChanged(sysdocObj));

            this.updateEditModeForWidgets();


            this.initContentWidget();
            this.m_contentWidget.show();
            this.activeEditorChanged();
        end

        function hide(this)
            this.m_tokenActiveEditorChanged=unSubscribeStudioService(this.m_studio,...
            'GLUE2:ActiveEditorChanged',...
            this.m_tokenActiveEditorChanged);
            this.m_tokenBlockDiagramChanged=unSubscribeStudioService(this.m_studio,...
            'GLUE2:BlockDiagramChanged',...
            this.m_tokenBlockDiagramChanged);

            if~isempty(this.m_contentWidget)
                this.m_contentWidget.hide();
            end




        end

        function initContentWidget(this)
            if~isempty(this.m_contentWidget)
                return;
            end
            this.m_contentWidget=this.m_router.createContentWidget(this.m_studio,this.m_isEditMode);
            this.setContentWidgetTitle();
            if this.m_router.linkToWrongFile()
                this.showErrorLinkWarnMessage();
            end
        end




        function actionToggleEditMode(this)
            if this.m_isEditMode
                this.saveDirty();
            else
                assert(~isempty(this.m_contentWidget));
                this.m_contentWidget.setUriCache();
            end
            this.m_isEditMode=~this.m_isEditMode;
            this.updateEditMode();
            if this.m_isEditMode
                this.m_contentWidget.setRTCFocus();
            end
        end



        function changed=setEditMode(this,editMode)
            changed=false;
            if this.m_isEditMode==editMode
                return;
            end
            this.m_isEditMode=editMode;
            this.updateEditMode();
            changed=true;
        end

        function updateEditMode(this)
            this.updateEditModeForWidgets();
            this.updateActiveEditor();
        end

        function updateEditModeForWidgets(this)


            if~isempty(this.m_contentWidget)
                this.m_contentWidget.setEditMode(this.m_isEditMode);
            end
        end

        function editMode=isEditMode(this)
            editMode=this.m_isEditMode;
        end






        function saveDirty(this)
            import simulink.sysdoc.internal.SysDocUtil;
            modelName=SysDocUtil.getModelName(this.m_studio);
            this.saveDirtyForModel(modelName);
        end


        function saveDirtyForModel(this,modelName)
            import simulink.sysdoc.internal.MixedMapRouter;
            if isempty(this.m_contentWidget)...
                ||isempty(this.m_sysDocID)...
                ||~this.m_isEditMode...
                ||isempty(modelName)
                return;
            end

            switch this.m_bindingType
            case MixedMapRouter.BINDING_TYPE_RTC
                if~this.m_contentWidget.getRTCLoaded()
                    return;
                end
                this.waitforRTCSaving();
                import simulink.sysdoc.internal.StudioWidgetManager;
                this.m_preCloseSaveStatus=StudioWidgetManager.SAVE_PROCESS_RUN;



                import simulink.sysdoc.internal.JSClientRTCProxy;
                JSClientRTCProxy.onSaveDocument(this.m_studio.getStudioTag(),...
                this.m_sysDocID.SysDocIDString,...
                modelName);
                this.handleRTCSaving();
            case MixedMapRouter.BINDING_TYPE_HTTP
                this.makeSureOptionsOff();
                this.applyBindingLink();
            end
        end

        function setContentWidgetTitle(this)
            import simulink.sysdoc.internal.MixedContentWidget;
            import simulink.sysdoc.internal.SysDocUtil;
            zipFilePath=this.m_router.getZipFilePath();
            if~isempty(zipFilePath)
                [~,name,ext]=fileparts(this.m_router.getZipFilePath());
                this.m_contentWidget.setTitle([MixedContentWidget.COMP_TITLE,' - ',name,ext]);
            end
        end

        function inModelRef=inModelRef(this)



            inModelRef=false;
            activeEditorDiagramHandle=this.m_studio.App.getActiveEditor.blockDiagramHandle;
            rootModelDiagramHandle=this.m_studio.App.blockDiagramHandle;
            if~isequal(Simulink.ID.getSID(activeEditorDiagramHandle),...
                Simulink.ID.getSID(rootModelDiagramHandle))
                inModelRef=true;
            end
        end

        function inLinkedLibrary=inLinkedLibrary(this)
            inLinkedLibrary=false;
            currentSysSID=this.m_sysDocID.SID;
            currentSys=Simulink.ID.getFullName(currentSysSID);
            rootModelDiagramHandle=this.m_studio.App.blockDiagramHandle;
            rootModelName=Simulink.ID.getSID(rootModelDiagramHandle);


            libData=libinfo(rootModelName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices);
            for i=1:length(libData)
                if(isequal(libData(i).Block,currentSys))
                    inLinkedLibrary=true;
                end
            end
        end

        function showErrorLinkWarnMessage(this)
            assert(~isempty(this.m_contentWidget));
            [messageID,unicodeMsg]=this.m_router.getLinkToWrongFileWarnMessage();
            this.m_contentWidget.showWarnMessage(messageID,unicodeMsg);
        end
    end

    methods(Access={?sysdoc.NotesTester,?SysDocTestInterface})



        function updateSysDocIDForActiveEditor(this)

            import simulink.sysdoc.internal.SysDocID
            editor=this.m_studio.App.getActiveEditor;
            this.m_sysDocID=SysDocID.getSysDocIDFromEditor(editor);
        end
    end

    methods(Access={?simulink.notes.internal.RTCRequestHandler,?simulink.notes.internal.RTCRequestFrontController,?sysdoc.NotesTester,?SysDocTestInterface})


        function studioTag=requestHandlerTestCallback(this)
            studioTag=['test',this.m_studio.getStudioTag()];
        end
    end

    methods(Access=protected)

        function await(this)
            this.waitforRTCSaving();
        end

        function waitforRTCSaving(this)
            import simulink.sysdoc.internal.StudioWidgetManager;
            if strcmp(this.m_preCloseSaveStatus,StudioWidgetManager.SAVE_PROCESS_RUN)
                waitfor(this,'m_preCloseSaveStatus',StudioWidgetManager.SAVE_PROCESS_DONE);
            end
            stopAndDeleteTimer(this.m_hSaveTimer);
            this.m_hSaveTimer=[];
        end

        function handleRTCSaving(this)


            import simulink.sysdoc.internal.StudioWidgetManager;
            if strcmp(this.m_preCloseSaveStatus,StudioWidgetManager.SAVE_PROCESS_RUN)


                this.m_hSaveTimer=timer(...
                'TimerFcn',@(h,e)this.preCloseSaveTimeout(),...
                'StartDelay',this.m_saveProcessTimeOut);

                start(this.m_hSaveTimer);

                if strcmp(this.m_preCloseSaveStatus,StudioWidgetManager.SAVE_PROCESS_RUN)
                    import simulink.sysdoc.internal.SysDocUtil;


                    this.m_saveTimeOutAsyncFuncMgr=SysDocUtil.startAsyncFuncManager(this.m_saveTimeOutAsyncFuncMgr,...
                    @(task)(this.checkForSaveDone(task)),...
                    @(task,err)(this.saveTimeOutErrorListener(task,err)));
                end
            end
        end



        function stopRepeat=checkForSaveDone(this,~)
            stopRepeat=false;
            import simulink.sysdoc.internal.StudioWidgetManager;

            if strcmp(this.m_preCloseSaveStatus,StudioWidgetManager.SAVE_PROCESS_RUN)
                return;
            end
            import simulink.sysdoc.internal.SysDocUtil;
            SysDocUtil.pauseAsyncFunctionManager(this.m_saveTimeOutAsyncFuncMgr);
            stopAndDeleteTimer(this.m_hSaveTimer);
            this.m_hSaveTimer=[];
        end


        function preCloseSaveTimeout(this)
            import simulink.sysdoc.internal.SysDocUtil;


            SysDocUtil.pauseAsyncFunctionManager(this.m_saveTimeOutAsyncFuncMgr);

            stopAndDeleteTimer(this.m_hSaveTimer);
            this.m_hSaveTimer=[];





            if strcmp(this.m_preCloseSaveStatus,StudioWidgetManager.SAVE_PROCESS_DONE)
                return;
            end

            import simulink.sysdoc.internal.StudioWidgetManager;
            this.m_preCloseSaveStatus=StudioWidgetManager.SAVE_PROCESS_DONE;
            warning(message('simulink_ui:sysdoc:resources:SaveTimeOut'));
        end


        function saveTimeOutErrorListener(this,~,~)
            import simulink.sysdoc.internal.StudioWidgetManager;
            this.m_saveTimeOutAsyncFuncMgr.stop();
            stopAndDeleteTimer(this.m_hSaveTimer);
            this.m_hSaveTimer=[];
            if strcmp(this.m_preCloseSaveStatus,StudioWidgetManager.SAVE_PROCESS_RUN)
                this.preCloseSaveTimeout();
            end
        end

        function[type,url,content,rootType]=getRouterInfo(this)
            import simulink.sysdoc.internal.MixedMapRouter;
            this.await();
            [type,url,content]=this.m_router.getURLAndContent(this.m_sysDocID,false);
            rootType=MixedMapRouter.BINDING_TYPE_INVALID;
            switch type
            case MixedMapRouter.BINDING_TYPE_INHERIT
                if~isempty(this.m_sysDocID.Parent)

                    [rootType,url,content]=this.m_router.getURLAndContent(this.m_sysDocID,true);
                else

                    type=MixedMapRouter.BINDING_TYPE_NONE;
                end
            end
        end
    end
end




function token=subscribeStudioService(studio,serviceName,oldToken,func)
    if isempty(oldToken)
        c=studio.getService(serviceName);
        token=c.registerServiceCallback(func);
        return;
    end
    token=oldToken;
end

function newToken=unSubscribeStudioService(studio,serviceName,token)
    newToken=[];
    if~isempty(token)
        c=studio.getService(serviceName);
        c.unRegisterServiceCallback(token);
    end
end

function stopAndDeleteTimer(hTimer)

    if~isempty(hTimer)&&strcmp(hTimer.Running,'on')
        stop(hTimer);
    end
    delete(hTimer);
end


