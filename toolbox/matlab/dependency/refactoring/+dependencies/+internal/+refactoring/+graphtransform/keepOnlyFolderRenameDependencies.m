function graph=keepOnlyFolderRenameDependencies(inGraph)






    deps=inGraph.Dependencies;
    folderTypes=i_getFolderTypes;
    keep=false(size(deps));
    for n=1:length(deps)
        keep(n)=ismember(deps(n).Type,folderTypes);
    end

    graph=dependencies.internal.graph.Graph(deps(keep));
end

function folderTypes=i_getFolderTypes()
    registry=dependencies.internal.Registry.Instance;
    [~,folderTypes]=registry.getRefactoringTypes();
    folderTypes=[...
    folderTypes;...
    {'BlockCallback,MaskDisplay,FunctionArgument';...
    'ModelReferenceDependency';...
    'CustomLibrary';...
    'CustomSource';...
    'StateflowTarget'}];
    folderTypes=arrayfun(@dependencies.internal.graph.Type,folderTypes);
end
