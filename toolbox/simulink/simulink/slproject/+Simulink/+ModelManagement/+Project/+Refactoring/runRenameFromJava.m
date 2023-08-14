function runRenameFromJava(renameConsumer,jOldPath,jNewPath,analysisWasCancelled)



    import dependencies.internal.refactoring.Action;

    project=matlab.project.rootProject;
    mlGraph=matlab.internal.project.dependency.getDependencyGraph(project);
    oldPath=string(jOldPath.getAbsolutePath());
    newPath=string(jNewPath.getAbsolutePath());

    renameAction=Action.createForMatlab(@()renameConsumer.run(false));

    dependencies.internal.refactoring.view.displayRename(...
    mlGraph,oldPath,newPath,analysisWasCancelled,renameAction)

end
