function runMoveFromJava(moveConsumer,oldFileList,destination,displayAutoRename)



    import dependencies.internal.refactoring.Action;

    project=matlab.project.rootProject;
    mlGraph=matlab.internal.project.dependency.getDependencyGraph(project);
    oldPaths=string(oldFileList.toArray());
    destinationPath=string(destination.getAbsolutePath());

    moveAction=Action.createForMatlab(@()moveConsumer.run(false));

    dependencies.internal.refactoring.view.displayMove(...
    mlGraph,oldPaths,destinationPath,displayAutoRename,moveAction)
end
