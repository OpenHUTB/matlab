function project=getCurrentProject()
























    project=slproject.ProjectManager(currentProject());

    if~isfolder(project.RootFolder)
        warning(message('MATLAB:project:api:ProjectRootFolderNotFound',project.RootFolder))
    end

end
