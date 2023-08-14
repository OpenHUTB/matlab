function jGraph=analyze(jRequest,jListener,jTerminator,jBusName)




    import dependencies.internal.util.callWithNodePath;

    files=string(jRequest.getFiles.toArray);
    nodes=dependencies.internal.graph.Node.createFileNode(files);
    nodes(end+1)=dependencies.internal.graph.Nodes.BaseWorkspaceNode;

    busElements=split(char(jBusName),'.');
    busNode=dependencies.internal.graph.Nodes.createVariableNode(busElements);

    analyzer=dependencies.internal.buses.BusAnalyzer(busNode);
    analyzer.CancelFunction=@jTerminator.isTerminated;
    analyzer.GraphFactory=@Simulink.ModelManagement.Project.Dependency.GraphFactory;
    analyzer.addlistener('AnalyzingNode',@(~,event)callWithNodePath(...
    @(path)jListener.statusUpdated(path,event.Remaining),...
    event.Node));
    analyzer.addlistener('AnalysisFinishing',@(~,~)jListener.statusUpdated(getString(message('MATLAB:project:util:DependencyAnalysisFinishing'))));

    jGraph=analyzer.analyze(nodes);

end

