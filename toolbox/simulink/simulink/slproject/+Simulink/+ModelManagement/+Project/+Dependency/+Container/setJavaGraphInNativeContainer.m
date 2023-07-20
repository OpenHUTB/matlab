function setJavaGraphInNativeContainer(container,jContainer)




    graph=Simulink.ModelManagement.Project.Dependency.convertGraph(jContainer);
    container.setGraph(graph);

end
