

classdef AutoscalerDataTypes





    properties
Value
    end
    methods
        function c=AutoscalerDataTypes(val)
            c.Value=int32(val);
        end
    end
    enumeration
        Unknown(0)
        FloatingPoint(1)
        FixedPoint(2)
        Inherited(3)
        AliasType(4)
        Enum(5)
        Boolean(6)
        Bus(7)
    end
end
