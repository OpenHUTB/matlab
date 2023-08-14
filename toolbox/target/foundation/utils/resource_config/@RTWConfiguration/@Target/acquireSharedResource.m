function acquireSharedResource(target,block,master_class,master_resource,shared_class,shared_resource,shared_resources,error_label)



















    allocated_master=false;

    try
        RTWConfiguration.Target.acquireResourceForBlock(...
        block,...
        master_class,...
        master_resource,...
        {'Master'},...
'Master'...
        );
        allocated_master=true;
    catch e
        switch(e.identifier)
        case 'RTWConfiguration:Target:acquireResourceForBlock:AllocationFailed'


        otherwise
            rethrow(e);
        end
    end

    if allocated_master
        try
            RTWConfiguration.Target.acquireResourceForBlock(...
            block,...
            shared_class,...
            shared_resource,...
            shared_resources,...
'Shared'...
            );
        catch e
            switch(e.identifier)
            case 'RTWConfiguration:Target:acquireResourceForBlock:AllocationFailed'

                shared_class_resource=target.findResourceForClass(shared_class);
                shared_res=get(shared_class_resource,shared_resource);
                host=shared_res.get_host(shared_resources);
                shared_resources_list=shared_resources{1};
                for i=2:length(shared_resources)
                    shared_resources_list=[shared_resources_list,' ',shared_resources{i}];%#ok<AGROW>
                end
                message=DAStudio.message('TargetCommon:resourceConfiguration:AcquireSharedResourceAllocationFailed',...
                error_label,shared_resources_list,block,host);
                error('RTWConfiguration:Target:acquireSharedResources:AllocationFailed',...
                '%s',message);
            otherwise
                rethrow(e);
            end
        end
    end
