classdef ( Sealed )EnumArrayParamType < coderapp.internal.config.type.AbstractEnumParamType



    methods
        function this = EnumArrayParamType(  )
            this@coderapp.internal.config.type.AbstractEnumParamType( 'enum[]',  ...
                'coderapp.internal.config.data.EnumArrayParamData' );
        end
    end

    methods
        function adjusted = validate( this, value, dataObj )
            arguments
                this
                value{ mustBeText( value ) }
                dataObj = [  ]
            end
            adjusted = cellstr( value );
            this.checkEnumValue( adjusted, dataObj );
            this.validateArraySize( adjusted, dataObj );
        end
    end

    methods ( Access = protected )
        function imported = importValue( this, value )
            imported = this.toCellStr( value );
        end

        function value = exportValue( ~, value )
        end

        function value = valueFromSchema( this, value )
            value = this.toCellStr( value );
        end
    end

    methods ( Static )
        function value = toCellStr( value )
            arguments
                value{ mustBeText( value ) }
            end
            value = cellstr( value );
        end
    end
end



