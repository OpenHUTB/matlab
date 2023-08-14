function projectRoot=projectRootForModel(modelName)

    load_system(modelName);

    fileToProjectMapper=Simulink.ModelManagement.Project.Util.FileToProjectMapper(which(modelName));
    projectRoot=fileToProjectMapper.ProjectRoot;

    if~isempty(slproject.getCurrentProjects())
        if MultiSim.internal.isReferencedInProject(projectRoot,currentProject())
            projectRoot=currentProject().RootFolder;
        end
    end
end
