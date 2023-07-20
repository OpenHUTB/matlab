classdef Model<lutdesigner.access.System

    properties(Constant)
        Type='model'
    end

    properties(SetAccess=immutable)
Path
    end

    methods
        function this=Model(name)
            this.Path=name;
        end

        function tf=isAvailable(this)
            tf=bdIsLoaded(this.Path);
        end

        function tf=contains(this,that)
            tf=isequal(this,that)||this.containsByPath(this.Path,that.Path);
        end

        function show(this)
            open_system(this.Path,'tab');
            cellfun(@(block)set_param(block,'Selected','off'),...
            lutdesigner.access.internal.getSelectedBlocksInSystem(this.Path));
        end
    end
end
