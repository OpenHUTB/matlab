classdef(Sealed)HistoryTracking<matlab.internal.profiler.interface.NumericEnum...
    &matlab.internal.profiler.types.MatlabConfigOption




    enumeration
        Off(0)
        On(1)
        TimeStamp(2)
        Mock(3)
    end

    methods(Static)
        function enumValue=fromNumericId(numericId)
            enumValue=matlab.internal.profiler.interface.NumericEnum.getEnumFromId(...
            'matlab.internal.profiler.types.HistoryTracking',numericId);
        end

        function out=isTypeOf(option)
            out=isa(option,'matlab.internal.profiler.types.HistoryTracking');
        end

        function obj=loadobj(s)
            obj=matlab.internal.profiler.types.HistoryTracking.fromNumericId(s.NumericId);
        end
    end
end