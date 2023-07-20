function modelGraph=createModelHierarchyGraph(graph)




    import dependencies.internal.graph.NodeFilter.fileExtension;

    modelGraph=dependencies.internal.viewer.util.createFilteredGraph(...
    graph,...
    fileExtension([".mdl",".slx",".sldd",".mldp",".slxp"]),...
    ["ModelReference","LibraryLink","SubsystemReference","ObserverReference","ExternalTestHarness","DataDictionary"]);

end
