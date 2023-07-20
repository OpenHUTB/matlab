function showTestFileInProject(tfObj)


    id=tfObj.id;

    filePath=stm.internal.getTestProperty(id,'testsuite').location;

    project=matlab.project.currentProject();

    matlab.internal.project.util.showFilesInProject(project,filePath);
end