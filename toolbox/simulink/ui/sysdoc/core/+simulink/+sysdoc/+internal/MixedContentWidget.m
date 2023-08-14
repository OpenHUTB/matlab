





classdef MixedContentWidget<simulink.sysdoc.internal.StudioComponentWidget
    properties(Access=public)
        webBrowserUrl=[];
    end

    properties(Access=protected)
        m_studio=[];
        m_router=[];

        m_dirtyMark=false;
        m_isEditMode=false;
        m_forceUpdateRTC=false;
        m_forceUpdateHttp=false;


        m_rtcInitialzied=false;
        m_rtcLoaded=false;
        m_browserType=[];
        m_bindingType=[];
        m_uri=[];
        m_lastBoundUri=[];
        m_uriCache=[];
        m_rootType=[];
        m_hasParent=[];
        m_hasExistRTCFile=[];
        m_postCreateComponentCB=[];


        m_zipFileStatus=[];


        m_compTitle=[];


        m_mainToolbar=[];
        m_dlgToolbar=[];
        m_toolbarActionMap=[];


        m_asyncFuncMgr=[];
        m_loadingUrl=[];

        m_IsTimedOut=false;
    end
    properties(Constant,Hidden)
        COMP_NAME_TAG='SysDocMixedEditor';
        COMP_TITLE=message('simulink_ui:sysdoc:resources:SystemDocumentation').getString();
        COMP_DIRTY_TITLE=[message('simulink_ui:sysdoc:resources:SystemDocumentation').getString(),'*'];
        DEFAULT_DOCK_SIDE='Right';
        COMP_TYPE='GLUE2:Notes Browser Component';

        HELPER_LOAD_TIMEOUT=5;
        HELPER_LOAD_PAUSE_INTERVAL=0.1;

        RTC_BROWSER=GLUE2.NotesBrowserComponent.RtcBrowserId;
        HTTP_BROWSER=GLUE2.NotesBrowserComponent.HttpBrowserId;

        RTC_BROWSER_TAG=GLUE2.NotesBrowserComponent.RtcBrowserTag;
        HTTP_BROWSER_TAG=GLUE2.NotesBrowserComponent.HttpBrowserTag;

        NOTIFICATION_BAR_TAG=GLUE2.NotesBrowserComponent.NotificationBarTag;

        WEB_RESOURCE_LOCATION='SystemDocumentationContent';

        HTML_ROOT_DIRECTORY='/toolbox/simulink/ui/sysdoc/core/web/sysdocrtc/';
        HTML_CONTENT_HTTP_NOLINK_EDIT=replace(fileread([simulink.sysdoc.internal.SysDocUtil.getContentPath(),'/http-nolink-edit-mode.html']),...
        '{0}',...
        message('simulink_ui:sysdoc:resources:TypeInURLBar').getString());
        HTML_CONTENT_HTTP_NOLINK_READ=replace(fileread([simulink.sysdoc.internal.SysDocUtil.getContentPath(),'/http-nolink-release-mode.html']),...
        '{0}',...
        message('simulink_ui:sysdoc:resources:SysNoPointedDoc').getString());
        HTML_CONTENT_PARENT_NOBOUND_READ=replace(fileread([simulink.sysdoc.internal.SysDocUtil.getContentPath(),'/parent-nobound-release-mode.html']),...
        '{0}',...
        message('simulink_ui:sysdoc:resources:UseParentNoBound').getString());
        HTML_CONTENT_NOBOUND_READ=replace(fileread([simulink.sysdoc.internal.SysDocUtil.getContentPath(),'/nobound-release-mode.html']),...
        '{0}',...
        message('simulink_ui:sysdoc:resources:SysNoBound').getString());
    end

    methods

        function url=get.webBrowserUrl(this)
            import simulink.sysdoc.internal.MixedContentWidget;
            url=this.m_comp.getUrl(MixedContentWidget.HTTP_BROWSER);
        end
    end

    methods(Static,Access=public)
















        function onShowBindingLinkForActiveStudio()
            import simulink.sysdoc.internal.SysDocUtil;
            studioWidgetMgr=SysDocUtil.getCurrentStudioWidgetManager();
            if isempty(studioWidgetMgr)
                assert(false,'Illegal use of notes buttons on QT Webbrowser toolbar.');
                return;
            end
            studioWidgetMgr.getContentWidget().showBindingLink();
        end

        function onShowBindingLink(studioWidgetMgr)
            studioWidgetMgr.getContentWidget().showBindingLink();
        end
    end

    methods(Access=public)
        function obj=MixedContentWidget(studio,router,editMode,dirtyMark)
            assert(~isempty(router),'MixedContentWidget::ctor - In the architecture, ContentWidget should be created by router, so that should be always valid here.')
            obj.m_studio=studio;
            obj.m_router=router;
            obj.m_dirtyMark=dirtyMark;
            obj.m_isEditMode=editMode;
            obj.m_forceUpdateRTC=true;
            obj.m_forceUpdateHttp=true;
            obj.m_postCreateComponentCB=[];

            import simulink.sysdoc.internal.MixedMapRouter;


            obj.m_browserType=MixedMapRouter.BINDING_TYPE_HTTP;
            obj.m_bindingType=MixedMapRouter.BINDING_TYPE_INVALID;
            obj.m_rootType=MixedMapRouter.BINDING_TYPE_INVALID;
            obj.m_asyncFuncMgr=dastudio_util.cooperative.AsyncFunctionRepeaterTask;
        end



        function reset(this)
            this.invalidate();

            this.setEditMode(false);
            this.clearUriCache();
        end


        function invalidate(this)
            this.m_forceUpdateRTC=true;
            this.m_forceUpdateHttp=true;
        end










        function setWidgetContent(this,...
            type,...
            url,...
            content,...
            rootType)
            if isempty(this.m_comp)||isempty(this.m_dlgToolbar)
                return;
            end

            import simulink.sysdoc.internal.MixedMapRouter;
            import simulink.sysdoc.internal.MixedContentWidget;
            import simulink.sysdoc.internal.MainToolbar;
            import simulink.sysdoc.internal.SysDocUtil;

            oldUri=this.m_uri;
            oldType=this.m_bindingType;
            oldRootType=this.m_rootType;
            this.m_uri=url;
            this.m_bindingType=type;
            this.m_rootType=rootType;


            if this.m_bindingType==MixedMapRouter.BINDING_TYPE_NODOC

                this.m_comp.resetBrowser(MixedContentWidget.HTTP_BROWSER);
                this.m_forceUpdateHttp=true;
                this.m_comp.setHTML(MixedContentWidget.HTTP_BROWSER,'');


                t=timer('StartDelay',this.HELPER_LOAD_TIMEOUT);
                t.TimerFcn=@(~,~)this.helperLoadTimeout();
                ct=onCleanup(@()delete(t));
                this.m_IsTimedOut=false;
                start(t);

                while isempty(this.m_comp.getHTML(MixedContentWidget.HTTP_BROWSER))&&~this.m_IsTimedOut
                    pause(this.HELPER_LOAD_PAUSE_INTERVAL);
                end
                stop(t);
                assert(~this.m_IsTimedOut,message('simulink_ui:sysdoc:resources:HelperLoadFailed').getString());

                this.showOptions(false);


                return;
            end


            SysDocUtil.pauseAsyncFunctionManager(this.m_asyncFuncMgr);




            showType=this.m_bindingType;
            if this.m_bindingType==MixedMapRouter.BINDING_TYPE_INHERIT

                useInherit=this.m_rootType==MixedMapRouter.BINDING_TYPE_RTC...
                ||(this.m_rootType==MixedMapRouter.BINDING_TYPE_HTTP&&~isempty(this.m_uri));


                sameUriAndType=(this.m_rootType==oldType...
                ||(oldType==MixedMapRouter.BINDING_TYPE_INHERIT&&this.m_rootType==oldRootType))...
                &&strcmp(this.m_uri,oldUri);


                if useInherit
                    showType=this.m_rootType;
                end
            else

                sameUriAndType=(this.m_bindingType==oldType...
                ||(oldType==MixedMapRouter.BINDING_TYPE_INHERIT&&this.m_bindingType==oldRootType))...
                &&strcmp(this.m_uri,oldUri);
            end


            this.updateToolbar();
            this.updateBrowsers();


            switch showType


            case MixedMapRouter.BINDING_TYPE_RTC

                if~this.m_rtcInitialzied
                    this.m_rtcInitialzied=true;
                    this.m_rtcLoaded=false;
                    this.initRTC(this.getStudio());
                end





                if~sameUriAndType||this.m_forceUpdateRTC
                    this.m_forceUpdateRTC=false;
                    studioTag=this.getStudio().getStudioTag();
                    import simulink.sysdoc.internal.JSClientRTCProxy;
                    JSClientRTCProxy.sendJSONContentToRTC(studioTag,content);
                end



            case MixedMapRouter.BINDING_TYPE_HTTP

                runForceUpdateHttp=false;
                if~sameUriAndType||this.m_forceUpdateHttp
                    runForceUpdateHttp=true;
                    this.m_forceUpdateHttp=false;
                    this.m_comp.resetBrowser(MixedContentWidget.HTTP_BROWSER);
                end

                if isempty(this.m_uri)&&isempty(this.m_uriCache)
                    this.m_comp.setHTML(MixedContentWidget.HTTP_BROWSER,'');



                    if this.m_isEditMode
                        import simulink.sysdoc.internal.MixedContentWidget;
                        this.m_comp.resetBrowser(MixedContentWidget.HTTP_BROWSER);
                        this.m_comp.setHTML(MixedContentWidget.HTTP_BROWSER,MixedContentWidget.HTML_CONTENT_HTTP_NOLINK_EDIT);
                    else
                        this.m_comp.setHTML(MixedContentWidget.HTTP_BROWSER,MixedContentWidget.HTML_CONTENT_HTTP_NOLINK_READ);
                    end
                else




                    if this.m_isEditMode&&~isempty(this.m_uriCache)
                        loadUrl=this.m_uriCache;
                    else
                        loadUrl=this.m_uri;
                    end
                    if runForceUpdateHttp
                        this.m_comp.resetBrowser(MixedContentWidget.HTTP_BROWSER);
                    end
                    this.setURLForHttpBrowser(loadUrl);
                end



            case MixedMapRouter.BINDING_TYPE_NONE
                if this.m_isEditMode


                    import simulink.sysdoc.internal.MixedContentWidget;
                    this.m_comp.resetBrowser(MixedContentWidget.HTTP_BROWSER);
                    this.m_comp.setHTML(MixedContentWidget.HTTP_BROWSER,'');
                    this.m_forceUpdateHttp=true;

                else
                    this.m_comp.setHTML(MixedContentWidget.HTTP_BROWSER,MixedContentWidget.HTML_CONTENT_NOBOUND_READ);
                end


            case MixedMapRouter.BINDING_TYPE_INHERIT

                if this.m_isEditMode


                    this.m_comp.resetBrowser(MixedContentWidget.HTTP_BROWSER);
                    this.m_forceUpdateHttp=true;
                    this.m_comp.setHTML(MixedContentWidget.HTTP_BROWSER,'');


                    import simulink.sysdoc.internal.MixedContentWidget;
                    this.m_comp.setUrl(MixedContentWidget.HTTP_BROWSER,...
                    MixedContentWidget.getNoteHelperPageLink(...
                    this.getStudio().getStudioTag(),...
                    'nobound',...
                    '',...
                    '',...
                    '',...
                    '',...
                    this.m_hasExistRTCFile,...
                    false,...
                    ''));
                    this.m_forceUpdateHttp=true;
                else
                    this.m_comp.setHTML(MixedContentWidget.HTTP_BROWSER,MixedContentWidget.HTML_CONTENT_PARENT_NOBOUND_READ);
                end


            case MixedMapRouter.BINDING_TYPE_MODELREUSE

                this.m_comp.resetBrowser(MixedContentWidget.HTTP_BROWSER);
                this.m_forceUpdateHttp=true;
                this.m_comp.setHTML(MixedContentWidget.HTTP_BROWSER,'');




                status='unsupportedobject';
                thisLevel='';
                notesSource='';
                modelLevel='';
                nodeToHide='';
                parentRTC=false;
                notesFileName='';
                enableGear=false;


                this.m_comp.setUrl(MixedContentWidget.HTTP_BROWSER,...
                MixedContentWidget.getNoteHelperPageLink(...
                this.getStudio().getStudioTag(),...
                status,...
                thisLevel,...
                notesSource,...
                modelLevel,...
                nodeToHide,...
                this.m_hasExistRTCFile,...
                parentRTC,...
                notesFileName));


                this.switchToHttpBrowser();
                this.m_dlgToolbar.updateToolTip(MainToolbar.BTN_DOC_SET_OPTION_TAG,MainToolbar.TT_SHOW_OPTION_SELECTED);
                this.disableFirstRowToolbarExceptForDocSet(enableGear);
                this.hideSecondRowToolbar();
                this.m_forceUpdateHttp=true;
            otherwise
                assert(false,'Unsupported type - should not allow executing this function with unexpected types.');
            end
        end

        function helperLoadTimeout(this)
            this.m_IsTimedOut=true;
        end

        function showOptions(this,enableGear)
            import simulink.sysdoc.internal.MixedContentWidget;
            import simulink.sysdoc.internal.MixedMapRouter;
            import simulink.sysdoc.internal.SysDocUtil;


            if this.isRealUrlNotesType()
                this.m_uriCache=this.getLoadingBrowserUrl();
            end


            SysDocUtil.pauseAsyncFunctionManager(this.m_asyncFuncMgr);
            this.m_comp.setHTML(MixedContentWidget.HTTP_BROWSER,'');


            status='';
            thisLevel='';
            notesSource='';
            modelLevel='options';
            nodeToHide='';
            parentRTC=false;
            notesFileName='';

            if this.m_bindingType==MixedMapRouter.BINDING_TYPE_NODOC
                if this.m_zipFileStatus==MixedMapRouter.DOC_FILE_NOT_FOUND
                    status='notfound';
                    notesFileName=get_param(SysDocUtil.getModelName(this.getStudio()),'Notes');
                else
                    status='nonotesfile';
                end
            else
                if this.m_isEditMode





                    status='';
                    thisLevel='inherit';
                    notesSource='';
                    nodeToHide='duplicate';
                    if~this.m_hasParent
                        thisLevel='nobound';
                        nodeToHide='inherit';
                    end
                    switch this.m_bindingType




                    case MixedMapRouter.BINDING_TYPE_INHERIT
                        if this.m_rootType==MixedMapRouter.BINDING_TYPE_RTC
                            parentRTC=true;
                            nodeToHide='';
                        end
                        status='inherit';

                        notesSource='inherit';



                    end
                end
            end


            this.m_comp.setUrl(MixedContentWidget.HTTP_BROWSER,...
            MixedContentWidget.getNoteHelperPageLink(...
            this.getStudio().getStudioTag(),...
            status,...
            thisLevel,...
            notesSource,...
            modelLevel,...
            nodeToHide,...
            this.m_hasExistRTCFile,...
            parentRTC,...
            notesFileName));


            this.switchToHttpBrowser();
            import simulink.sysdoc.internal.MainToolbar;
            this.m_dlgToolbar.updateToolTip(MainToolbar.BTN_DOC_SET_OPTION_TAG,MainToolbar.TT_SHOW_OPTION_SELECTED);
            this.disableFirstRowToolbarExceptForDocSet(enableGear);
            this.hideSecondRowToolbar();
            this.m_forceUpdateHttp=true;
        end





















        function showBindingLink(this)
            import simulink.sysdoc.internal.MixedContentWidget;
            currentUri=this.m_comp.getUrl(MixedContentWidget.HTTP_BROWSER);
            if strcmp(currentUri,this.m_uri)&&~isempty(this.m_lastBoundUri)
                this.m_comp.setUrl(MixedContentWidget.HTTP_BROWSER,this.m_lastBoundUri);
            else
                this.m_comp.setUrl(MixedContentWidget.HTTP_BROWSER,this.m_uri);
            end
        end




        function src=getSource(this)
            src=this.m_mainToolbar;
        end

        function type=getBrowserType(this)
            type=this.m_bindingType;
        end

        function dirty=getDirty(this)
            dirty=this.m_dirtyMark;
        end

        function url=getLoadingBrowserUrl(this)
            import dastudio_util.cooperative.AsyncFunctionRepeaterTask.Status;
            processResultStatus=this.m_asyncFuncMgr.Status;

            if processResultStatus==Status.Running&&this.isRealUrlNotesType()
                url=this.m_loadingUrl;
                return;
            end
            import simulink.sysdoc.internal.MainToolbar;
            url=this.getBrowerUrl();
        end

        function url=getBrowerUrl(this)
            import simulink.sysdoc.internal.MixedContentWidget;
            url=this.m_comp.getUrl(MixedContentWidget.HTTP_BROWSER);
        end

        function setHasParent(this,hasParent)
            this.m_hasParent=hasParent;
        end

        function setHasExistRTCFile(this,hasExistRTCFile)
            this.m_hasExistRTCFile=hasExistRTCFile;
        end

        function setZipFileStatus(this,zipFileStatus)
            this.m_zipFileStatus=zipFileStatus;
        end

        function setRTCLoaded(this,rtcLoaded)
            this.m_rtcLoaded=rtcLoaded;
        end

        function rtcLoaded=getRTCLoaded(this)
            rtcLoaded=this.m_rtcLoaded;
        end

        function setLastBoundUri(this,lastBoundUri)
            this.m_lastBoundUri=lastBoundUri;
        end

        function setDocSetGearButton(this,v)
            import simulink.sysdoc.internal.MainToolbar;
            this.m_dlgToolbar.setWidgetValue(MainToolbar.BTN_DOC_SET_OPTION_TAG,v);
        end

        function isToggled=isOptionsOn(this)
            import simulink.sysdoc.internal.MainToolbar;
            isToggled=this.m_dlgToolbar.getWidgetValue(MainToolbar.BTN_DOC_SET_OPTION_TAG);
        end



        function setUriCache(this)
            import simulink.sysdoc.internal.MixedMapRouter;
            if(this.m_browserType~=MixedMapRouter.BINDING_TYPE_HTTP)
                return;
            end
            if this.m_bindingType==MixedMapRouter.BINDING_TYPE_NONE
                this.clearUriCache();
                return;
            end
            import simulink.sysdoc.internal.MixedContentWidget;
            this.m_uriCache=this.m_comp.getUrl(MixedContentWidget.HTTP_BROWSER);
        end



        function clearUriCache(this)
            this.m_uriCache='';
        end

        function showWarnMessage(this,messageID,unicodeMsg)
            if isempty(this.m_comp)
                this.m_postCreateComponentCB=@()this.showWarnMessage(messageID,unicodeMsg);
                return;
            end
            this.m_comp.showWarnMessage(messageID,unicodeMsg,false);
        end

        function hideNotification(this)
            if isempty(this.m_comp)
                return;
            end
            this.m_comp.hideNotificationBar();
        end



        function undoToggleButtonChange(this,actionTag)
            if isempty(this.m_dlgToolbar)
                return;
            end
            this.m_dlgToolbar.setWidgetValue(actionTag,~this.m_dlgToolbar.getWidgetValue(actionTag));
        end


        function setRTCFocus(this)
            import simulink.sysdoc.internal.MixedMapRouter;
            if~this.m_isEditMode||this.m_bindingType~=MixedMapRouter.BINDING_TYPE_RTC
                return;
            end
            if isempty(this.m_dlgToolbar)
                return;
            end
            import simulink.sysdoc.internal.MixedContentWidget;
            this.m_comp.setFocus(MixedContentWidget.RTC_BROWSER);
        end




        function setEditMode(this,editMode)
            this.m_isEditMode=editMode;
        end





        function actionChanged(this,actionTag,actionKey,actionNewValue)
            if isempty(this.m_comp)...
                ||isempty(this.m_dlgToolbar)...
                ||isempty(this.m_toolbarActionMap)
                return;
            end
            if~this.m_toolbarActionMap.isKey(actionKey)
                return;
            end
            func=this.m_toolbarActionMap(actionKey);
            func(this.m_dlgToolbar,this.m_comp,this.m_mainToolbar.getTagToSplitItemMap(),actionTag,actionNewValue);
        end




        function show(this)
            this.show@simulink.sysdoc.internal.StudioComponentWidget();
        end

        function title=getTitle(this)
            if isempty(this.m_compTitle)
                import simulink.sysdoc.internal.MixedContentWidget;
                import simulink.sysdoc.internal.SysDocUtil;
                modelName=SysDocUtil.getModelName(this.getStudio());
                assert(~isempty(modelName));
                title=[MixedContentWidget.COMP_TITLE,' - ',modelName];
            else
                title=this.m_compTitle;
            end
        end

        function setTitle(this,title)
            this.m_compTitle=title;
        end

        function updateTitle(this)
            import simulink.sysdoc.internal.MixedContentWidget;
            this.getStudio().setDockComponentTitle(this.m_comp,this.getTitle());
        end

        function dockSide=getDefaultDockside(this)
            import simulink.sysdoc.internal.MixedContentWidget;
            dockSide=MixedContentWidget.DEFAULT_DOCK_SIDE;
        end

        function studio=getStudio(this)
            studio=this.m_studio;
        end

        function initComponentAndShow(this,studio)
            import simulink.sysdoc.internal.SysDocUtil;
            viewComp=this.getComponent();
            if~isempty(viewComp)&&isvalid(viewComp)
                return;
            end


            this.createNotesBrowserComponent(studio);
            if~isempty(this.m_postCreateComponentCB)
                this.m_postCreateComponentCB();
                this.m_postCreateComponentCB=[];
            end
        end

        function setToolbar(this,toolbar)
            this.m_dlgToolbar=toolbar;
        end

        function compType=getCompType(this)
            import simulink.sysdoc.internal.MixedContentWidget;
            compType=MixedContentWidget.COMP_TYPE;
            return
        end

        function printPage(this)
            import simulink.sysdoc.internal.MixedMapRouter;
            if this.m_browserType==MixedMapRouter.BINDING_TYPE_HTTP
                import simulink.sysdoc.internal.MixedContentWidget;
                this.m_comp.printCurrentPage(MixedContentWidget.HTTP_BROWSER);
            else
                import simulink.sysdoc.internal.JSClientRTCProxy;
                JSClientRTCProxy.onPrintPage(this.getStudio().getStudioTag());
            end
        end

        function printRTCContent(this,htmlContent)
            import simulink.sysdoc.internal.MixedMapRouter;
            if this.m_browserType==MixedMapRouter.BINDING_TYPE_RTC
                GLUE2.NotesBrowserComponent.printHtmlContent(htmlContent);
            end
        end


    end

    methods(Access={?sysdoc.NotesTester,?SysDocTestInterface})



        function toolbarDlg=getToolbarDialog(this)
            toolbarDlg=this.m_dlgToolbar;
        end

        function rtcInitialzied=getRTCInitialized(this)
            rtcInitialzied=this.m_rtcInitialzied;
        end
    end

    methods(Access=protected)




        function setURLForHttpBrowser(this,url)
            import simulink.sysdoc.internal.MixedContentWidget;
            if strcmp(this.m_comp.getUrl(MixedContentWidget.HTTP_BROWSER),url)
                return;
            end
            this.m_comp.setUrl(MixedContentWidget.HTTP_BROWSER,url);
        end






        function updateToolbar(this)
            if isempty(this.m_dlgToolbar)
                return;
            end

            assert(this.m_bindingType~=MixedMapRouter.BINDING_TYPE_INVALID);

            import simulink.sysdoc.internal.MixedMapRouter;
            import simulink.sysdoc.internal.MainToolbar;
            import simulink.sysdoc.internal.MixedContentWidget;




            this.m_dlgToolbar.setEnabled(MainToolbar.BTN_TOGGLE_EDIT_BIND_TAG,true);
            this.m_dlgToolbar.setWidgetValue(MainToolbar.BTN_TOGGLE_EDIT_BIND_TAG,this.m_isEditMode);
            if this.m_isEditMode
                this.m_dlgToolbar.updateToolTip(MainToolbar.BTN_TOGGLE_EDIT_BIND_TAG,MainToolbar.TT_EDIT_BIND_SELECTED);
            else
                this.m_dlgToolbar.updateToolTip(MainToolbar.BTN_TOGGLE_EDIT_BIND_TAG,MainToolbar.TT_EDIT_BIND_UNSELECTED);
            end


            this.m_dlgToolbar.setEnabled(MainToolbar.BTN_GOTO_ROOT_TAG,this.m_bindingType==MixedMapRouter.BINDING_TYPE_INHERIT);


            this.m_dlgToolbar.setVisible(MainToolbar.CB_BIND_TYPE_TAG,this.m_hasParent);
            this.m_dlgToolbar.setVisible(MainToolbar.CB_BIND_TYPE_ROOT_TAG,~this.m_hasParent);


            this.m_dlgToolbar.setEnabled(MainToolbar.CB_BIND_TYPE_TAG,this.m_isEditMode);
            this.m_dlgToolbar.setEnabled(MainToolbar.CB_BIND_TYPE_ROOT_TAG,this.m_isEditMode);


            assert(this.m_bindingType~=MixedMapRouter.BINDING_TYPE_INVALID);
            this.m_dlgToolbar.setWidgetValue(MainToolbar.CB_BIND_TYPE_TAG,this.m_bindingType);
            this.m_dlgToolbar.setWidgetValue(MainToolbar.CB_BIND_TYPE_ROOT_TAG,this.m_bindingType);



            this.m_dlgToolbar.setWidgetValue(MainToolbar.BTN_DOC_SET_OPTION_TAG,false);
            this.m_dlgToolbar.setEnabled(MainToolbar.BTN_DOC_SET_OPTION_TAG,true);
            this.m_dlgToolbar.updateToolTip(MainToolbar.BTN_DOC_SET_OPTION_TAG,MainToolbar.TT_SHOW_OPTION_UNSELECTED);




            this.m_dlgToolbar.setVisible(MainToolbar.RTC_EDIT_PANEL_TAG,...
            (this.m_bindingType==MixedMapRouter.BINDING_TYPE_RTC)&&this.m_isEditMode);




            httpBarVisible=(this.m_bindingType==MixedMapRouter.BINDING_TYPE_HTTP)...
            ||(this.m_bindingType==MixedMapRouter.BINDING_TYPE_INHERIT...
            &&this.m_rootType==MixedMapRouter.BINDING_TYPE_HTTP...
            &&this.m_isEditMode==false);
            import simulink.sysdoc.internal.MixedContentWidget;
            this.m_comp.setToolBarVisible(MixedContentWidget.HTTP_BROWSER,httpBarVisible);
            if httpBarVisible
                this.m_comp.setEnabledModelDocBrowserControls(MixedContentWidget.HTTP_BROWSER,~isempty(this.m_uri)||~isempty(this.m_lastBoundUri));
                this.m_comp.setModelDocBrowserControlsVisible(this.m_bindingType==MixedMapRouter.BINDING_TYPE_HTTP&&this.m_isEditMode);
            end
        end


        function updateBrowsers(this)
            import simulink.sysdoc.internal.JSClientRTCProxy;
            import simulink.sysdoc.internal.MixedMapRouter;



            showRTC=this.m_bindingType==MixedMapRouter.BINDING_TYPE_RTC...
            ||(this.m_bindingType==MixedMapRouter.BINDING_TYPE_INHERIT...
            &&this.m_rootType==MixedMapRouter.BINDING_TYPE_RTC);
            if showRTC
                this.switchToRTCBrowser();
            else
                this.switchToHttpBrowser();
            end



            if showRTC

                rtcEditMode=this.m_isEditMode&&~(this.m_hasParent&&this.m_rootType==MixedMapRouter.BINDING_TYPE_RTC);
                JSClientRTCProxy.setRTCEditMode(this.getStudio().getStudioTag(),rtcEditMode);


                if this.m_browserType==MixedMapRouter.BINDING_TYPE_RTC&&this.m_isEditMode
                    this.setRTCFocus();
                end
            end
        end

        function switchToRTCBrowser(this)
            import simulink.sysdoc.internal.MixedContentWidget;
            import simulink.sysdoc.internal.MixedMapRouter;

            if this.m_browserType~=MixedMapRouter.BINDING_TYPE_RTC
                this.m_comp.setBrowserVisible(MixedContentWidget.HTTP_BROWSER,false);
                this.m_comp.setBrowserVisible(MixedContentWidget.RTC_BROWSER,true);
                this.m_browserType=MixedMapRouter.BINDING_TYPE_RTC;
            end
        end

        function switchToHttpBrowser(this)
            import simulink.sysdoc.internal.MixedContentWidget;
            import simulink.sysdoc.internal.MixedMapRouter;

            if this.m_browserType~=MixedMapRouter.BINDING_TYPE_HTTP
                this.m_comp.setBrowserVisible(MixedContentWidget.RTC_BROWSER,false);
                this.m_comp.setBrowserVisible(MixedContentWidget.HTTP_BROWSER,true);
                this.m_browserType=MixedMapRouter.BINDING_TYPE_HTTP;
            end
        end

        function disableFirstRowToolbarExceptForDocSet(this,enableGear)
            import simulink.sysdoc.internal.MainToolbar;
            import simulink.sysdoc.internal.MixedMapRouter;




            this.m_dlgToolbar.setEnabled(MainToolbar.BTN_TOGGLE_EDIT_BIND_TAG,false);


            this.m_dlgToolbar.setEnabled(MainToolbar.BTN_GOTO_ROOT_TAG,false);


            this.m_dlgToolbar.setEnabled(MainToolbar.CB_BIND_TYPE_TAG,false);
            this.m_dlgToolbar.setEnabled(MainToolbar.CB_BIND_TYPE_ROOT_TAG,false);

            this.m_dlgToolbar.setEnabled(MainToolbar.BTN_DOC_SET_OPTION_TAG,enableGear);
        end

        function hideSecondRowToolbar(this)
            import simulink.sysdoc.internal.MainToolbar;
            import simulink.sysdoc.internal.MixedMapRouter;




            this.m_dlgToolbar.setVisible(MainToolbar.RTC_EDIT_PANEL_TAG,false);



            import simulink.sysdoc.internal.MixedContentWidget;
            this.m_comp.setToolBarVisible(MixedContentWidget.HTTP_BROWSER,false);
        end




        function createNotesBrowserComponent(this,studio)
            import simulink.sysdoc.internal.SysDocUtil;
            if~SysDocUtil.isNotEmptyAndValid(studio)
                return;
            end



            nameTag=this.getNameTag();


            import GLUE2.NotesBrowserComponent;
            this.m_comp=NotesBrowserComponent(studio,nameTag);
            assert(~isempty(this.m_comp),'createSysDocWebDDGComponent: failed to create NotesBrowserComponent.');
            this.m_comp.CloseCallback='simulink.sysdoc.internal.StudioWidgetManager.onContentWidgetDialogClose';


            import simulink.sysdoc.internal.MainToolbar;
            this.m_mainToolbar=MainToolbar(this.getStudio());
            this.m_comp.setToolbarSource(this.m_mainToolbar);


            this.componentConfigFunc(this.m_comp,studio);

            if simulink.SystemDocumentationApplication.getInstance().isDebugMode()
                import simulink.sysdoc.internal.MixedContentWidget;
                this.m_comp.setDebug(MixedContentWidget.RTC_BROWSER,true);
                this.m_comp.enableInspectorOnLoad(MixedContentWidget.RTC_BROWSER,true);
            end



            studio.registerComponent(this.m_comp);
            this.m_comp.PersistState=true;
            studio.moveComponentToDock(this.m_comp,this.getTitle(),this.getDefaultDockside(),'Tabbed');
            this.m_dlgToolbar=DAStudio.ToolRoot.getOpenDialogs(this.m_mainToolbar);
            assert(~isempty(this.m_dlgToolbar),'createSysDocWebDDGComponent: failed to get dialog.');


            this.m_toolbarActionMap=containers.Map;
            this.m_toolbarActionMap('enabled')=@setDlgEnabled;
            this.m_toolbarActionMap('selected')=@setDlgSelected;


            this.m_comp.setTabTitle(message('simulink_ui:sysdoc:resources:SystemDocumentation').getString());
        end


        function initRTC(this,studio)
            connector.ensureServiceOn;
            studioTag=studio.getStudioTag();
            import simulink.sysdoc.internal.MixedContentWidget;
            dlgUrl=MixedContentWidget.getRTCLink(studioTag,...
            this.m_isEditMode,...
            simulink.SystemDocumentationApplication.getInstance().isTestMode());
            this.m_comp.setUrl(MixedContentWidget.RTC_BROWSER,dlgUrl);
            this.m_forceUpdateRTC=true;


            import com.mathworks.services.clipboardservice.ConnectorClipboardService;
            ConnectorClipboardService.getInstance();
        end





        function realUrlNotesType=isRealUrlNotesType(this)
            import simulink.sysdoc.internal.MixedMapRouter;
            realUrlNotesType=this.m_bindingType==MixedMapRouter.BINDING_TYPE_HTTP...
            ||(this.m_bindingType==MixedMapRouter.BINDING_TYPE_INHERIT...
            &&this.m_rootType==MixedMapRouter.BINDING_TYPE_HTTP);
        end
    end

    methods(Static,Access=public)







        function nameTag=getNameTag()
            import simulink.sysdoc.internal.MixedContentWidget;
            nameTag=MixedContentWidget.COMP_NAME_TAG;
        end


        function dlgUrl=getRTCLink(studioTag,editMode,isTestMode)
            import simulink.sysdoc.internal.MainToolbar;
            import simulink.sysdoc.internal.MixedContentWidget;
            if editMode
                readOnlyTag='false';
            else
                readOnlyTag='true';
            end
            testString='';
            if isTestMode
                testString='&test=testEditor';
            end
            if simulink.SystemDocumentationApplication.getInstance().isDebugMode()
                htmlFile='index-debug.html';
                testString='&test=testEditor';
            else
                htmlFile='index.html';
            end
            dlgUrl=connector.getUrl([MixedContentWidget.HTML_ROOT_DIRECTORY...
            ,htmlFile...
            ,'?studioTag=',studioTag...
            ,'&readOnly=',readOnlyTag...
            ,testString...
            ,MainToolbar.RTC_BUTTON_TAGS_QUERY]);
        end


        function dlgUrl=getNoteHelperPageLink(studioTag,...
            statusPage,...
            thislevelPage,...
            notessourcePage,...
            modellevelPage,...
            nodeToHide,...
            hasExistRTCFile,...
            parentRTC,...
            notesFileName)
            import simulink.sysdoc.internal.MixedContentWidget;
            if hasExistRTCFile
                strExistRTCTag='true';
            else
                strExistRTCTag='false';
            end
            if parentRTC
                strParentRTCTag='true';
            else
                strParentRTCTag='false';
            end
            if simulink.SystemDocumentationApplication.getInstance().isDebugMode()
                htmlFile='note-helper-debug.html';
            else
                htmlFile='note-helper.html';
            end
            dlgUrl=connector.getUrl([MixedContentWidget.HTML_ROOT_DIRECTORY...
            ,htmlFile...
            ,'?studioTag=',studioTag...
            ,'&status=',statusPage...
            ,'&thisLevel=',thislevelPage...
            ,'&notesSource=',notessourcePage...
            ,'&modelLevel=',modellevelPage...
            ,'&nodeToHide=',nodeToHide...
            ,'&rtcExist=',strExistRTCTag...
            ,'&parentRTC=',strParentRTCTag...
            ,'&notesFileName=',notesFileName]);
        end












        function componentConfigFunc(src,studio)

            connector.ensureServiceOn;
            import simulink.sysdoc.internal.MixedContentWidget;
            import simulink.sysdoc.internal.SysDocUtil;
            connector.addWebAddOnsPath(MixedContentWidget.WEB_RESOURCE_LOCATION,SysDocUtil.getContentPath());





        end

    end
end





function setDlgEnabled(dlg,~,itemMap,tag,value)
    if~itemMap.isKey(tag)

        dlg.setEnabled(tag,value);
        return;
    end


    itemInfo=itemMap(tag);
    splitTag=itemInfo.SplitTag;
    splitItem=itemInfo.Item;
    if splitItem.isMultiChoiceItem()&&dlg.isEnabled(splitTag)~=value

        dlg.setEnabled(splitTag,value);
    end
end

function setDlgSelected(dlg,comp,itemMap,tag,value)
    if~itemMap.isKey(tag)

        dlg.setWidgetValue(tag,value);
        return;
    end


    itemInfo=itemMap(tag);
    splitItem=itemInfo.Item;
    splitTag=itemInfo.SplitTag;
    splitItem.setChecked(value);
    if splitItem.isMultiChoiceItem()

        dlg.setWidgetValue(splitTag,'');
    else
        if value
            import simulink.sysdoc.internal.MainToolbar;
            itemTag=splitItem.getTag();

            dlg.setWidgetValue(splitTag,itemTag);
        else

            dlg.setWidgetValue(splitTag,'');
        end
    end
end
