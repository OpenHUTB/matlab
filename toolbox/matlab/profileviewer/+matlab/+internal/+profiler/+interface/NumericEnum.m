classdef ( Abstract )NumericEnum

    properties ( SetAccess = immutable, GetAccess = private )
        NumericId
    end

    methods ( Static, Abstract )
        enumValue = fromNumericId( numericId )
        obj = loadobj( s )
    end

    methods
        function obj = NumericEnum( numericId )
            arguments
                numericId( 1, 1 ){ mustBeInteger, mustBeNonnegative }
            end

            obj.NumericId = numericId;
        end

        function id = toNumericId( obj )
            id = obj.NumericId;
        end

        function sobj = saveobj( obj )
            sobj.NumericId = obj.NumericId;
        end
    end

    methods ( Static, Access = protected )
        function enumVal = getEnumFromId( enumClassName, numericId )
            arguments
                enumClassName( 1, : ){ mustBeText }
                numericId( 1, 1 ){ mustBeInteger, mustBeNonnegative }
            end

            enumValues = enumeration( enumClassName );
            enumVal = enumValues( arrayfun( @( x )x.NumericId, enumValues ) == numericId );
        end
    end
end

