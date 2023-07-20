function runRemoveFromProjectFromJava(removeConsumer,oldFileList)



    import dependencies.internal.refactoring.Action;

    project=matlab.project.rootProject;
    mlGraph=matlab.internal.project.dependency.getDependencyGraph(project);
    oldPaths=string(oldFileList.toArray());

    removeAction=Action.createForMatlab(@()removeConsumer.run(false));

    dependencies.internal.refactoring.view.displayRemove(mlGraph,oldPaths,removeAction)

end
