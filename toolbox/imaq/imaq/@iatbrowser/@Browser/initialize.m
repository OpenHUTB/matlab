function initialize(this,refreshingHardwareTree)









    this.messageBus=iatbrowser.MessageBus();

    this.isClosing=false;


    this.currentVideoinputObject=[];


    this.isRefreshingHardware=refreshingHardwareTree;

    desk=iatbrowser.getDesktop();



    closeCallback=handle(desk.getCloseCallback());
    this.closeListener=handle.listener(closeCallback,'delayed',@handleClose);


    this.treePanel=iatbrowser.HardwareTree;
    connect(this,this.treePanel,'down');


    this.infoPanel=iatbrowser.InfoPanelController(this.treePanel.rootNode);
    connect(this,this.infoPanel,'down');


    this.prevPanelController=iatbrowser.PreviewPanelController(this.treePanel.rootNode);
    connect(this,this.prevPanelController,'down');


    this.acqParamPanel=iatbrowser.AcquisitionParameterPanelController(this.treePanel.rootNode,this.prevPanelController);
    connect(this,this.acqParamPanel,'down');

    this.sessionLogPanelController=iatbrowser.SessionLogController(this);


    this.roiGUIElementsController=iatbrowser.ROIGUIElementsController(...
    this.prevPanelController.prevPanel.fig,this.prevPanelController.prevPanel.axis,...
    this.treePanel.rootNode);
    this.roiGUIElementsController.addPreviewPanelControllerUDDListeners(this.prevPanelController);
    addlistener(this.roiGUIElementsController,'EnteringROIMode',@handleEnteringROIMode);
    addlistener(this.roiGUIElementsController,'LeavingROIMode',@handleLeavingROIMode);

    this.treePanel.selectNode(this.treePanel.rootNode,true);



    supportCallback=handle(desk.getTechSupportCallback());
    this.supportListener=handle.listener(supportCallback,'delayed',@handleSupport);

    toolboxHelpCallback=handle(desk.getToolboxHelpCallback());
    this.toolboxHelpListener=handle.listener(toolboxHelpCallback,'delayed',...
    @(obj,event)helpview(fullfile(docroot,'toolbox','imaq','imaq.map'),'imaqtool_chapter'));

    desktopHelpCallback=handle(desk.getDesktopChapterCallback());
    this.desktopHelpListener=handle.listener(desktopHelpCallback,'delayed',@handleDesktopHelp);

    demosCallback=handle(desk.getDemosCallback());
    this.demosListener=handle.listener(demosCallback,'delayed',@handleDemos);

    reopenCallback=handle(desk.getReopenCallback());
    this.reopenListener=handle.listener(reopenCallback,'delayed',@handleReopen);

    refreshCallback=handle(desk.getRefreshCallback());
    this.refreshListener=handle.listener(refreshCallback,'delayed',@handleRefresh);

    imaqregisterCallback=handle(desk.getIMAQRegisterCallback());
    this.imaqregisterListener=handle.listener(imaqregisterCallback,'delayed',@handleIMAQRegister);

    function handleEnteringROIMode(obj,event)%#ok<INUSD,INUSD>
        this.prevPanelController.enteringROIMode();
    end

    function handleLeavingROIMode(obj,event)%#ok<INUSD,INUSD>
        this.prevPanelController.leavingROIMode();
    end

    function handleClose(obj,event)
        try
            drawnow;
            this.isClosing=true;

            if this.treePanel.abortNodeSelectionChange||~iatbrowser.isDiskLoggingConfigurationValid(this.currentVideoinputObject)
                od=iatbrowser.OptionDialog;
                od.showOptionDialog(...
                iatbrowser.getDesktopFrame(),...
                'INVALID_DISK_LOGGING_CONFIG',...
                event.JavaEvent,...
                @configureMemoryLogging,...
                @cancelClose);
            else
                checkForExport(obj,event);
            end
        catch

            proceedToClose(obj,event);
        end

        function configureMemoryLogging(callbackObj,eventdata)
            vidObj=this.currentVideoinputObject;
            vidObj.LoggingMode='memory';
            this.treePanel.abortNodeSelectionChange=false;
            checkForExport(callbackObj,eventdata);
        end

        function checkForExport(callbackObj,eventData)
            if this.prevPanelController.areFramesAvailableForExport

                od=iatbrowser.OptionDialog();
                od.showOptionDialog(...
                iatbrowser.getDesktopFrame(),...
                'CLOSE_FRAMES_WILL_BE_LOST',...
                eventData.JavaEvent,...
                @proceedToClose,...
                @cancelClose);
            else
                proceedToClose(callbackObj,eventData);
            end
        end

        function cancelClose(callbackObj,eventData)%#ok<INUSD>
            this.isClosing=false;
        end

        function proceedToClose(callbackObj,eventData)%#ok<INUSD,INUSD>

            glassPaneSentinel=iatbrowser.GlassPaneSentinel;
            desk=iatbrowser.getDesktop();
            desk.enableGlassPane(true);

            this.prevPanelController.clearFrames();
            if this.prevPanelController.isPreviewing()
                this.prevPanelController.stopPreview(false);
            end
            this.acqParamPanel.stopPropertyUpdateTimer();
            this.prevPanelController.destroy(true);
            this.prevPanelController=[];
            destroy(this.roiGUIElementsController);
            this.roiGUIElementsController=[];


            delete(glassPaneSentinel);

            desk.closeAfterCallback();
            this.isClosing=false;
        end
    end

    function handleReopen(obj,event)%#ok<INUSD>
        this.prevPanelController=iatbrowser.PreviewPanelController(this.treePanel.rootNode);
        connect(this,this.prevPanelController,'down');
        b=iatbrowser.Browser();
        this.roiGUIElementsController=iatbrowser.ROIGUIElementsController(...
        this.prevPanelController.prevPanel.fig,...
        this.prevPanelController.prevPanel.axis,...
        b.treePanel.rootNode);
        this.roiGUIElementsController.addPreviewPanelControllerUDDListeners(this.prevPanelController);


        hardwareTree=this.treePanel;
        currentNode=hardwareTree.currentNode;
        hardwareTree.currentNode=[];
        hardwareTree.abortNodeSelectionChange=false;
        hardwareTree.selectNode(currentNode,true);
    end

    function handleSupport(obj,event)%#ok<INUSD>
        glassPaneSentinel=iatbrowser.GlassPaneSentinel;%#ok<NASGU>
        desk=iatbrowser.getDesktop();
        desk.enableGlassPane(true);
        imaqsupport;
    end

    function handleDemos(obj,event)%#ok<INUSD>
        demo('toolbox','Image Acquisition');
    end

    function handleDesktopHelp(obj,event)%#ok<INUSD,INUSD>
        desk=iatbrowser.getDesktop();
        title=com.mathworks.toolbox.imaq.browser.StringResources.DESKTOP.getString('HelpPanel.title');
        desk.showClient(title);
    end

    function handleRefresh(obj,event)%#ok<INUSD,INUSD>
        this.handleRefresh();
    end

    function handleIMAQRegister(obj,event)
        this.handleIMAQRegister(obj,event);
    end
end
