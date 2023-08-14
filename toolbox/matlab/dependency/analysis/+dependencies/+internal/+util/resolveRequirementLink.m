function dep=resolveRequirementLink(node,upComp,reqType,reqPath,linkID,reqSID,type)




    import dependencies.internal.graph.Component;
    import dependencies.internal.graph.Dependency;
    import dependencies.internal.graph.Type;

    dep=dependencies.internal.graph.Dependency.empty;

    if~isempty(reqPath)
        switch reqType
        case 'linktype_rmi_url'


        case{'doors','linktype_rmi_doors'}





        case 'linktype_rmi_simulink'
            if strncmp(reqPath,'$ModelName$',length('$ModelName$'))
                reqNode=node;
            else
                reqNode=i_rmiResolve(reqPath,node);
            end
            dep=Dependency.createSource(upComp,i_getSimulinkLinkComponent(reqNode,linkID,reqSID),type);

        otherwise
            reqNode=i_rmiResolve(reqPath,node);
            dep=Dependency.createSource(upComp,i_getLinkComponent(reqNode,linkID),type);
        end
    end

end

function simulinkLinkComponent=i_getSimulinkLinkComponent(node,linkID,reqSID)
    if ""==linkID
        simulinkLinkComponent=dependencies.internal.graph.Component.createRoot(node);
    else
        linkType=dependencies.internal.graph.Type("RequirementLinkID");
        simulinkLinkComponent=dependencies.internal.graph.Component(node,linkID,linkType,0,"",linkID,reqSID);
    end
end

function linkComponent=i_getLinkComponent(node,linkID)
    if ""==linkID
        linkComponent=dependencies.internal.graph.Component.createRoot(node);
    else
        linkType=dependencies.internal.graph.Type("RequirementLinkID");
        linkComponent=dependencies.internal.graph.Component(node,linkID,linkType,0,"","","");
    end
end

function reqNode=i_rmiResolve(path,node)


    state=warning('off');
    cleanup=onCleanup(@()warning(state));


    if rmiut.isCompletePath(path)
        resolved=path;
    else
        resolved=rmiut.full_path(path,fileparts(node.Location{1}));
    end


    if isempty(resolved)
        reqNode=dependencies.internal.graph.Node.createFileNode(path);
    else
        reqNode=dependencies.internal.graph.Node.createFileNode(resolved);
    end

end
