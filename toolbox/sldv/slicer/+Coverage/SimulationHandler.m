classdef SimulationHandler < handle






    properties ( Access = private )
        modelParams;
        Dirty;
        covEnable = false;
        startTime = 0;
        stopTime = [  ];
        origStartTime = 0;



        preCompileModelProps;
        changedModelProps = false;



        simInTempState = [  ];

        RefConfigSet;
        modelName;

        cvdata = [  ];
        simOut = [  ];


        streamingRunID = [  ];
        streamingSigName = '';
        hQueue = [  ];

        cosObj = [  ];
        simListeners = struct( 'startSimCb', [  ], 'pauseSimCb', [  ],  ...
            'stopSimCb', [  ], 'postStopSimCb', [  ] );

        termListener = [  ];

        prevSimState = [  ];

        stepCov = {  };

        tempModelState Simulink.internal.TemporaryModelState;
    end

    properties ( Access = public )

        isOrigModel = false;
        stepper;
        modelH;
        allMdls;
        dlg = [  ];
        UsingStepper = false;


        initializing = false;


        cmdLineSim = false;




        enhCovAvailable = false;







        finishedSim = true;

        collectCoverageFromSim = true;



        steppingBack = false;
    end

    events
        eventModelTerminatedExternal
    end

    methods
        function obj = SimulationHandler( mdl )

            obj.modelH = get_param( mdl, 'Handle' );


            obj.allMdls = find_mdlrefs( mdl, 'MatchFilter', @Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices, 'AllLevels', true, 'KeepModelsLoaded', true );

            obj.Dirty = get_param( obj.modelH, 'Dirty' );

            obj.modelName = get_param( obj.modelH, 'Name' );

            configureDefaultModelParameters( obj );

            obj.origStartTime = get_param( obj.modelH, 'StartTime' );
            obj.stepper = Simulink.SimulationStepper( obj.modelH );
        end

        function configureDefaultModelParameters( obj )
            cfgSet = getActiveConfigSet( obj.modelH );
            if isa( cfgSet, 'Simulink.ConfigSetRef' )
                obj.attachTempConfigSet;
            end





            obj.modelParams.ReturnWorkspaceOutputs = get_param( obj.modelH, 'ReturnWorkspaceOutputs' );
            set_param( obj.modelH, 'ReturnWorkspaceOutputs', 'on' )
            defaultParams = struct(  ...
                'CovEnable', 'off',  ...
                'CovShowResultsExplorer', 'off',  ...
                'CovScope', 'EntireSystem',  ...
                'RecordRefInstanceCoverage', 'off',  ...
                'ReturnWorkspaceOutputsName', modelslicerprivate( 'generateTempVarName' ),  ...
                'LimitDataPoints', 'off',  ...
                'LoggingToFile', 'off',  ...
                'StartTime', get_param( obj.modelH, 'StartTime' ) ...
                );
            configureModelParameters( obj, defaultParams );
        end

        function simState = runSimAndGetSimStateWithoutCov( obj, startTime, stopTime )
            setPauseTime( obj, startTime );
            setStopTime( obj, stopTime );
            run( obj );
            simState = getSimState( obj );
            run( obj );
        end

        function [ simState, cvd ] = runSimAndGetSimStateWithCov( obj, startTime, stopTime )
            setPauseTime( obj, startTime );
            setStopTime( obj, stopTime );
            enableCoverageRecording( obj );
            run( obj );
            simState = getSimState( obj );
            run( obj );
            cvd = getCoverage( obj );
        end

        function runAndPause( obj, pauseTime )
            obj.setPauseTime( pauseTime );
            obj.stepper.runBlockingNonUIModeWithErrorsThrown(  );
            obj.unsetPauseTime;
        end

        function rollBackAndPause( obj, prevTimeStep )
            obj.stepper.stop;
            obj.runAndPause( prevTimeStep );
        end

        function stepForward( obj )
            obj.stepper.forward(  );
        end

        function stepBack( obj )
            assert( obj.isRunning(  ) );
            obj.steppingBack = true;

            try
                obj.stepper.rollback(  );
            catch Mex
                obj.steppingBack = false;
                rethrow( Mex );
            end
            obj.steppingBack = false;
        end

        function continueSim( obj )
            assert( obj.isRunning(  ) );
            obj.stepper.continue;
        end

        function runSim( obj )
            obj.stepper.runBlockingNonUIModeWithErrorsThrown;
        end

        function stopSim( obj )
            assert( obj.isRunning(  ) );
            obj.stepper.stop;
        end

        function applySimInToModel( obj, simIn )
            if ~isempty( obj.tempModelState )
                delete( obj.tempModelState );
            end
            obj.tempModelState = Simulink.internal.TemporaryModelState( simIn );
        end

        function yesno = isRunning( obj )
            yesno = strcmp( get_param( obj.modelH, 'SimulationStatus' ), 'paused' ) ||  ...
                strcmp( get_param( obj.modelH, 'SimulationStatus' ), 'running' );
        end

        function yesno = isInitialized( obj )
            yesno = ~strcmp( get_param( obj.modelH, 'SimulationStatus' ), 'stopped' );
        end

        function setInternalObject( obj )

            cosObj_warning_obj = warning( 'query',  ...
                'Simulink:modelReference:ParameterOnlyValidWhenModelIsCompiledAndTopModel' );
            cos_warning_state = cosObj_warning_obj.state;
            warning( 'off', 'Simulink:modelReference:ParameterOnlyValidWhenModelIsCompiledAndTopModel' );



            obj.cosObj = get_param( obj.modelH, 'InternalObject' );


            warning( cos_warning_state, 'Simulink:modelReference:ParameterOnlyValidWhenModelIsCompiledAndTopModel' );
        end





        function initialize( obj )
            try
                obj.UsingStepper = false;
                if obj.isOrigModel
                    obj.setInternalObject(  );
                end



                obj.initializing = true;
                if strcmpi( get_param( obj.modelH, 'FastRestart' ), 'on' )
                    obj.initializeStepper(  );
                end


                if ~obj.isInitialized
                    set_param( obj.modelH, 'FastRestart', 'off' )
                    if ~obj.changedModelProps && obj.isOrigModel
                        obj.changeModelProperties;
                    end
                    feval( obj.modelName, 'init' );
                end
                obj.initializing = false;
                obj.addTermListener(  );
            catch ex
                obj.initializing = false;
                obj.revertModelProperties( obj.modelH );
                throw( ex );
            end
        end

        function initializeStepper( obj )

            if ~obj.isInitialized
                if ~obj.changedModelProps && obj.isOrigModel
                    obj.changeModelProperties;
                end




                hmi_warning_obj = warning( 'query',  ...
                    'SimulinkHMI:errors:ModelReferenceNotSupportedLong' );
                old_warning_state = hmi_warning_obj.state;
                warning( 'off', 'SimulinkHMI:errors:ModelReferenceNotSupportedLong' );
                cleanupObj = onCleanup( @(  )warning( old_warning_state, 'SimulinkHMI:errors:ModelReferenceNotSupportedLong' ) );





                set_param( obj.modelH, 'Dirty', obj.Dirty );
                obj.UsingStepper = true;








                aInterceptor = Simulink.output.StorageInterceptorCb(  );
                scope_definer = Simulink.output.registerProcessor( aInterceptor );%#ok<NASGU>


                obj.stepper.initialize;
                clearBaseWorkspaceVars( obj );


                clear scope_definer;
                thrownMsgs = aInterceptor.getInterceptedMsg;


                errorMex = processFastRestartDiagnostics( obj, thrownMsgs );

                if ~obj.isInitialized
                    obj.UsingStepper = false;
                end
                if ~isempty( errorMex )
                    throw( errorMex );
                end



                obj.addSimListeners(  );
            end
        end

        function run( obj, stepperSim, simulationInput )
            if nargin < 2
                stepperSim = true;
                simulationInput = [  ];
            end


            tune_warning_obj = warning( 'query',  ...
                'Simulink:blocks:WarnTuningWhenCoverage' );
            old_warning_state = tune_warning_obj.state;
            warning( 'off', 'Simulink:blocks:WarnTuningWhenCoverage' );
            cleanupObj = onCleanup( @(  )warning( old_warning_state, 'Simulink:blocks:WarnTuningWhenCoverage' ) );


            obj.removeSimListeners(  );



            obj.cmdLineSim = true;
            if stepperSim
                obj.stepper.runBlockingNonUIModeWithErrorsThrown(  );
                obj.getSimCovDataFromWorkspace(  );
            else
                checkSimInAndSimulate( obj, simulationInput );
            end
            obj.cmdLineSim = false;


            obj.addSimListeners(  );
        end

        function updateCovData( obj )
            try
                coveng = cvi.TopModelCov.getInstance( obj.modelH );
                data = coveng.lastCovData;
                obj.addStepCov( data );
                obj.cvdata = obj.getAggregateStepCov(  );
                obj.stepCov( : ) = [  ];
            catch
            end
        end

        function getSimCovDataFromWorkspace( obj )
            try
                returnWorkspaceOutputsName = get_param( obj.modelH, 'ReturnWorkspaceOutputsName' );
                obj.simOut = evalin( 'base', returnWorkspaceOutputsName );
            catch
            end
            obj.updateCovData;
            clearBaseWorkspaceVars( obj );
        end

        function simState = getSimState( obj )
            simState = get_param( obj.modelH, 'CurrentSimState' );
        end

        function reInitialize( obj )

            if ~obj.isStepperInitialized
                obj.run;
            end
        end

        function yesno = isStepperInitialized( obj )
            if obj.UsingStepper
                yesno = obj.stepper.executionStatus == 2;
            else
                yesno = false;
            end
        end

        function terminate( obj, revertProps )
            arguments
                obj
                revertProps( 1, 1 )logical = true
            end

            isInit = obj.isInitialized;
            if isInit
                obj.removeTermListener(  );
                if ~obj.UsingStepper
                    feval( obj.modelName, 'term' );
                else
                    obj.stepper.stop;
                    clearBaseWorkspaceVars( obj );

                    if strcmp( get_param( obj.modelH, 'FastRestart' ), 'on' )
                        set_param( obj.modelH, 'FastRestart', 'off' );

                        set_param( obj.modelH, 'FastRestart', 'on' );
                    end
                    obj.removeSimListeners(  );
                    obj.cosObj = [  ];
                end
                if obj.isOrigModel && revertProps
                    obj.revertModelProperties( obj.modelH );
                end
            end
        end

        function cvd = getCoverage( obj )
            cvd = [  ];
            try
                cvd = Coverage.CovData( obj.cvdata, [  ], [  ], obj.simOut );
            catch
            end
        end

        function [ cvdata, simOut ] = getCovData( obj )
            simOut = getSimOut( obj );
            cvdata = obj.cvdata;
        end

        function simOut = getSimOut( obj )
            simOut = obj.simOut;
        end

        function setPauseTime( obj, tstart )
            obj.startTime = tstart;
            params = struct( 'EnablePauseTimes', 'on', 'PauseTimes', num2str( tstart, '%20.20g' ) );
            configureModelParameters( obj, params );
        end

        function unsetPauseTime( obj )
            params = struct( 'EnablePauseTimes', 'off' );
            configureModelParameters( obj, params );
        end

        function setStopTime( obj, tstop )
            obj.stopTime = tstop;
            params = struct( 'StopTime', num2str( tstop, '%15.15g' ) );
            configureModelParameters( obj, params );
        end

        function enableCoverageRecording( obj )
            if ~obj.isInitialized
                obj.covEnable = true;

                params = Coverage.SimulationHandler.getCoverageParams(  );
                configureModelParameters( obj, params );
            end
        end

        function configureModelParameters( obj, params )
            flds = fieldnames( params );
            for n = 1:length( flds )
                thisParam = flds{ n };


                if ~strcmp( get_param( obj.modelH, thisParam ), params.( thisParam ) )










                    if ( ~isfield( obj.modelParams, thisParam ) )
                        obj.modelParams.( thisParam ) = get_param( obj.modelH, thisParam );
                    end
                    set_param( obj.modelH, thisParam, params.( thisParam ) );
                end
            end
            set_param( obj.modelH, 'Dirty', 'off' );
        end
        function delete( obj )

            if ~bdIsLoaded( obj.modelName ) || ~ishandle( obj.modelH ) || ( ~isempty( obj.cosObj ) && ~isvalid( obj.cosObj ) )
                return ;
            end


            if obj.isInitialized
                obj.terminate;
            else
                obj.revertModelProperties( obj.modelH );
            end

            clearBaseWorkspaceVars( obj );
            restoreModelParameters( obj );
        end


        function restoreModelParameters( obj )
            if isempty( obj.modelParams )
                return ;
            end
            if obj.isOrigModel
                modlDirty = get_param( obj.modelH, 'Dirty' );
            else
                modlDirty = obj.Dirty;
            end

            if isempty( obj.RefConfigSet )
                flds = fieldnames( obj.modelParams );
                prms = {  };
                for n = 1:length( flds )
                    if ~any( strcmp( flds{ n }, { 'ReturnWorkspaceOutputs', 'ReturnWorkspaceOutputsName', 'PauseTimes' } ) )
                        prms{ end  + 1 } = flds{ n };%#ok<AGROW>
                        prms{ end  + 1 } = obj.modelParams.( flds{ n } );%#ok<AGROW>
                    end
                end
                if ~isempty( prms )
                    set_param( obj.modelH, prms{ : } );
                end


                set_param( obj.modelH, 'ReturnWorkspaceOutputs', 'on' )
                set_param( obj.modelH, 'ReturnWorkspaceOutputsName', obj.modelParams.ReturnWorkspaceOutputsName );
                set_param( obj.modelH, 'ReturnWorkspaceOutputs', obj.modelParams.ReturnWorkspaceOutputs );
            else
                obj.detachTempConfigSet( obj.modelH );
            end

            obj.modelParams = [  ];


            set_param( obj.modelH, 'Dirty', modlDirty );
        end

        function changeModelProperties( obj )

            modlDirty = get_param( obj.modelH, 'Dirty' );




            obj.preCompileModelProps.RefConfigSet = [  ];
            cfgSet = getActiveConfigSet( obj.modelH );
            if isa( cfgSet, 'Simulink.ConfigSetRef' ) ...
                    && ( strcmp( get_param( obj.modelH, 'BlockReduction' ), 'on' ) ...
                    || strcmp( get_param( obj.modelH, 'ConditionallyExecuteInputs' ), 'on' ) ...
                    || ~strcmp( get_param( obj.modelH, 'AlgebraicLoopMsg' ), 'error' ) )
                obj.preCompileModelProps.RefConfigSet = cfgSet;
                origConfigSet = sldvshareprivate( 'mdl_get_configset', obj.modelH );
                tempConfigSet = attachConfigSetCopy( obj.modelH, origConfigSet, true );
                tempConfigSet.Name = 'Model Slicer Temporary Config Set';
                setActiveConfigSet( obj.modelH, tempConfigSet.Name );
            end



            obj.preCompileModelProps.BlockReduction = get_param( obj.modelH, 'BlockReduction' );
            if strcmp( obj.preCompileModelProps.BlockReduction, 'on' )
                set_param( obj.modelH, 'BlockReduction', 'off' );
            end
            obj.preCompileModelProps.ConditionallyExecuteInputs =  ...
                get_param( obj.modelH, 'ConditionallyExecuteInputs' );
            if strcmp( obj.preCompileModelProps.ConditionallyExecuteInputs, 'on' )
                set_param( obj.modelH, 'ConditionallyExecuteInputs', 'off' );
            end


            obj.preCompileModelProps.AlgebraicLoopMsg =  ...
                get_param( obj.modelH, 'AlgebraicLoopMsg' );
            if ~strcmp( obj.preCompileModelProps.AlgebraicLoopMsg, 'error' )
                set_param( obj.modelH, 'AlgebraicLoopMsg', 'error' );
            end
            obj.convertToNormalModeIfPossible(  );
            obj.initPropertyProvingBlocksStatusMap(  );


            bdObj = get_param( obj.modelH, 'Object' );
            if ~bdObj.hasCallback( 'PostNameChange', 'SlicerNamaChangeCallback' )
                Simulink.addBlockDiagramCallback( obj.modelH, 'PostNameChange', 'SlicerNamaChangeCallback',  ...
                    @(  )ModelSlicer.modelNameChangeCallback( obj.modelH, obj.modelName, ~isempty( obj.dlg ) ) );
            end
            set_param( obj.modelH, 'Dirty', modlDirty )
            obj.changedModelProps = true;
        end

        function revertModelProperties( obj, modelH2Revert )
            arguments
                obj
                modelH2Revert = obj.modelH;
            end

            if isempty( obj.preCompileModelProps )
                return ;
            end

            modelH2Revert = get_param( modelH2Revert, 'handle' );
            modlDirty = get_param( modelH2Revert, 'Dirty' );

            if isempty( obj.preCompileModelProps.RefConfigSet )

                if ~strcmp( get_param( modelH2Revert, 'BlockReduction' ),  ...
                        obj.preCompileModelProps.BlockReduction )
                    set_param( modelH2Revert, 'BlockReduction',  ...
                        obj.preCompileModelProps.BlockReduction );
                end
                if ~strcmp( get_param( modelH2Revert, 'ConditionallyExecuteInputs' ),  ...
                        obj.preCompileModelProps.ConditionallyExecuteInputs )
                    set_param( modelH2Revert, 'ConditionallyExecuteInputs',  ...
                        obj.preCompileModelProps.ConditionallyExecuteInputs );
                end
                if ~strcmp( get_param( modelH2Revert, 'AlgebraicLoopMsg' ),  ...
                        obj.preCompileModelProps.AlgebraicLoopMsg )
                    set_param( modelH2Revert, 'AlgebraicLoopMsg',  ...
                        obj.preCompileModelProps.AlgebraicLoopMsg );
                end
            else


                configSets = getConfigSets( modelH2Revert );
                if any( strcmp( configSets, obj.preCompileModelProps.RefConfigSet.Name ) )
                    setActiveConfigSet( modelH2Revert, obj.preCompileModelProps.RefConfigSet.Name )
                end
                if any( strcmp( configSets, 'Model Slicer Temporary Config Set' ) )
                    detachConfigSet( modelH2Revert, 'Model Slicer Temporary Config Set' );
                end
                obj.preCompileModelProps.RefConfigSet = [  ];
            end

            if ( modelH2Revert == obj.modelH )
                obj.restoreSimulationMode(  );
                obj.restorePropertyProvingBlocksStatusMap(  );
            end

            bdObj = get_param( modelH2Revert, 'Object' );
            if bdObj.hasCallback( 'PostNameChange', 'SlicerNamaChangeCallback' )

                Simulink.removeBlockDiagramCallback( modelH2Revert, 'PostNameChange', 'SlicerNamaChangeCallback' );
            end
            set_param( modelH2Revert, 'Dirty', modlDirty );

            if ( modelH2Revert == obj.modelH )





                obj.changedModelProps = false;
            end
        end

        function attachTempConfigSet( obj )



            obj.RefConfigSet = [  ];
            cfgSet = getActiveConfigSet( obj.modelH );
            obj.RefConfigSet = cfgSet;
            origConfigSet = sldvshareprivate( 'mdl_get_configset', obj.modelH );
            tempConfigSet = attachConfigSetCopy( obj.modelH, origConfigSet, true );
            tempConfigSet.Name = 'Model Slicer Temporary Config Set';
            setActiveConfigSet( obj.modelH, tempConfigSet.Name );
        end

        function detachTempConfigSet( obj, modelH2Revert )


            configSets = getConfigSets( modelH2Revert );
            if any( strcmp( configSets, obj.RefConfigSet.Name ) )
                setActiveConfigSet( modelH2Revert, obj.RefConfigSet.Name )
            end
            if any( strcmp( configSets, 'Model Slicer Temporary Config Set' ) )
                detachConfigSet( modelH2Revert, 'Model Slicer Temporary Config Set' );
            end
            obj.RefConfigSet = [  ];
        end

        function enableStreamingCovCollection( obj )
            try
                obj.finishedSim = false;
                obj.enhCovAvailable = false;

                unique_name = tempname;
                unique_name = unique_name( end  - 5:end  );
                bpath = [ 'covPath_', unique_name ];
                Id = [ 'covSigId_', unique_name ];
                sigName = [ 'covSig_', unique_name ];

                DoubleType = Simulink.AsyncQueue.DataType( 'double' );
                sig = Simulink.AsyncQueue.Signal.create( DoubleType, int32( 4 ), false, false );
                sigSource = Simulink.AsyncQueue.SignalSource;
                sigSource.Path = bpath;
                sigSource.ID = Id;
                sigSource.Name = sigName;
                sigSource.Index = 1;
                sig.setSource( sigSource );
                obj.hQueue = Simulink.AsyncQueue.Queue( sig );

                client = Simulink.AsyncQueue.SignalClient;
                client.ObserverType = 'database_observer';
                obj.hQueue.bindClient( client );

                Simulink.AsyncQueue.Queue.configureQueuesAndLaunchThreads(  ...
                    obj.hQueue );

                cv( 'SetAsyncQueue', obj.hQueue );
                signal = Simulink.sdi.getSignal( sig.ID );
                obj.streamingRunID = signal.runID;
                obj.streamingSigName = sigName;
                cv( 'EnableStreaming', 1 );
            catch Mex
                disableStreamingCovCollection( obj );
                rethrow( Mex );
            end
        end

        function disableStreamingCovCollection( obj )

            obj.hQueue = [  ];
            if ~isempty( obj.streamingRunID )
                Simulink.sdi.deleteRun( obj.streamingRunID );
            end
            obj.streamingRunID = [  ];
            obj.streamingSigName = '';
            obj.enhCovAvailable = false;
            obj.finishedSim = true;
        end

        function cvd = processStreamingData( obj )
            cv( 'EnableStreaming', 0 );
            delete( obj.hQueue );
            runID = obj.streamingRunID;
            [ covdata, simout ] = obj.getCovData;
            try
                covSignal = getElement( Simulink.sdi.exportRun( runID ), obj.streamingSigName );
                covTs = covSignal.Values;
            catch ex
                disableStreamingCovCollection( obj );
                Mex = MException( 'ModelSlicer:ErrorReadingCovStream',  ...
                    getString( message( 'Sldv:ModelSlicer:Coverage:ErrorReadingCovStream' ) ) );
                Mex = Mex.addCause( ex );
                throw( Mex );
            end

            covIdDfsMap = Coverage.buildCovIdDfsMap( covdata );



            if ~isempty( covIdDfsMap ) && isa( covTs, 'timeseries' )

                [ CovIds, idx ] = sort( covTs.Data( :, 3 ) );

                Data = [ covTs.Data( idx, 1 ), covTs.Data( idx, 2 ), covTs.Data( idx, 4 ) ];

                [ keys, ia, ~ ] = unique( CovIds, 'stable' );
                ia( end  + 1 ) = length( CovIds ) + 1;

                Idx = zeros( length( covIdDfsMap ), 2 );

                for i = 1:length( keys )
                    if ~isKey( covIdDfsMap, keys( i ) )
                        continue ;
                    end
                    j = covIdDfsMap( keys( i ) );
                    Idx( j, : ) = [ ia( i ), ia( i + 1 ) - 1 ];
                end
                covStreamMap = struct( 'Data', Data, 'Idx', Idx );
            else
                covStreamMap = [  ];
                covIdDfsMap = [  ];
            end

            cvd = Coverage.CovData( covdata, covStreamMap, covIdDfsMap, simout );

            obj.disableStreamingCovCollection(  );
        end

        function cvd = collectEnhancedCoverage( obj, tstop, simulationInput )
            try
                modlDirty = get_param( obj.modelH, 'Dirty' );
                obj.setStopTime( tstop );
                set_param( obj.modelH, 'EnablePauseTimes', 'off' );
                obj.enableStreamingCovCollection(  );
                try
                    if obj.UsingStepper
                        obj.run( false, simulationInput );
                    else
                        checkSimInAndSimulate( obj, simulationInput );
                    end
                catch mex
                    cv( 'EnableStreaming', 0 );
                    rethrow( mex );
                end
                cvd = obj.processStreamingData(  );
                set_param( obj.modelH, 'Dirty', modlDirty );
            catch Mex
                disableStreamingCovCollection( obj );
                rethrow( Mex );
            end
        end


        function checkSimInAndSimulate( obj, simulationInput )
            if isempty( simulationInput )
                obj.simOut = sim( obj.modelName );
            else
                obj.simOut = sim( simulationInput );
            end
            obj.updateCovData(  );
        end

        function cvf = getOriginalCovFilter( obj )
            cvf = '';
            if ~isempty( obj.modelParams ) &&  ...
                    isfield( obj.modelParams, 'CovFilter' )
                fld = 'CovFilter';
                cvf = obj.modelParams.( fld );
            end
        end

        function applyOrigCovParams( obj, newModelH )
            params = Coverage.SimulationHandler.getCoverageParams(  );
            fields = fieldnames( params );
            for i = 1:length( fields )
                fn = fields{ i };
                if ~isempty( obj.modelParams ) &&  ...
                        isfield( obj.modelParams, fn ) &&  ...
                        ~strcmpi( fn, 'CovFilter' )
                    set_param( newModelH, fn, obj.modelParams.( fn ) );
                end
            end
        end

        function terminateSimulation( obj )

            obj.enhCovAvailable = true;
        end





        function covdata = getStepCov( obj )
            covdata = [  ];
            coveng = cvi.TopModelCov.getInstance( obj.modelH );
            lastCovData = coveng.lastCovData;
            if ~isempty( lastCovData )
                if obj.isNewerCvData( lastCovData )
                    obj.addStepCov( lastCovData );
                elseif obj.getStopTimeFromCvData( obj.stepCov{ end  } ) ==  ...
                        obj.getStopTimeFromCvData( lastCovData )


                    obj.stepCov{ end  } = lastCovData;
                else


                    lastCovData = obj.resetCovToSimTime( lastCovData );
                end
                covdata = Coverage.CovData( lastCovData );
            end
        end

        function addSimulationPauseCallBack( obj, callbackFunc )
            assert( isempty( obj.simListeners.pauseSimCb ) );
            obj.simListeners.pauseSimCb = addlistener( obj.cosObj, 'SLExecEvent::SIMSTATUS_PAUSED',  ...
                callbackFunc );
        end

        function removeSimulationPauseCallBack( obj )
            delete( obj.simListeners.pauseSimCb );
            obj.simListeners.pauseSimCb = [  ];
        end

        function addSimulationStopCallBack( obj, callbackFunc )
            assert( isempty( obj.simListeners.stopSimCb ) &&  ...
                isempty( obj.simListeners.postStopSimCb ) );
            obj.simListeners.stopSimCb = addlistener( obj.cosObj, 'SLExecEvent::POST_TERMINATE_OF_SIM_MODEL_EVENT',  ...
                callbackFunc );
            obj.simListeners.postStopSimCb = addlistener( obj.cosObj, 'SLExecEvent::SIMSTATUS_COMPILED',  ...
                callbackFunc );
        end

        function removeSimulationStopCallBack( obj )
            delete( obj.simListeners.stopSimCb );
            obj.simListeners.stopSimCb = [  ];
            delete( obj.simListeners.postStopSimCb );
            obj.simListeners.postStopSimCb = [  ];
        end
    end

    methods
        function set.collectCoverageFromSim( obj, val )
            obj.collectCoverageFromSim = val;
            obj.configCovListeners( val );
        end
    end

    methods ( Access = private )
        function convertToNormalModeIfPossible( obj )
            if isfield( obj.preCompileModelProps, 'SimulationModeMap' ) &&  ...
                    ~isempty( obj.preCompileModelProps.SimulationModeMap )
                return ;
            end
            SimulationModeMap =  ...
                containers.Map( 'KeyType', 'double', 'ValueType', 'any' );
            [ allMdlH, mdlBlkH ] = Transform.AtomicGroup.searchModelBlocks( obj.modelH );
            for i = 1:length( allMdlH )
                mdlH = allMdlH( i );
                doit( mdlH )
            end







            refMdlH = arrayfun( @( b )get_param( get_param( b, 'ModelName' ), 'Handle' ), mdlBlkH );
            [ refMdlH, idx ] = sort( refMdlH );
            refMdlH = [ 0, refMdlH, 0 ];
            mdlBlkH = [ 0, mdlBlkH( idx ), 0 ];
            len = length( refMdlH );

            for i = 2:len - 1
                doit( mdlBlkH( i ) );
            end

            obj.preCompileModelProps.SimulationModeMap = SimulationModeMap;
            function doit( elemH )
                simMode = get_param( elemH, 'SimulationMode' );
                if ~strcmpi( simMode, 'normal' ) &&  ...
                        ~isUnderForEachSubsys( elemH )
                    set_param( elemH, 'SimulationMode', 'normal' );
                    SimulationModeMap( elemH ) = simMode;
                    set_param( bdroot( elemH ), 'Dirty', 'off' );
                end
            end
        end


        function initPropertyProvingBlocksStatusMap( obj )

            if isfield( obj.preCompileModelProps, 'PropertyProvingBlocksStatusMap' ) &&  ...
                    ~isempty( obj.preCompileModelProps.PropertyProvingBlocksStatusMap )
                return ;
            end



            refMdls = find_mdlrefs( obj.modelH, 'MatchFilter', @Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices );

            observerBlks = Simulink.observer.internal.loadObserverModelsForBD( obj.modelH );
            observerBlks = reshape( observerBlks, numel( observerBlks ), 1 );
            refMdls = vertcat( refMdls, observerBlks );
            PPMap = [  ];


            PPMap.proofObjectiveBlocks = find_system( refMdls, 'LookUnderMasks', 'on',  ...
                'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,  ...
                'FollowLinks', 'off', 'masktype', 'Design Verifier Proof Objective' );
            PPMap.assertBlocks = find_system( refMdls, 'LookUnderMasks', 'on',  ...
                'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,  ...
                'FollowLinks', 'off', 'BlockType', 'Assertion' );
            PPMap.ModelVerificationBlks = {  };



            observerSinks = Analysis.getSignalObservers(  );

            if strcmp( observerSinks.Subsystem( 1 ), 'simulink/Sinks/XY Graph' )
                observerSinks.Subsystem( 1 ) = [  ];
            end

            for d = 1:length( observerSinks.Subsystem )


                subsys = find_system( refMdls, 'FindAll', 'on',  ...
                    'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,  ...
                    'LookUnderMasks', 'all', 'FollowLinks', 'off',  ...
                    'ReferenceBlock', sprintf( observerSinks.Subsystem{ d } ) );
                if ( ~isempty( subsys ) )
                    PPMap.ModelVerificationBlks = [ PPMap.ModelVerificationBlks;subsys ];
                end
            end

            PPMap.referencedModels = refMdls;
            for i = 1:length( PPMap.referencedModels )
                PPMap.dirtyFlag{ i } = get_param( PPMap.referencedModels{ i }, 'dirty' );
            end

            PPMap.origStopSimStatusProofBlk = {  };
            PPMap.origStopSimStatusAssertBlk = {  };
            PPMap.origStopSimStatusModelVerificationBlks = {  };

            for i = 1:length( PPMap.proofObjectiveBlocks )
                stopSim = get_param( PPMap.proofObjectiveBlocks{ i }, 'enableStopSim' );
                PPMap.origStopSimStatusProofBlk{ i } = stopSim;
                if ~strcmp( stopSim, 'off' )
                    set_param( PPMap.proofObjectiveBlocks{ i }, 'enableStopSim', 'off' );
                end
            end

            for i = 1:length( PPMap.assertBlocks )
                stopSim = get_param( PPMap.assertBlocks{ i }, 'StopWhenAssertionFail' );
                PPMap.origStopSimStatusAssertBlk{ i } = stopSim;
                set_param( PPMap.assertBlocks{ i }, 'StopWhenAssertionFail', 'off' );
            end

            for i = 1:length( PPMap.ModelVerificationBlks )
                stopSim = get_param( PPMap.ModelVerificationBlks{ i }, 'StopWhenAssertionFail' );
                PPMap.origStopSimStatusModelVerificationBlks{ i } = stopSim;
                set_param( PPMap.ModelVerificationBlks{ i }, 'StopWhenAssertionFail', 'off' );
            end

            obj.preCompileModelProps.PropertyProvingBlocksStatusMap = PPMap;
        end

        function restoreSimulationMode( obj )
            if isfield( obj.preCompileModelProps, 'SimulationModeMap' ) &&  ...
                    ~isempty( obj.preCompileModelProps.SimulationModeMap )
                SimulationModeMap = obj.preCompileModelProps.SimulationModeMap;
                keys = SimulationModeMap.keys;
                values = SimulationModeMap.values;
                for i = 1:length( keys )
                    simMode = values{ i };
                    elemH = keys{ i };
                    set_param( elemH, 'SimulationMode', simMode );
                    set_param( bdroot( elemH ), 'Dirty', 'off' );
                end
                obj.preCompileModelProps.SimulationModeMap = [  ];
            end
        end


        function restorePropertyProvingBlocksStatusMap( obj )
            if isfield( obj.preCompileModelProps, 'PropertyProvingBlocksStatusMap' ) &&  ...
                    ~isempty( obj.preCompileModelProps.PropertyProvingBlocksStatusMap )

                PPMap = obj.preCompileModelProps.PropertyProvingBlocksStatusMap;

                for i = 1:length( PPMap.proofObjectiveBlocks )
                    currentStpSim = get_param( PPMap.proofObjectiveBlocks( i ), 'enableStopSim' );
                    if ~strcmp( currentStpSim, PPMap.origStopSimStatusProofBlk{ i } )
                        set_param( PPMap.proofObjectiveBlocks{ i }, 'enableStopSim',  ...
                            PPMap.origStopSimStatusProofBlk{ i } );
                    end
                end

                for i = 1:length( PPMap.assertBlocks )
                    set_param( PPMap.assertBlocks{ i }, 'StopWhenAssertionFail',  ...
                        PPMap.origStopSimStatusAssertBlk{ i } );
                end

                for i = 1:length( PPMap.ModelVerificationBlks )
                    set_param( PPMap.ModelVerificationBlks{ i }, 'StopWhenAssertionFail',  ...
                        PPMap.origStopSimStatusModelVerificationBlks{ i } );
                end

                for i = 1:length( PPMap.referencedModels )
                    set_param( PPMap.referencedModels{ i }, 'dirty', PPMap.dirtyFlag{ i } );
                end
                obj.preCompileModelProps.PropertyProvingBlocksStatusMap = [  ];
            end
        end

        function clearBaseWorkspaceVars( obj )
            try
                evalin( 'base', [ 'clear ', get_param( obj.modelH, 'ReturnWorkspaceOutputsName' ) ] );
                evalin( 'base', [ 'clear ', get_param( obj.modelH, 'CovSaveName' ) ] );
            catch
            end
        end

        function addSimListeners( obj )
            if obj.isOrigModel &&  ...
                    obj.UsingStepper &&  ...
                    obj.isInitialized &&  ...
                    ~isempty( obj.cosObj )
                obj.simListeners.startSimCb = addlistener( obj.cosObj, 'SLExecEvent::START_OF_SIM_MODEL_EVENT',  ...
                    @( ~, ~ )obj.enableStreamingCovCollection(  ) );
                obj.simListeners.stopSimCb = addlistener( obj.cosObj, 'SLExecEvent::POST_TERMINATE_OF_SIM_MODEL_EVENT',  ...
                    @( ~, ~ )obj.terminateSimulation(  ) );
            end
        end

        function removeSimListeners( obj )
            f = fields( obj.simListeners );
            for idx = 1:length( f )
                delete( obj.simListeners.( f{ idx } ) )
                obj.simListeners.( f{ idx } ) = [  ];
            end
        end

        function addTermListener( obj )
            if ~isempty( obj.cosObj )
                obj.termListener = addlistener( obj.cosObj, 'SLExecEvent::SIMSTATUS_STOPPED',  ...
                    @( ~, ~ )obj.notify( 'eventModelTerminatedExternal' ) );
            end
        end

        function removeTermListener( obj )
            delete( obj.termListener );
            obj.termListener = [  ];
            obj.removeSimulationPauseCallBack(  );
            obj.removeSimulationStopCallBack(  );
        end

        function errorMex = processFastRestartDiagnostics( obj, thrownMsgs )
            if ~isempty( obj.dlg )
                modelslicerprivate( 'MessageHandler', 'open', obj.modelName );
            end
            errorMex = [  ];




            for i = 1:length( thrownMsgs )
                msg = thrownMsgs( i );
                ex = MException( msg.MessageId, '%s', msg.Message );
                if any( contains( msg.MessageId, { 'Simulink:Stepper', 'SimState' } ) )
                    modelslicerprivate( 'MessageHandler', 'info', ex );
                elseif any( contains( msg.MessageId, { 'Simulink:Logging:TopMdlOverrideUpdated',  ...
                        'Simulink:Engine:OutportCannotLogNonBuiltInDataTypes' } ) )
                    continue ;
                else
                    if strcmpi( msg.Severity, 'WARNING' )
                        modelslicerprivate( 'MessageHandler', 'warning', ex, obj.modelName );
                    elseif strcmpi( msg.Severity, 'ERROR' )
                        if isempty( errorMex )
                            errorMex = ex;
                        else
                            errorMex = errorMex.addCause( ex );
                        end
                    end
                end
            end
        end

        function addStepCov( obj, cvdata )


            if obj.isNewerCvData( cvdata )
                obj.stepCov{ end  + 1 } = cvdata;
            end
        end

        function yesno = isNewerCvData( obj, cvdata )
            yesno = isempty( obj.stepCov ) ||  ...
                obj.getStopTimeFromCvData( obj.stepCov{ end  } ) <  ...
                obj.getStopTimeFromCvData( cvdata );
        end

        function stopTime = getStopTimeFromCvData( obj, cvdata )
            if isa( cvdata, 'cv.cvdatagroup' )
                cvdata = cvdata.get( obj.modelName );
            end
            stopTime = cvdata.simulationStopTime;
        end

        function cvdata = resetCovToSimTime( obj, cvdata )

            currentSimTime = obj.getStopTimeFromCvData( cvdata );

            while size( obj.stepCov, 2 ) > 0 &&  ...
                    obj.getStopTimeFromCvData( obj.stepCov{ end  } ) > currentSimTime
                obj.stepCov( end  ) = [  ];
            end

            if size( obj.stepCov, 2 ) == 0
                obj.stepCov{ 1 } = cvdata;
            end
            cvdata = obj.stepCov{ end  };
        end

        function cvdata = getStepCovForSimTime( obj, simTime )
            cvdata = [  ];
            for idx = length( obj.stepCov ): - 1:1
                if isequal( obj.getStopTimeFromCvData( obj.stepCov{ idx } ),  ...
                        simTime )
                    cvdata = obj.stepCov{ idx };
                    return ;
                end
            end
        end

        function cvdataAggr = getAggregateStepCov( obj )
            cvdataAggr = [  ];
            if ~isempty( obj.stepCov )
                cvdataAggr = obj.stepCov{ 1 };
                for i = 2:length( obj.stepCov )
                    cvdataAggr = cvdataAggr + obj.stepCov{ i };
                end
            end
        end

        function configCovListeners( obj, val )
            if val
                obj.addSimListeners(  );
                obj.addTermListener(  );
            else
                obj.removeSimListeners(  );
                obj.removeTermListener(  );
            end
            set_param( obj.modelH, 'Dirty', 'off' );
        end
    end
    methods ( Static )
        function adjustedStartTime = getAdjustedStartTime( tstart, enhCov )

            try
                tLessThanStart = enhCov.tout( enhCov.tout < tstart );
                adjustedStartTime = tLessThanStart( end  );
            catch
                adjustedStartTime = tstart;
            end
        end
        function covParams = getCoverageParams(  )
            covParams = struct(  ...
                'CovEnable', 'on',  ...
                'CovIncludeTopModel', 'on',  ...
                'CovModelRefEnable', 'on',  ...
                'CovMetricSettings', 'dce',  ...
                'CovHtmlReporting', 'off',  ...
                'CovScope', 'EntireSystem',  ...
                'CovSaveSingleToWorkspaceVar', 'off',  ...
                'CovSaveCumulativeToWorkspaceVar', 'off',  ...
                'CovSaveOutputData', 'off',  ...
                'CovUseTimeInterval', 'off',  ...
                'CovHighlightResults', 'off',  ...
                'CovShowResultsExplorer', 'off',  ...
                'CovForceBlockReductionOff', 'on',  ...
                'RecordRefInstanceCoverage', 'on',  ...
                'CovStartTime', 0,  ...
                'SaveTime', 'on',  ...
                'CovFilter', '',  ...
                'LimitDataPoints', 'off',  ...
                'ReturnWorkspaceOutputs', 'on',  ...
                'SignalLogging', 'on' );
            covParams.CovReportOnPause = 'on';
            covParams.CovOutputDir = tempdir;
        end
    end
end

function val = isUnderForEachSubsys( mdlBlkH )

bObj = get( mdlBlkH, 'Object' );
parentObj = bObj.getParent;

try
    while ~isa( parentObj, 'Simulink.BlockDiagram' )
        stype = Simulink.SubsystemType( parentObj.Handle );
        if stype.isForEachSubsystem
            val = true;
            return ;
        end
        parentObj = parentObj.getParent;
    end
catch
end

val = false;
end

