function refreshDerivedData(cbInfo,action)

    className=get_param(cbInfo.Context.Object.BlockHandle,'ClassName');

    typeChain=cbInfo.Context.Object.TypeChain{1};

    action.selected=cbInfo.Context.Object.ShowDerivedData;

    if(contains(className,'Solid')&&(~contains(className,'Flexible')))
        action.enabled=~strcmpi(typeChain,'FrameCreation');
        action.icon='inertia';
        action.text='Inertia';
    elseif(contains(className,'Flexible'))
        if(contains(className,'Beam'))
            action.enabled=~strcmpi(typeChain,'FrameCreation');
            action.icon='flexibleStiffness';
            action.text='Stiffness';
        elseif(contains(className,'Plate')||...
            contains(className,'ReducedOrderFlexibleSolid'))
            action.enabled=false;
            action.icon='flexibleStiffness';
            action.text='Stiffness';
        end
    else
        action.enabled=false;
    end

end

