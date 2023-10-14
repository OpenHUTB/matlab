classdef SimulationRunnerParallelLocal < MultiSim.internal.SimulationRunnerParallelBase
    properties ( Constant, Access = private )
        DefaultConfig = MultiSim.internal.SimulationRunnerParallelLocalConfig
    end

    methods
        function obj = SimulationRunnerParallelLocal( simMgr, pool, namedargs )
            arguments
                simMgr( 1, 1 )Simulink.SimulationManager
                pool( 1, 1 )parallel.Pool = gcp
                namedargs.Config( 1, 1 )MultiSim.internal.SimulationRunnerParallelLocalConfig = MultiSim.internal.SimulationRunnerParallelLocal.DefaultConfig
            end

            namedargsCell = namedargs2cell( namedargs );
            obj = obj@MultiSim.internal.SimulationRunnerParallelBase( simMgr, pool, namedargsCell{ : } );
        end
    end


    methods
        function ActualSimulationInputs = setup( obj, ActualSimulationInputs )


            obj.cacheWorkerInitialDirectory(  );


            obj.loadSimulinkOnWorkers(  );


            obj.setupDataDictionaryCache(  );


            obj.attachFiles(  );



            load_system( obj.ModelName )
            modelFile = which( obj.ModelName );
            modelPath = fileparts( modelFile );
            parfevalOnAll( obj.Pool, @addpath, 0, modelPath );


            projectRoot = obj.getProjectRoot(  );
            if ~isempty( projectRoot ) && MultiSim.internal.isProjectLoaded( projectRoot )
                obj.notifyProgress( message( 'Simulink:MultiSim:LoadingProjectOnWorkers' ) );
                parfevalOnAll( obj.Pool, @locSetupProject, 0, projectRoot );
            end


            obj.attachSetupFcnDependencies(  );
            obj.attachCleanupFcnDependencies(  );


            obj.setupWorkersAndBuild(  );


            updateAttachedFiles( obj.Pool )


            ActualSimulationInputs = obj.setupFastRestart( ActualSimulationInputs );



            obj.enableFutureCompletedEvent(  );
        end

        function arg = createExecutionArgs( obj, fh, simInput )
            simInput = obj.setupSimulationInput( simInput );
            arg = { fh, simInput, obj.WorkingDir };
        end

        function addDataToSimFuture( ~, ~, ~ )
        end

        function execFh = executeFcnHandle( ~ )
            execFh = @localExecute;
        end

        function cleanup( obj )
            obj.notifyProgress( message( 'Simulink:MultiSim:CleaningupWorkers' ) );


            if ~isa( obj.Pool, 'parallel.Pool' ) || ~isvalid( obj.Pool ) || ~obj.Pool.Connected

                return ;
            end

            delete( obj.FutureCompletedListener );
            obj.FutureCompletedListener = [  ];
            obj.Pool.FevalQueue.hToggleCallbacks( obj.ToggleCallbacksValue );
            obj.runCleanupFcn(  );

            obj.closeProject(  );
            obj.resetCurrentDir(  );
            obj.cleanupDataDictionaryCache(  );
            obj.clearSDIRepositoryFile(  );
            obj.showFinalJobDiagnostic(  );
        end

        function cancel( obj, runId )


            if nargin == 1
                runId = [  ];
            end
            obj.cancelFuture( runId );
        end
    end
end

function out = localExecute( fh, simInp, workingDir )
load_system( simInp.ModelName );
simInp.SimulationDirectory = workingDir;
simInp = MultiSim.internal.SimulationRunner.makeLTFFileNamesUnique( simInp, workingDir );
runNumStr = num2str( simInp.RunId );
simInp = simInp.addHiddenModelParameter( 'ConcurrencyResolvingToFileSuffix', [ '_', runNumStr ] );
simInp = SlCov.CoverageAPI.setupSimInputForCoverage( simInp, workingDir );
out = MultiSim.internal.runSingleSim( fh, simInp );

simulink.multisim.internal.debuglog( "SDI: Cleaning up worker after parsim" );

fs = dir( Simulink.sdi.getSource(  ) );


heuristicSizeInBytes = 10 * 1024 * 1024;
actualSizeInBytes = fs.bytes;
if actualSizeInBytes > heuristicSizeInBytes
    Simulink.sdi.internal.cleanupWorkerAfterParsim(  );
end
end

function locSetupProject( projectRoot )


simulink.multisim.internal.debuglog( "Loading project" );
project = simulinkproject( projectRoot );
instance = MultiSim.internal.WorkerTempStorage.getInstance(  );
instance.store( 'parsimProject', project' );
end


