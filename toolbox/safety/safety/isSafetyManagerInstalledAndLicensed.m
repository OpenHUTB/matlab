function[value,msg]=isSafetyManagerInstalledAndLicensed(~)
    [value,msg]=isSafetyAnalyzerInstalledAndLicensed();
    if~value
        return
    end

    value=slfeature('SafetyManager');
    msg='';
end
