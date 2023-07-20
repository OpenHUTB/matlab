classdef MatrixParameterProxy<lutdesigner.data.proxy.DataProxy




    properties(Dependent)
Value
Min
Max
Unit
FieldName
Description
    end

    methods
        function restrictions=getReadRestrictionsFor(this,field)
            restrictions=this.("get"+field+"ReadRestrictionsImpl")();
            restrictions=restrictions(:);
        end

        function restrictions=getWriteRestrictionsFor(this,field)
            restrictions=this.("get"+field+"WriteRestrictionsImpl")();
            restrictions=restrictions(:);
        end


        function value=get.Value(this)
            restrictions=this.getValueReadRestrictionsImpl();
            if~isempty(restrictions)
                error(restrictions(end).Reason);
            end
            value=this.getValueImpl();
        end

        function set.Value(this,value)
            restrictions=this.getValueWriteRestrictionsImpl();
            if~isempty(restrictions)
                error(restrictions(end).Reason);
            end
            this.setValueImpl(value);
        end


        function min=get.Min(this)
            restrictions=this.getMinReadRestrictionsImpl();
            if~isempty(restrictions)
                error(restrictions(end).Reason);
            end
            min=getMinImpl(this);
        end

        function set.Min(this,min)
            restrictions=this.getMinWriteRestrictionsImpl();
            if~isempty(restrictions)
                error(restrictions(end).Reason);
            end
            setMinImpl(this,min);
        end


        function max=get.Max(this)
            restrictions=this.getMaxReadRestrictionsImpl();
            if~isempty(restrictions)
                error(restrictions(end).Reason);
            end
            max=getMaxImpl(this);
        end

        function set.Max(this,max)
            restrictions=this.getMaxWriteRestrictionsImpl();
            if~isempty(restrictions)
                error(restrictions(end).Reason);
            end
            setMaxImpl(this,max);
        end


        function unit=get.Unit(this)
            restrictions=this.getUnitReadRestrictionsImpl();
            if~isempty(restrictions)
                error(restrictions(end).Reason);
            end
            unit=getUnitImpl(this);
        end

        function set.Unit(this,unit)
            restrictions=this.getUnitWriteRestrictionsImpl();
            if~isempty(restrictions)
                error(restrictions(end).Reason);
            end
            setUnitImpl(this,unit);
        end


        function fieldName=get.FieldName(this)
            restrictions=this.getFieldNameReadRestrictionsImpl();
            if~isempty(restrictions)
                error(restrictions(end).Reason);
            end
            fieldName=getFieldNameImpl(this);
        end

        function set.FieldName(this,fieldName)
            restrictions=this.getFieldNameWriteRestrictionsImpl();
            if~isempty(restrictions)
                error(restrictions(end).Reason);
            end
            setFieldNameImpl(this,fieldName);
        end


        function description=get.Description(this)
            restrictions=this.getDescriptionReadRestrictionsImpl();
            if~isempty(restrictions)
                error(restrictions(end).Reason);
            end
            description=getDescriptionImpl(this);
        end

        function set.Description(this,description)
            restrictions=this.getDescriptionWriteRestrictionsImpl();
            if~isempty(restrictions)
                error(restrictions(end).Reason);
            end
            setDescriptionImpl(this,description);
        end
    end

    methods(Abstract,Access=protected)

        restrictions=getValueReadRestrictionsImpl(this);

        restrictions=getValueWriteRestrictionsImpl(this);

        value=getValueImpl(this);

        setValueImpl(this,value);


        restrictions=getMinReadRestrictionsImpl(this);

        restrictions=getMinWriteRestrictionsImpl(this);

        min=getMinImpl(this);

        setMinImpl(this,min);


        restrictions=getMaxReadRestrictionsImpl(this);

        restrictions=getMaxWriteRestrictionsImpl(this);

        max=getMaxImpl(this);

        setMaxImpl(this,max);


        restrictions=getUnitReadRestrictionsImpl(this);

        restrictions=getUnitWriteRestrictionsImpl(this);

        unit=getUnitImpl(this);

        setUnitImpl(this,unit);


        restrictions=getFieldNameReadRestrictionsImpl(this);

        restrictions=getFieldNameWriteRestrictionsImpl(this);

        fieldName=getFieldNameImpl(this);

        setFieldNameImpl(this,fieldName);


        restrictions=getDescriptionReadRestrictionsImpl(this);

        restrictions=getDescriptionWriteRestrictionsImpl(this);

        description=getDescriptionImpl(this);

        setDescriptionImpl(this,description);
    end
end
