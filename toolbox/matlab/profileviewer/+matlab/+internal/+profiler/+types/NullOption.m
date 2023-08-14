classdef(Sealed)NullOption<matlab.internal.profiler.interface.ConfigOption




    properties(Constant,Access=protected)
        CompatibleProfilerType=matlab.internal.profiler.ProfilerType.Matlab;
    end

    methods(Static)
        function out=isTypeOf(~)
            out=false;
        end
    end
end
