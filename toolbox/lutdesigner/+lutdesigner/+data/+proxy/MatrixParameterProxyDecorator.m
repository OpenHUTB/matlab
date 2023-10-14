classdef ( Abstract )MatrixParameterProxyDecorator < lutdesigner.data.proxy.MatrixParameterProxy

    properties ( SetAccess = immutable, GetAccess = private )
        MatrixParameterProxy
    end

    methods
        function this = MatrixParameterProxyDecorator( matrixParameterProxy )
            arguments
                matrixParameterProxy( 1, 1 )lutdesigner.data.proxy.MatrixParameterProxy
            end
            this.MatrixParameterProxy = matrixParameterProxy;
        end
    end

    methods ( Access = protected )
        function dataUsage = listDataUsageImpl( this )
            dataUsage = this.MatrixParameterProxy.listDataUsage(  );
        end


        function restrictions = getValueReadRestrictionsImpl( this )
            restrictions = this.MatrixParameterProxy.getReadRestrictionsFor( 'Value' );
        end

        function restrictions = getValueWriteRestrictionsImpl( this )
            restrictions = this.MatrixParameterProxy.getWriteRestrictionsFor( 'Value' );
        end

        function value = getValueImpl( this )
            value = this.MatrixParameterProxy.Value;
        end

        function setValueImpl( this, value )
            this.MatrixParameterProxy.Value = value;
        end


        function restrictions = getMinReadRestrictionsImpl( this )
            restrictions = this.MatrixParameterProxy.getReadRestrictionsFor( 'Min' );
        end

        function restrictions = getMinWriteRestrictionsImpl( this )
            restrictions = this.MatrixParameterProxy.getWriteRestrictionsFor( 'Min' );
        end

        function min = getMinImpl( this )
            min = this.MatrixParameterProxy.Min;
        end

        function setMinImpl( this, min )
            this.MatrixParameterProxy.Min = min;
        end


        function restrictions = getMaxReadRestrictionsImpl( this )
            restrictions = this.MatrixParameterProxy.getReadRestrictionsFor( 'Max' );
        end

        function restrictions = getMaxWriteRestrictionsImpl( this )
            restrictions = this.MatrixParameterProxy.getWriteRestrictionsFor( 'Max' );
        end

        function max = getMaxImpl( this )
            max = this.MatrixParameterProxy.Max;
        end

        function setMaxImpl( this, max )
            this.MatrixParameterProxy.Max = max;
        end


        function restrictions = getUnitReadRestrictionsImpl( this )
            restrictions = this.MatrixParameterProxy.getReadRestrictionsFor( 'Unit' );
        end

        function restrictions = getUnitWriteRestrictionsImpl( this )
            restrictions = this.MatrixParameterProxy.getWriteRestrictionsFor( 'Unit' );
        end

        function unit = getUnitImpl( this )
            unit = this.MatrixParameterProxy.Unit;
        end

        function setUnitImpl( this, unit )
            this.MatrixParameterProxy.Unit = unit;
        end


        function restrictions = getFieldNameReadRestrictionsImpl( this )
            restrictions = this.MatrixParameterProxy.getReadRestrictionsFor( 'FieldName' );
        end

        function restrictions = getFieldNameWriteRestrictionsImpl( this )
            restrictions = this.MatrixParameterProxy.getWriteRestrictionsFor( 'FieldName' );
        end

        function fieldName = getFieldNameImpl( this )
            fieldName = this.MatrixParameterProxy.FieldName;
        end

        function setFieldNameImpl( this, fieldName )
            this.MatrixParameterProxy.FieldName = fieldName;
        end


        function restrictions = getDescriptionReadRestrictionsImpl( this )
            restrictions = this.MatrixParameterProxy.getReadRestrictionsFor( 'Description' );
        end

        function restrictions = getDescriptionWriteRestrictionsImpl( this )
            restrictions = this.MatrixParameterProxy.getWriteRestrictionsFor( 'Description' );
        end

        function description = getDescriptionImpl( this )
            description = this.MatrixParameterProxy.Description;
        end

        function setDescriptionImpl( this, description )
            this.MatrixParameterProxy.Description = description;
        end
    end
end


