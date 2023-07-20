function value=auto_allocate(resource,host,callback)











































    if isa(host,'RTWConfiguration.Allocation')
        allocation=host;
        allocation.disconnect;
    else
        allocation=RTWConfiguration.Allocation(host,'',callback);
    end
    allocations=resource.allocations.find('-class','RTWConfiguration.Allocation');

    allocated_values={};
    for i=1:length(allocations)
        allocated_values=union(allocated_values,allocations(i).value);
    end
    if~isempty(allocated_values)
        [unallocated_values,idx]=setdiff(resource.resources,allocated_values);
    else
        unallocated_values=resource.resources;
        idx=1;
    end

    if~isempty(unallocated_values)
        value=resource.resources{min(idx)};
        resource.allocations.connect(allocation,'down');
        allocation.value={value};
    else
        value=[];
    end







