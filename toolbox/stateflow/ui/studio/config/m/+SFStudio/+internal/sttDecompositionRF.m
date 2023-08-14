function sttDecompositionRF(cbInfo,action)




    action.enabled=false;
    action.selected=false;

    isFeatureOn=feature('ParallelStatesInSTT');
    if~isFeatureOn
        return;
    end

    chartId=SFStudio.Utils.getChartId(cbInfo);
    if~Stateflow.STT.StateEventTableMan.isStateTransitionTable(chartId)
        return;
    end

    sttman=Stateflow.STT.StateEventTableMan(chartId);
    currentSelection=sttman.viewManager.CurrentSelectionInfo;
    if isempty(currentSelection.SelectedObject)
        decomposition=sf('get',chartId,'.decomposition');
    elseif isa(currentSelection.SelectedObject,'Stateflow.STT.StateCell')
        decomposition=sf('get',currentSelection.SelectedObject.stateUddH.Id,'.decomposition');
    else
        return
    end

    action.enabled=true;
    isExclusiveRF=strcmp(action.name,'sttExclusiveDecompositionAction');
    if isExclusiveRF
        action.selected=decomposition==0;
    else
        action.selected=decomposition==1;
    end
end
