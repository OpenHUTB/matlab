function[RTOSInfoObjs]=getSupportedRTOSInfoForHardwareName(hardwareInfo)






    RTOSInfoObjs={};

    if isempty(hardwareInfo)
        return
    end
    attributeInfo=loc_getAttributeForHardwareConfiguration(hardwareInfo);
    if isempty(attributeInfo)
        Tokens={};
    else
        Tokens=attributeInfo.Tokens;
    end
    for i=1:numel(hardwareInfo.RTOSInfoFiles)
        defFile=codertarget.utils.replaceTokensforHardwareName(hardwareInfo,hardwareInfo.RTOSInfoFiles{i},Tokens);
        rtosInfo=codertarget.Registry.manageInstance('get','rtos',defFile);
        RTOSInfoObjs{end+1}=rtosInfo;%#ok<AGROW>
    end
end




function out=loc_getAttributeForHardwareConfiguration(hwInfo)
    if isa(hwInfo,'codertarget.targethardware.ProcessorUnitInfo')
        out=codertarget.attributes.getProcessingUnitAttributes(hwInfo);
    else
        out=codertarget.attributes.getTargetHardwareAttributesForHardwareName(hwInfo);
    end
end