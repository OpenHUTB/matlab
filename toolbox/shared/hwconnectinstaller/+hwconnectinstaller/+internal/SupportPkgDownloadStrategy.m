classdef SupportPkgDownloadStrategy



    properties(Constant)
        SUPPORTPACKAGE_DL_TIMEOUT_SECONDS=15;
    end


    methods(Abstract,Access=public)


        downloadSupportPackageFilesOverwrite(downloadDir,supportPackage)

        logNewDownloadUsageData(logger,supportPackage)
    end

end