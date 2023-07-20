function result=getStateflowElementType(sid)









    result='';
    sfObj=Simulink.ID.getHandle(sid);
    key=class(sfObj);

    if isnumeric(sfObj)&&...
        Stateflow.SLUtils.isStateflowBlock(sfObj)&&...
        strcmpi(get_param(sfObj,'SFBlockType'),'Chart')
        key='Stateflow.Chart';
    end

    switch key
    case 'Stateflow.Transition'
        result='Transition';
    case 'Stateflow.State'
        result='State';
    case 'Stateflow.Event'
        result='Event';
    case 'Stateflow.SimulinkBasedState'
        result='SimulinkBasedState';
    case 'Stateflow.Junction'
        result='Junction';
    case 'Stateflow.TruthTable'
        result='TruthTable';
    case 'Stateflow.SLFunction'
        result='SimulinkFunction';
    case 'Stateflow.Function'
        result='GraphicalFunction';
    case 'Stateflow.EMFunction'
        result='MATLABFunction';
    case 'Stateflow.Chart'
        result='Chart';
    end



end




