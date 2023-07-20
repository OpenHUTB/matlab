classdef PerVarDataType_E<uint8




    enumeration
        SS_DOUBLE_E(0)
        SS_SINGLE_E(1)
        SS_INT8_E(2)
        SS_UINT8_E(3)
        SS_INT16_E(4)
        SS_UINT16_E(5)
        SS_INT32_E(6)
        SS_UINT32_E(7)
        SS_BOOLEAN_E(8)
        INT64_E(9)
        UINT64_E(10)
    end

    methods
        function out=int2char(obj)
            out=num2str(uint8(obj));
        end
    end
end