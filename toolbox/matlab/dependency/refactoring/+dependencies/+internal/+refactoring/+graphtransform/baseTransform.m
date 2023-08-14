function graph=baseTransform(inGraph)






    graph=dependencies.internal.graph.MutableGraph(inGraph);

    graph=i_addInvertedTestHarnessInfo(graph);
    graph=i_addFlippedRequirementDeps(graph);
end

function graph=i_addInvertedTestHarnessInfo(graph)
    import dependencies.internal.graph.DependencyFilter;
    import dependencies.internal.graph.Type;

    deps=graph.Dependencies;

    externalTestHarnessFilter=DependencyFilter.dependencyType("ExternalTestHarness")&...
    DependencyFilter.hasRelationship(Type.SOURCE);
    testHarnessInfoFilter=DependencyFilter.dependencyType("TestHarnessInfo")&...
    DependencyFilter.hasRelationship(Type.SOURCE);

    testHarnessInfoDeps=deps(testHarnessInfoFilter.apply(deps));

    if isempty(testHarnessInfoDeps)

        return;
    end

    for externalTestHarnessDep=deps(externalTestHarnessFilter.apply(deps))
        model=externalTestHarnessDep.DownstreamNode;
        matchingHarnessInfoDeps=testHarnessInfoDeps(model==[testHarnessInfoDeps.UpstreamNode]);
        for testHarnessInfoDep=matchingHarnessInfoDeps
            graph.addDependency(i_makeDummyDependency(externalTestHarnessDep,testHarnessInfoDep));
        end
    end

    for dep=testHarnessInfoDeps
        graph.addDependency(i_makeFlippedDependency(dep));
    end
end

function graph=i_addFlippedRequirementDeps(graph)
    import dependencies.internal.graph.DependencyFilter;
    import dependencies.internal.graph.Type;

    deps=graph.Dependencies;

    filter=DependencyFilter.dependencyType("RequirementInfo",true)&...
    DependencyFilter.hasRelationship(Type.SOURCE);

    for dep=deps(filter.apply(deps))
        graph.addDependency(i_makeFlippedDependency(dep));
    end
end

function dep=i_makeDummyDependency(externalTestHarnessDep,testHarnessInfoDep)
    externalTestHarness=externalTestHarnessDep.UpstreamNode;
    testHarnessInfo=testHarnessInfoDep.DownstreamNode;
    dep=dependencies.internal.graph.Dependency(...
    testHarnessInfo,"",externalTestHarness,"",...
    testHarnessInfoDep.Type.ID);

end

function dep=i_makeFlippedDependency(inDep)
    dep=dependencies.internal.graph.Dependency(...
    inDep.DownstreamNode,inDep.DownstreamComponent.Path,...
    inDep.UpstreamNode,inDep.UpstreamComponent.Path,...
    inDep.Type.ID,inDep.Relationship.ID);

end
