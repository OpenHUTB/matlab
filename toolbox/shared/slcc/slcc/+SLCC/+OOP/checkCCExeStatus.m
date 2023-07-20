function[settingsChecksum,fullChecksum,existingExePath,buildNeeded,hasInitTerm]=checkCCExeStatus(modelName)


    if(~ischar(modelName))
        modelName=get_param(modelName,'Name');
    end

    [settingsChecksum,~,fullChecksum,~,ccSettingInfo]=cgxeprivate('computeCCChecksumFromModel',modelName);

    if nargout<3
        return
    end

    expectedExeFullPath=SLCC.OOP.getCustomCodeExeExpectedFullPath(settingsChecksum,fullChecksum);


    if~isempty(ccSettingInfo.customCodeSettings.prebuiltCCDependency)
        assert(isfile(ccSettingInfo.customCodeSettings.prebuiltCCDependency.simExe),...
        'Custom code prebuilt executable must exist.');
        existingExePath=ccSettingInfo.customCodeSettings.prebuiltCCDependency.simExe;
        buildNeeded=false;
    elseif exist(expectedExeFullPath,'file')==2
        existingExePath=expectedExeFullPath;
        buildNeeded=false;
    else
        existingExePath='';
        buildNeeded=true;
    end


    customCodeSettings=CGXE.CustomCode.CustomCodeSettings.createFromModel(modelName);
    hasInitTerm=~isempty(strtrim(customCodeSettings.customInitializer))||...
    ~isempty(strtrim(customCodeSettings.customTerminator));


end
