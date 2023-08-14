function projects=rootProject()















    if matlab.internal.project.util.useWebFrontEnd
        projects=matlab.internal.project.api.rootProject;
        return;
    end

    if~usejava('jvm')
        projects=matlab.project.Project.empty();
        return;
    end

    try
        import matlab.internal.project.util.processJavaCall;
        import matlab.internal.project.containers.CurrentProjectContainer;
        loadedProjects=processJavaCall(...
        @()com.mathworks.toolbox.slproject.project.matlab.api.MatlabAPIFacadeFactory.getAllLoadedProjects()...
        );

        numProjects=numel(loadedProjects);

        if numProjects==0
            projects=matlab.project.Project.empty();
            return;
        end

        for idx=1:numProjects
            projects(idx)=matlab.project.Project(...
            CurrentProjectContainer(loadedProjects(idx).getProjectManager())...
            );
        end
    catch exception
        if strcmp(exception.identifier,'MATLAB:project:api:CurrentProjectMismatch')
            projects=matlab.project.Project.empty();
            return
        end
        rethrow(exception);
    end

end

