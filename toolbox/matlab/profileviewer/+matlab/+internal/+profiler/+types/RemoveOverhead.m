classdef(Sealed)RemoveOverhead<matlab.internal.profiler.interface.NumericEnum...
    &matlab.internal.profiler.types.MatlabConfigOption




    enumeration
        Off(0)
        On(1)
    end

    methods(Static)
        function enumValue=fromNumericId(numericId)
            enumValue=matlab.internal.profiler.interface.NumericEnum.getEnumFromId(...
            'matlab.internal.profiler.types.RemoveOverhead',numericId);
        end

        function out=isTypeOf(option)
            out=isa(option,'matlab.internal.profiler.types.RemoveOverhead');
        end

        function obj=loadobj(s)
            obj=matlab.internal.profiler.types.RemoveOverhead.fromNumericId(s.NumericId);
        end
    end
end
