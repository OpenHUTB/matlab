function hardwareTreeNodeSelectedCallback(this,callbackObj,eventdata)%#ok<INUSL,INUSL>

    nodeObject=eventdata.JavaEvent.newNode;
    browser=iatbrowser.Browser;

    if isequal(nodeObject,this.currentNode)

        return;
    end


    if this.abortNodeSelectionChange||~iatbrowser.isDiskLoggingConfigurationValid(browser.currentVideoinputObject)
        od=iatbrowser.OptionDialog;
        od.showOptionDialog(...
        com.mathworks.toolbox.imaq.browser.IATBrowserDesktop.getInstance.getMainFrame,...
        'INVALID_DISK_LOGGING_CONFIG',...
        eventdata.JavaEvent,...
        @configureMemoryLogging,...
        @reselectOldNode);
    else
        checkForExport(callbackObj,eventdata);
    end

    function configureMemoryLogging(callbackObj,eventdata)
        vidObj=browser.currentVideoinputObject;
        vidObj.LoggingMode='memory';
        this.abortNodeSelectionChange=false;
        checkForExport(callbackObj,eventdata);
    end

    function checkForExport(obj,eventdata)%#ok<INUSL>

        if browser.prevPanelController.areFramesAvailableForExport

            od=iatbrowser.OptionDialog;
            od.showOptionDialog(...
            iatbrowser.getDesktopFrame(),...
            'CHANGE_FORMATS_FRAMES_WILL_BE_LOST',...
            eventdata.JavaEvent,...
            @proceed,...
            @reselectOldNode);
        else
            proceed([],eventdata);
        end
    end

    function reselectOldNode(obj,eventdata)%#ok<INUSL>
        javaMethodEDT('setReselectingNode',java(this.javaPeer),true);
        this.selectNode(eventdata.JavaEvent.oldNode,false)
        formatPanel=browser.acqParamPanel.javaPeer.getFormatNodePanel();
        formatPanel.selectLoggingTab();
        drawnow;
    end

    function proceed(obj,eventdata)%#ok<INUSL>
        browser.acqParamPanel.stopPropertyUpdateTimer();
        javaMethodEDT('setEnabled',javaMethodEDT('getClearConfigAction',java(this.javaPeer)),false);
        javaMethodEDT('setEnabled',javaMethodEDT('getExportHWConfigAction',java(this.javaPeer)),false);
        desk=iatbrowser.getDesktop();
        desk.enableGlassPane(true);

        nodeObject=eventdata.JavaEvent.newNode;

        browser.prevPanelController.restartPreview=browser.prevPanelController.isPreviewing();
        if browser.prevPanelController.isPreviewing()
            browser.prevPanelController.stopPreview(false);
        end
        eventName=iatbrowser.generateNodeSelectedEventName(nodeObject);
        mEventData=iatbrowser.TreeNodeSelectedEventData(...
        eventdata.JavaEvent.oldNode,...
        eventdata.JavaEvent.newNode);


        this.currentNode=nodeObject;


        if strcmp(eventName,'rootNodeSelected')||strcmp(eventName,'deviceNodeSelected')
            browser.currentVideoinputObject=[];
        end

        success=nodeObject.setupNodeAfterSelection(mEventData);
        glassPaneSentinel=iatbrowser.GlassPaneSentinel;%#ok<NASGU>
        if success
            notify(nodeObject,eventName,mEventData);
            browser.messageBus.generateEvent('TreeNodeSelected',mEventData);
        else
            reselectOldNode([],eventdata);
        end
        javaMethodEDT('updateUI',java(this.javaTreePeer));
    end

end
