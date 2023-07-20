function performLicenseChecks(~)




    licenseFlag=builtin('license','checkout','Signal_Blocks');
    if~licenseFlag
        error(message('dspshared:system:sigLicenseFailed'));
    end


