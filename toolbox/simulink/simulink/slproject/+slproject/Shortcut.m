classdef Shortcut

















    properties(Dependent,GetAccess=public,SetAccess=public)

        Name;

        Group;
    end

    properties(Dependent,GetAccess=public,SetAccess=private)

        File;

        RunAtStartup;

        RunAtShutdown;
    end

    properties(GetAccess=private,SetAccess=immutable)
        Delegate;
    end

    methods(Access=public,Hidden=true)
        function obj=Shortcut(delegate)
            obj.Delegate=delegate;
        end
    end

    methods

        function name=get.Name(obj)
            name=char(obj.Delegate.Name);
        end

        function group=get.Group(obj)
            group=char(obj.Delegate.Group);
        end

        function file=get.File(obj)
            file=char(obj.Delegate.File);
        end

        function bool=get.RunAtStartup(obj)
            import matlab.internal.project.util.EntryPointType;
            bool=obj.Delegate.Type==EntryPointType.StartUp;
        end

        function bool=get.RunAtShutdown(obj)
            import matlab.internal.project.util.EntryPointType;
            bool=obj.Delegate.Type==EntryPointType.Shutdown;
        end

        function obj=set.Name(obj,name)
            obj.Delegate.Name=name;
        end

        function obj=set.Group(obj,group)
            obj.Delegate.Group=group;
        end

    end

end
