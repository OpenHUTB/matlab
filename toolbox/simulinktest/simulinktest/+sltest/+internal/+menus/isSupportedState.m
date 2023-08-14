function bool=isSupportedState(selection)
    if~isscalar(selection)
        bool=false;
        return;
    end

    bool=(isa(selection,'Stateflow.State')&&sfprivate('get_state_for_atomic_subchart',selection.Chart.Id)==0)||...
    isa(selection,'Stateflow.AtomicSubchart')||...
    isa(selection,'Stateflow.SimulinkBasedState');
end
