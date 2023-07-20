function licenseText=getCustomLicense(licenseField)









    validateattributes(licenseField,{'char'},{},'getCustomLicense','str');

    matchPattern=regexp(licenseField,'^@(?<fileName>[\w]+\.txt)','names');

    if isempty(matchPattern)
        licenseText=licenseField;
    else
        assert(isfield(matchPattern,'fileName'),'Cannot derive Custom License filename');
        licenseFile=fullfile(matlabroot,'toolbox','shared','hwconnectinstaller','resources',matchPattern.fileName);
        if~exist(licenseFile,'file')
            error(message('hwconnectinstaller:setup:CustomLicenseFileNotFound',licenseFile));
        else
            licenseText=fileread(licenseFile);
        end
    end
