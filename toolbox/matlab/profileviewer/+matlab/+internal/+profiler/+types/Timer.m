classdef(Sealed)Timer<matlab.internal.profiler.interface.NumericEnum...
    &matlab.internal.profiler.types.MatlabConfigOption




    enumeration
        Mock(5)
        Processor(4)
        Performance(3)
        Real(2)
        Cpu(1)
        None(0)
    end

    methods(Static)
        function enumValue=fromNumericId(numericId)
            enumValue=matlab.internal.profiler.interface.NumericEnum.getEnumFromId(...
            'matlab.internal.profiler.types.Timer',numericId);
        end

        function out=isTypeOf(option)
            out=isa(option,'matlab.internal.profiler.types.Timer');
        end

        function obj=loadobj(s)
            obj=matlab.internal.profiler.types.Timer.fromNumericId(s.NumericId);
        end
    end
end
