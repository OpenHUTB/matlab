function out = hasAtomicSubchart(modelH)
    % 
    
    % This function was previously named as check_has_atomic_subchart and 
    % was part of private/plc_mdl_check_initial_property.m
    
    out = false;
    charts = plc_find_system(modelH, 'LookUnderMasks', 'on', 'FollowLinks', 'on', 'SFBlockType', 'Chart');
    
    for i = 1 : length(charts)
        cId = sfprivate('block2chart', charts{i});
        c = idToHandle(sfroot, cId);
        if ~isempty(c.find('-isa', 'Stateflow.AtomicSubchart'))
            out = true;
            break;
        end
    end
end