function handleStopAcqClickedCallback(this,~,~)






    desk=iatbrowser.getDesktop();
    desk.enableGlassPane(true);
    drawnow;

    try
        this.stopping=true;
        stop(iatbrowser.Browser().currentVideoinputObject);

        ed=iatbrowser.SessionLogEventData(iatbrowser.Browser().currentVideoinputObject,...
        'stop(vid);\n\n');
        iatbrowser.Browser().messageBus.generateEvent('SessionLogEvent',ed);

    catch err
        desk.enableGlassPane(false);

        errorMsg=[imaqgate('privateGetJavaResourceString',...
        'com.mathworks.toolbox.imaq.browser.resources.RES_DESKTOP',...
        'StopAcq.Failed.Message'),err.getReport('basic','hyperlinks','off')];

        md=iatbrowser.MessageDialog();
        md.showMessageDialogWithAdditionalMessage(...
        iatbrowser.getDesktopFrame(),...
        'STOP_ACQUISITION_FAILED',...
        errorMsg,...
        [],...
        []);
    end





end
