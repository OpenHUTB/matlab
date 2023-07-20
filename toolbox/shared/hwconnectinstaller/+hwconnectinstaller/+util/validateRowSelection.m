function isSelectionCorrect=validateRowSelection(pkgInfo,indxSelectedSpPkgs)











    validateattributes(pkgInfo,{'struct'},{'nonempty'},'validateRowSelection','pkgInfo');
    validateattributes(indxSelectedSpPkgs,{'double'},{'nonempty'},'validateRowSelection','indxSelectedSpPkgs');


    assert(all(indxSelectedSpPkgs<=numel(pkgInfo)),'Index for selected support package out of bounds');


    validMultiSelectActions={DAStudio.message('hwconnectinstaller:setup:SelectPackage_Install'),...
    DAStudio.message('hwconnectinstaller:setup:SelectPackage_Download'),...
    DAStudio.message('hwconnectinstaller:setup:SelectPackage_Uninstall')};


    isSelectionCorrect=true;

    action=pkgInfo(indxSelectedSpPkgs(1)).Action;
    allActions={pkgInfo(indxSelectedSpPkgs).Action};


    if length(indxSelectedSpPkgs)>1
        isSelectionCorrect=all(strcmp(action,allActions))&&ismember(action,validMultiSelectActions);
    end

