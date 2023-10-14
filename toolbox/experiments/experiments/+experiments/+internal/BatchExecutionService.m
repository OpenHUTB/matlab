classdef BatchExecutionService < handle

    methods
        function runInfo = execSubmitBatchJob( this, expDef, clusterName, poolSizeStr, mode )
            arguments
                this
                expDef
                clusterName
                poolSizeStr
                mode = 'batch_simultaneous'
            end
            import experiments.internal.ExperimentException

            if strcmp( mode, 'batch_simultaneous' )
                modeMsg = message( 'experiments:manager:ExpExectionMode_Batch_Simultaneous' ).getString(  );
            else
                modeMsg = message( 'experiments:manager:ExpExectionMode_Batch_Sequential' ).getString(  );
            end
            if ~matlab.internal.parallel.isPCTInstalled
                throw( ExperimentException( message( 'experiments:manager:NoParallelInstalled', modeMsg ) ) );
            end
            if ~matlab.internal.parallel.isPCTLicensed
                throw( ExperimentException( message( 'experiments:manager:NoParallelLicense', modeMsg ) ) );
            end

            try
                cluster = parcluster( clusterName );
            catch ME
                throw( ExperimentException( ME ) );
            end
            poolSize = str2double( poolSizeStr );
            if poolSize < 0 || floor( poolSize ) ~= poolSize
                throw( ExperimentException( message( 'experiments:manager:InvalidPoolSize', poolSizeStr ) ) );
            end

            if strcmp( mode, 'batch_simultaneous' ) && poolSize < 1
                modeMsg = message( 'experiments:manager:ExpExectionMode_Batch_Simultaneous' ).getString(  );
                throw( ExperimentException( message( 'experiments:manager:InvalidPoolSize1', modeMsg ) ) );
            end

            runInfo = this.execExperimentInitRun( expDef,  - 1, true );
            if ~isempty( runInfo.error )
                this.rsSetRun( runInfo );
                return ;
            end

            snapshotDir = fullfile( this.getResultsDir(  ), runInfo.runID, 'Snapshot' );
            prj = currentProject;
            tag = message( 'experiments:manager:BatchJobTag', runInfo.runLabel, runInfo.expName, char( prj.Name ) ).getString(  );
            runInfo.job.ClusterProfile = cluster.Profile;
            runInfo.job.trainingType = expDef.Process.Type;
            runInfo.job.refreshTime = experiments.internal.getCurrentTimeString(  );
            useKVStore = ~isempty( which( 'getCurrentValueStore' ) );

            if ~useKVStore
                job2 = createJob( cluster, 'Tag', tag );
                runInfo.job.ID = [  - 1, job2.ID ];
                tsk = createTask( job2, @( ~ )[  ], 0, {  }, 'Name', 'RunInfo' );
                tsk.InputArguments = { runInfo };
            else
                runInfo.job.ID = [  - 1,  - 1 ];
            end
            try
                job = batch( cluster,  ...
                    @experiments.internal.BatchExecutionService.runBatchExperiment,  ...
                    0,  ...
                    { expDef, runInfo, strcmp( mode, 'batch_simultaneous' ) },  ...
                    'Pool', poolSize,  ...
                    'CurrentFolder', '.',  ...
                    'AttachedFiles', snapshotDir,  ...
                    'AutoAddClientPath', false,  ...
                    'AutoAttachFiles', false );
            catch ME
                ME = experiments.internal.ExperimentException( ME );
                runInfo.error = this.getErrorReport( ME );
                this.rsSetRun( runInfo );
                return ;
            end
            runInfo.job.State = job.State;
            if ~useKVStore
                runInfo.job.ID = [ job.ID, job2.ID ];
                tsk.InputArguments = { runInfo };
            else
                runInfo.job.ID = [ job.ID,  - 1 ];
                store = job.ValueStore;
                store( 'RunInfo' ) = runInfo;
            end
            job.Tag = tag;

            this.rsSetRun( runInfo );
        end

        function res = execGetClusterList( ~ )
            [ res.list, res.def ] = parallel.listProfiles(  );
        end

        function out = execDeleteBatchJob( this, runID )
            [ job, out.errorMsg ] = this.getJobFromRunID( runID );
            if ~isempty( out.errorMsg )
                return ;
            end
            job.delete(  );
            this.cancelTrials( runID, true, 'deleted' );
            out.job = this.rsGetRun( runID ).job;
            this.emit( "endBatchRun", runID );
        end

        function out = execStopBatchJob( this, runID )
            [ job, out.errorMsg ] = this.getJobFromRunID( runID );
            if ~isempty( out.errorMsg )
                return ;
            end
            job.cancel(  );
            out = this.execCheckBatchJob( runID );
            this.cancelTrials( runID, false, 'canceled' );
            out.newRunInfo = this.rsGetRun( runID );
            this.emit( "endBatchRun", runID );
        end

        function data = readStoreData( ~, jobInfo, key )
            cluster = parcluster( jobInfo.ClusterProfile );
            if jobInfo.ID( 2 ) > 0
                job = cluster.findJob( 'ID', jobInfo.ID( 2 ) );
                tsk = findTask( job, 'Name', key );
                data = [  ];
                if isempty( tsk )
                    return ;
                end
                if isempty( tsk.InputArguments )
                    return ;
                end
                data = tsk.InputArguments{ 1 };
            else
                job = cluster.findJob( 'ID', jobInfo.ID( 1 ) );
                store = job.ValueStore;
                if store.isKey( key )
                    data = store( key );
                else
                    data = [  ];
                end
            end
        end

        function errorMsg = execDownloadTrial( this, runID, trialID )
            [ ~, errorMsg ] = this.getJobFromRunID( runID );
            if ~isempty( errorMsg )
                return ;
            end
            runInfo = this.rsGetRun( runID );
            curTrial = this.rsGetRun( runID ).data{ trialID };
            assert( runInfo.data{ trialID }{ 2 }.resultInCluster == true );

            data = this.readStoreData( runInfo.job, [ 'InputOutput_', num2str( trialID ) ] );
            trialDir = fullfile( this.getRunDir( runID ), [ 'Trial_', num2str( trialID ) ] );
            trialOutputFile = fullfile( trialDir, 'output.mat' );
            if ~isempty( data ) && ~exist( trialOutputFile, 'file' )
                if ~isfolder( trialDir )
                    mkdir( trialDir );
                end
                this.saveTrialParamsAndOutputs( trialDir, data{ 1 }, data{ 2 } );
            end

            curTrial{ 2 }.resultInCluster = false;
            res.rowInd = trialID - 1;
            res.rowData = this.rsUpdateTrial( runID, trialID, curTrial );
            this.emit( [ 'updateRow/', runInfo.uuid ], res );
        end

        function error = getErrorFromJob( ~, job )
            error = '';
            tasks = job.Tasks;
            if isempty( tasks( 1 ).Error )
                return ;
            end

            error = tasks( 1 ).Error.message;
        end

        function out = execCheckBatchJob( this, runID )
            out.newRunInfo = [  ];
            out.errorMsg = '';
            [ job, errorMsg ] = this.getJobFromRunID( runID );
            if ~isempty( errorMsg )
                out.errorMsg = errorMsg;
                return ;
            end
            runInfo = this.rsGetRun( runID );
            out.newRunInfo = this.readStoreData( runInfo.job, 'RunInfo' );
            out.annotationsList = this.annotationsLoad( runID );
            if isempty( out.newRunInfo )
                out.newRunInfo = runInfo;
                return ;
            end

            out.newRunInfo.job.refreshTime = experiments.internal.getCurrentTimeString(  );
            out.newRunInfo.job.Error = this.getErrorFromJob( job );

            if isempty( out.newRunInfo.job.Error )
                out.newRunInfo.job.State = job.State;
            else
                out.newRunInfo.job.State = 'error';
                this.emit( "endBatchRun", runID );
            end

            nTrial = length( out.newRunInfo.data );

            function saveTrainingPlot( trainingAxes, trainingPlotFile )
                loctrainingPlot = uifigure( 'Visible', 'off' );
                cleanupTrainingPlot = onCleanup( @(  )delete( loctrainingPlot ) );
                trainingAxes.Parent = loctrainingPlot;
                drawnow(  );
                savefig( loctrainingPlot, trainingPlotFile );
                trainingAxes.Parent = [  ];
                clear cleanupTrainingPlot;
            end

            N = length( runInfo.data );
            for i = 1:nTrial
                if i <= N && isfield( runInfo.data{ i }{ 2 }, 'resultInCluster' )
                    out.newRunInfo.data{ i }{ 2 }.resultInCluster = runInfo.data{ i }{ 2 }.resultInCluster;
                end
                trialDir = fullfile( this.getRunDir( runID ), [ 'Trial_', num2str( i ) ] );
                trainingAxes = this.readStoreData( out.newRunInfo.job, [ 'TrainingPlot_', num2str( i ) ] );
                if ~isempty( trainingAxes )
                    trainingPlotRunningFile = [ trialDir, filesep, 'trainingPlot_Running.fig' ];
                    trainingPlotFile = [ trialDir, filesep, 'trainingPlot.fig' ];
                    if ~isfolder( trialDir )
                        mkdir( trialDir );
                    end
                    curTrial = out.newRunInfo.data{ i };
                    if strcmp( curTrial{ 2 }.status, 'Running' )
                        saveTrainingPlot( trainingAxes, trainingPlotRunningFile );
                    elseif strcmp( curTrial{ 2 }.status, 'Complete' ) && ~exist( trainingPlotFile, 'file' )
                        saveTrainingPlot( trainingAxes, trainingPlotFile );
                        if exist( trainingPlotRunningFile, 'file' )
                            delete( trainingPlotRunningFile );
                        end
                    end
                end
                trialConfusionMatrixInfoFile = fullfile( trialDir, 'confusionmatrix.mat' );
                data = this.readStoreData( out.newRunInfo.job, [ 'VisData_', num2str( i ) ] );
                if ~isempty( data ) && ~exist( trialConfusionMatrixInfoFile, 'file' )
                    if ~isfolder( trialDir )
                        mkdir( trialDir );
                    end
                    this.saveTrialVisualizationData( trialDir, data{ 1 }, data{ 2 } );
                end
            end
            this.rsSetRun( out.newRunInfo );
            if ismember( out.newRunInfo.job.State, [ "finished", "failed" ] )
                this.emit( "endBatchRun", runID );
            end
        end

        function [ job, errMsg ] = getJobFromRunID( this, runID )
            errMsg = '';
            job = [  ];
            if ~matlab.internal.parallel.isPCTInstalled
                errMsg = message( 'experiments:manager:NoParallelInstalled_batch' ).getString(  );
                return ;
            end
            if ~matlab.internal.parallel.isPCTLicensed
                errMsg = message( 'experiments:manager:NoParallelLicense_batch' ).getString(  );
                return ;
            end

            runInfo = this.rsGetRun( runID );
            assert( isfield( runInfo.job, 'ClusterProfile' ), 'Invalid run id' );
            assert( isfield( runInfo.job, 'ID' ), 'Invalid run id' );

            if ~ismember( runInfo.job.ClusterProfile, parallel.clusterProfiles(  ) )
                errMsg = message( 'experiments:manager:CouldNotFindResults_batch' ).getString(  );
                return ;
            end
            cluster = parcluster( runInfo.job.ClusterProfile );

            job = cluster.findJob( 'ID', runInfo.job.ID( 1 ) );
            if isempty( job )
                errMsg = message( 'experiments:manager:CouldNotFindResults_batch' ).getString(  );
                return ;
            end
        end
    end

    methods ( Static )

        function runBatchExperiment( expDef, runInfo, useParallel )
            service = experiments.internal.View( 'browser', 'none' );
            oldThrottleVal = service.feature.trainingPlotterThrottleRate;
            function EMCleanUP( service, val )
                service.feature.set( 'trainingPlotterThrottleRate', val );
                delete( service );
            end
            cleanup = onCleanup( @(  )EMCleanUP( service, oldThrottleVal ) );
            service.feature.set( 'trainingPlotterThrottleRate', 30 );


            projDir = tempname( tempdir );
            resultsDir = fullfile( projDir, 'Results' );
            runDir = fullfile( resultsDir, runInfo.runID );
            mkdir( runDir );

            cd( resultsDir );
            resultInfoFile = fullfile( resultsDir, 'resultInfo.mat' );
            resultInfo = experiments.internal.ResultInfo(  );
            j1 = getCurrentJob(  );
            runInfo.job.ID( 1 ) = j1.ID;
            resultInfo.resultMap( runInfo.runID ) = runInfo;
            save( resultInfoFile, 'resultInfo' );
            service.resultsDir = resultsDir;
            service.execSetParallelToggle( useParallel );

            isBayesOptExp = ~( strcmp( expDef.ExperimentType, 'ParamSweep' ) );
            isCustomExperiment = strcmp( expDef.Process.Type, 'CustomTraining' );

            if isBayesOptExp
                nTrial = 1;
            else
                nTrial = length( runInfo.data );
            end

            if ~isCustomExperiment
                setupFcn = expDef.Process.SetupFcn;
                trainingFcn = '';
            else
                setupFcn = '';
                trainingFcn = expDef.Process.TrainingFcn;
            end

            service.execInfo.runBatch = true;
            loc_snapshotDir = getAttachedFilesFolder(  );
            import experiments.internal.ExperimentException
            if ~isCustomExperiment
                trialDir = fullfile( runDir, 'Trial_0' );
                if ~isfolder( trialDir )
                    mkdir( trialDir );
                end
                curTrial.runID = runInfo.runID;
                curTrial.trialID = 0;
                paramStruct = service.constructParamStruct( runInfo.paramList, runInfo.FirstParam );
                trialRunner = experiments.internal.TrialRunner( '', '', '', paramStruct, setupFcn, service.execInfo, curTrial, '', '', loc_snapshotDir, '', '' );
                trialRunner.isParallel = useParallel;
                [ Error, runInfo.trainingType, runInfo.usesValidation ] = trialRunner.getInputAndTrainingType( service.feature.mockTrainNetwork );
                if ~isempty( Error )
                    setupFcnErrorME = ExperimentException( message( 'experiments:editor:setupFcnError' ) );
                    setupFcnErrorME = setupFcnErrorME.addCause( ExperimentException( Error.ME ) );

                    runInfo.error = service.getErrorReport( setupFcnErrorME );
                    service.rsSetRun( runInfo );
                    return ;
                end
                service.setIsClassification( strcmp( runInfo.trainingType, 'classification' ) );



                optMetric = expDef.Process.OptimizableMetricData;
                if isBayesOptExp && ~runInfo.usesValidation && ~isempty( optMetric )


                    if ( optMetric{ 1 } == 2 || optMetric{ 1 } == 3 )
                        ME = ExperimentException( message( 'experiments:editor:InvalidMetricSelection' ) );

                        runInfo.error = service.getErrorReport( ME );
                        service.rsSetRun( runInfo );
                        return ;
                    end
                end

                stdMetrics = { 'NA', 'NA' };
                if runInfo.usesValidation
                    stdMetrics = [ stdMetrics, { 'NA', 'NA' } ];
                end

                runInfo.OptimizableMetric = expDef.Process.OptimizableMetricData;


                if runInfo.isBayesOpt && ~runInfo.usesValidation && runInfo.OptimizableMetric{ 1 } > 3
                    runInfo.OptimizableMetric{ 1 } = runInfo.OptimizableMetric{ 1 } - 2;
                end
            else
                runInfo.trainingType = 'CustomTraining';
                runInfo.usesValidation = false;
                stdMetrics = {  };
                runInfo.OptimizableMetric = expDef.Process.OptimizableMetricData;
            end
            runInfo.stdMetrics = stdMetrics;
            if ~isBayesOptExp
                mData = {  };
                if ~isCustomExperiment
                    mData = runInfo.metricData;
                end
                for i = 1:nTrial
                    runInfo.data{ i } = [ runInfo.data{ i }, stdMetrics, mData ];
                end
            end

            if ~isCustomExperiment
                ouputColValues = service.genOutputColValues( runInfo );
                for outputCol = fieldnames( ouputColValues )'
                    runInfo.colValues.( outputCol{ 1 } ) = ouputColValues.( outputCol{ 1 } );
                end
            end
            service.rsSetRun( runInfo );
            if useParallel
                service.initDataQAndTrialRunnerMap(  );
                service.createParallelPoolAndAttachFiles( loc_snapshotDir );
            end
            service.setupExecutionInfo( runInfo.runID, 1:1:nTrial, setupFcn, trainingFcn, loc_snapshotDir, runInfo.trainingType, runInfo.usesValidation );
            service.execInfo.runBatch = true;
            if isBayesOptExp
                service.setupBayesoptRelatedExecutionInfo( runInfo.optVars, runInfo.metricData, runInfo.stdMetrics, runInfo.OptimizableMetric, runInfo.BayesOptOptions );
            end
            service.execExperimentStartRun(  );
            while service.getIsExpRunning(  )
                pause( 2 );
            end
            try

                rmdir( projDir, 's' );
            catch

            end
        end
    end
end


