function handleDiskParametersChangedCallback(this,~,event)








    warnState=warning('off','imaq:set:diskLogger:aviOnGT8bitFormat');
    oc=onCleanup(@()warning(warnState));

    glassPaneSentinel=iatbrowser.GlassPaneSentinel;%#ok<NASGU>

    browser=iatbrowser.Browser();

    if browser.isClosing
        return
    end


    filename=char(event.JavaEvent.filename);
    origfilename=filename;
    autoincrement=logical(event.JavaEvent.autoincrement);
    profile=char(event.JavaEvent.profile);
    invalidFilename=logical(event.JavaEvent.invalidFilename);




    vidObj=browser.currentVideoinputObject;



    origProfile=this.videoWriterProfile;

    if invalidFilename
        vidObj.DiskLogger=[];
    end


    if strcmpi(vidObj.LoggingMode,'memory')
        status=iatbrowser.DiskParametersUpdatedEventData(true);
        browser.messageBus.generateEvent('DiskParametersUpdated',status);
        return;
    end

    diskLogger=vidObj.DiskLogger;



    if isempty(filename)
        vidObj.DiskLogger=[];
        status=iatbrowser.DiskParametersUpdatedEventData(false);
        iatbrowser.Browser().messageBus.generateEvent('DiskParametersUpdated',status);
        return
    else
        [filename,fileExists]=iatbrowser.validateDiskLoggerFilename(filename,profile);
    end



    if(autoincrement&&~this.LogFileIndexIncrementProps.getAutoincrement(vidObj))
        [filePath,fileBase,fileExt]=fileparts(filename);
        fileBase=[fileBase,'_0001'];
        filename=fullfile(filePath,[fileBase,fileExt]);
        [filename,fileExists]=iatbrowser.validateDiskLoggerFilename(filename,profile);

        javaPeer=java(this.javaPeer);
        formatNodePanel=javaPeer.getFormatNodePanel();
        formatNodePanel.setInvalidFilenameSpecified(false);

        this.LogFileIndexIncrementProps.setHasIncremented(vidObj,false);
    elseif(~autoincrement&&...
        this.LogFileIndexIncrementProps.getAutoincrement(vidObj)&&...
        ~this.LogFileIndexIncrementProps.getHasIncremented(vidObj))
        [filename,fileExists]=iatbrowser.validateDiskLoggerFilename(strrep(filename,'_0001',''),profile);
    end

    this.LogFileIndexIncrementProps.setAutoincrement(vidObj,autoincrement);

    if isempty(diskLogger)

        if fileExists
            diskLogger=this.handleDiskLoggerFileExists(filename,profile);
        else
            diskLogger=iatbrowser.createDiskLogger(filename,profile,[]);
        end

        validateDiskLogger(diskLogger);
        return;
    end



    if(strcmp(filename,fullfile(diskLogger.Path,diskLogger.Filename))&&...
        strcmp(profile,this.videoWriterProfile))

        if~strcmp(filename,origfilename)
            this.updateLoggingPanel;
        end
        status=iatbrowser.DiskParametersUpdatedEventData(true);
        iatbrowser.Browser().messageBus.generateEvent('DiskParametersUpdated',status);
        return
    end

    if fileExists
        diskLogger=this.handleDiskLoggerFileExists(filename,profile);

        if isempty(diskLogger)
            status=iatbrowser.DiskParametersUpdatedEventData(false);
            iatbrowser.Browser().messageBus.generateEvent('DiskParametersUpdated',status);
            return;
        end
    else
        vidObj.DiskLogger=[];
        if strcmp(profile,origProfile)
            diskLogger=iatbrowser.createDiskLogger(filename,profile,diskLogger);
        else
            diskLogger=iatbrowser.createDiskLogger(filename,profile,[]);
        end
    end

    validateDiskLogger(diskLogger);

    if isempty(diskLogger)
        return;
    end


    if(strcmp(origfilename,fullfile(diskLogger.Path,diskLogger.Filename))&&...
        strcmp(profile,origProfile))
        return
    else
        this.updateLoggingPanel;
    end

    return;

    function validateDiskLogger(diskLogger)
        if isempty(diskLogger)
            this.handleInvalidDiskLoggerFileName();

            status=iatbrowser.DiskParametersUpdatedEventData(false);
            iatbrowser.Browser().messageBus.generateEvent('DiskParametersUpdated',status);
            return;
        end

        vidObj.DiskLogger=diskLogger;

        ed=iatbrowser.SessionLogEventData(vidObj,'vid.DiskLogger = diskLogger;\n\n');
        iatbrowser.Browser().messageBus.generateEvent('SessionLogEvent',ed);

        this.updateLoggingPanel;
        if strcmp(diskLogger.VideoFormat,'Indexed')&&isempty(diskLogger.Colormap)
            status=iatbrowser.DiskParametersUpdatedEventData(false);
            iatbrowser.Browser().messageBus.generateEvent('DiskParametersUpdated',status);
        else
            status=iatbrowser.DiskParametersUpdatedEventData(true);
            iatbrowser.Browser().messageBus.generateEvent('DiskParametersUpdated',status);
        end
    end
end
