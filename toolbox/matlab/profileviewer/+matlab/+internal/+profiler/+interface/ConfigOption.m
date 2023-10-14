classdef ( Abstract )ConfigOption < matlab.mixin.Heterogeneous

    properties ( Abstract, Constant, Access = protected )

        CompatibleProfilerType
    end

    methods
        function compatible = isCompatible( obj, profilerType )



            arguments
                obj
                profilerType( 1, 1 )matlab.internal.profiler.ProfilerType
            end

            compatible = isequal( profilerType, obj.CompatibleProfilerType );
        end
    end

    methods ( Abstract, Static )
        out = isTypeOf( option )
    end
end

