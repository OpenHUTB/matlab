function refactor(deps,newPaths,handlers)




    import dependencies.internal.graph.Type;

    if nargin<3
        handlers=dependencies.internal.Registry.Instance.RefactoringHandlers;
    end

    newPaths=cellstr(newPaths);

    nodes=[deps.UpstreamNode];
    [~,uniqueNodes,depIndexes]=unique(nodes);

    for idx=1:length(uniqueNodes)
        node=nodes(uniqueNodes(idx));
        dependencies.internal.action.edit(node);

        for depIdx=find(depIndexes==idx)'
            i_refactor(deps(depIdx),newPaths{depIdx},handlers);
        end

        if node.Type==Type.TEST_HARNESS
            sltest.harness.close(node.Location{2:3});
        end
    end

end


function i_refactor(dep,newPath,handlers)

    for n=1:length(handlers)
        if ismember(dep.Type.ID,handlers(n).Types)
            handlers(n).refactor(dep,newPath);
            return
        end
    end

end
