function sprootFileDir=getSprootSettingFileLocation()




    overrideLocation=getenv('SUPPORTPACKAGE_INSTALLER_SPROOTFILE_LOCATION');
    if~isempty(overrideLocation)
        sprootFileDir=overrideLocation;
    else

        sprootFileDir=fullfile(matlabroot,'toolbox','local');
    end
end