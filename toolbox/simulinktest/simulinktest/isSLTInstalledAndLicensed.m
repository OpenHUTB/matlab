function[value,msg]=isSLTInstalledAndLicensed(~)
    value=Simulink.harness.internal.isInstalled()&&Simulink.harness.internal.licenseTest();
    msg='';
end
