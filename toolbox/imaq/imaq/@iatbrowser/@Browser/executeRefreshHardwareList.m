function executeRefreshHardwareList(this)

    glassPaneSentinel=iatbrowser.GlassPaneSentinel;%#ok<NASGU>
    desk=iatbrowser.getDesktop();
    desk.enableGlassPane(true);

    this.messageBus=[];

    this.prevPanelController.clearFrames;

    this.treePanel.destroy(false);
    this.treePanel=[];

    this.acqParamPanel.destroy(false);
    this.acqParamPanel=[];

    this.infoPanel.destroy(false);
    this.infoPanel=[];

    this.prevPanelController.destroy(true);
    this.prevPanelController=[];

    this.sessionLogPanelController.destroy(false);
    this.sessionLogPanelController=[];





    mainFrame=iatbrowser.getDesktopFrame();
    mainFrame.requestFocus();

    drawnow;

    this.initialize(true);

    desk.disableExport();
    this.isRefreshingHardware=false;

end
