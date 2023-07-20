function modeSelectionDropDownButtonRefresher(cbinfo,action)




    appContext=multicoredesigner.internal.toolstrip.getappcontextobj(cbinfo);
    if isempty(appContext)
        action.enabled=false;
        return;
    end
    action.enabled=true;

    selection=appContext.Mode;


    switch(selection)
    case 'CostEstimation'
        action.text=getString(message('dataflow:Toolstrip:SelectModeCostEstimationText'));
        action.icon='costEstimation';
    case 'SILPILProfiling'
        action.text=getString(message('dataflow:Toolstrip:SelectModeProfilingText'));
        action.icon='costProfilingSILPIL';
    case 'SimulationProfiling'
        action.text=getString(message('dataflow:Toolstrip:SelectModeSimulationProfilingText'));
        action.icon='costSimulation';
    end
end


