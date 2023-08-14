function[value,msg]=isSafetyAnalyzerInstalledAndLicensed(~)
    value=slfeature('SysSafetyApp');
    msg='';
end
