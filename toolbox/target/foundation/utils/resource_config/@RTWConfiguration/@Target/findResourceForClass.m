function config=findResourceForClass(config_handle,classkey)










    node=config_handle.activeList.find('-class','RTWConfiguration.Node','classkey',classkey);
    if isempty(node)
        config=[];
    else
        if isempty(node.resources)




            lib=node.sourceLibrary;
            cdc=find_system(lib,'SearchDepth',1,'tag','CONFIGURATION DATA CLASS');
            assert(~isempty(cdc),'Can''t find configuration block in library %s.',lib);
            cdc=cdc{1};

            required_resource=get_param(cdc,'rClassName');

            if~all(isspace(required_resource))
                resource=eval(required_resource);
                node.resources=resource;
            end
        end
        config=node.resources;
    end
