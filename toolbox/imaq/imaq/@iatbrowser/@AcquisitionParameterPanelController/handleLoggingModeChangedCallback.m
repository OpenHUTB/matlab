function handleLoggingModeChangedCallback(this,~,event)







    vidObj=iatbrowser.Browser().currentVideoinputObject;


    loggingMode=char(event.JavaEvent);
    if strcmpi(vidObj.LoggingMode,loggingMode)
        return
    end


    set(vidObj,'LoggingMode',loggingMode);

    ed=iatbrowser.SessionLogEventData(vidObj,'vid.LoggingMode = ''%s'';\n\n',loggingMode);
    iatbrowser.Browser().messageBus.generateEvent('SessionLogEvent',ed);



    if strfind(lower(loggingMode),'disk')
        if isempty(vidObj.DiskLogger)
            status=iatbrowser.DiskParametersUpdatedEventData(false);
        else
            status=iatbrowser.DiskParametersUpdatedEventData(true);
        end

        iatbrowser.Browser().messageBus.generateEvent('DiskParametersUpdated',status);

        javaPeer=java(this.javaPeer);
        formatNodePanel=javaPeer.getFormatNodePanel();
        formatNodePanel.setFocusInFileNameField();
    else



        status=iatbrowser.DiskParametersUpdatedEventData(true);
        iatbrowser.Browser().messageBus.generateEvent('DiskParametersUpdated',status);
    end

end
