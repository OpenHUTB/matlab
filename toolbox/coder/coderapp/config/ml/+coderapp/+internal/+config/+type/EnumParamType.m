classdef ( Sealed )EnumParamType < coderapp.internal.config.type.AbstractEnumParamType

    methods
        function this = EnumParamType(  )
            this@coderapp.internal.config.type.AbstractEnumParamType( 'enum',  ...
                'coderapp.internal.config.data.EnumParamData' );
        end
    end

    methods
        function adjusted = validate( this, value, dataObj )
            arguments
                this
                value{ mustBeTextScalar( value ) }
                dataObj = [  ]
            end
            adjusted = char( value );
            this.checkEnumValue( adjusted, dataObj );
        end
    end

    methods ( Access = protected )
        function imported = importValue( this, value )
            imported = this.toChar( value );
        end

        function value = exportValue( ~, value )
        end

        function value = valueFromSchema( this, value )
            value = this.toChar( value );
        end
    end

    methods ( Static )
        function value = toChar( value )
            arguments
                value{ mustBeTextScalar( value ) }
            end
            value = char( value );
        end
    end
end



