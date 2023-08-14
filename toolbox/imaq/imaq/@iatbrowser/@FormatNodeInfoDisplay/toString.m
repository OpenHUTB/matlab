function displayString=toString(this)






















    stringTemplate=...
    ['<html>'...
    ,'<h3>%s</h3>'...
    ,'<table>'...
    ,'<tr><td align="left">Device:</td><td>%s</td></tr>'...
    ,'<tr><td align="left">Resolution:</td><td>%dx%d</td></tr>'...
    ,'<tr><td align="left">Selected source:</td><td>%s</td></tr>'...
    ,'<tr><td align="left">Number of frames to acquire:</td><td>%d</td></tr>'...
    ,'%s'...
    ,'%s',...
'<tr><td align="left">Adaptor/Driver Description:</td><td>%s</td></tr>'...
    ,'<tr><td align="left">Adaptor/Driver Version:</td><td>%s</td></tr>'...
    ,'</table>'...
    ,'</html>'];

    formatNode=this.node;
    deviceNode=formatNode.Parent;

    vidObj=formatNode.VideoinputObject;

    curFormat=vidObj.VideoFormat;
    curDevice=deviceNode.DeviceName;
    curResolution=vidObj.VideoResolution;
    curSource=vidObj.SelectedSourceName;
    curNumFrames=vidObj.FramesPerTrigger*(vidObj.TriggerRepeat+1);
    curLogging=vidObj.LoggingMode;
    curLogging=strrep(curLogging,'&',' and ');

    loggingString=sprintf('<tr><td align="left">Logging mode:</td><td>%s</td></tr>',curLogging);


    indentingSpaces='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';





    needExtraAmp=true;

    if(~isempty(strfind(vidObj.LoggingMode,'disk'))&&~isempty(vidObj.DiskLogger))
        needExtraAmp=false;
        diskLogger=vidObj.DiskLogger;
        filename=fullfile(diskLogger.Path,diskLogger.Filename);

        formatString='%s\n<tr><td align="left">%s%s:</td><td>%s</td></tr>';
        loggingString=sprintf(formatString,loggingString,['&',indentingSpaces],'Filename',filename);
        loggingString=sprintf(formatString,loggingString,indentingSpaces,'Profile',iatbrowser.Browser().acqParamPanel.videoWriterProfile);

        propsToDisplay=fieldnames(set(diskLogger));
        for ii=1:length(propsToDisplay)
            loggingString=sprintf(formatString,loggingString,indentingSpaces,propsToDisplay{ii},mat2str(diskLogger.(propsToDisplay{ii})));
        end
    end

    triggerString=sprintf('<tr><td align="left">Trigger type:</td><td>%s</td></tr>',vidObj.TriggerType);
    if strcmpi(vidObj.TriggerType,'hardware')
        if needExtraAmp
            sourceSpaces=['&',indentingSpaces];
        else
            sourceSpaces=indentingSpaces;
        end
        triggerString=sprintf('%s\n<tr><td align="left">%sTrigger source:</td><td>%s</td></tr>',triggerString,sourceSpaces,vidObj.TriggerSource);
        triggerString=sprintf('%s\n<tr><td align="left">%sTrigger condition:</td><td>%s</td></tr>',triggerString,indentingSpaces,vidObj.TriggerCondition);
    end

    hwinfo=imaqhwinfo(vidObj);
    vendorDriverDescription=hwinfo.VendorDriverDescription;
    vendorDriverVersion=hwinfo.VendorDriverVersion;

    displayString=sprintf(stringTemplate,curFormat,...
    curDevice,...
    curResolution(1),...
    curResolution(2),...
    curSource,...
    curNumFrames,...
    loggingString,...
    triggerString,...
    vendorDriverDescription,...
    vendorDriverVersion);

end