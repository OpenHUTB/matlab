function incrementLogFileIndex(this)







    warnState=warning('off','imaq:set:diskLogger:aviOnGT8bitFormat');
    oc=onCleanup(@()warning(warnState));
    glassPaneSentinel=iatbrowser.GlassPaneSentinel;%#ok<NASGU>


    vidObj=iatbrowser.Browser().currentVideoinputObject;

    if(~this.LogFileIndexIncrementProps.getAutoincrement(vidObj))
        return
    end

    currentLogger=vidObj.DiskLogger;
    vidObj.DiskLogger=[];

    currentFilename=fullfile(currentLogger.Path,currentLogger.Filename);
    [filePath,fileName,fileExt]=fileparts(currentFilename);

    currentIndex=regexp(currentFilename,['_(\d+)\',fileExt,'$'],'tokens');

    if isempty(currentIndex)
        md=iatbrowser.MessageDialog();
        md.showMessageDialog(...
        iatbrowser.getDesktopFrame(),...
        'LOGFILE_INCREMENT_FAILED',...
        [],...
        @cleanup);
        return;
    end

    currentIndex=currentIndex{1}{1};

    indexWidth=length(currentIndex);


    formatString=sprintf('%%.%dd',indexWidth);
    newIndex=sprintf(formatString,str2double(currentIndex)+1);
    indexedFileName=regexprep(fileName,[currentIndex,'$'],newIndex);
    newFilename=fullfile(filePath,[indexedFileName,fileExt]);

    [newFilename,fileExists]=iatbrowser.validateDiskLoggerFilename(newFilename,this.videoWriterProfile);

    if fileExists
        newLogger=this.handleDiskLoggerFileExists(newFilename,this.videoWriterProfile);
    else
        newLogger=iatbrowser.createDiskLogger(newFilename,this.videoWriterProfile,currentLogger);
    end

    vidObj.Disklogger=newLogger;
    ed=iatbrowser.SessionLogEventData(vidObj,'vid.DiskLogger = diskLogger;\n\n');
    iatbrowser.Browser().messageBus.generateEvent('SessionLogEvent',ed);

    this.LogFileIndexIncrementProps.setHasIncremented(vidObj,true);

    this.updateLoggingPanel();

    function cleanup(~,~)
        this.LogFileIndexIncrementProps.setAutoincrement(vidObj,false);
        this.handleInvalidDiskLoggerFileName();
        status=iatbrowser.DiskParametersUpdatedEventData(false);
        iatbrowser.Browser().messageBus.generateEvent('DiskParametersUpdated',status);
    end

end

