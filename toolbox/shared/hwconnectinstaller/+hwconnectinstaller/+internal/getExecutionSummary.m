function[completeActions,incompleteActions]=getExecutionSummary(selectedPackages,tasksRemaining,downloadDir)
















    completeActions=struct('completedPkg',{},'pkgLocation',{},'completedAction',{});
    incompleteActions=struct('incompletePkg',{});



    selectedPackages_Names={selectedPackages.FullName};


    for i=1:numel(tasksRemaining)
        incompleteActions(i).incompletePkg=tasksRemaining(i).PackageInfo.FullName;
    end
    incompletePackages_Names={incompleteActions.incompletePkg};



    [~,completedItems]=setdiff(selectedPackages_Names,incompletePackages_Names);
    completedPackages=selectedPackages(completedItems);


    for i=1:numel(completedPackages)
        completeActions(i).completedPkg=completedPackages(i).FullName;
        completeActions(i).completedAction=completedPackages(i).Action;


        if strcmp(completedPackages(i).Action,DAStudio.message('hwconnectinstaller:setup:SelectPackage_Install'))||...
            strcmp(completedPackages(i).Action,DAStudio.message('hwconnectinstaller:setup:SelectPackage_Reinstall'))||...
            strcmp(completedPackages(i).Action,DAStudio.message('hwconnectinstaller:setup:SelectPackage_Update'))

            installedPkgInfo=hwconnectinstaller.internal.PackageInfo.getSpPkgInfo(completedPackages(i).Name);
            if isempty(installedPkgInfo)
                completeActions(i).pkgLocation='';
            else
                completeActions(i).pkgLocation=installedPkgInfo.RootDir;
            end
        elseif strcmp(completedPackages(i).Action,DAStudio.message('hwconnectinstaller:setup:SelectPackage_Download'))


            completeActions(i).pkgLocation=downloadDir;
        end
    end
