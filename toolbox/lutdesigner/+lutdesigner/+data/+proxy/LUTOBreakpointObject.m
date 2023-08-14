classdef LUTOBreakpointObject<lutdesigner.data.proxy.MatrixParameterObject

    properties(SetAccess=immutable)
DimensionIndex
    end

    methods
        function this=LUTOBreakpointObject(objectSource,dimensionIndex)
            this=this@lutdesigner.data.proxy.MatrixParameterObject(objectSource);
            this.DimensionIndex=dimensionIndex;
        end
    end

    methods(Access=protected)
        function value=getFieldImpl(this,object,field)
            value=object.Breakpoints(this.DimensionIndex).(field);
        end

        function object=setFieldImpl(this,object,field,value)
            object.Breakpoints(this.DimensionIndex).(field)=value;
        end
    end
end
