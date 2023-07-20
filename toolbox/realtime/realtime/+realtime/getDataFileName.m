function filePathName=getDataFileName(dataType,targetName)




    allTargetHardwares=realtime.internal.TargetHardware.getAllTargetHardwareInfosInRegistry;
    allTargetHardwareNames=allTargetHardwares.keys;
    for ii=1:allTargetHardwares.length
        targetHardwares=allTargetHardwares(allTargetHardwareNames{ii});
        if any(ismember(targetHardwares.keys,targetName))
            fName=[dataType,'Data',targetHardwares(targetName)];
            filePathName=['realtime.internal.',fName];
            break;
        end
    end
end