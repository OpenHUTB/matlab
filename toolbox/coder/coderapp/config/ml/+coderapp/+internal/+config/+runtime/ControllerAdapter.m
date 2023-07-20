classdef(Abstract)ControllerAdapter<coderapp.internal.log.Loggable&matlab.mixin.Heterogeneous


    properties(SetAccess=protected)
        CanValidate(1,1)logical=false
        CanImport(1,1)logical=false
        CanExport(1,1)logical=false
        CanToCode(1,1)logical=false
        CanWake(1,1)logical=false
        CanPostSet(1,1)logical=true
    end

    properties(Abstract,SetAccess=immutable)
        Id char
    end

    methods(Access={?coderapp.internal.config.runtime.ControllerAdapter,...
        ?coderapp.internal.config.runtime.NodeAdapter})

        function value=validate(this,value)%#ok<*INUSL>
        end

        function value=import(this,value)
        end

        function value=export(this,value)
        end

        function code=toCode(this,value)
            code='[]';
        end
    end

    methods(Abstract,Access={?coderapp.internal.config.runtime.ControllerAdapter,...
        ?coderapp.internal.config.runtime.NodeAdapter})

        initAdapter(this,node)


        initialize(this)
        update(this)
        postSet(this)
    end
end