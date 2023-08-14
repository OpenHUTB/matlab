function out = isDSMOwnedBySF(dsmid)
    % 
    
    % This function was previously named as is_dsm_owned_by_sf and was part
    % of private/plc_mdl_check_initial_property.m
    
    out = false;
    parentPath = get_param(dsmid, 'Parent');
    
    try
        chart = sfprivate('block2chart',parentPath);
        charttype = sf('get', chart, '.type');
    catch
        return;
    end
    
    if(isempty(charttype) || charttype ~=0)
        out = false; %charttype is not stateflow chart
    else
        out = true; %charttype is a stateflow chart
    end
end