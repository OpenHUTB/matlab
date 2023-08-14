function packageInfo=getPackageDisplayInfo(spPkgList,webSpPkgList,instSpPkgList,installerWorkflow)















    if~exist('installerWorkflow','var')
        installerWorkflow=hwconnectinstaller.internal.InstallerWorkflow.InstallFromInternet;
    end
    xlateEnt=struct(...
    'Install','',...
    'Download','',...
    'Uninstall','',...
    'Update','',...
    'Reinstall','',...
    'None','',...
    'NewFeatures','',...
    'FirstVersion','');
    xlateEnt=hwconnectinstaller.internal.getXlateEntries('hwconnectinstaller','setup','SelectPackage',xlateEnt);


    packageInfo=struct(...
    'Name',{},...
    'InstalledVersion',{},...
    'LatestVersion',{},...
    'Url',{},...
    'InfoText',{},...
    'InfoUrl',{},...
    'BaseCode',{},...
    'LicenseUrl',{},...
    'Platform',{},...
    'Action',{},...
    'SupportCategory',{},...
    'BaseProduct',{},...
    'AllowDownloadWithoutInstall',{},...
    'PackageIsSelectable',{},...
    'TpPkgInfo',{});
    currPlatform=computer;

    j=1;
    pkgNameList={};

    for i=1:length(spPkgList)
        spWeb=hwconnectinstaller.PackageInstaller.getSpPkgObject(spPkgList(i).Name,webSpPkgList);
        spInst=hwconnectinstaller.PackageInstaller.getSpPkgObject(spPkgList(i).Name,instSpPkgList);
        if ismember(spPkgList(i).Name,pkgNameList)||...
            (~isempty(spWeb)&&~spWeb.Visible)||...
            (~isempty(spInst)&&~spInst.Visible)


            continue;
        end
        pkgNameList{end+1}=spPkgList(i).Name;%#ok<AGROW>
        if isempty(spWeb)&&~isempty(spInst)


            packageInfo=createPackageInfo(spInst,packageInfo,j);
            packageInfo(j).InstalledVersion=spInst.Version;
            packageInfo(j).LatestVersion='';
            if~installerWorkflow.isUninstall
                packageInfo(j).Action=xlateEnt.None;
            else
                packageInfo(j).Action=xlateEnt.Uninstall;
            end

        elseif~isempty(spWeb)&&~isempty(spInst)

            packageInfo=createPackageInfo(spInst,packageInfo,j);
            packageInfo(j).InstalledVersion=spInst.Version;
            packageInfo(j).LatestVersion=spWeb.Version;

            if installerWorkflow.isUninstall
                packageInfo(j).Action=xlateEnt.Uninstall;
            elseif ismember(currPlatform,spWeb.Platform)
                if(spWeb>spInst)
                    packageInfo(j).Action=xlateEnt.Update;
                else
                    packageInfo(j).Action=xlateEnt.Reinstall;
                end
            else
                packageInfo(j).Action=xlateEnt.None;
            end
            tpPkgList=hwconnectinstaller.PackageInstaller.getTpPackages(webSpPkgList,spInst,installerWorkflow);
            packageInfo(j).TpPkgInfo=i_getTpPkgInfo(tpPkgList);
        else


            packageInfo=createPackageInfo(spWeb,packageInfo,j);
            packageInfo(j).InstalledVersion='';
            packageInfo(j).LatestVersion=spWeb.Version;
            if ismember(currPlatform,spWeb.Platform)
                packageInfo(j).Action=xlateEnt.Install;
            else
                packageInfo(j).Action=xlateEnt.None;
            end
            tpPkgList=hwconnectinstaller.PackageInstaller.getTpPackages(webSpPkgList,spWeb,installerWorkflow);
            packageInfo(j).TpPkgInfo=i_getTpPkgInfo(tpPkgList);
        end



        isSelectable=~isequal(packageInfo(j).Action,xlateEnt.None)&&...
        hwconnectinstaller.internal.isProductInstalled(packageInfo(j).BaseProduct);
        if installerWorkflow.isDownload
            packageInfo(j).PackageIsSelectable=...
            isSelectable&&packageInfo(j).AllowDownloadWithoutInstall;
        else
            packageInfo(j).PackageIsSelectable=...
            isSelectable;
        end

        j=j+1;
    end


    if~isempty(packageInfo)
        packageInfo=hwconnectinstaller.internal.sortPackageDisplayInfo(packageInfo);
    end

end






function tpPkgInfo=i_getTpPkgInfo(tpPkgList)


    tpPkgInfo=struct('Name',{},'Url',{},'LicenseUrl',{});
    for n=1:length(tpPkgList)
        tpPkgInfo(n)=...
        struct('Name',tpPkgList(n).Name,...
        'Url',tpPkgList(n).Url,...
        'LicenseUrl',tpPkgList(n).LicenseUrl);
    end
end

function spPackageInfo=createPackageInfo(spInfo,spPackageInfo,indx)


    spPackageInfo(indx).Name=spInfo.Name;
    spPackageInfo(indx).FullName=spInfo.FullName;
    spPackageInfo(indx).DisplayName=spInfo.DisplayName;
    spPackageInfo(indx).InfoText=spInfo.InfoText;
    spPackageInfo(indx).Url=spInfo.Url;
    spPackageInfo(indx).BaseCode=spInfo.BaseCode;
    spPackageInfo(indx).LicenseUrl=spInfo.LicenseUrl;
    spPackageInfo(indx).InfoUrl=spInfo.InfoUrl;
    spPackageInfo(indx).SupportCategory=spInfo.SupportCategory;
    spPackageInfo(indx).Platform=hwconnectinstaller.util.getPrettyPlatform(spInfo.PlatformStr);
    spPackageInfo(indx).BaseProduct=spInfo.BaseProduct;
    spPackageInfo(indx).AllowDownloadWithoutInstall=spInfo.AllowDownloadWithoutInstall;
    spPackageInfo(indx).CustomLicenseNotes=spInfo.CustomLicenseNotes;
    spPackageInfo(indx).ShowSPLicense=spInfo.ShowSPLicense;
end
