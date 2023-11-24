function destroy(this)

    this.messageBus=[];

    this.treePanel.destroy(true);
    this.treePanel=[];

    this.infoPanel.destroy(true);
    this.infoPanel=[];

    this.acqParamPanel.destroy(true);
    this.acqParamPanel=[];

    this.sessionLogPanelController.destroy(true);
    this.sessionLogPanelController=[];

    if~isempty(this.prevPanelController)
        this.prevPanelController.destroy(true);
        this.prevPanelController=[];
    end

    if~isempty(this.roiGUIElementsController)
        destroy(this.roiGUIElementsController);
        this.roiGUIElementsController=[];
    end

    this.closeListener=[];
    this.supportListener=[];
    this.toolboxHelpListener=[];
    this.desktopHelpListener=[];
    this.demosListener=[];
    this.reopenListener=[];
    this.refreshListener=[];

    mFiles=inmem;
    if ismember('iatbrowser.OptionDialog.OptionDialog',mFiles)
        dia=iatbrowser.OptionDialog;
        dia.destroy();
    end
    if ismember('iatbrowser.MessageDialog.MessageDialog',mFiles)
        dia=iatbrowser.MessageDialog;
        dia.destroy();
    end

    desk=com.mathworks.toolbox.imaq.browser.IATBrowserDesktop.getInstance();
    desk.destroy();

    munlock('Browser');
    clear('Browser');
    delete(this);