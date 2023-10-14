classdef ( Abstract )SimulationRunner < handle
    properties
        ModelName
        Options
        NumSims
        ModelToApply
    end

    properties ( Hidden = true )
        ParallelBuildFcn = @( in )MultiSim.internal.doParallelBuild( in )
    end

    properties ( GetAccess = protected, SetAccess = immutable )
        Config
    end

    properties ( Transient, SetAccess = immutable )
        ForRunAll( 1, 1 )logical
    end

    properties ( Constant, Access = private )
        DefaultConfig = MultiSim.internal.SimulationRunnerConfig
    end

    properties ( Transient = true, Access = protected )
        WorkingDir

        SimulationDebugger
        SignalsToUnlog = Simulink.SimulationData.SignalLoggingInfo.empty
        OldDLO
        OldDirtyFlag
    end

    properties ( Transient = true )
        CancelRequested = false
    end

    properties ( Abstract, SetAccess = protected )






        SingleSimOutputType
    end

    properties ( Abstract, SetAccess = protected, Hidden = true )
        MultiSimRunningMessage
    end

    properties ( Access = protected )
        AllModels string
    end

    methods ( Abstract )


        out = executeImpl( obj, fh, simIns )
        cancel( obj, runId )
        dispatchRunsIfNeeded( obj )
        assignOutputsOnSimManager( ob )
    end

    events


        SimulationOutputAvailable


        ProgressMessageGenerated


        SimulationAborted







        SimulationFinishedRunning



        AllSimulationsQueued
    end

    methods

        function obj = SimulationRunner( simMgr, namedargs )
            arguments
                simMgr( 1, 1 )Simulink.SimulationManager
                namedargs.Config( 1, 1 )MultiSim.internal.SimulationRunnerConfig = MultiSim.internal.SimulationRunner.DefaultConfig
            end

            obj.Config = namedargs.Config;

            obj.ForRunAll = simMgr.ForRunAll;


            obj.Options = simMgr.Options;



            obj.ModelName = simMgr.ModelName;
            obj.NumSims = numel( simMgr.SimulationInputs );

            obj.AllModels = string( simMgr.AllModelNames );

            obj.WorkingDir = pwd;
            obj.ModelToApply = '';
            if ~isempty( simMgr.SimulationInputs )
                obj.ModelToApply = simMgr.SimulationInputs( 1 ).getModelNameForApply;
            end
        end

        function out = connectToSimulation( obj, runId )
            obj.SimulationDebugger.connect( runId );
            out = obj.SimulationDebugger;
        end

        function delete( obj )
            delete( obj.SimulationDebugger );
        end
    end


    methods

        function setup( obj )

            obj.runSetupFcn(  );
        end


        function setupSims( ~, ~ )

        end


        function cleanup( obj )

            obj.runCleanupFcn(  );
        end
    end


    methods ( Access = protected )
        function doParallelBuild( obj )
            load_system( obj.ModelName );
            if strcmp( get_param( obj.ModelName, 'EnableParallelModelReferenceBuilds' ), 'off' )
                return ;
            end
            obj.notifyProgress( message( 'Simulink:MultiSim:ParallelModelRefBuild' ) );
            try
                defaultSimIn = Simulink.SimulationInput( obj.ModelName );
                obj.ParallelBuildFcn( defaultSimIn );
            catch ME
                msld = MSLDiagnostic( ME );
                buildErrorsDiscardList = { 'Simulink:slbuild:poolArchInconsistent',  ...
                    'Simulink:slbuild:parallelFileSystemInaccessible',  ...
                    'Simulink:slbuild:CoverageParallelBuild',  ...
                    'Simulink:slbuild:NoCommonCompiler' };

                cause = [  ];
                for i = 1:numel( buildErrorsDiscardList )
                    matchingCauses = msld.findID( buildErrorsDiscardList{ i } );
                    if ~isempty( matchingCauses )
                        cause = matchingCauses{ 1 };
                        break ;
                    end
                end

                if ~isempty( cause )
                    cause = MSLException( cause );
                    err = MException( message( 'Simulink:MultiSim:ParallelModelRefBuildFailed' ) );
                    err = err.addCause( cause );
                    obj.reportAsWarning( err );
                else
                    rethrow( ME );
                end
            end
        end

        function reportAsWarning( obj, ME )

            warnState = warning( 'query', 'backtrace' );
            oc = onCleanup( @(  )warning( warnState ) );
            warning off backtrace;
            msld = MSLDiagnostic( ME );
            msld.reportAsWarning( obj.ModelName, false );
        end

        function runSetupFcn( obj )
            try
                if ~isempty( obj.Options.SetupFcn )
                    obj.notifyProgress( message( 'Simulink:MultiSim:RunGeneric', 'SetupFcn' ) );
                    obj.Options.SetupFcn(  );
                end
            catch ME


                err = MException( message( 'Simulink:Commands:SetupFcnError' ) );
                err = err.addCause( ME );
                throw( err );
            end
        end

        function runCleanupFcn( obj )
            try
                if ~isempty( obj.Options.CleanupFcn )
                    obj.notifyProgress( message( 'Simulink:MultiSim:RunGeneric', 'CleanupFcn' ) );
                    obj.Options.CleanupFcn(  );
                end
            catch ME




                err = MException( message( 'Simulink:Commands:CleanupFcnError' ) );
                err = err.addCause( ME );
                obj.reportAsWarning( err )
            end
        end

        function notifyProgress( obj, msg )
            eventData = MultiSim.internal.ProgressMessageEventData( msg );
            obj.notify( 'ProgressMessageGenerated', eventData );
        end

        function notifySimulationAborted( obj, runIds )
            eventData = MultiSim.internal.SimulationAbortedEventData( true, runIds );
            obj.notify( 'SimulationAborted', eventData );
        end

        function notifySimulationFinishedRunning( obj, runId )
            assert( isscalar( runId ),  ...
                'SimulationRunner:notifySimulationFinishedRunning runId must be a scalar' );
            msg.RunId = runId;
            eventData = MultiSim.internal.SimulationRunnerEventData( msg );
            notify( obj, 'SimulationFinishedRunning', eventData );
        end

        function out = preAllocateOutputs( obj, simIns )


            [ M, N ] = size( simIns );
            out( M, N ) = obj.SingleSimOutputType;
        end
    end

    methods ( Static, Access = protected )

        function result = wasStopRequested( out )
            result = false;
            md = out.getSimulationMetadata;
            if ( isempty( md ) || isempty( md.ExecutionInfo ) ||  ...
                    isempty( md.ExecutionInfo.ErrorDiagnostic ) ||  ...
                    isempty( md.ExecutionInfo.ErrorDiagnostic.Diagnostic ) )
                return ;
            end

            diagnostic = md.ExecutionInfo.ErrorDiagnostic.Diagnostic;

            if ( strcmp( diagnostic.identifier,  ...
                    'Simulink:Commands:SimAborted' ) ||  ...
                    strcmp( diagnostic.identifier,  ...
                    'SL_SERVICES:utils:CNTRL_C_INTERRUPTION' ) ||  ...
                    strcmp( diagnostic.identifier,  ...
                    'MATLAB:handle_graphics:exceptions:UserBreak' ) )
                result = true;
                return ;
            end


            if strfind( diagnostic.message, 'Ctrl-C' )
                result = true;
                return ;
            end
        end

        function simInput = makeLTFFileNamesUnique( simInput, workingDir )
            runNumber = simInput.RunId;

            if ( simInput.isLTFSetToOn(  ) )
                assert( isscalar( runNumber ) );
                assert( isfinite( runNumber ) );
                assert( runNumber > 0 );
                currName = simInput.getLTFName(  );
                logfileName = MultiSim.internal.getUniqueLoggingFileName( workingDir, currName, runNumber );
                simInput = simInput.addHiddenModelParameter( 'LoggingFileName', logfileName );
            end
        end

        function turnOnLoggingForSignals( sigs, topModel )


            allMdls = find_mdlrefs( topModel, 'MatchFilter', @Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices );
            for idx = 1:numel( allMdls )
                load_system( allMdls{ idx } );
            end
            for idx = 1:numel( sigs )
                bPath = sigs( idx ).BlockPath.convertToCell;
                ph = get_param( bPath{ end  }, 'PortHandles' );
                ph = ph.Outport( sigs( idx ).OutputPortIndex );
                set_param( ph, 'DataLogging', 'on' )
            end
        end
    end
end


