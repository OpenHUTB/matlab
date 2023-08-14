function result=currentProjectExistsAndContainsAnyNode(nodes)





    import dependencies.internal.graph.NodeFilter.fileWithin
    project=matlab.project.currentProject;
    result=~isempty(project)&&any(fileWithin(string(project.RootFolder)).apply(nodes));

end
