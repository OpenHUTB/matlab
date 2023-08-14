function performLicenseChecks(~)




    licenseFlag=builtin('license','checkout','phased_array_system_toolbox');
    if~licenseFlag
        error(message('phased:slintensitywebscopes:LicenseFailed','Doppler-Time Intensity Scope'));
    end
    return;