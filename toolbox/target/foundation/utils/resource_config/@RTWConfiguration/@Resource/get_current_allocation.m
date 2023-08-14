function value=get_current_allocation(resource,host)















    allocation=resource.allocations.find('-class','RTWConfiguration.Allocation',...
    'host_object',host);

    if~isempty(allocation)
        value=allocation.value;
    else
        value={};
    end
