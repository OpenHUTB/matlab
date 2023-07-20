classdef ProjectReference<slproject.FolderReference






    properties(Dependent,GetAccess=public,SetAccess=private)

        Project;
    end

    methods(Access=public,Hidden=true)
        function obj=ProjectReference(delegate)
            obj=obj@slproject.FolderReference(delegate);
        end

        function obj=enable(obj)

            obj=slproject.ProjectReference(obj.Delegate.enable());
        end
    end

    methods
        function proj=get.Project(obj)
            proj=slproject.ProjectManager(obj.Delegate.Project);
        end
    end

end
