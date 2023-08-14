classdef SimulinkParameter<lutdesigner.data.proxy.MatrixParameterObject

    methods
        function this=SimulinkParameter(objectSource)
            this=this@lutdesigner.data.proxy.MatrixParameterObject(objectSource);
        end
    end

    methods(Access=protected)

        function restrictions=getFieldNameWriteRestrictionsImpl(~)
            restrictions=lutdesigner.data.restriction.WriteRestriction('lutdesigner:data:fieldNameUsedAsID');
        end

        function fieldName=getFieldNameImpl(this)
            fieldName=this.ObjectSource.Name;
        end

        function setFieldNameImpl(~,~)
        end
    end

    methods(Access=protected)
        function value=getFieldImpl(~,object,field)
            value=object.(field);
        end

        function object=setFieldImpl(~,object,field,value)
            object.(field)=value;
        end
    end
end
