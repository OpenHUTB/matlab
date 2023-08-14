function viewer=openProjectDependencyViewer(controller,root,name,debug)




    parameters={"Controller",controller,...
    "Debug",debug,...
    "Node",dependencies.internal.graph.Node.createFileNode(root)...
    ,"Tag",'ProjectDependencyAnalyzer'};

    if~isempty(name)
        parameters=[parameters,{"Name",name}];
    end

    viewer=dependencies.internal.viewer.DependencyViewer(parameters{:});

    viewer.launch();

    if debug
        disp(viewer.Window.getUrl());
    end
end
