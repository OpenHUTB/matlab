function handle=view(input,varargin)













    if~feature('HasDisplay')
        title=string(message("MATLAB:dependency:viewer:AppTitle"));
        error(message("MATLAB:dependency:viewer:CannotRunInNoDisplayMode",title));
    end

    nodes=dependencies.internal.util.getNodes(input);

    viewer=dependencies.internal.viewer.DependencyViewer("Nodes",nodes,varargin{:});

    if nargout<1
        wm=dependencies.internal.widget.WindowManager.Instance;
        wm.launchAndRegister(viewer);
    else
        viewer.launch();
        handle=viewer;
    end

    viewer.analyze(nodes);

end
