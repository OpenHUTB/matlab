classdef MatrixParameterWithImposedUnit<lutdesigner.data.proxy.MatrixParameterWithImposedMetaField

    methods
        function this=MatrixParameterWithImposedUnit(matrixParameterProxy,unitSource)
            this=this@lutdesigner.data.proxy.MatrixParameterWithImposedMetaField(matrixParameterProxy,'Unit',unitSource);
        end
    end

    methods(Access=protected)
        function restrictions=getUnitReadRestrictionsImpl(this)
            restrictions=this.getImposedMetaFieldReadRestrictions();
        end

        function restrictions=getUnitWriteRestrictionsImpl(this)
            restrictions=this.getImposedMetaFieldWriteRestrictions();
        end

        function unit=getUnitImpl(this)
            unit=this.getImposedMetaField();
        end

        function setUnitImpl(this,unit)
            this.setImposedMetaField(unit);
        end
    end
end
