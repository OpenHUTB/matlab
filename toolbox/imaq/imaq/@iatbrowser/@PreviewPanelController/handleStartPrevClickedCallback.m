function handleStartPrevClickedCallback(this,obj,event)%#ok<INUSD,INUSD>





    if this.areFramesAvailableForExport
        od=iatbrowser.OptionDialog();
        od.showOptionDialog(...
        iatbrowser.getDesktopFrame(),...
        'START_PREVIEW_WILL_BE_LOST',...
        [],...
        @proceed,...
        []);
    else
        proceed();
    end

    function proceed(callbackObj,eventData)%#ok<INUSD,INUSD>
        prevPanelButtonPanel=java(this.prevPanel.prevPanelButtonPanel);
        prevPanelButtonPanel.setButtonsForPreviewStartOrStop(true);
        this.startPreview(false);
    end
end
