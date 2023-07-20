classdef MemoryUnit<double













    enumeration
        bits(1)
        bytes(8)
        Kb(1000)
        Kibit(1024)
        KB(8000)
        KiB(8192)
        Mb(1000000)
        Mibit(1048576)
        MB(8000000)
        MiB(8388608)
        Gb(1000000000)
        Gibit(1073741824)
        GB(8000000000)
        GiB(8589934592)
    end

    methods(Static)
        function conversionFactor=getConversionFactor(memoryUnit1,memoryUnit2)


            memoryUnit1=convertStringsToChars(memoryUnit1);
            memoryUnit2=convertStringsToChars(memoryUnit2);
            if ischar(memoryUnit1)
                memoryUnit1=FunctionApproximation.internal.MemoryUnit(memoryUnit1);
            end
            if ischar(memoryUnit2)
                memoryUnit2=FunctionApproximation.internal.MemoryUnit(memoryUnit2);
            end
            conversionFactor=double(memoryUnit1)/double(memoryUnit2);
        end

        function defaultEnum=getDefault()


            defaultEnum=FunctionApproximation.internal.MemoryUnit.bits;
        end
    end
end