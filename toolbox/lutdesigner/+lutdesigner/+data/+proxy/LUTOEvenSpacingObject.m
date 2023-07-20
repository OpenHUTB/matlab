classdef LUTOEvenSpacingObject<lutdesigner.data.proxy.MatrixParameterObject

    properties(SetAccess=immutable)
DimensionIndex
    end

    methods
        function this=LUTOEvenSpacingObject(objectSource,dimensionIndex)
            this=this@lutdesigner.data.proxy.MatrixParameterObject(objectSource);
            this.DimensionIndex=dimensionIndex;
        end
    end

    methods(Access=protected)

        function restrictions=getValueWriteRestrictionsImpl(~)
            restrictions=lutdesigner.data.restriction.WriteRestriction('lutdesigner:data:evenSpacingWriteLimitation');
        end

        function value=getValueImpl(this)
            object=this.ObjectSource.read();
            firstPoint=this.getFieldImpl(object,'FirstPoint');
            spacing=this.getFieldImpl(object,'Spacing');
            numPoints=lutdesigner.data.proxy.internal.getSizeOnDimension(this.ObjectSource.read().Table.Value,this.DimensionIndex);
            value=lutdesigner.data.proxy.internal.populateEvenSpacingValue(firstPoint,spacing,numPoints);
        end

        function setValueImpl(~,~)
        end


        function restrictions=getFieldNameReadRestrictionsImpl(~)
            restrictions=lutdesigner.data.restriction.ReadRestriction;
        end

        function restrictions=getFieldNameWriteRestrictionsImpl(~)
            restrictions=lutdesigner.data.restriction.WriteRestriction;
        end

        function fieldName=getFieldNameImpl(~)%#ok
        end

        function setFieldNameImpl(~,~)
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
