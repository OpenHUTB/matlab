function out=getCurrentPlatform()








    overridePlatform=getenv('SUPPORTPACKAGE_INSTALLER_PLATFORM');
    if~isempty(overridePlatform)
        out=overridePlatform;
    else
        out=computer;
    end
