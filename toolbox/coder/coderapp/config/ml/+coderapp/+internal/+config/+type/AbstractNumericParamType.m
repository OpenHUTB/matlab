classdef ( Abstract )AbstractNumericParamType < coderapp.internal.config.AbstractParamType

    properties ( SetAccess = immutable, GetAccess = protected )
        NumericClass( 1, : )char
    end

    methods
        function this = AbstractNumericParamType( name, doClass, numericClass, varargin )
            arguments
                name( 1, : )char
                doClass( 1, : )char
                numericClass( 1, : )char
            end
            arguments( Repeating )
                varargin
            end

            this@coderapp.internal.config.AbstractParamType( name, doClass );
            this.NumericClass = numericClass;
        end
    end

    methods
        function adjusted = validate( this, value, dataObj )
            arguments
                this
                value{ mustBeNumeric( value ) }
                dataObj = [  ]
            end

            adjusted = this.castToExpected( value );
            this.validateArraySize( value, dataObj );
            if ~isempty( dataObj )
                if adjusted <= dataObj.Min
                    if dataObj.IncludeMin
                        if adjusted ~= dataObj.Min
                            pterror( message( 'coderApp:config:coderGeneral:numericValueMustBeGreaterThanOrEqualTo', dataObj.Min ) );
                        end
                    else
                        pterror( message( 'coderApp:config:coderGeneral:numericValueMustBeGreaterThan', dataObj.Min ) );
                    end
                elseif adjusted >= dataObj.Max
                    if dataObj.IncludeMax
                        if adjusted ~= dataObj.Max
                            pterror( message( 'coderApp:config:coderGeneral:numericValueMustBeLessThanOrEqualTo', dataObj.Max ) );
                        end
                    else
                        pterror( message( 'coderApp:config:coderGeneral:numericValueMustBeLessThan', dataObj.Max ) );
                    end
                end
            end
        end
    end

    methods ( Access = protected )
        function imported = importValue( this, value )
            imported = this.castToExpected( value );
        end

        function value = exportValue( ~, value )
        end

        function value = valueFromSchema( this, value )
            value = this.castToExpected( value );
        end
    end

    methods
        function casted = castToExpected( this, value )
            casted = cast( value, this.NumericClass );
        end
    end

    methods ( Static )
        function code = toCode( value )
            code = mat2str( value );
        end

        function str = toString( values )
            str = num2str( values );
        end
    end
end


