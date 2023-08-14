function cloneDetectionUIObject=apiToGUIClonesDataAdapter(cloneDetectionUIObject,clonesDataObject)




    if isa(cloneDetectionUIObject,'CloneDetectionUI.CloneDetectionUI')
        cloneDetectionUIObject.model=clonesDataObject.model;
        cloneDetectionUIObject.systemFullName=clonesDataObject.systemFullName;
        cloneDetectionUIObject.m2mObj=clonesDataObject.m2mObj;
        cloneDetectionUIObject.isAcrossModel=clonesDataObject.isAcrossModel;
        cloneDetectionUIObject.listOfFolders=clonesDataObject.listOfFolders;
        cloneDetectionUIObject.libraryList=clonesDataObject.libraryList;
        cloneDetectionUIObject.excludeLibraries=clonesDataObject.excludeLibraries;
        cloneDetectionUIObject.excludeModelReferences=clonesDataObject.excludeModelReferences;
        cloneDetectionUIObject.excludeInactiveRegions=clonesDataObject.excludeInactiveRegions;
        cloneDetectionUIObject.excludeCloneDetection=clonesDataObject.excludeCloneDetection;
        cloneDetectionUIObject.parameterThreshold=clonesDataObject.parameterThreshold;
        cloneDetectionUIObject.parameterThreshold_old=clonesDataObject.parameterThreshold_old;
        cloneDetectionUIObject.enableClonesAnywhere=clonesDataObject.enableClonesAnywhere;
        cloneDetectionUIObject.defaultThreshold=clonesDataObject.defaultThreshold;
        cloneDetectionUIObject.refactorOptions=clonesDataObject.refactorOptions;
        cloneDetectionUIObject.cloneGroupSidListMap=clonesDataObject.cloneGroupSidListMap;
        cloneDetectionUIObject.backUpPath=clonesDataObject.backUpPath;
        cloneDetectionUIObject.historyVersions=clonesDataObject.historyVersions;
        cloneDetectionUIObject.backupModel=clonesDataObject.backupModel;
        cloneDetectionUIObject.objectFile=clonesDataObject.objectFile;
        cloneDetectionUIObject.blockPathCategoryMap=clonesDataObject.blockPathCategoryMap;

        cloneDetectionUIObject.refactoredClonesLibFileName=clonesDataObject.refactoredClonesLibFileName;
        cloneDetectionUIObject.cloneDetectionStatus=clonesDataObject.cloneDetectionStatus;
        cloneDetectionUIObject.metrics=clonesDataObject.metrics;
        cloneDetectionUIObject.totalBlocks=clonesDataObject.totalBlocks;
        cloneDetectionUIObject.ignoreSignalName=clonesDataObject.ignoreSignalName;
        cloneDetectionUIObject.ignoreBlockProperty=clonesDataObject.ignoreBlockProperty;
        cloneDetectionUIObject.isReplaceExactCloneWithSubsysRef=clonesDataObject.isReplaceExactCloneWithSubsysRef;
        cloneDetectionUIObject.CloneResults=clonesDataObject.CloneResults;
        cloneDetectionUIObject.ReplaceResults=clonesDataObject.ReplaceResults;
        cloneDetectionUIObject.EquivalencyCheckResults=clonesDataObject.EquivalencyCheckResults;






        propertiesDialog=DAStudio.ToolRoot.getOpenDialogs(cloneDetectionUIObject.ddgRight);
        if isempty(propertiesDialog)
            cloneDetectionUIObject.ddgRight=CloneDetectionUI.internal.DDGViews.ddgDialogRight(cloneDetectionUIObject);
        end

        resultsDialog=DAStudio.ToolRoot.getOpenDialogs(cloneDetectionUIObject.ddgBottom);
        if isempty(resultsDialog)
            cloneDetectionUIObject.ddgBottom=CloneDetectionUI.internal.DDGViews.ddgDialogBottom(cloneDetectionUIObject);
        end

        helpDialog=DAStudio.ToolRoot.getOpenDialogs(cloneDetectionUIObject.ddgHelp);
        if isempty(helpDialog)
            cloneDetectionUIObject.ddgHelp=CloneDetectionUI.internal.DDGViews.ddgDialogHelp(cloneDetectionUIObject);
        end

        cloneDetectionUIObject.refactorButtonEnable=cloneDetectionUIObject.cloneDetectionStatus;
    end
end

