classdef ( Abstract )SimulationRunnerRapidBase < MultiSim.internal.SimulationRunnerParallelBase
    methods
        function obj = SimulationRunnerRapidBase( simMgr, pool )
            arguments
                simMgr( 1, 1 )Simulink.SimulationManager
                pool( 1, 1 )parallel.Pool = gcp
            end

            obj = obj@MultiSim.internal.SimulationRunnerParallelBase( simMgr, pool );
            obj.SingleSimOutputType = Simulink.SimulationOutput;
            obj.MultiSimRunningMessage =  ...
                message( 'Simulink:Commands:MultiSimRunningSimOnThreadWorkers' );
        end
    end


    methods
        function simOut = executeImpl( obj, fh, simIns )
            obj.NumSims = numel( simIns );


            obj.setupSims( simIns );
            obj.disableSDIStreaming(  );
            simIns = obj.setupLogging( simIns );
            for i = 1:obj.NumSims
                simIns( i ) = obj.setupSimulationInput( simIns( i ) );
            end

            eventData = MultiSim.internal.SimulationRunnerEventData( [  ] );
            notify( obj, 'AllSimulationsQueued', eventData );

            simOut = obj.preAllocateOutputs( simIns );%#ok<NASGU>

            simOut = obj.runLightweightSim( fh, simIns, simOut );



            if obj.CancelRequested || obj.wasStopRequested( simOut )

                evtData = MultiSim.internal.SimulationAbortedEventData( true, simIns( 1 ).RunId:obj.NumSims );
                obj.notify( 'SimulationAborted', evtData );

                err = MException( message( 'Simulink:Commands:SimAborted' ) );
                msld = MSLDiagnostic( err );
                msld.reportAsError( obj.ModelName, false );
            end

        end

    end

    methods ( Abstract, Access = protected )
        simInputs = setupLogging( obj, simInputs )
    end

    methods ( Access = private )
        function simOut = runLightweightSim( obj, fh, simInputs, simOut )
            assert( numel( simInputs ) == obj.NumSims );
            assert( numel( simOut ) == obj.NumSims );


            multisimInfo.dataQueue = parallel.pool.DataQueue;
            afterEach( multisimInfo.dataQueue, @( simOutInfo )obj.notifySimulationFinished( simOutInfo ) );
            multisimInfo.verboseQueue = parallel.pool.DataQueue;
            afterEach( multisimInfo.verboseQueue, @( verboseInfo )obj.dispVerboseInfo( verboseInfo ) );

            if isa( obj.Pool, 'parallel.ThreadPool' )


                simOut = simulink.rapidaccelerator.internal.runParallelSimOnProcessWorker(  ...
                    fh, simInputs, multisimInfo );
            else

                nWorker = min( [ obj.Pool.NumWorkers, obj.NumSims ] );
                nSimIn = ceil( obj.NumSims / nWorker );
                runFutures( 1:nWorker ) = parallel.FevalFuture;
                for wIdx = 1:nWorker
                    simInBegin = ( wIdx - 1 ) * nSimIn + 1;
                    simInEnd = min( [ simInBegin + nSimIn - 1, obj.NumSims ] );
                    runFutures( wIdx ) = obj.Pool.parfeval(  ...
                        @simulink.rapidaccelerator.internal.runParallelSimOnProcessWorker,  ...
                        1,  ...
                        fh,  ...
                        simInputs( simInBegin:simInEnd ),  ...
                        multisimInfo );
                end
                out = runFutures.fetchOutputs( 'UniformOutput', false );


                nCell = numel( out );
                simOutIdx = 1;
                for i = 1:nCell
                    nOut = numel( out{ i } );
                    for j = 1:nOut
                        simOut( simOutIdx ) = out{ i }( j );
                        simOutIdx = simOutIdx + 1;
                    end
                end
            end

        end


        function disableSDIStreaming( obj )
            parfevalOnAll( obj.Pool, @Simulink.sdi.enablePCTSupport, 0, false );
        end

        function notifySimulationFinished( obj, simOutInfo )
            obj.notifySimulationFinishedRunning( simOutInfo.runId );
            obj.notify( 'SimulationOutputAvailable',  ...
                MultiSim.internal.SimulationOutputAvailableEventData(  ...
                simOutInfo.simOut, simOutInfo.runId ) );
        end

        function dispVerboseInfo( ~, verboseInfo )
            try
                env_value = getenv( 'RAPID_ACCELERATOR_OPTIONS_VERBOSE' );
                if ( ~isempty( env_value ) )

                    isVerbose = str2double( env_value );
                else
                    isVerbose = evalin( 'base', 'rapidAcceleratorOptions.verbose' );
                end
                if ( isVerbose )
                    disp( verboseInfo );
                end
            catch E %#ok


            end
        end
    end


end


