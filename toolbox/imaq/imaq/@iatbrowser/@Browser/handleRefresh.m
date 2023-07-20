function handleRefresh(this)






    if this.prevPanelController.areFramesAvailableForExport

        od=iatbrowser.OptionDialog();
        od.showOptionDialog(...
        iatbrowser.getDesktopFrame(),...
        'REFRESH_FRAMES_WILL_BE_LOST',...
        [],...
        @warnAboutConfigurations,...
        []);
    else
        warnAboutConfigurations();
    end

    function warnAboutConfigurations(callbackObj,eventData)%#ok<INUSD,INUSD>

        od=iatbrowser.OptionDialog();
        od.showOptionDialog(...
        iatbrowser.getDesktopFrame(),...
        'REFRESH_CONFIG_WILL_BE_LOST',...
        [],...
        @proceedWithRefresh,...
        []);
    end

    function proceedWithRefresh(callbackObj,eventData)%#ok<INUSD,INUSD>
        desk=iatbrowser.getDesktop();

        desk.enableGlassPane(true);

        this.treePanel.refreshing=true;
        this.isRefreshingHardware=true;

        if this.prevPanelController.isPreviewing()
            this.prevPanelController.stopPreview(false);
        end

        this.acqParamPanel.stopPropertyUpdateTimer();

        delete(imaqfind);
        imaqreset;

        this.treePanel.refreshing=false;
        this.isRefreshingHardware=false;

        desk.enableGlassPane(false);
        drawnow;
        md=iatbrowser.MessageDialog();
        md.showMessageDialog(...
        iatbrowser.getDesktopFrame(),...
        'REFRESH_COMPLETE',...
        [],...
        []);
    end
end

