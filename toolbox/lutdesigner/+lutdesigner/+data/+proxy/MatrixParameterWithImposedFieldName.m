classdef MatrixParameterWithImposedFieldName<lutdesigner.data.proxy.MatrixParameterWithImposedMetaField

    methods
        function this=MatrixParameterWithImposedFieldName(matrixParameterProxy,fieldNameSource)
            this=this@lutdesigner.data.proxy.MatrixParameterWithImposedMetaField(matrixParameterProxy,'FieldName',fieldNameSource);
        end
    end

    methods(Access=protected)
        function restrictions=getFieldNameReadRestrictionsImpl(this)
            restrictions=this.getImposedMetaFieldReadRestrictions();
        end

        function restrictions=getFieldNameWriteRestrictionsImpl(this)
            restrictions=this.getImposedMetaFieldWriteRestrictions();
        end

        function fieldName=getFieldNameImpl(this)
            fieldName=this.getImposedMetaField();
        end

        function setFieldNameImpl(this,fieldName)
            this.setImposedMetaField(fieldName);
        end
    end
end
