classdef ( Sealed )HistorySize < matlab.internal.profiler.types.MatlabConfigOption

    properties ( SetAccess = immutable )
        SizeOfHistory
    end

    methods
        function obj = HistorySize( size )
            arguments
                size( 1, 1 ){ mustBePositive, mustBeInteger }
            end

            obj.SizeOfHistory = size;
        end
    end

    methods ( Static )
        function out = isTypeOf( option )
            out = isa( option, 'matlab.internal.profiler.types.HistorySize' );
        end
    end
end
