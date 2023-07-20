function costAnalysisButtonRefresher(cbinfo,action)




    appContext=multicoredesigner.internal.toolstrip.getappcontextobj(cbinfo);
    if isempty(appContext)
        action.enabled=false;
        return;
    end
    action.enabled=true;

    selection=appContext.Mode;


    switch(selection)
    case 'CostEstimation'
        action.icon='estimate';
        action.text=getString(message('dataflow:Toolstrip:EstimateButtonMulticoreDesignerActionText'));
        action.description=getString(message('dataflow:Toolstrip:EstimateButtonMulticoreDesignerActionTooltip'));
        action.enabled=true;
    case 'SILPILProfiling'
        action.icon='profileCost';
        action.text=getString(message('dataflow:Toolstrip:ProfileButtonMulticoreDesignerActionText'));
        action.description=getString(message('dataflow:Toolstrip:ProfileButtonMulticoreDesignerActionTooltip'));
        action.enabled=true;
    case 'SimulationProfiling'
        action.icon='profileCost';
        action.text=getString(message('dataflow:Toolstrip:SimulationProfileButtonMulticoreDesignerActionText'));
        action.description=getString(message('dataflow:Toolstrip:SimualtionProfileButtonMulticoreDesignerActionTooltip'));
        action.enabled=false;
    end
end


