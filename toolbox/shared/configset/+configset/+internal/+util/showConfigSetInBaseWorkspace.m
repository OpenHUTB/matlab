function showConfigSetInBaseWorkspace(configSetName)









    me=daexplr;
    node=me.getTreeSelection;
    if node.getFullName~="Base Workspace"
        imme=DAStudio.imExplorer(me);
        nodes=imme.getVisibleTreeNodes;
        node=nodes{cellfun(@(x)strcmp(x.getFullName,'Base Workspace'),nodes)};
        me.view(node);
    end


    if nargin>0
        imme=DAStudio.imExplorer(me);
        list=imme.getVisibleListNodes;
        item=list{cellfun(@(x)x.getFullName=="Base Workspace/"+configSetName,list)};
        if isempty(item)||~isa(item.getVariable,'Simulink.ConfigSetRoot')

            throw(MSLException([],message('configset:util:ConfigSetNotFoundInBaseWorkspace',...
            configSetName)));
        end
        me.view(item);
    else

        me.view([]);
    end
