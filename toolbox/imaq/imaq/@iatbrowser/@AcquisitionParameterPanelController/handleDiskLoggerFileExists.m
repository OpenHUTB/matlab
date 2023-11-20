function diskLogger=handleDiskLoggerFileExists(this,filename,profileName)

    javaPeer=java(this.javaPeer);
    formatNodePanel=javaPeer.getFormatNodePanel();
    formatNodePanel.setMatlabUpdate(true);
    cleanup=onCleanup(@()formatNodePanel.setMatlabUpdate(false));

    browser=iatbrowser.Browser();
    vidObj=browser.currentVideoinputObject;

    dialog=iatbrowser.LogFilePresentDialog();
    choice=dialog.doDialog();

    switch(choice)
    case dialog.Cancel
        this.handleInvalidDiskLoggerFileName();
        diskLogger=[];
    case dialog.Overwrite
        if strcmp(profileName,this.videoWriterProfile)
            oldLogger=vidObj.DiskLogger;
        else
            oldLogger=[];
        end
        vidObj.DiskLogger=[];
        delete(filename);
        ed=iatbrowser.SessionLogEventData(vidObj,'delete(fullfile(diskLogger.Path, diskLogger.Filename));\n\n');
        iatbrowser.Browser().messageBus.generateEvent('SessionLogEvent',ed);

        diskLogger=iatbrowser.createDiskLogger(filename,profileName,oldLogger);
    end

end
