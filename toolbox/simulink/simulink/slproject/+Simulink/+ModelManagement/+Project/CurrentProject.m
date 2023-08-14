classdef CurrentProject<Simulink.ModelManagement.Project.ProjectManager







    methods(Access=public)

        function obj=CurrentProject()
            warning(message('MATLAB:project:api:APIDeprecation',...
            'Simulink.ModelManagement.Project.getCurrentProject'));
        end

        function loadProject(~,projectLocation)







            Simulink.ModelManagement.Project.checkArgument(projectLocation,'char','projectLocation');



            if~exist(projectLocation,'dir')
                error(message('MATLAB:project:api:IsNotDirectory',projectLocation));
            end


            [ok,fn]=fileattrib(projectLocation);
            if~ok



                candidate=pwd;
                [~,f]=fileparts(candidate);


                if ispc
                    b=strcmpi(f,projectLocation);
                else
                    b=strcmp(f,projectLocation);
                end
                if b

                    resolvedLocation=candidate;
                else

                    error(message('MATLAB:project:api:IsNotDirectory',projectLocation));
                end
            else
                resolvedLocation=fn.Name;
            end

            openProject(resolvedLocation);
        end

        function close(~)
            project=matlab.project.currentProject();
            if~isempty(project)
                close(project);
            end
        end

        function value=isProjectLoaded(~)
            value=~isempty(matlab.project.rootProject());
        end

    end

    methods(Access=protected)
        function project=getCurrentProject(~)
            project=matlab.project.currentProject();
            if isempty(project)
                error(message('MATLAB:project:api:NoProjectCurrentlyLoaded'));
            end
        end
    end

end

