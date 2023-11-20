function updateLoggingPanel(this)

    javaPeer=java(this.javaPeer);
    formatNodePanel=javaPeer.getFormatNodePanel();

    vidObj=iatbrowser.Browser().currentVideoinputObject;

    loggingMode=vidObj.LoggingMode;

    logToDisk=false;
    logToMemory=false;

    if strcmp('memory',loggingMode)
        logToMemory=true;
    elseif strcmp('disk',loggingMode)
        logToDisk=true;
    elseif strcmp('disk&memory',loggingMode)
        logToMemory=true;
        logToDisk=true;
    else
        error(message('imaq:imaqtool:loggingModeError'));
    end

    formatNodePanel.updateLoggingModes(logToMemory,logToDisk);
    diskLogger=vidObj.DiskLogger;
    colorspaceInfo=propinfo(vidObj,'ReturnedColorSpace');
    defaultColorspace=colorspaceInfo.DefaultValue;

    if isempty(diskLogger)
        filename='';
        if strcmp(defaultColorspace,'grayscale')
            profile='Grayscale AVI';
        else
            profile='Uncompressed AVI';
        end
        props=java.util.ArrayList();
    else
        filename=fullfile(diskLogger.Path,diskLogger.Filename);
        profile=this.videoWriterProfile;
        props=iatbrowser.convertVideoWriterPropertiesToList(diskLogger);
    end

    profiles=VideoWriter.getProfiles();
    availProfiles={profiles.Name};

    if~strcmp(defaultColorspace,'grayscale')
        availProfiles=setxor(availProfiles,{'Grayscale AVI','Indexed AVI'});
    end

    autoincrement=this.LogFileIndexIncrementProps.getAutoincrement(vidObj);

    formatNodePanel.updateDiskLoggingParameters(filename,...
    availProfiles,profile,autoincrement);

    formatNodePanel.setVideoWriterProperties(...
    iatbrowser.VideoWriterSetter(vidObj,vidObj.DiskLogger),...
    props);

    info=imaqhwinfo(vidObj);
    dataType=info.NativeDataType;

    if~isempty(diskLogger)&&...
        ~strcmp(dataType,'uint8')&&...
        ~(strcmp(profile,'Motion JPEG 2000')||strcmp(profile,'Archival'))
        formatNodePanel.showProfileWarning(true)
    else
        formatNodePanel.showProfileWarning(false)
    end
