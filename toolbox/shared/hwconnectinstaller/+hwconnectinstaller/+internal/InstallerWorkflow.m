classdef InstallerWorkflow





    enumeration
        InstallFromInternet,DownloadFromInternet,InstallFromFolder,Uninstall;
    end

    methods(Access='public')
        function isInternet=isInternet(obj)
            isInternet=(hwconnectinstaller.internal.InstallerWorkflow.InstallFromInternet==obj);
        end
        function isDownload=isDownload(obj)
            isDownload=(hwconnectinstaller.internal.InstallerWorkflow.DownloadFromInternet==obj);
        end
        function isFolder=isFolder(obj)
            isFolder=(hwconnectinstaller.internal.InstallerWorkflow.InstallFromFolder==obj);
        end
        function isUninstall=isUninstall(obj)
            isUninstall=(hwconnectinstaller.internal.InstallerWorkflow.Uninstall==obj);
        end
    end

end

