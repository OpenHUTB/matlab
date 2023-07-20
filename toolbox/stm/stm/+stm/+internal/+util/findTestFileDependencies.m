function findTestFileDependencies(tfObj)




    id=tfObj.id;

    filePath=stm.internal.getTestProperty(id,'testsuite').location;

    project=matlab.project.currentProject();
    if~isempty(project)
        matlab.internal.project.dependency.openDependencyAnalyzer(project,"DependenciesOf",filePath);
    end
end