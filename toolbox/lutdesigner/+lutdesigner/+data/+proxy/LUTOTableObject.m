classdef LUTOTableObject<lutdesigner.data.proxy.MatrixParameterObject

    methods
        function this=LUTOTableObject(objectSource)
            this=this@lutdesigner.data.proxy.MatrixParameterObject(objectSource);
        end
    end

    methods(Access=protected)
        function value=getFieldImpl(~,object,field)
            value=object.Table.(field);
        end

        function object=setFieldImpl(~,object,field,value)
            object.Table.(field)=value;
        end
    end
end
