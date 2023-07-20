

function type=getSFSelectionType(backendId)
    obj=sf('IdToHandle',backendId);
    if isa(obj,'Stateflow.State')||...
        isa(obj,'Stateflow.AtomicSubchart')||...
        isa(obj,'Stateflow.SimulinkBasedState')
        type=BindMode.SelectionTypeEnum.SFSTATE;
    elseif isa(obj,'Stateflow.Transition')
        type=BindMode.SelectionTypeEnum.SFTRANSITION;
    elseif isa(obj,'Stateflow.Data')
        type=BindMode.SelectionTypeEnum.SFDATA;
    elseif isa(obj,'Stateflow.Event')
        type=BindMode.SelectionTypeEnum.SFEVENT;
    elseif isa(obj,'Stateflow.Message')
        type=BindMode.SelectionTypeEnum.SFMESSAGE;
    elseif isa(obj,'Stateflow.SLFunction')
        type=BindMode.SelectionTypeEnum.SFSLFUNCTION;
    else
        type=BindMode.SelectionTypeEnum.NONE;
    end
end