classdef ReferencedProjectContainer<matlab.internal.project.containers.ProjectContainer



    properties(Access=private)
        ProjectRootFolder;
        Enabled=false;
    end

    methods(Access=public)

        function obj=ReferencedProjectContainer(rootFolder,enabled)
            if nargin>1
                obj.Enabled=enabled;
            end
            obj.ProjectRootFolder=rootFolder;
        end

        function javaProjectManager=getJavaProjectManager(obj)
            projectControlSet=obj.getJavaProjectControlSet();
            javaProjectManager=projectControlSet.getProjectManager();
        end

        function projectControlSet=getJavaProjectControlSet(obj)

            import matlab.internal.project.util.processJavaCall;
            import com.mathworks.toolbox.slproject.project.matlab.api.MatlabAPIFacadeFactory;
            projectControlSet=processJavaCall(...
            @()MatlabAPIFacadeFactory.getReferencedControlSet(...
            java.io.File(char(obj.ProjectRootFolder)),...
            obj.Enabled...
            ));
        end

        function manager=getMatlabAPIProjectManager(obj)
            import com.mathworks.toolbox.slproject.project.matlab.api.MatlabAPIMatlabProjectManager;
            import matlab.internal.project.util.processJavaCall;
            root=char(obj.ProjectRootFolder);
            manager=processJavaCall(...
            @()MatlabAPIMatlabProjectManager.newInstance(root,false,~obj.Enabled)...
            );

        end
    end

end


