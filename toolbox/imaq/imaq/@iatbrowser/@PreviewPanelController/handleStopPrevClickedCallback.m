function handleStopPrevClickedCallback(this,obj,event)%#ok<INUSD,INUSD>






    set(this.prevPanel.statLabel,'String',...
    imaqgate('privateGetJavaResourceString',...
    'com.mathworks.toolbox.imaq.browser.resources.RES_DESKTOP',...
    'PreviewPanel.waiting'));

    this.stopPreview(true);
end