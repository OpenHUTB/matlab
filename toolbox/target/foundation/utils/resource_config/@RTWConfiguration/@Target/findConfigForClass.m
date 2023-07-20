function config=findConfigForClass(config_handle,classkey)










    node=config_handle.activeList.find('-class','RTWConfiguration.Node','classkey',classkey);
    if isempty(node)
        assert(false,'Can''t find node of class %s',classkey);
    else
        config=node.data;
    end
