function runFindClones(cbinfo)



    ddgBottomObj=[];
    try
        sysHandle=SLStudio.Utils.getModelName(cbinfo);
        [path,~]=clone_detection_app.internal.getSelectedSystem(cbinfo);
        cloneDetectionUI=get_param(sysHandle,'CloneDetectionUIObj');

        if~isempty(cloneDetectionUI)
            selectedBoundary='';
            if~cloneDetectionUI.isAcrossModel
                cloneDetectionUI.systemFullName=path;
                selectedBoundary=path;
            else
                if isempty(cloneDetectionUI.listOfFolders)
                    DAStudio.error('sl_pir_cpp:creator:IllegalListOfFolders');
                end
            end

            [cloneDetectionUI.excludeLibraries,cloneDetectionUI.excludeModelReferences,...
            cloneDetectionUI.excludeInactiveRegions,...
            cloneDetectionUI.excludeCloneDetection]=clone_detection_app.internal.getExclusions(sysHandle);

            cloneDetectionUI.setCompareModelButtonEnable(false);

            cloneDetectionSettings=Simulink.CloneDetection.Settings();
            cloneDetectionSettings=clone_detection_app.internal.guiDataToAPISettingsAdapter(...
            cloneDetectionUI,cloneDetectionSettings);

            cloneResults=Simulink.CloneDetection.findClones(selectedBoundary,...
            cloneDetectionSettings);
            cloneDetectionUI.CloneResults=cloneResults;
            clonesRawData=Simulink.CloneDetection.internal.util.getClonesDataFromSavedResults(...
            cloneResults);

            cloneDetectionUI=clone_detection_app.internal.apiToGUIClonesDataAdapter(...
            cloneDetectionUI,clonesRawData);

            set_param(sysHandle,'CloneDetectionUIObj',cloneDetectionUI);
            Simulink.CloneDetection.internal.util.saveCloneDetectionUIObj(cloneDetectionUI);

            CloneDetectionUI.internal.util.showEmbedded(cloneDetectionUI.ddgRight,'Right','Tabbed');
            CloneDetectionUI.internal.util.showEmbedded(cloneDetectionUI.ddgBottom,'Bottom','Tabbed');

            ddgBottomObj=cloneDetectionUI.ddgBottom;

            cloneDetectionUI.populateCloneResultsInGUI();
        end
    catch exception
        set_param(sysHandle,'CloneDetectionUIObj',cloneDetectionUI);
        if~isempty(ddgBottomObj)
            ddgBottomObj.status='error';
            ddgBottomObj.result=exception.message;
            dlgBottom=DAStudio.ToolRoot.getOpenDialogs(ddgBottomObj);
            dlgBottom.refresh;
        end
        exception.throwAsCaller();
    end
end


