function name_vec=getSFunctionStateNames(sfcnBlock)




    stateNames=get_param(sfcnBlock,'SFcnStateName');
    assert(~isempty(stateNames));

    pat=',';
    name_vec=regexp(stateNames,pat,'split');

