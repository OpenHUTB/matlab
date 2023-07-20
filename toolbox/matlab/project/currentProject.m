function project=currentProject(varargin)








    narginchk(0,0);
    nargoutchk(0,1);


    try
        try
            project=matlab.internal.project.api.currentProject();
            if~isempty(project)
                return;
            end
        catch
        end
        projectContainer=matlab.internal.project.containers.CurrentProjectContainer();
        project=matlab.project.Project(projectContainer);
    catch exception
        import matlab.internal.project.util.exceptions.MatlabAPIMatlabException.throwAPIException;
        throwAPIException(exception);
    end

end

