function[licenseText,licenseFile,dialogTitle]=getLicenseAndDialogTitle(supportPackage)




























































    validateattributes(supportPackage,{'hwconnectinstaller.SupportPackage'},{'nonempty','size',[1,1]})

    if strcmpi(supportPackage.CustomLicense,'yes')&&~isempty(supportPackage.CustomMWLicenseFiles)
        error(message('hwconnectinstaller:setup:CannotSpecityBothLicenseFields'));
    end


    if strcmpi(supportPackage.CustomLicense,'yes')
        licenseFile=hwconnectinstaller.util.getUSRPLicenseFile(supportPackage.CustomLicense);
        licenseText=fileread(licenseFile);
        [~,fileName]=fileparts(licenseFile);
        dialogTitle=getDialogTitle(fileName);
    else

        [licenseText,licenseFile,dialogTitle]=useCustomMWLicenseFilesOrDefault(supportPackage);
    end
end
function[licenseText,licenseFile,dialogTitle]=useCustomMWLicenseFilesOrDefault(supportPackage)
    isPrerelease=~isempty(strfind(hwconnectinstaller.util.getCurrentRelease,'Prerelease'));

    specifiedLicenses=strsplit(supportPackage.CustomMWLicenseFiles,',');
    specifiedLicenses(cellfun(@isempty,specifiedLicenses))=[];
    resourcesPath=fullfile(matlabroot,'toolbox','shared','hwconnectinstaller','resources');
    switch numel(specifiedLicenses)
    case 0

        if~isequal(supportPackage.CustomMWLicenseFiles,'')
            error(message('hwconnectinstaller:setup:Invalid_CustomMWLicenseFiles'));
        end

        if isPrerelease
            licenseFile=fullfile(resourcesPath,'prerelease_license.txt');
            licenseText=hwconnectinstaller.util.getMathWorksPrereleaseLicense;
        else
            licenseFile=fullfile(resourcesPath,'license.txt');
            licenseText=hwconnectinstaller.util.getMathWorksLicense;
        end
    case 2

        [licenseText,licenseFile]=readSpecifiedLicenseFile(resourcesPath,specifiedLicenses,isPrerelease);
    otherwise

        error(message('hwconnectinstaller:setup:Invalid_CustomMWLicenseFiles'));
    end
    [~,fName]=fileparts(licenseFile);
    dialogTitle=getDialogTitle(fName);

end



function dialogTitle=getDialogTitle(fileName)

    messageID=['hwconnectinstaller:license:',lower(fileName),'_title'];
    dialogTitle=message(messageID).getString;
end

function[licenseText,licenseFile]=readSpecifiedLicenseFile(resourcesPath,licenseFiles,isPrerelease)

    assert(numel(licenseFiles)==2,'Invalid number of license files specified to readSpecifiedLicenseFile');
    prLicenseFile=fullfile(resourcesPath,licenseFiles{1});
    grLicenseFile=fullfile(resourcesPath,licenseFiles{2});

    checkLicenseFileExists(prLicenseFile);
    checkLicenseFileExists(grLicenseFile);
    if isPrerelease
        licenseFile=prLicenseFile;
        licenseText=fileread(licenseFile);
    else
        licenseFile=grLicenseFile;
        licenseText=fileread(licenseFile);
    end
end

function checkLicenseFileExists(licenseFile)
    if~logical(exist(licenseFile,'file'));
        error(message('hwconnectinstaller:setup:NonExistentCustomMWLicenseFile',licenseFile));
    end
end
