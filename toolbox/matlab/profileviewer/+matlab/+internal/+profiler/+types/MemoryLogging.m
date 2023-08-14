classdef(Sealed)MemoryLogging<matlab.internal.profiler.interface.NumericEnum...
    &matlab.internal.profiler.types.MatlabConfigOption




    enumeration
        Off(1)
        CallMemory(2)
        On(3)
    end

    methods(Static)
        function enumValue=fromNumericId(numericId)
            enumValue=matlab.internal.profiler.interface.NumericEnum.getEnumFromId(...
            'matlab.internal.profiler.types.MemoryLogging',numericId);
        end

        function out=isTypeOf(option)
            out=isa(option,'matlab.internal.profiler.types.MemoryLogging');
        end

        function obj=loadobj(s)
            obj=matlab.internal.profiler.types.MemoryLogging.fromNumericId(s.NumericId);
        end
    end
end
