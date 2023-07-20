function syncProjectFiles(project)





    projectManager=evolutions.internal.project.ProjectManager.get;
    projectInfo=getProjectInfoFromPath(projectManager,project);
    if~isempty(projectInfo)
        projectInfo.syncProjectFiles;
        projectManager.updateProjectFileListener(projectInfo);
    end

end
