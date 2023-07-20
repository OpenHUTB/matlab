function items_allocated=manual_allocate(resource,host,items_requested)



























    items_available=resource.resources;

    if ischar(items_requested)

        items_requested={items_requested};
    end

    if~all(ismember(items_requested,items_available))
        if~iscell(items_requested)
            items_requested={items_requested};
        end
        err.message=DAStudio.message('TargetCommon:resourceConfiguration:ManualAllocateNoSuchItem',...
        sprintf('"%s" ',items_requested{:}),...
        sprintf('"%s" ',items_available{:}));

        err.identifier='RTWConfiguration:Resource:manual_allocate:NoSuchItem';
        error(err);
    end


    items_allocated={};
    for i=1:length(items_requested)
        item_requested=items_requested{i};


        priority_host=resource.get_host(item_requested);
        if isequal(host,priority_host)


            item_allocated=item_requested;
        else
            if isempty(priority_host)

                item_allocated=item_requested;
                i_allocate_items(resource,host,item_requested)
            else



                priority_allocation=resource.allocations.find(...
                '-class','RTWConfiguration.Allocation',...
                'host_object',priority_host);
                if priority_allocation.is_auto_allocation


                    i_allocate_items(resource,host,item_requested)
                    auto_value=resource.auto_allocate(priority_allocation);
                    if~isempty(auto_value)


                        priority_allocation.notify_reallocation(resource,auto_value);
                        item_allocated=item_requested;
                    else



                        i_deallocate_items(resource,host,item_requested);


                        resource.auto_allocate(priority_allocation);
                        item_allocated=[];
                    end
                else


                    item_allocated=[];
                end
            end
        end
        if isempty(item_allocated)
            items_allocated=[];


            i_deallocate_items(resource,host,items_requested);
            break;
        else
            items_allocated={items_allocated{:},item_allocated};%#ok<*CCAT>
        end
    end
    if length(items_allocated)==1
        items_allocated=items_allocated{1};
    end




    function i_allocate_items(resource,host,items)
        current_allocation=resource.allocations.find('-class','RTWConfiguration.Allocation','host_object',host);
        if~isempty(current_allocation)


            current_allocation.value=union(current_allocation.value,items);
        else

            new_alloc_obj=RTWConfiguration.Allocation(host,items,[]);
            resource.allocations.connect(new_alloc_obj,'down');
        end

        function i_deallocate_items(resource,host,items)
            current_allocation=resource.allocations.find('-class','RTWConfiguration.Allocation','host_object',host);
            if~isempty(current_allocation)


                current_allocation.value=setdiff(current_allocation.value,items);
                if isempty(current_allocation.value)
                    current_allocation.disconnect;
                end
            else

            end



