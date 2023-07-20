function viewer=createViewer(container,root,name,debug)




    viewer=dependencies.internal.viewer.DependencyViewer(...
    Controller=container.createController(),...
    Name=name,...
    Debug=debug,...
    Node=dependencies.internal.graph.Node.createFileNode(root),...
    Tag='ProjectDependencyAnalyzer');

    if debug
        disp(viewer.Window.getUrl());
    end

end
