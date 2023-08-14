classdef(Abstract)AbstractParam<handle&matlab.mixin.Heterogeneous


    properties(SetAccess=?coderapp.internal.config.Configuration)
        Key char{mustBeNonempty}
        Type coderapp.internal.config.AbstractParamType
    end

    properties(Dependent)
Value
        Enabled logical
        Visible logical

    end

    properties(Dependent,GetAccess=protected,SetAccess=immutable)
        Locked logical
    end

    properties(GetAccess=protected,SetAccess=?coderapp.internal.config.Configuration)
        Configuration coderapp.internal.config.Configuration
    end

    properties(Access=?coderapp.internal.config.Configuration)
        ParamStore coderapp.internal.config.dm.ParamStore
    end

    methods
        function value=get.Value(this)
            value=this.Configuration.getAttr(this.Key,'value');
        end

        function enabled=get.Enabled(this)
            enabled=this.Configuration.getAttr(this.Key,'enabled');
        end

        function visible=get.Visible(this)
            visible=this.Configuration.getAttr(this.Key,'enabled');
        end

        function locked=get.Locked(this)
            locked=this.Configuration.isLocked(this);
        end
    end


    methods(Access=protected)
        function assertUnlocked(this)
            if this.Locked
                error('Attempt to modify locked param "%s".',this.Key);
            end
        end

        function assertNotDerived(this)
            if this.Type.Derived
                error('Attempted to modify derived param "%s". Derived params are not modifiable.',this.Key);
            end
        end
    end
end