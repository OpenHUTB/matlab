function runReplaceClones(cbinfo)




    try
        sysHandle=SLStudio.Utils.getModelName(cbinfo);
        cloneDetectionUI=get_param(sysHandle,'CloneDetectionUIObj');
        ddgBottomObj=cloneDetectionUI.ddgBottom;
        cloneDetectionUI.setRefactorButtonEnable(false);
        dlgRight=DAStudio.ToolRoot.getOpenDialogs(cloneDetectionUI.ddgRight);

        if~isempty(cloneDetectionUI.refactoredClonesLibFileName)
            libraryname=cloneDetectionUI.refactoredClonesLibFileName;
        else
            libraryname='newLibraryFile';
        end

        cloneReplacementConfig=Simulink.CloneDetection.ReplacementConfig(...
        libraryname);

        for ignoredClone=keys(cloneDetectionUI.m2mObj.excluded_sysclone)
            cloneReplacementConfig.addCloneToIgnoreList(ignoredClone);
        end

        cloneDetectionUI.ddgRight.blockdiffHtml='';

        replaceResults=Simulink.CloneDetection.replaceClones(...
        cloneDetectionUI.CloneResults,cloneReplacementConfig);
        cloneDetectionUI.ReplaceResults=replaceResults;

        cloneDetectionUIUpdated=get_param(sysHandle,'CloneDetectionUIObj');

        cloneDetectionUI.m2mObj.genmodelprefix=cloneDetectionUIUpdated.m2mObj.genmodelprefix;
        cloneDetectionUI.m2mObj.excluded_sysclone=cloneDetectionUIUpdated.m2mObj.excluded_sysclone;
        cloneDetectionUI.m2mObj.cloneresult=cloneDetectionUIUpdated.m2mObj.cloneresult;
        cloneDetectionUI.blockPathCategoryMap=cloneDetectionUIUpdated.blockPathCategoryMap;
        if isprop(cloneDetectionUIUpdated.m2mObj,'inputLibName')&&...
            isprop(cloneDetectionUI.m2mObj,'inputLibName')
            cloneDetectionUI.m2mObj.inputLibName=cloneDetectionUIUpdated.m2mObj.inputLibName;
        end

        cloneDetectionUI.m2mObj.libname=cloneDetectionUIUpdated.m2mObj.libname;

        ddgBottomObj.status='success';
        backupModelName=slEnginePir.util.getBackupModelName(cloneDetectionUIUpdated.m2mObj.genmodelprefix,...
        cloneDetectionUI.m2mObj.mdlName);
        ddgBottomObj.result=DAStudio.message('sl_pir_cpp:creator:RefactorMessage',...
        backupModelName,cloneDetectionUI.m2mObj.mdlName);
        CloneDetectionUI.internal.util.hiliteAllClones(true,...
        length(cloneDetectionUI.m2mObj.cloneresult.similar),...
        cloneDetectionUI.blockPathCategoryMap,cloneDetectionUI.colorCodes);
        cloneDetectionUI.setCompareModelButtonEnable(true);
        dlgBottom=DAStudio.ToolRoot.getOpenDialogs(ddgBottomObj);

        updatedObj=cloneDetectionUI;
        save(cloneDetectionUI.objectFile,'updatedObj');
        set_param(sysHandle,'CloneDetectionUIObj',cloneDetectionUI);

        if~isempty(dlgBottom)
            dlgBottom.refresh;
        end

        if~isempty(dlgRight)
            dlgRight.refresh;
        end


        CloneDetectionUI.internal.util.removeAllHighlights;

        CloneDetectionUI.internal.util.hideEmbedded(cloneDetectionUI.ddgRight);

    catch exception
        ddgBottomObj.status='error';
        ddgBottomObj.result=exception.message;
        cloneDetectionUI.setCompareModelButtonEnable(false);
        dlgBottom=DAStudio.ToolRoot.getOpenDialogs(ddgBottomObj);
        cloneDetectionUIUpdated=get_param(sysHandle,'CloneDetectionUIObj');

        cloneDetectionUI.m2mObj.genmodelprefix=cloneDetectionUIUpdated.m2mObj.genmodelprefix;
        cloneDetectionUI.m2mObj.excluded_sysclone=cloneDetectionUIUpdated.m2mObj.excluded_sysclone;
        cloneDetectionUI.m2mObj.cloneresult=cloneDetectionUIUpdated.m2mObj.cloneresult;
        cloneDetectionUI.blockPathCategoryMap=cloneDetectionUIUpdated.blockPathCategoryMap;
        if isprop(cloneDetectionUIUpdated.m2mObj,'inputLibName')&&...
            isprop(cloneDetectionUI.m2mObj,'inputLibName')
            cloneDetectionUI.m2mObj.inputLibName=cloneDetectionUIUpdated.m2mObj.inputLibName;
        end

        cloneDetectionUI.m2mObj.libname=cloneDetectionUIUpdated.m2mObj.libname;
        save_system(cloneDetectionUI.m2mObj.libname,[],'SaveDirtyReferencedModels',true);
        close_system(cloneDetectionUI.m2mObj.libname,1,'SaveDirtyReferencedModels','on');
        updatedObj=cloneDetectionUI;
        save(cloneDetectionUI.objectFile,'updatedObj');
        set_param(sysHandle,'CloneDetectionUIObj',cloneDetectionUI);
        if~isempty(dlgBottom)
            dlgBottom.refresh;
        end
        if~isempty(dlgRight)
            dlgRight.refresh;
        end
    end
end


