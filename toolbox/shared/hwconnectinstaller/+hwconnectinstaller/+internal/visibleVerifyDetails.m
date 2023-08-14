function v=visibleVerifyDetails(hStep,varargin)




    hSetup=hStep.getSetup();



    if hSetup.SelectedPackage==-1
        v=1;
    else

        if(hSetup.InstallerWorkflow.isDownload||hSetup.InstallerWorkflow.isUninstall)
            v=0;
        else
            spPkgInfo=hSetup.PackageInfo(hSetup.SelectedPackage);
            v=0;
            for i=1:numel(spPkgInfo)
                if~isempty(spPkgInfo(i).TpPkgInfo)
                    v=1;
                    return;
                end
            end
        end
    end


