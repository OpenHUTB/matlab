
classdef CurrentProjectContainer<matlab.internal.project.containers.ProjectContainer



    properties(Access=private)
        ProjectRootFolder;
    end

    methods(Access=public)

        function obj=CurrentProjectContainer(projectManager)

            if(nargin==0)
                projectManager=obj.getJavaProjectControlSet().getProjectManager();
            end

            obj.ProjectRootFolder=projectManager.getProjectRoot();

        end

        function javaProjectManager=getJavaProjectManager(obj)

            projectControlSet=iGetControlSet(obj.ProjectRootFolder);

            javaProjectManager=projectControlSet.getProjectManager();

        end

        function projectControlSet=getJavaProjectControlSet(obj)

            projectControlSet=iGetControlSet(obj.ProjectRootFolder);

        end

        function manager=getMatlabAPIProjectManager(obj)
            import com.mathworks.toolbox.slproject.project.matlab.api.MatlabAPIMatlabProjectManager;
            import matlab.internal.project.util.processJavaCall;
            manager=processJavaCall(...
            @()MatlabAPIMatlabProjectManager(obj.ProjectRootFolder)...
            );
        end

    end

end

function javaProjectControlSetFacade=iGetControlSet(projectFolder)

    import matlab.internal.project.util.processJavaCall;
    import com.mathworks.toolbox.slproject.project.matlab.api.MatlabAPIFacadeFactory;
    javaProjectControlSetFacade=processJavaCall(...
    @()MatlabAPIFacadeFactory.getMatchingControlSetFacade(projectFolder)...
    );

end
