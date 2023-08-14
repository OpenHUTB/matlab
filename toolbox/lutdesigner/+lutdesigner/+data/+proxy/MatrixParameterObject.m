classdef MatrixParameterObject<lutdesigner.data.proxy.MatrixParameterProxy

    properties(SetAccess=immutable,GetAccess=protected)
ObjectSource
    end

    methods
        function this=MatrixParameterObject(objectSource)
            this.ObjectSource=objectSource;
        end
    end

    methods(Access=protected)
        function dataUsage=listDataUsageImpl(this)
            dataUsage=lutdesigner.data.proxy.DataUsage;
            dataUsage.DataSource=this.ObjectSource;
            dataUsage.UsedAs='/';
        end


        function restrictions=getValueReadRestrictionsImpl(this)
            restrictions=this.ObjectSource.getReadRestrictions();
        end

        function restrictions=getValueWriteRestrictionsImpl(this)
            restrictions=this.ObjectSource.getWriteRestrictions();
        end

        function value=getValueImpl(this)
            value=this.getField('Value');
        end

        function setValueImpl(this,value)
            this.setField('Value',value);
        end


        function restrictions=getMinReadRestrictionsImpl(this)
            restrictions=this.ObjectSource.getReadRestrictions();
        end

        function restrictions=getMinWriteRestrictionsImpl(this)
            restrictions=this.ObjectSource.getWriteRestrictions();
        end

        function min=getMinImpl(this)
            min=this.getField('Min');
        end

        function setMinImpl(this,min)
            this.setField('Min',min);
        end


        function restrictions=getMaxReadRestrictionsImpl(this)
            restrictions=this.ObjectSource.getReadRestrictions();
        end

        function restrictions=getMaxWriteRestrictionsImpl(this)
            restrictions=this.ObjectSource.getWriteRestrictions();
        end

        function max=getMaxImpl(this)
            max=this.getField('Max');
        end

        function setMaxImpl(this,max)
            this.setField('Max',max);
        end


        function restrictions=getUnitReadRestrictionsImpl(this)
            restrictions=this.ObjectSource.getReadRestrictions();
        end

        function restrictions=getUnitWriteRestrictionsImpl(this)
            restrictions=this.ObjectSource.getWriteRestrictions();
        end

        function unit=getUnitImpl(this)
            unit=this.getField('Unit');
        end

        function setUnitImpl(this,unit)
            this.setField('Unit',unit);
        end


        function restrictions=getFieldNameReadRestrictionsImpl(this)
            restrictions=this.ObjectSource.getReadRestrictions();
        end

        function restrictions=getFieldNameWriteRestrictionsImpl(this)
            restrictions=this.ObjectSource.getWriteRestrictions();
        end

        function fieldName=getFieldNameImpl(this)
            fieldName=this.getField('FieldName');
        end

        function setFieldNameImpl(this,fieldName)
            this.setField('FieldName',fieldName);
        end


        function restrictions=getDescriptionReadRestrictionsImpl(this)
            restrictions=this.ObjectSource.getReadRestrictions();
        end

        function restrictions=getDescriptionWriteRestrictionsImpl(this)
            restrictions=this.ObjectSource.getWriteRestrictions();
        end

        function description=getDescriptionImpl(this)
            description=this.getField('Description');
        end

        function setDescriptionImpl(this,description)
            this.setField('Description',description);
        end
    end

    methods(Access=private)
        function value=getField(this,field)
            object=this.ObjectSource.read();
            value=this.getFieldImpl(object,field);
        end

        function setField(this,field,value)
            object=this.ObjectSource.read();
            object=this.setFieldImpl(object,field,value);
            this.ObjectSource.write(object);
        end
    end

    methods(Abstract,Access=protected)
        value=getFieldImpl(this,object,field);

        setFieldImpl(this,object,field,value);
    end
end
