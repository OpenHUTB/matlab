classdef ProfilerType

    enumeration
        Matlab
        Pool
    end

    methods ( Static )
        function type = fromString( str )
            arguments
                str{ mustBeTextScalar }
            end

            import matlab.internal.profiler.ProfilerType;
            switch str
                case 'Matlab'
                    type = ProfilerType.Matlab;
                case 'Pool'
                    type = ProfilerType.Pool;
                otherwise
                    error( message( 'MATLAB:profiler:InvalidProfilerType', str ) );
            end
        end

        function executionOrder = getDefaultExecutionOrder(  )


            import matlab.internal.profiler.ProfilerType

            executionOrder = [ ProfilerType.Matlab, ProfilerType.Pool ];
        end

        function executionOrder = getExecutionOrderForAction( action )
            arguments
                action( 1, 1 )matlab.internal.profiler.interface.ProfilerAction
            end

            import matlab.internal.profiler.interface.ProfilerAction
            import matlab.internal.profiler.ProfilerType





            switch action
                case ProfilerAction.On


                    executionOrder = [ ProfilerType.Pool, ProfilerType.Matlab ];
                case ProfilerAction.Off


                    executionOrder = [ ProfilerType.Matlab, ProfilerType.Pool ];
                case ProfilerAction.Resume


                    executionOrder = [ ProfilerType.Pool, ProfilerType.Matlab ];
                case ProfilerAction.Clear
                    executionOrder = ProfilerType.getDefaultExecutionOrder(  );
                case ProfilerAction.Reset
                    executionOrder = ProfilerType.getDefaultExecutionOrder(  );
                case ProfilerAction.Status
                    executionOrder = ProfilerType.getDefaultExecutionOrder(  );
                case ProfilerAction.Info
                    executionOrder = ProfilerType.getDefaultExecutionOrder(  );
                otherwise
                    executionOrder = matlab.internal.profiler.ProfilerType.empty(  );
            end
        end
    end
end

