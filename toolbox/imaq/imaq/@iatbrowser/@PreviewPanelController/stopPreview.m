function stopPreview(this,clearWindow)





    this.prevPanel.stopPreview(iatbrowser.Browser().currentVideoinputObject,clearWindow);
    send(this,'PreviewStopping',[]);
end