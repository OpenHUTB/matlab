function instanceGraph=createModelInstanceGraph(graph)




    import dependencies.internal.graph.DependencyFilter.dependencyType;
    import dependencies.internal.graph.NodeFilter;
    import dependencies.internal.viewer.util.createFilteredGraph;

    inDeps=graph.Dependencies;
    protectedModelDependencies=inDeps(apply(dependencyType("ProtectedModel"),inDeps));
    nodesWithProtectedModel=unique([protectedModelDependencies.DownstreamNode]);

    nodeFilter=NodeFilter.fileExtension([".mdl",".slx",".mldp",".slxp"]);
    if~isempty(nodesWithProtectedModel)
        nodeFilter=nodeFilter&~NodeFilter.isMember(nodesWithProtectedModel);
    end

    nodeFilter=nodeFilter&NodeFilter.wrapNode(@i_isAcceptedSimulinkType);

    modelGraph=createFilteredGraph(...
    graph,...
    nodeFilter,...
    ["ModelReference","SubsystemReference","ObserverReference"]);

    instanceGraph=dependencies.internal.graph.MutableGraph;
    sourceNodes=modelGraph.Nodes(arrayfun(@(n)i_isSourceNode(modelGraph,n),modelGraph.Nodes));
    instanceGraph.addNode(sourceNodes);
    arrayfun(@(node)i_addDependencies(node,[],modelGraph,instanceGraph),sourceNodes);
end

function accepted=i_isAcceptedSimulinkType(nodes)
    import dependencies.internal.viewer.simulink.getSimulinkType;
    types=arrayfun(@getSimulinkType,nodes);
    accepted=ismember(types,{'model','subsystem','protectedModel'});
end

function issource=i_isSourceNode(graph,node)
    upstream=graph.getUpstreamDependencies(node);
    issource=isempty(upstream)||all([upstream.UpstreamNode]==node);
end

function i_addDependencies(currentNode,path,modelGraph,instanceGraph)

    if isempty(path)
        modelNode=currentNode;
    else
        modelNode=path(end).DownstreamNode;
    end
    import dependencies.internal.graph.Component;
    for dep=modelGraph.getDownstreamDependencies(modelNode)
        nextPath=[path,dep];

        if~i_isCyclic(nextPath)
            nextNode=i_createInstanceNode(nextPath);

            instanceDep=dependencies.internal.graph.Dependency(...
            Component.replaceNode(currentNode,dep.UpstreamComponent),...
            Component.replaceNode(nextNode,dep.DownstreamComponent),...
            dep.Type,dep.Relationship);

            instanceGraph.addDependency(instanceDep);

            i_addDependencies(nextNode,nextPath,modelGraph,instanceGraph);
        end
    end

end


function cyclic=i_isCyclic(path)
    filter=dependencies.internal.graph.NodeFilter.isMember([path.UpstreamNode]);
    cyclic=apply(filter,path(end).DownstreamNode);
end


function instance=i_createInstanceNode(path)
    node=path(end).DownstreamNode;

    if path(end).Relationship==dependencies.internal.graph.Type.TOOLBOX
        instance=node;
    else
        components=[path.UpstreamComponent];
        location=[
        string(node.Location{1}),...
        string(path(1).UpstreamNode.Location{1}),...
        components.Path...
        ];

        instance=dependencies.internal.graph.Node(...
        location,node.Type.ID,node.Resolved);
    end
end
