function dep=createDependency(location,component,type)





    [node,component]=i_createNodeAndComponent(location,component);

    rel=dependencies.internal.graph.Dependencies.SourceRelationship;

    dep=dependencies.internal.graph.Dependency(...
    node,component,node,component,type,rel);
end


function[node,component]=i_createNodeAndComponent(location,component)
    pattern="^(.+)\|\|TestHarness\|\|(.+?(\/.*)?)$";
    tokens=regexp(component,pattern,"once","tokens");
    if isempty(tokens)
        node=dependencies.internal.graph.Node.createFileNode(location);
        return
    end
    blockNameInModel=tokens{1};
    blockNameInHarness=tokens{2};
    harnessName=split(blockNameInHarness,"/");
    harnessName=harnessName{1};
    component=blockNameInHarness;
    node=dependencies.internal.graph.Nodes.createTestHarnessNode(...
    location,blockNameInModel,harnessName);
end