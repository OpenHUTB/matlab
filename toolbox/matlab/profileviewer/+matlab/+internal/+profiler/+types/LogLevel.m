classdef(Sealed)LogLevel<matlab.internal.profiler.interface.NumericEnum...
    &matlab.internal.profiler.types.MatlabConfigOption




    enumeration
        Mmex(1)
        Builtin(2)
    end

    methods(Static)
        function enumValue=fromNumericId(numericId)
            enumValue=matlab.internal.profiler.interface.NumericEnum.getEnumFromId(...
            'matlab.internal.profiler.types.LogLevel',numericId);
        end

        function out=isTypeOf(option)
            out=isa(option,'matlab.internal.profiler.types.LogLevel');
        end

        function obj=loadobj(s)
            obj=matlab.internal.profiler.types.LogLevel.fromNumericId(s.NumericId);
        end
    end
end