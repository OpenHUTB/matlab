function startPreview(this,acqStarting)




    try
        this.prevPanel.startPreview(iatbrowser.Browser().currentVideoinputObject,acqStarting);
        previewStartingEventData=iatbrowser.PreviewStartingEventData(this,acqStarting);
        send(this,'PreviewStarting',previewStartingEventData);
    catch err
        this.prevPanel.fixWindowAfterFailureToPreviewOrStart();
        errorMsg=[iatbrowser.getResourceString('RES_DESKTOP',...
        'Preview.Failed.Message'),err.getReport('basic','hyperlinks','off')];
        md=iatbrowser.MessageDialog();
        md.showMessageDialogWithAdditionalMessage(...
        iatbrowser.getDesktopFrame(),...
        'START_PREVIEW_FAILED',...
        errorMsg,...
        [],...
        []);
    end

end