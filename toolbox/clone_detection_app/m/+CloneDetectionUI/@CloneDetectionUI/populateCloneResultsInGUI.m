
function populateCloneResultsInGUI(cloneDetectionUI)




    ddgBottomObj=cloneDetectionUI.ddgBottom;





    if~isempty(cloneDetectionUI.m2mObj.cloneresult)
        if~isa(cloneDetectionUI.m2mObj,'slEnginePir.acrossModelGraphicalCloneDetection')
            cloneDetectionUI.setRefactorButtonEnable(true);
            cloneDetectionUI.setCompareModelButtonEnable(false);
        else
            cloneDetectionUI.setRefactorButtonEnable(false);
            cloneDetectionUI.setCompareModelButtonEnable(false);
        end
        cloneDetectionUI.cloneDetectionStatus=true;
    else
        cloneDetectionUI.setRefactorButtonEnable(false);
        cloneDetectionUI.setCompareModelButtonEnable(false);
        cloneDetectionUI.cloneDetectionStatus=false;
    end


    CloneDetectionUI.internal.util.removeAllHighlights;


    if~isempty(cloneDetectionUI.m2mObj.cloneresult)
        CloneDetectionUI.internal.util.hiliteAllClones(true,...
        length(cloneDetectionUI.m2mObj.cloneresult.similar),...
        cloneDetectionUI.blockPathCategoryMap,cloneDetectionUI.colorCodes);
    end

    if~isempty(cloneDetectionUI.m2mObj.cloneresult)&&~isempty(cloneDetectionUI.m2mObj.cloneresult.Before)
        if isempty(cloneDetectionUI.libraryList)
            constructHelperMaps(cloneDetectionUI);
        end
        ddgBottomObj.result=DAStudio.message('sl_pir_cpp:creator:DetectClonesSuccess');
        ddgBottomObj.status='success';
    else
        ddgBottomObj.result=DAStudio.message('sl_pir_cpp:creator:noclonesfound');
        ddgBottomObj.status='error';
    end

    dlgBottom=DAStudio.ToolRoot.getOpenDialogs(ddgBottomObj);

    if~isempty(dlgBottom)
        dlgBottom.refresh;
    end

    cloneDetectionUI.ddgRight.blockdiffHtml='';
    dlgRight=DAStudio.ToolRoot.getOpenDialogs(cloneDetectionUI.ddgRight);
    if~isempty(dlgRight)
        dlgRight.refresh;
    end
end


