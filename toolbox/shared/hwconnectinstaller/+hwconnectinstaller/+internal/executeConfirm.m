function completeOverride=executeConfirm(hStep,command,varargin)





    options=struct('deferClearClasses',false);
    completeOverride=false;
    if~isempty(varargin)
        if isstruct(varargin{1})

            options=varargin{1};
        end
    end
    switch(command)
    case 'initialize',
    case 'initDisplay',
    case 'callback',
        completeOverride=true;
        switch(varargin{1})
        case 'Help',
            hwconnectinstaller.helpView('confirminstallation');
        otherwise,
            completeOverride=false;
        end
    case 'next',


        hSetup=hStep.getSetup();
        hInstaller=hSetup.getInstaller();


        hMWDownloadManager=hwconnectinstaller.util.download.MWDownloadManager.getInstance();


        hMWDownloadManager.setHandoffMethod(@hStep.next,{''});
        hMWDownloadManager.setCancelMethod(@cancelSPIAndResetDownloadManager,{hStep});
        hMWDownloadManager.setErrorMethod(@handleDownloadError,{hSetup,hStep});
        try

            if isempty(hSetup.ExecuteTaskItem)

                logger=hSetup.UsageLogger;
                logger.ComponentName='';
                if(hSetup.MWALogin.ResultIsValid&&hSetup.MWALogin.IsLoggedIn)
                    logger.sendLoginWhenEnabled(hSetup.MWALogin.UserName,hSetup.MWALogin.LoginToken);
                end
                logger.sendEventWhenEnabled('WORKFLOW_START',char(hSetup.InstallerWorkflow));
                logger.sendEventWhenEnabled('ENTRY_POINT',char(hSetup.SPIEntryPoint));
                logger.Enabled=true;
            end


            if hSetup.SkipInstall
                hwconnectinstaller.internal.inform(hStep.StepData.Labels.Skipping);
            else

                initPackageList(hSetup);

                packageListItem=hSetup.ExecuteTaskItem(1);
                if~isempty(packageListItem)
                    pkgInfo=packageListItem.PackageInfo;

                    hSetup.UsageLogger.ComponentName=pkgInfo.Name;

                    if exist(fullfile(hSetup.InstallDir,hwconnectinstaller.SupportPackage.getPkgTag(pkgInfo.Name),'dir'))==7
                        hwconnectinstaller.PackageInstaller.verifyInstallFolderIsEmpty(hSetup.InstallDir,hwconnectinstaller.SupportPackage.getPkgTag(pkgInfo.Name));
                    end
                    if isequal(pkgInfo.Action,...
                        DAStudio.message(hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:SelectPackage_Install')))

                        completeOverride=installWorkflow(hSetup,hInstaller,pkgInfo);

                    elseif isequal(pkgInfo.Action,...
                        DAStudio.message(hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:SelectPackage_Download')))

                        completeOverride=downloadWorkflow(hSetup,hInstaller,pkgInfo);

                    elseif isequal(pkgInfo.Action,...
                        DAStudio.message(hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:SelectPackage_Uninstall')))

                        options.deferClearClasses=true;
                        hInstaller.uninstallRecursive(pkgInfo.Name,true,true,...
                        options);
                    else


                        completeOverride=updateWorkflow(hSetup,hInstaller,pkgInfo,options);
                    end


                    if completeOverride==false
                        removeCompletedTask(hSetup);




                        if~isempty(hSetup.ExecuteTaskItem)



                            hMWDownloadManager.resetManager();
                            completeOverride=hwconnectinstaller.internal.executeConfirm(hStep,command,varargin);
                        else
                            hSetup.UsageLogger.sendEventWhenEnabled('WORKFLOW_COMPLETE',char(hSetup.InstallerWorkflow));

                            if options.deferClearClasses
                                doDeferredClearClasses();
                            end

                            if~hMWDownloadManager.isDownloading()
                                hMWDownloadManager.clearSessionSummary();
                                hMWDownloadManager.resetManager();
                            end

                        end
                    end


                end
            end
        catch exception
            hSetup.UsageLogger.sendEventWhenEnabled('ABORTED_WORKFLOW',exception.identifier);














            hMWDownloadManager.resetManager();
            showExecSummary(hSetup,hStep);


            hMWDownloadManager.clearSessionSummary();

            hSetup.ExecuteTaskItem=[];
            rethrow(exception);
        end

    end
end




function completeOverride=performThreadedDownload(downloadDir,hSetup,pkgInfo,options)


    hwconnectinstaller.internal.inform(sprintf('executeConfirm/performThreadedDownload: %s',pkgInfo.Name));
    completeOverride=false;

    hMWDownloadManager=hwconnectinstaller.util.download.MWDownloadManager.getInstance();

    if~exist('options','var')
        options=struct('progressBar',true,'customTpPkgsDownloadFcn',...
        @(info)hMWDownloadManager.addNewDownload(info.url,info.downloadFileName,info.friendlyName),...
        'archiveExistAction','dialog','skipInstalledPackages',false);
    end


    hInstaller=hSetup.getInstaller();





    hInstaller.downloadRecursive(pkgInfo.Name,...
    downloadDir,options);

    if(hMWDownloadManager.getNumDownloads()>0)
        hwconnectinstaller.internal.inform('executeConfirm/performThreadedDownload: Starting 3p downloads');
        hMWDownloadManager.setProgressBar(true);



        hSetup.ExecuteTaskItem(1).InstallOnReentry=true;
        hMWDownloadManager.startDownloads();
        completeOverride=true;
    else
        hwconnectinstaller.internal.inform('executeConfirm/performThreadedDownload: No 3p downloads - invoking installFromFolder');
        if isequal(pkgInfo.Action,DAStudio.message(hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:SelectPackage_Install')))||...
            isequal(pkgInfo.Action,DAStudio.message(hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:SelectPackage_Reinstall')))||...
            isequal(pkgInfo.Action,DAStudio.message(hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:SelectPackage_Update')))
            installFromFolder(hSetup,hInstaller,pkgInfo);
        end
    end
end


function completeOverride=installWorkflow(hSetup,hInstaller,pkgInfo)
    hwconnectinstaller.internal.inform(sprintf('executeConfirm/installWorkflow: %s',pkgInfo.Name));
    if~isempty(hSetup.DownloadDir)||hSetup.ExecuteTaskItem(1).InstallOnReentry







        completeOverride=installFromFolder(hSetup,hInstaller,pkgInfo);
    else




        completeOverride=installFromInternet(hSetup,hInstaller,pkgInfo);
    end
end


function completeOverride=downloadWorkflow(hSetup,hInstaller,pkgInfo)
    hwconnectinstaller.internal.inform(sprintf('executeConfirm/downloadWorkflow: %s',pkgInfo.Name));
    completeOverride=false;
    if(hInstaller.ThreadedDownloadEnabled)

        hMWDownloadManager=hwconnectinstaller.util.download.MWDownloadManager.getInstance();
        if isequal(hMWDownloadManager.getDownloadStatus,hMWDownloadManager.NOT_STARTED)
            completeOverride=performThreadedDownload(hSetup.ExecuteTaskItem(1).DownloadDir,hSetup,pkgInfo);
        end

    else

        hInstaller.downloadRecursive(pkgInfo.Name,hSetup.DownloadDir);
    end

end


function completeOverride=updateWorkflow(hSetup,hInstaller,pkgInfo,options)
    if hSetup.ExecuteTaskItem(1).InstallOnReentry
        hwconnectinstaller.internal.inform(sprintf('executeConfirm/updateWorkflow (installOnReentry): %s',pkgInfo.Name));


        completeOverride=installFromFolder(hSetup,hInstaller,pkgInfo);


        if(options.deferClearClasses)&&isequal(numel(hSetup.ExecuteTaskItem),1)

            doDeferredClearClasses();


            completeOverride=false;
        end
    else
        hwconnectinstaller.internal.inform(sprintf('executeConfirm/updateWorkflow (uninstall): %s',pkgInfo.Name));



        options=struct('uninstallErrorAction','continue','cleanExeServer',1,'deferClearClasses',true,...
        'implicitUninstallVisiblePkgs',true);
        hInstaller.uninstallRecursive(pkgInfo.Name,true,true,...
        options);



        hMWDownloadManager=hwconnectinstaller.util.download.MWDownloadManager.getInstance();
        hStep=hSetup.CurrentStep;
        hMWDownloadManager.setHandoffMethod(@hStep.next,{options});

        completeOverride=installWorkflow(hSetup,hInstaller,pkgInfo);
        if~hSetup.ExecuteTaskItem(1).InstallOnReentry&&isequal(numel(hSetup.ExecuteTaskItem),1)

            doDeferredClearClasses();


            completeOverride=false;
        end
    end
end


function completeOverride=installFromFolder(hSetup,hInstaller,pkgInfo)
    hwconnectinstaller.internal.inform(sprintf('executeConfirm/installFromFolder: %s',pkgInfo.Name));
    hInstaller.installRecursive(pkgInfo.Name,...
    hSetup.ExecuteTaskItem(1).DownloadDir,hSetup.ExecuteTaskItem(1).InstallDir,true);
    completeOverride=false;
end


function completeOverride=installFromInternet(hSetup,hInstaller,pkgInfo)
    hwconnectinstaller.internal.inform(sprintf('executeConfirm/installFromInternet: %s',pkgInfo.Name));
    completeOverride=false;
    if(hInstaller.ThreadedDownloadEnabled)


        spPkg=hInstaller.getSpPkgObject(pkgInfo.Name,hSetup.WebSpPkg);
        spPkgDownloadDir=hInstaller.createDownloadDirForInstall(hSetup.ExecuteTaskItem(1).InstallDir,hwconnectinstaller.SupportPackage.getPkgTag(spPkg.Name));



        hSetup.ExecuteTaskItem(1).DownloadDir=spPkgDownloadDir;
        hMWDownloadManager=hwconnectinstaller.util.download.MWDownloadManager.getInstance();
        options=struct('progressBar',true,'customTpPkgsDownloadFcn',...
        @(info)hMWDownloadManager.addNewDownload(info.url,info.downloadFileName,info.friendlyName),...
        'archiveExistAction','overwrite','skipInstalledPackages',true);
        completeOverride=performThreadedDownload(fileparts(spPkgDownloadDir),hSetup,pkgInfo,options);
    else

        hInstaller.installRecursive(pkgInfo.Name,...
        hSetup.DownloadDir,hSetup.InstallDir,true);
    end
end

function initPackageList(hSetup)





    if isempty(hSetup.ExecuteTaskItem)
        for i=1:numel(hSetup.SelectedPackage)
            if((hSetup.SelectedPackage(i)>=1)&&(hSetup.SelectedPackage(i)<=numel(hSetup.PackageInfo)))
                packageListItem.PackageInfo=hSetup.PackageInfo(hSetup.SelectedPackage(i));
                packageListItem.DownloadDir=hSetup.DownloadDir;
                packageListItem.InstallDir=hSetup.InstallDir;
                packageListItem.InstallOnReentry=false;
                hSetup.ExecuteTaskItem=[hSetup.ExecuteTaskItem,packageListItem];
            else
                error(message(hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:NoSupportPackageSelection')));
            end
        end
    end
end

function removeCompletedTask(hSetup)

    hSetup.ExecuteTaskItem=hSetup.ExecuteTaskItem(2:end);

end

function doDeferredClearClasses()
    warning('off','MATLAB:ClassInstanceExists');
    warning('off','MATLAB:objectStillExists');
    clear classes;
    warning('on','MATLAB:ClassInstanceExists');
    warning('on','MATLAB:objectStillExists');
end

function cancelSPIAndResetDownloadManager(hStep)






    hStep.cancel('');




    hwconnectinstaller.util.download.MWDownloadManager.reset();
end

function handleDownloadError(hSetup,hStep)





    hSetup.UsageLogger.sendEventWhenEnabled('ABORTED_WORKFLOW','ThirdPartyDownloadError');
    showExecSummary(hSetup,hStep);


    hMWDownloadManager=hwconnectinstaller.util.download.MWDownloadManager.getInstance();
    hMWDownloadManager.clearSessionSummary();
    hSetup.ExecuteTaskItem=[];
    hStep.cancel('');
end

function showExecSummary(hSetup,hStep)




    [pkgsDone,pkgsIncomplete]=hwconnectinstaller.internal.getExecutionSummary(hSetup.PackageInfo(hSetup.SelectedPackage),hSetup.ExecuteTaskItem,...
    hSetup.DownloadDir);







    if~isempty(pkgsDone)&&~isempty(pkgsIncomplete)

        completedPkgNames={pkgsDone.completedPkg};

        completedPkgsList=sprintf(' - %s\n',completedPkgNames{:});

        incompletePkgNames={pkgsIncomplete.incompletePkg};

        incompletePkgList=sprintf(' - %s\n',incompletePkgNames{:});



        switch(pkgsDone(1).completedAction)
        case DAStudio.message(hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:SelectPackage_Download'))
            id=hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:SummaryText_Download');
        case DAStudio.message(hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:SelectPackage_Install'))
            id=hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:SummaryText_Install');
        case DAStudio.message(hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:SelectPackage_Reinstall'))
            id=hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:SummaryText_Reinstall');
        case DAStudio.message(hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:SelectPackage_Uninstall'))
            id=hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:SummaryText_Uninstall');
        case DAStudio.message(hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:SelectPackage_Update'))
            id=hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:SummaryText_Update');
        otherwise
            assert(false,'Completed action does not match any known action ID');
        end

        msg=message(id,...
        completedPkgsList,...
        incompletePkgList);

        exception=MException('hwconnectinstaller:executeConfirm',msg.getString);

        hStep.showError(exception);
    end

end
