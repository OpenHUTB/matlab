function host=get_host(resource,keys)

























    allocations=resource.allocations.find('-class','RTWConfiguration.Allocation');
    host=[];
    if~isempty(allocations)
        for i=1:length(allocations)
            allocation=allocations(i);
            if any(ismember(keys,get(allocation,'value')))
                host=allocation.host_object;
                return;
            end
        end
    end

