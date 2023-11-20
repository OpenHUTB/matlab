function initialize(this,rootNode,prevPanel)

    this.javaPeer=handle(com.mathworks.toolbox.imaq.browser.acquisitionParameters.AcquisitionParametersPanel.getInstance());
    connect(this,this.javaPeer,'down');

    addTreeNodeListeners(rootNode);
    addFormatNodePanelWidgetListeners;
    addDeviceNodePanelWidgetListeners;
    addPreviewPanelControllerListeners(prevPanel);

    browser=iatbrowser.Browser();

    this.incrementLogFileIndexListener=event.listener(browser.messageBus,...
    'DiskLoggingFinished',@(obj,event)this.incrementLogFileIndex());

    treeViewPanel=com.mathworks.toolbox.imaq.browser.TreeViewPanel.getInstance();
    clearConfigCallback=handle(treeViewPanel.getClearConfigCallback());
    this.clearCurrentConfigListener=handle.listener(clearConfigCallback,'delayed',@handleClearCurrentConfig);
    this.LogFileIndexIncrementProps=iatbrowser.LogFileIndexIncrementParameters();


    function addTreeNodeListeners(node)
        [theEvent,nodeClass]=iatbrowser.generateNodeSelectedEventName(node);
        nodeHandler=eval(['@handle',nodeClass,'Selected']);
        if isempty(this.treeNodeListeners)
            this.treeNodeListeners=event.listener(node,theEvent,nodeHandler);
        else
            this.treeNodeListeners(end+1)=event.listener(node,theEvent,nodeHandler);
        end


        if isa(node,'iatbrowser.DeviceNode')
            this.treeNodeListeners(end+1)=event.listener(node,'formatNodeAdded',@handleFormatNodeAdded);
        end

        children=node.getChildren();
        for ii=1:length(children)
            curchild=children{ii};
            addTreeNodeListeners(curchild);
        end
    end

    function addFormatNodePanelWidgetListeners
        javaPeer=java(this.javaPeer);
        formatNodePanel=javaPeer.getFormatNodePanel();

        framesToAcquireCallback=handle(formatNodePanel.getFramesToAcquireCallback());
        this.widgetListeners=handle.listener(framesToAcquireCallback,'delayed',@handleFramesToAcquireChanged);
        this.widgetListeners(end+1)=handle.listener(this,'handleFramesPerTriggerUpdated',@(obj,theEvent)updateTriggerPanel(this));

        colorspaceCallback=handle(formatNodePanel.getColorspaceCallback());
        this.widgetListeners(end+1)=handle.listener(colorspaceCallback,'delayed',@handleColorspaceChanged);

        sourceChangedCallback=handle(formatNodePanel.getSourceChangedCallback());
        this.widgetListeners(end+1)=handle.listener(sourceChangedCallback,'delayed',@handleSourceChanged);

        loggingModeChangedCallback=handle(formatNodePanel.getLoggingModeChangedCallback());
        this.widgetListeners(end+1)=handle.listener(loggingModeChangedCallback,'delayed',@handleLoggingModeChanged);

        diskParametersChangedCallback=handle(formatNodePanel.getDiskLoggingParametersCallback());
        this.widgetListeners(end+1)=handle.listener(diskParametersChangedCallback,'delayed',@handleDiskParametersChanged);

        triggerTypeChangedCallback=handle(formatNodePanel.getTriggerTypeCallback());
        this.widgetListeners(end+1)=handle.listener(triggerTypeChangedCallback,'delayed',@handleTriggerConditionChanged);

        triggerSourceChangedCallback=handle(formatNodePanel.getTriggerSourceCallback());
        this.widgetListeners(end+1)=handle.listener(triggerSourceChangedCallback,'delayed',@handleTriggerSourceChanged);

        triggerConditionChangedCallback=handle(formatNodePanel.getTriggerConditionCallback());
        this.widgetListeners(end+1)=handle.listener(triggerConditionChangedCallback,'delayed',@handleTriggerConditionChanged);

        triggerRepeatChangedCallback=handle(formatNodePanel.getTriggerRepeatCallback());
        this.widgetListeners(end+1)=handle.listener(triggerRepeatChangedCallback,'delayed',@handleTriggerRepeatChanged);

        devicePropertiesTabStateChangedCallback=handle(formatNodePanel.getDeviceTabStateChangedCallback());
        this.widgetListeners(end+1)=handle.listener(devicePropertiesTabStateChangedCallback,'delayed',@(obj,event)this.handleDevicePropertiesTabCallback(event));
    end

    function addDeviceNodePanelWidgetListeners
        javaPeer=java(this.javaPeer);
        deviceNodePanel=javaPeer.getDeviceNodePanel();

        formatSelectedCallback=handle(deviceNodePanel.getFormatSelectedCallback());
        this.widgetListeners(end+1)=handle.listener(formatSelectedCallback,'delayed',@handleFormatSelected);

        selectCameraFileCallback=handle(deviceNodePanel.getSelectCameraFileCallback());
        this.widgetListeners(end+1)=handle.listener(selectCameraFileCallback,'delayed',@handleSelectCameraFile);
    end

    function addPreviewPanelControllerListeners(ppc)


        this.previewPanelControllerListeners=handle.listener(ppc,'PreviewStarting',...
        @(src,data)this.updateDevicePanel());
        this.previewPanelControllerListeners(end+1)=handle.listener(ppc,'PreviewStopping',...
        @(src,data)this.updateDevicePanel());
    end

    function localCommonTreeNodeSelectedActions()


        this.stopPropertyUpdateTimer();
    end

    function handleRootNodeSelected(node,theEvent)%#ok<INUSD,DEFNU>
        localCommonTreeNodeSelectedActions();
        javaMethodEDT('makeRootNodePaneVisible',java(this.javaPeer));
        treeView=com.mathworks.toolbox.imaq.browser.TreeViewPanel.getInstance();
        javaMethodEDT('setEnabled',treeView.getClearConfigAction(),false);
    end

    function handleDeviceNodeSelected(node,theEvent)%#ok<INUSD,DEFNU>

        localCommonTreeNodeSelectedActions();

        javaPeer=java(this.javaPeer);
        javaPeer.makeDeviceNodePaneVisible();
        browser=iatbrowser.Browser;
        deviceNode=browser.treePanel.currentNode;
        formats=deviceNode.getSupportedFormats();

        devicePanel=javaPeer.getDeviceNodePanel();


        devicePanel.setDisplayedFormats(formats);

        devicePanel.setCameraFileSupported(deviceNode.CameraFileSupport);

        treeView=com.mathworks.toolbox.imaq.browser.TreeViewPanel.getInstance();
        javaMethodEDT('setEnabled',treeView.getClearConfigAction(),false);
        javaMethodEDT('setEnabled',treeView.getExportHWConfigAction(),false);
    end

    function handleFormatNodeSelected(node,theEvent)%#ok<INUSD,INUSD>

        localCommonTreeNodeSelectedActions();

        this.updateGeneralPanel;
        this.updateDevicePanel;
        this.updateLoggingPanel;
        this.updateTriggerPanel;
        this.updateROIPanel;
        javaMethodEDT('makeFormatNodePaneVisible',java(this.javaPeer));

        vidObj=iatbrowser.Browser().currentVideoinputObject;

        if get(vidObj,'FramesPerTrigger')~=Inf
            set(vidObj,'FramesAcquiredFcnCount',vidObj.FramesPerTrigger);
        end

        treeView=com.mathworks.toolbox.imaq.browser.TreeViewPanel.getInstance();
        javaMethodEDT('setEnabled',treeView.getClearConfigAction(),true);
        javaMethodEDT('setEnabled',treeView.getExportHWConfigAction(),true);
    end

    function handleSelectCameraFileNodeSelected(node,theEvent)%#ok<INUSD,INUSD,DEFNU>

    end

    function handleFormatNodeAdded(node,theEvent)%#ok<INUSL>
        this.treeNodeListeners(end+1)=event.listener(theEvent.FormatNode,'formatNodeSelected',@handleFormatNodeSelected);
    end

    function handleFramesToAcquireChanged(obj,theEvent)
        this.handleFramesToAcquireChangedCallback(obj,theEvent);
    end

    function handleColorspaceChanged(obj,theEvent)
        this.handleColorspaceChangedCallback(obj,theEvent);
    end

    function handleSourceChanged(obj,theEvent)
        iatbrowser.Browser().messageBus.generateEvent('VideoinputPropertyChanged');
        this.handleSourceChangedCallback(obj,theEvent);
    end

    function handleLoggingModeChanged(obj,theEvent)
        this.handleLoggingModeChangedCallback(obj,theEvent);
    end

    function handleDiskParametersChanged(obj,theEvent)
        this.handleDiskParametersChangedCallback(obj,theEvent);
        browser=iatbrowser.Browser;
        browser.infoPanel.updateFormatNodeInfoDisplay;
    end

    function handleTriggerSourceChanged(obj,theEvent)
        this.handleTriggerSourceChangedCallback(obj,theEvent);
    end

    function handleTriggerConditionChanged(obj,theEvent)
        this.handleTriggerConditionChangedCallback(obj,theEvent);
    end

    function handleTriggerRepeatChanged(obj,theEvent)
        this.handleTriggerRepeatChangedCallback(obj,theEvent);
    end

    function handleFormatSelected(obj,theEvent)
        this.handleFormatSelectedCallback(obj,theEvent);
    end

    function handleSelectCameraFile(obj,theEvent)
        this.handleSelectCameraFileCallback(obj,theEvent)
    end

    function handleClearCurrentConfig(node,theEvent)%#ok<INUSD>
        browser=iatbrowser.Browser();

        if browser.prevPanelController.areFramesAvailableForExport()

            od=iatbrowser.OptionDialog();
            od.showOptionDialog(...
            iatbrowser.getDesktopFrame(),...
            'CLEAR_CONFIG_FRAMES_WILL_BE_LOST',...
            [],...
            @proceedToClearCurrentConfig,...
            []);
        else
            proceedToClearCurrentConfig();
        end
    end

    function proceedToClearCurrentConfig(callbackObj,eventData)%#ok<INUSD,INUSD>
        javaMethodEDT('enableGlassPane',iatbrowser.getDesktop(),true);
        browser=iatbrowser.Browser();
        browser.prevPanelController.clearFrames();
        if browser.prevPanelController.isPreviewing()
            browser.prevPanelController.stopPreview(false);
        end
        browser.treePanel.resetCurrentNode();
    end

end
