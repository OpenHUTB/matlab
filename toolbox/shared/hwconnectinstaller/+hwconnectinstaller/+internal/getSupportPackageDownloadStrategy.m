function strategy=getSupportPackageDownloadStrategy




    if~isempty(getenv('SUPPORTPACKAGE_INSTALLER_SSI_DOWNLOAD'))

        strategy=hwconnectinstaller.internal.LegacyDownloadStrategy;

    else

        strategy=hwconnectinstaller.internal.SSIDownloadStrategy;
    end