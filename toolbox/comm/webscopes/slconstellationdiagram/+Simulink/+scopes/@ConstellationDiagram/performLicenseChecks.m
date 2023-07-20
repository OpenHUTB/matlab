function performLicenseChecks(~)



    licenseFlag=builtin('license','checkout','communication_toolbox');
    if~licenseFlag
        error(message('comm:system:commLicenseFailed'));
    end
    return;