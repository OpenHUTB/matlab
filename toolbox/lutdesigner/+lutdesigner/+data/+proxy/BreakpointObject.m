classdef BreakpointObject<lutdesigner.data.proxy.MatrixParameterObject

    methods
        function this=BreakpointObject(objectSource)
            this=this@lutdesigner.data.proxy.MatrixParameterObject(objectSource);
        end
    end

    methods(Access=protected)
        function value=getFieldImpl(~,object,field)
            value=object.Breakpoints.(field);
        end

        function object=setFieldImpl(~,object,field,value)
            object.Breakpoints.(field)=value;
        end
    end
end
