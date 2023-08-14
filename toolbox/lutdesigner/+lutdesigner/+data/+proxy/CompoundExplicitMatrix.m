classdef CompoundExplicitMatrix<lutdesigner.data.proxy.CompoundMatrixParameter

    properties(SetAccess=immutable,GetAccess=private)
ValueSource
    end

    methods
        function this=CompoundExplicitMatrix(valueSource,varargin)
            this=this@lutdesigner.data.proxy.CompoundMatrixParameter(varargin{:});
            this.ValueSource=valueSource;
        end
    end

    methods(Access=protected)
        function dataUsage=listDataUsageImpl(this)
            dataUsage=[
            listDataUsageImpl@lutdesigner.data.proxy.CompoundMatrixParameter(this)
            lutdesigner.data.proxy.DataUsage(this.ValueSource,'/Value')
            ];
        end


        function restrictions=getValueReadRestrictionsImpl(this)
            restrictions=this.ValueSource.getReadRestrictions();
        end

        function restrictions=getValueWriteRestrictionsImpl(this)
            restrictions=this.ValueSource.getWriteRestrictions();
        end

        function value=getValueImpl(this)
            value=this.readNumericSource(this.ValueSource);
        end

        function setValueImpl(this,value)
            this.writeNumericSource(this.ValueSource,value);
        end


        function restrictions=getFieldNameReadRestrictionsImpl(this)
            if this.isMetaFieldSpecified('FieldName')
                restrictions=getFieldNameReadRestrictionsImpl@lutdesigner.data.proxy.CompoundMatrixParameter(this);
            else
                restrictions=this.ValueSource.getReadRestrictions();
            end
        end

        function restrictions=getFieldNameWriteRestrictionsImpl(this)
            if this.isMetaFieldSpecified('FieldName')
                restrictions=getFieldNameWriteRestrictionsImpl@lutdesigner.data.proxy.CompoundMatrixParameter(this);
            else
                restrictions=lutdesigner.data.restriction.WriteRestriction('lutdesigner:data:fieldNameUsedAsID');
            end
        end

        function fieldName=getFieldNameImpl(this)
            if this.isMetaFieldSpecified('FieldName')
                fieldName=getFieldNameImpl@lutdesigner.data.proxy.CompoundMatrixParameter(this);
            else
                fieldName=this.ValueSource.Name;
            end
        end

        function setFieldNameImpl(this,fieldName)
            if this.isMetaFieldSpecified('FieldName')
                setFieldNameImpl@lutdesigner.data.proxy.CompoundMatrixParameter(this,fieldName);
            end
        end
    end
end
