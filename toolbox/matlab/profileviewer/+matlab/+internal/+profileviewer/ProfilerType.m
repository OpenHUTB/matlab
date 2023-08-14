classdef ProfilerType




    enumeration
NONE
MATLAB
MPI
    end

    methods
        function obj=ProfilerType
            mlock;
        end
    end

    methods(Static)
        function type=fromChar(str)
            import matlab.internal.profileviewer.ProfilerType;
            switch str
            case{'NONE',''}
                type=ProfilerType.NONE;
            case 'MATLAB'
                type=ProfilerType.MATLAB;
            case 'MPI'
                type=ProfilerType.MPI;
            otherwise
                error(message('MATLAB:profiler:InvalidProfilerType'));
            end
        end
    end
end

