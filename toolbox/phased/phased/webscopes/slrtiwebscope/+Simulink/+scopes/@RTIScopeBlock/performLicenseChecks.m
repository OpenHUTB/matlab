function performLicenseChecks(~)




    licenseFlag=builtin('license','checkout','phased_array_system_toolbox');
    if~licenseFlag
        error(message('phased:slintensitywebscopes:LicenseFailed','Range-Time Intensity Scope'));
    end
    return;