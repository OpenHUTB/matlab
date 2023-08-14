function project=currentProject()



















    try
        project=matlab.internal.project.api.currentProject();
        if~isempty(project)
            return;
        end
    catch
    end

    if~usejava('jvm')
        project=matlab.project.Project.empty();
        return;
    end

    try
        import matlab.internal.project.util.processJavaCall;
        controlSetFacade=processJavaCall(...
        @()com.mathworks.toolbox.slproject.project.matlab.api.MatlabAPIFacadeFactory.getCurrentProject()...
        );

        if isempty(controlSetFacade)
            project=matlab.project.Project.empty();
            return;
        end

        projectContainer=matlab.internal.project.containers.CurrentProjectContainer(controlSetFacade.getProjectManager());
    catch exception
        import matlab.internal.project.util.exceptions.MatlabAPIMatlabException.throwAPIException;
        throwAPIException(exception);
    end

    project=matlab.project.Project(projectContainer);

    if(exist(project.RootFolder,'dir')==0)
        warning(message('MATLAB:project:api:ProjectRootFolderNotFound',project.RootFolder))
    end

end

