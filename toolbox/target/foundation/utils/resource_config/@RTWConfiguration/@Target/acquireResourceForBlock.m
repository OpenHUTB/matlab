




















function acquiredResource=acquireResourceForBlock(block,configType,resourceType,requestedResource,msg)



    simStatus=lower(get_param(bdroot(block),'SimulationStatus'));

    switch simStatus
    case{'initializing','updating'}

        target=RTWConfigurationCB('get_target',block);
        resources=target.findResourceForClass(configType);
        resource=get(resources,resourceType);
        current_allocation=resource.get_current_allocation(block);
        if isempty(current_allocation);

            acquiredResource=resource.manual_allocate(block,requestedResource);
            if isempty(acquiredResource)
                host=resource.get_host(requestedResource);
                host_alloc=resource.get_current_allocation(host);
                conflict=intersect(host_alloc,requestedResource);


                fblock=regexprep(block,'\s',' ');
                fhost=regexprep(host,'\s',' ');
                errmsg=DAStudio.message('TargetCommon:resourceConfiguration:AcquireResourceAllocationFailed',...
                msg,sprintf('%s ',conflict{:}),fblock,fhost,msg);
                error('RTWConfiguration:Target:acquireResourceForBlock:AllocationFailed','%s',errmsg);
            end
        else


            if isempty(setdiff(requestedResource,current_allocation))

                requestedResource=current_allocation;
            else

                TargetCommon.ProductInfo.error('resourceConfiguration','MultiResourceProgrammingError');
            end
        end

    case{'stopped'}

        acquiredResource=requestedResource;
    end




