classdef Information<matlab.internal.project.util.ProjectHandle&dynamicprops





    properties(Dependent)

Description
    end

    properties(Dependent,GetAccess=public,SetAccess=private)

SourceControlIntegration

RepositoryLocation

SourceControlMessages

ReadOnly

TopLevel
    end

    properties(GetAccess=private,SetAccess=immutable)
        Project;
    end

    methods(Access=public,Hidden=true)
        function obj=Information(project)
            obj.Project=project;
            obj.addWorkingFolderProperties();
        end
    end

    methods
        function information=get.SourceControlMessages(obj)












            information=cellstr(obj.Project.SourceControlMessages);
        end

        function adapter=get.SourceControlIntegration(obj)











            adapter=char(obj.Project.SourceControlIntegration);
        end

        function file=get.RepositoryLocation(obj)











            file=char(obj.Project.RepositoryLocation);
        end

        function description=get.Description(obj)











            description=char(obj.Project.Description);
        end

        function set.Description(obj,description)











            validateattributes(description,{'char','string'},{});
            obj.Project.Description=description;
        end

        function readonly=get.ReadOnly(obj)











            readonly=obj.Project.ReadOnly;
        end

        function topLevel=get.TopLevel(obj)











            topLevel=obj.Project.TopLevel;
        end
    end

    methods(Access=private)
        function addWorkingFolderProperties(obj)
            projectClass=metaclass(obj.Project);
            workingFolders=setdiff(properties(obj.Project),{projectClass.PropertyList.Name});

            for n=1:length(workingFolders)
                folder=workingFolders{n};
                prop=obj.addprop(folder);
                prop.GetMethod=@(obj,value)obj.getWorkingFolderValue(folder);
                prop.SetMethod=@(obj,value)obj.setWorkingFolderValue(folder,value);
            end
        end

        function value=getWorkingFolderValue(obj,folder)

            value=char(obj.Project.(folder));
            if isempty(value)
                if folder=="SimulinkCacheFolder"
                    value=Simulink.fileGenControl('get','CacheFolder');
                elseif folder=="SimulinkCodeGenFolder"
                    value=Simulink.fileGenControl('get','CodeGenFolder');
                end
            end
        end

        function setWorkingFolderValue(obj,folder,value)
            validateattributes(value,{'char','string','slproject.ProjectFile'},{'nonempty'},'','file');
            if isa(value,'slproject.ProjectFile')
                value=value.Path;
            end
            obj.Project.(folder)=value;
        end
    end

end
