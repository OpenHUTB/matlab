
classdef(Enumeration)OPTYPE<Simulink.IntEnumType
    enumeration
        UNKNOWN(0)
        ADD(1)
        MULT(2)
        DIV(3)
        RELOP(4)
        DELAY(5)
        SFEML(6)
        INSTANCE(7)
    end
    methods(Static=true)
        function retVal=getDefaultValue()
            retVal=BA.Abstraction.OPTYPE.UNKNOWN;
        end
    end
end
