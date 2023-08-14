function runDeleteFromJava(deleteConsumer,oldFileList)




    import dependencies.internal.refactoring.Action;
    import dependencies.internal.refactoring.view.displayDelete;

    project=matlab.project.rootProject;
    mlGraph=matlab.internal.project.dependency.getDependencyGraph(project);
    oldPaths=string(oldFileList.toArray());

    deleteAction=Action.createForMatlab(@()deleteConsumer.run(false));

    displayDelete(mlGraph,oldPaths,deleteAction)

end
