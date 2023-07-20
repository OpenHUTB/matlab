function format=getSupportPackageFormat()







    if isempty(getenv('SUPPORTPACKAGE_INSTALLER_ARCHIVE_FORMAT'))
        format='COMPONENTZIP';
    else
        format=getenv('SUPPORTPACKAGE_INSTALLER_ARCHIVE_FORMAT');
    end
