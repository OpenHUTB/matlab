classdef FileToProjectMapper<handle






    properties(GetAccess=private,SetAccess=private)

        FileProvider;

        cFile=[];
        cProjectRoot=[]
        cInAProject=[];
        cIsAProjectLoaded=[];
        cCurrentProject=[];
        cInRootOfCurrentProject=[];
        cInCurrentProject=[];
    end

    properties(Dependent=true,GetAccess=public,SetAccess=private)
File
ProjectRoot
InAProject
InRootOfALoadedProject
InALoadedProject
    end

    properties(Dependent=true,GetAccess=private,SetAccess=private)
        LoadedProjectForFile;
    end


    methods(Access=public)
        function obj=FileToProjectMapper(fileProvider)
            if ischar(fileProvider)
                fileProvider=@()fileProvider;
            end
            obj.FileProvider=fileProvider;
        end

        function loadedProject=findLoadedProjectWithRoot(obj)
            loadedProject=matlab.project.rootProject;
            if isempty(loadedProject)
                return;
            end
            if obj.ProjectRoot~=loadedProject.RootFolder
                loadedProject=loadedProject([]);
            end
        end
    end

    methods
        function value=get.File(obj)

            if isempty(obj.cFile)
                obj.cFile=obj.FileProvider();
            end
            value=obj.cFile;
            return
        end

        function value=get.ProjectRoot(obj)
            if isempty(obj.cProjectRoot)
                [obj.cInAProject,obj.cProjectRoot]=...
                matlab.internal.project.util.isUnderProjectRoot(obj.File);
            end
            value=obj.cProjectRoot;

        end
        function value=get.InAProject(obj)
            if isempty(obj.cInAProject)
                [obj.cInAProject,obj.cProjectRoot]=matlab.internal.project.util.isUnderProjectRoot(obj.File);
            end
            value=obj.cInAProject;
        end

        function value=get.LoadedProjectForFile(obj)
            if isempty(obj.cCurrentProject)
                try
                    obj.cCurrentProject=obj.findLoadedProjectWithRoot();
                catch ME
                    obj.cCurrentProject=[];
                end
            end
            value=obj.cCurrentProject;
        end

        function value=get.InRootOfALoadedProject(obj)
            if isempty(obj.cInRootOfCurrentProject)
                currentProject=obj.LoadedProjectForFile;

                obj.cInRootOfCurrentProject=...
                ~isempty(currentProject)...
                &&strcmp(obj.ProjectRoot,currentProject.RootFolder);
            end
            value=obj.cInRootOfCurrentProject;
        end

        function value=get.InALoadedProject(obj)

            if(~obj.InRootOfALoadedProject)
                value=false;
                return
            end
            project=obj.LoadedProjectForFile;
            if isempty(obj.cInCurrentProject)
                projectFile=project.findFile(obj.File);
                obj.cInCurrentProject=~isempty(projectFile);
            end
            value=obj.cInCurrentProject;
        end

    end

end