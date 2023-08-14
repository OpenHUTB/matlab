function fixWindowAfterFailureToPreviewOrStart(this)







    set(this.statLabel,'String',...
    iatbrowser.getResourceString('RES_DESKTOP',...
    'PreviewPanel.waiting'));

    this.clearWindow('iatbrowser.FormatNode');
    this.hideRuntimeLabels();
    prevPanelButtonPanel=java(this.prevPanelButtonPanel);
    prevPanelButtonPanel.setButtonsForStart();

end

