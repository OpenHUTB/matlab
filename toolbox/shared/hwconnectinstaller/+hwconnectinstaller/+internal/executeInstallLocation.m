function completeOverride=executeInstallLocation(filterCriteria,hStep,command,varargin)



    completeOverride=false;
    switch(command)
    case 'initialize',
        if(isempty(hStep.StepData))
            xlateEnt=struct(...
            'Leader','',...
            'Internet','',...
            'Folder','',...
            'Download','',...
            'Uninstall','',...
            'Info','',...
            'Browse','',...
            'BrowseInfo','',...
            'Progress','',...
            'Connect','',...
            'Scan','');
            xlateEnt=hwconnectinstaller.internal.getXlateEntries('hwconnectinstaller','setup','Install',xlateEnt);
            hStep.StepData.Labels=xlateEnt;
            xlateTipEnt=struct(...
            'Choice','',...
            'Folder','',...
            'Browse','');
            xlateTipEnt=hwconnectinstaller.internal.getXlateEntries('hwconnectinstaller','setup','InstallTip',xlateTipEnt);
            hStep.StepData.ToolTip=xlateTipEnt;
            hStep.StepData.Choice=0;
            hStep.StepData.Folder=hStep.getSetup.getInstaller().getDefaultDownloadDir();
        end

    case 'callback',
        completeOverride=true;
        assert(~isempty(hStep.StepData));
        switch(varargin{1})
        case 'Choice',
            hStep.StepData.Choice=varargin{3};
        case 'Help',
            hwconnectinstaller.helpView('installorupdatetarget');
        case 'Browse',
            hDlg=varargin{3};
            folderLoc=hDlg.getWidgetValue(varargin{4});
            userpick=uigetdir(folderLoc,hStep.StepData.Labels.BrowseInfo);

            if(ischar(userpick)&&(exist(userpick,'dir')==7))
                hStep.StepData.Folder=userpick;

                hDlg.setWidgetValue(varargin{4},hStep.StepData.Folder);
            end
        case 'HardwareConfigure',
            launchTargetupdater(hStep);
        otherwise,
            completeOverride=false;
        end
    case 'next'
        hSetup=hStep.getSetup();
        hwconnectinstaller.internal.inform('Got the install choice: ');
        switch hStep.StepData.Choice
        case hStep.StepData.ChoiceIndex.Choice_Internet
            hwconnectinstaller.internal.inform(hStep.StepData.Labels.Internet);
            hSetup.InstallerWorkflow=...
            hwconnectinstaller.internal.InstallerWorkflow.InstallFromInternet;
        case hStep.StepData.ChoiceIndex.Choice_Download
            hwconnectinstaller.internal.inform(hStep.StepData.Labels.Download);
            hSetup.InstallerWorkflow=...
            hwconnectinstaller.internal.InstallerWorkflow.DownloadFromInternet;
        case hStep.StepData.ChoiceIndex.Choice_Folder

            dlg=DAStudio.ToolRoot.getOpenDialogs;
            spiDlg=dlg.find('dialogTag','support_package_installer');
            folder=spiDlg.getWidgetValue('Install_Step_Folder');
            hStep.StepData.Folder=hwconnectinstaller.util.resolveTildeChars(strtrim(folder));
            hwconnectinstaller.internal.inform(hStep.StepData.Labels.Folder);
            hwconnectinstaller.internal.inform(hStep.StepData.Folder);
            hSetup.InstallerWorkflow=...
            hwconnectinstaller.internal.InstallerWorkflow.InstallFromFolder;
            if(exist(hStep.StepData.Folder,'dir')~=7)
                error(message(hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:DirectoryDoesNotExist'),hStep.StepData.Folder));
            end
        otherwise
            hwconnectinstaller.internal.inform(hStep.StepData.Labels.Uninstall);
            hSetup.InstallerWorkflow=...
            hwconnectinstaller.internal.InstallerWorkflow.Uninstall;
        end





        hSetup.MWALogin.initiateLoginCheck();


        hSetup.showProgressBar(hStep.StepData.Labels.Progress,...
        hStep.StepData.Labels.Connect,-1);
        c=onCleanup(@()hSetup.closeProgressBar());


        hInstaller=hSetup.getInstaller();
        hSetup.setProgressBarValue(hStep.StepData.Labels.Scan,-1);
        if~(hStep.StepData.Choice==hStep.StepData.ChoiceIndex.Choice_Uninstall)
            if(hStep.StepData.Choice==hStep.StepData.ChoiceIndex.Choice_Internet)||...
                (hStep.StepData.Choice==hStep.StepData.ChoiceIndex.Choice_Download)
                hSetup.DownloadDir='';
                hSetup.WebSpPkg=hInstaller.getPackageListFromWeb();



                if isempty(hSetup.WebSpPkg)
                    error(message(hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:Install_NoPkgFound_OnWeb')));
                end
            elseif hStep.StepData.Choice==hStep.StepData.ChoiceIndex.Choice_Folder
                hSetup.DownloadDir=hStep.StepData.Folder;
                archivehandler=hwconnectinstaller.ArchiveHandler.getInstance();
                hSetup.WebSpPkg=archivehandler.getPkgListFromFolder(hSetup.DownloadDir);


                if isempty(hSetup.WebSpPkg)
                    archivehandler.diagnoseInstallFromFolder(hStep.StepData.Folder)
                end
            end
            if hStep.StepData.Choice~=hStep.StepData.ChoiceIndex.Choice_Download
                hSetup.setProgressBarValue(hStep.StepData.Labels.Scan,0.7);
            end
            if isempty(hSetup.InstSpPkg)
                hSetup.InstSpPkg=hInstaller.getInstalledPackages(false);
            end


            if hStep.StepData.Choice~=hStep.StepData.ChoiceIndex.Choice_Download
                hSetup.setProgressBarValue(hStep.StepData.Labels.Scan,0.8);
            end

            hSetup.FilteredSpPkg=hwconnectinstaller.internal.filterSpPkgList(hSetup.WebSpPkg,filterCriteria);
            if~isempty(hSetup.InstSpPkg)
                hSetup.InstSpPkg=hwconnectinstaller.internal.filterSpPkgList(hSetup.InstSpPkg,filterCriteria);
            end

            if isempty(hSetup.FilteredSpPkg)
                if hStep.StepData.Choice==hStep.StepData.ChoiceIndex.Choice_Folder
                    error(message(hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:Install_NoFilteredPkgFound_SupportCategory')));
                else
                    error(message(hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:Install_NoFilteredPkgFound')));
                end
            end



            if hStep.StepData.Choice==hStep.StepData.ChoiceIndex.Choice_Folder
                hSetup.PackageInfo=hwconnectinstaller.internal.getPackageDisplayInfo(...
                hSetup.FilteredSpPkg,...
                hSetup.WebSpPkg,...
                hSetup.InstSpPkg,hSetup.InstallerWorkflow);
                if isempty(hSetup.PackageInfo)
                    error(message('hwconnectinstaller:setup:Install_PkgMissing'));
                end
            else
                hSetup.PackageInfo=hwconnectinstaller.internal.getPackageDisplayInfo(...
                [hSetup.FilteredSpPkg,hSetup.InstSpPkg],...
                hSetup.WebSpPkg,...
                hSetup.InstSpPkg,hSetup.InstallerWorkflow);
            end

            if hSetup.InstallerWorkflow.isDownload
                for i=1:length(hSetup.PackageInfo)
                    hSetup.PackageInfo(i).Action=DAStudio.message(hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:SelectPackage_Download'));
                end
            end
        else


            if hSetup.canAccessInternet


                hSetup.WebSpPkg=hInstaller.getPackageListFromWeb();
            end

            hSetup.InstSpPkg=hInstaller.getInstalledPackages(false);
            if isempty(hSetup.InstSpPkg)
                error(message(hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:Install_NoInstalledPkgFound')));
            end
            hSetup.FilteredSpPkg=hwconnectinstaller.internal.filterSpPkgList(hSetup.InstSpPkg,filterCriteria);
            if isempty(hSetup.FilteredSpPkg)
                error(message(hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:Install_NoFilteredPkgFound')));
            end

            packageInfo=hwconnectinstaller.internal.getPackageDisplayInfo(...
            hSetup.FilteredSpPkg,...
            hSetup.WebSpPkg,...
            hSetup.InstSpPkg,hSetup.InstallerWorkflow);

            if isempty(packageInfo)







                installDirs={};
                for k=1:numel(hSetup.FilteredSpPkg)
                    installDirs{k}=hSetup.FilteredSpPkg(k).InstallDir;%#ok<AGROW>
                end
                installDirList=strjoin(unique(installDirs),'\n');
                error(message(hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:Install_CorruptedConfiguration'),installDirList));
            else
                hSetup.PackageInfo=packageInfo;
            end

        end

        assert(~isempty(hSetup.PackageInfo),'Unable to find all the required files for Support Package Installation');

        if hStep.StepData.Choice~=hStep.StepData.ChoiceIndex.Choice_Download
            hSetup.setProgressBarValue(hStep.StepData.Labels.Scan,0.95);
        end

        hSetup.SelectedHardware=-1;
    end
end

function launchTargetupdater(hStep)









    hwconnectinstaller.util.registerInstalledMessageCatalogs();

    hSetup=hwconnectinstaller.Setup.get;

    assert(isequal(hSetup.Steps.Children(1),hSetup.CurrentStep),'Support Package Installer not on the "Select an Action" screen');
    assert(~isempty(hSetup.Steps.Children(2)),'No Steps present for configuring hardware');

    hSetup.next(hStep,'');
end

