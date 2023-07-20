



function atomicSubchartMappingRF(cbinfo,action)
    action.enabled=false;
    selection=cbinfo.getSelection;
    if length(selection)==1
        if Stateflow.SFUtils.isAtomic(selection)
            action.enabled=true;
        elseif isa(selection,'Stateflow.SimulinkBasedState')
            action.enabled=true;
        end
    end
end
