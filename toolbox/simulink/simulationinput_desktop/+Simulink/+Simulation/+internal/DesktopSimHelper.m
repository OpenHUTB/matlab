classdef DesktopSimHelper < Simulink.Simulation.internal.SimHelper




    properties ( Constant, Access = private )
        VariableWorkspaceAndContextParser = getVariableWorkspaceAndContextParser(  )
        SimFcn = @( simIn )builtin( 'sim', simIn );
    end

    methods ( Static )
        function doPreSimulationChecks( ~ )




        end

        function simInput = doPreSimulationSetup( simInput )
            load_system( simInput.ModelName );
            Simulink.Simulation.internal.DesktopSimHelper.initializeSimulationInputInfoOnBDAssociatedData( simInput );
            Simulink.Simulation.internal.DesktopSimHelper.setSimInputModelWorkspaceNames( simInput );

            slInternal( 'setupActiveSimulation',  ...
                get_param( simInput.ModelName, 'Handle' ), simInput );







            if ~simInput.UsingManager
                MultiSim.internal.doParallelBuild( simInput );
            end
            simInput = Simulink.Simulation.internal.DesktopSimHelper.setAllowOneTimeNonTunableParamChange( simInput );
            simInput = Simulink.Simulation.internal.DesktopSimHelper.setupFastRestart( simInput );
        end
        function simInput = setupFastRestart( simInput )

            if slfeature( 'ParsimSupportFastRestartInNAR' ) > 0
                frSetting = get_param( simInput, 'FastRestart' );
                if strcmp( frSetting, 'on' ) &&  ...
                        strcmp( get_param( simInput, 'SimulationMode' ), 'rapid-accelerator' )
                    paramValue = [  ];
                    try
                        paramValue = simInput.getModelParameter(  ...
                            'RapidAcceleratorUpToDateCheck' );
                    catch
                    end
                    if isempty( paramValue )
                        simInput.ImplicitRapidAcceleratorUpToDateCheckOff = true;

                        simInput = simInput.setModelParameter( 'FastRestart', 'off' );



                        simInput = simInput.setModelParameter(  ...
                            'RapidAcceleratorUpToDateCheck', 'off' );
                    end
                end
            end
        end
        function out = sim( simInput, config )
            arguments
                simInput Simulink.SimulationInput{ mustBeNonempty }
                config.SimFcn( 1, 1 )function_handle = Simulink.Simulation.internal.DesktopSimHelper.SimFcn
                config.BlockDiagramAssociatedData( 1, 1 )Simulink.Simulation.internal.BlockDiagramAssociatedDataInterface = Simulink.Simulation.internal.BlockDiagramAssociatedData
            end
            oldf = slfeature( 'SetParamOnLinks', 0 );
            setParamOnLinksCleanup = onCleanup( @(  )slfeature( 'SetParamOnLinks', oldf ) );

            if slfeature( 'SimInputLoadVarFromExternalFile' ) > 0 &&  ...
                    slfeature( 'SlDataEnableDataConsistencyCheck' ) > 0
                simInput = Simulink.Simulation.internal.DesktopSimHelper.updateVariablesDataSource( simInput );
            end
            simInput = Simulink.Simulation.internal.DesktopSimHelper.enableAllowPauseForNonRapidAccelSims( simInput );
            silpilCleanup = Simulink.Simulation.internal.DesktopSimHelper.setSimInputOnBDAssociatedDataForSILPIL( simInput );%#ok<NASGU>
            Simulink.Simulation.internal.DesktopSimHelper.setSimInputModelWorkspaceNames( simInput );

            Simulink.Simulation.internal.DesktopSimHelper.markModelRefsForAccelRebuildIfLoggingChanged( simInput );
            out = config.SimFcn( simInput );
            out = out.setUserString( simInput.UserString );
            Simulink.Simulation.internal.DesktopSimHelper.disableFastRestartSettingIfModelDoesNotSupportIt( simInput );
        end

        function out = captureErrorInSimulationOutput( ME, simInput )
            out = MultiSim.internal.createSimulationOutput( ME, simInput.ModelName );
            out = out.setUserString( simInput.UserString );
        end

        function executePostSimTasksOnSuccess( simInput )
            modelName = simInput.ModelName;
            if ~bdIsLoaded( modelName )
                load_system( modelName )
                closeModelCleanup = onCleanup( @(  )bdclose( modelName ) );
            end
            Simulink.Simulation.internal.DesktopSimHelper.unregisterSimulationInputInfo( simInput )
            slInternal( 'emitSimAndCallbacksCompletedMessage',  ...
                get_param( modelName, 'Handle' ) );
        end

        function executePostSimTasksOnFailure( simInput )
            Simulink.Simulation.internal.DesktopSimHelper.unregisterSimulationInputInfo( simInput )



            slInternal( 'emitFinalSimStatus',  ...
                get_param( simInput.ModelName, 'Handle' ), true, false );
            slInternal( 'emitSimAndCallbacksCompletedMessage',  ...
                get_param( simInput.ModelName, 'Handle' ) );
        end

        function out = runUsingManager( simInputs, varargin )


            p = inputParser;
            addParameter( p, 'ShowSimulationManager', 'off', @( x )any( validatestring( x, { 'on', 'off' } ) ) );
            p.KeepUnmatched = true;
            parse( p, varargin{ : }, 'AllowParallelSimulations', false );

            simMgr = Simulink.SimulationManager( simInputs );
            options = p.Unmatched;

            simMgr.Options = options;

            if simMgr.Options.AllowMultipleModels
                modelsToCheck = unique( { simInputs.ModelName } );
            else
                modelsToCheck = { simInputs.validateModelNames(  ) };
            end


            cellfun( @( x )errorIfSimulationAlreadyStarted( x ), modelsToCheck );

            if strcmpi( p.Results.ShowSimulationManager, 'on' )

                multiSimMgr = MultiSim.internal.MultiSimManager.getMultiSimManager;
                multiSimMgr.addJob( simMgr );
                simMgr.Options.ShowSimulationManager = true;
            end
            out = simMgr.run(  );
        end

        function simInput = tuneParametersForRapidAccelerator( simInput, rtp )
            nonTunableVariables = struct( [  ] );
            if isempty( rtp )
                folderConfig = Simulink.filegen.internal.FolderConfiguration( simInput.ModelName );
                buildDir = folderConfig.RapidAccelerator.absolutePath( 'ModelCode' );
                buildRTPFile = fullfile( buildDir, filesep, 'build_rtp.mat' );
                if ~isfile( buildRTPFile )

                    slxcCleanup = onCleanup( @(  )builtin( '_removeAllSLCacheModelInfo' ) );
                    builtin( '_unpackSLCacheRapidAccelRTP', simInput.ModelName );




                    if ~simInput.IsUsingPCT && ~isfile( buildRTPFile )

                        Simulink.BlockDiagram.buildRapidAcceleratorTarget( simInput.ModelName );
                    end
                    if ~isfile( buildRTPFile )
                        error( message( 'Simulink:Commands:SimInputCannotFindRTPFile' ) );
                    end
                end
                rtp = load( buildRTPFile );
            end

            Simulink.Simulation.internal.warnAboutNonTunableVarChange( simInput, rtp.nonTunableVariables );

            for i = 1:numel( simInput.Variables )
                try
                    rtp = Simulink.BlockDiagram.modifyTunableParameters(  ...
                        rtp,  ...
                        simInput.Variables( i ).Name,  ...
                        simInput.Variables( i ).Value ...
                        );
                catch ME
                    switch ME.identifier
                        case 'RTW:rsim:SetRTPParamBadIdentifier'

                        otherwise
                            throw( ME )
                    end
                end
            end

            rtp.internal.forInternalUse = true;

            rtp.internal.simInputVariables = { simInput.Variables.Name };

            simInput = simInput.addHiddenModelParameter( 'RapidAcceleratorParameterSets', rtp );
        end

        function [ varValue, varWasResolved ] = getVariableValue( modelName, varName, varargin )
            p = Simulink.Simulation.internal.DesktopSimHelper.VariableWorkspaceAndContextParser;
            parse( p, varargin{ : } );

            varWorkspace = p.Results.Workspace;

            switch varWorkspace
                case 'global-workspace'

                    load_system( modelName );

                    location = slprivate( 'getVariableLocation', modelName, varName );
                    [ location, ~, ~, ~, ~ ] =  ...
                        slprivate( 'parseLocation', modelName,  ...
                        location, varName );
                    if any( strcmp( location, { 'base', 'dictionary' } ) )
                        varValue = evalinGlobalScope( modelName, varName );
                        varWasResolved = true;
                    else
                        varValue = [  ];
                        varWasResolved = false;
                    end

                otherwise

                    load_system( varWorkspace );
                    modelWS = get_param( varWorkspace, 'ModelWorkspace' );
                    varValue = slprivate( 'modelWorkspaceGetVariableHelper', modelWS, varName );
                    varWasResolved = true;
            end



            if varWasResolved && isa( varValue, 'handle' )
                varValue = copy( varValue );
            end
        end

        function simInput = updateVariablesDataSource( simInput )


            arguments
                simInput( 1, 1 )Simulink.SimulationInput
            end



            for varIdx = 1:numel( simInput.Variables )
                defaultDataSource = 'global-workspace';
                if ~strcmp( simInput.Variables( varIdx ).DataSource, defaultDataSource )
                    simInput.Variables( varIdx ).DataSource = defaultDataSource;
                end
            end

            topModel = simInput.ModelName;
            if ~bdIsLoaded( topModel )
                load_system( topModel );
            end




            if strcmp( simInput.get_param( 'EnforceDataConsistency' ), 'off' )

                model2DA = containers.Map;
                exInvalidContext = MException( message( 'Simulink:Commands:SimInputInvalidSimInputForSim', topModel ) );

                varWithUnsupportedSimMode = {  };
                uniqueVarInDdLinkedToTopMdl = false;



                topMdlSimMode = '';
                daTop = [  ];

                for varIdx = 1:numel( simInput.Variables )
                    strContext = convertCharsToStrings( simInput.Variables( varIdx ).Context );
                    varName = simInput.Variables( varIdx ).Name;



                    if ~strcmp( strContext, "" )












                        if isempty( topMdlSimMode )
                            topMdlSimMode = simInput.get_param( 'SimulationMode' );
                        end


                        if ~isa( daTop, 'Simulink.Data.DataAccessor' )
                            daTop = Simulink.data.DataAccessor.createForExternalData( topModel );
                        end
                        varIds = daTop.identifyByName( varName );
                        if numel( varIds ) == 1 && endsWith( varIds.getDataSourceFriendlyName, '.sldd' )
                            uniqueVarInDdLinkedToTopMdl = true;
                        end

                        if strcmp( strContext, topModel ) ...
                                && ( startsWith( 'accelerator', topMdlSimMode, 'IgnoreCase', true ) || startsWith( 'rapid-accelerator', topMdlSimMode, 'IgnoreCase', true ) ) ...
                                && uniqueVarInDdLinkedToTopMdl
                            varWithUnsupportedSimMode = [ varWithUnsupportedSimMode, varName ];%#ok<*AGROW>
                        end


                        if model2DA.isKey( strContext )
                            da = model2DA( strContext );
                        else
                            da = Simulink.data.DataAccessor.createForExternalData( strContext );
                            model2DA( strContext ) = da;
                        end

                        potentialDataSources = getPotentialDataSources( varName, da, strContext );
                        exInvalidContext = checkIfValidDataSource( varName,  ...
                            strContext, potentialDataSources, exInvalidContext );
                        dataSource = potentialDataSources{ 1 };
                        if isempty( exInvalidContext.cause )
                            simInput.Variables( varIdx ).DataSource = dataSource;
                        end
                    end
                end

                if ~isempty( varWithUnsupportedSimMode )
                    constructMsg = strjoin( varWithUnsupportedSimMode, ', ' );
                    exInvalidSimMode =  ...
                        MException( message( 'Simulink:Commands:SimInputAccelAndRapidModeNotSupported', topModel, constructMsg ) );
                    throw( exInvalidSimMode );
                end


                if ~isempty( exInvalidContext.cause )
                    throw( exInvalidContext );
                end
            end
        end
    end

    methods ( Static, Access = private )
        function simInput = enableAllowPauseForNonRapidAccelSims( simInput )
            simMode = simInput.get_param( 'SimulationMode' );



            if ~startsWith( simMode, 'r', 'IgnoreCase', true )
                simInput = simInput.addHiddenModelParameter( 'AllowPause', 'on' );
            end
        end

        function setSimInputModelWorkspaceNames( simInput )
            arguments
                simInput Simulink.SimulationInput{ mustBeNonempty }
            end

            modelHandle = get_param( simInput.ModelName, 'Handle' );
            dataId = 'SL_SimulationInputInfo';
            if ~Simulink.BlockDiagramAssociatedData.isRegistered( modelHandle, dataId )
                Simulink.Simulation.internal.DesktopSimHelper.initializeSimulationInputInfoOnBDAssociatedData( simInput );
            end
            simInputInfo = Simulink.BlockDiagramAssociatedData.get( modelHandle, dataId );
            modelWkspNames = unique( arrayfun( @( x )x.Workspace + "", simInput.Variables ) );
            simInputInfo.ModelWorkspaceNames = modelWkspNames;
            Simulink.BlockDiagramAssociatedData.set( modelHandle, dataId, simInputInfo );
        end

        function unregisterSimulationInputInfo( simInput )
            modelHandle = get_param( simInput.ModelName, 'Handle' );
            dataId = 'SL_SimulationInputInfo';





            if Simulink.BlockDiagramAssociatedData.isRegistered( modelHandle, dataId )
                Simulink.BlockDiagramAssociatedData.unregister( modelHandle, dataId );
            end
        end

        function markModelRefsForAccelRebuildIfLoggingChanged( simInput )
            arguments
                simInput( 1, 1 )Simulink.SimulationInput
            end

            modelName = simInput.ModelName;
            portParams = simInput.PortParameters;

            modifiedModels = unique( string( get_param( bdroot( [ portParams.PortHandle ] ), 'Name' ) ) );
            modifiedModelRefs = modifiedModels( ~strcmp( modifiedModels, modelName ) );

            dataId = 'SL_SimulationInputInfo';
            modelHandle = get_param( modelName, 'Handle' );
            simInputInfo = Simulink.BlockDiagramAssociatedData.get( modelHandle, dataId );
            simInputInfo.ModelsModifiedForLogging = modifiedModelRefs;
            Simulink.BlockDiagramAssociatedData.set( modelHandle, dataId, simInputInfo );
        end

        function cleanupFcn = setSimInputOnBDAssociatedDataForSILPIL( simInput )




            cleanupFcn = onCleanup( @(  )[  ] );
            simMode = simInput.get_param( 'SimulationMode' );
            if strncmpi( simMode, 'software-in-the-loop (sil)', length( simMode ) ) ||  ...
                    strncmpi( simMode, 'processor-in-the-loop (pil)', length( simMode ) )
                bdAssociatedDataId = 'SL_SimInputForSILPIL';
                modelHandle = get_param( simInput.ModelName, 'Handle' );
                if ~Simulink.BlockDiagramAssociatedData.isRegistered( modelHandle, bdAssociatedDataId )
                    Simulink.BlockDiagramAssociatedData.register( modelHandle, bdAssociatedDataId, 'any' );
                end
                simInputForSILPIL = transformSimInputForSILPIL( simInput );
                Simulink.BlockDiagramAssociatedData.set( modelHandle, bdAssociatedDataId, simInputForSILPIL );
                cleanupFcn = onCleanup( @(  )Simulink.BlockDiagramAssociatedData.set( modelHandle, bdAssociatedDataId, Simulink.SimulationInput.empty ) );
            end
        end

        function initializeSimulationInputInfoOnBDAssociatedData( simInput )
            bdAssociatedDataId = 'SL_SimulationInputInfo';
            modelHandle = get_param( simInput.ModelName, 'Handle' );
            if ~Simulink.BlockDiagramAssociatedData.isRegistered( modelHandle, bdAssociatedDataId )
                Simulink.BlockDiagramAssociatedData.register( modelHandle, bdAssociatedDataId, 'any' );
            end
            bdData = Simulink.internal.getDefaultSimulationInputInfo(  );
            Simulink.BlockDiagramAssociatedData.set( modelHandle, bdAssociatedDataId, bdData );
        end

        function simInput = setAllowOneTimeNonTunableParamChange( simInput )
            if isempty( simInput.SimInfo )
                simInput.SimInfo = Simulink.Simulation.internal.SimInfo;
            end

            if slsvTestingHook( 'AllowNonTunableParamChangeInFR' ) > 0
                simInput.SimInfo.AllowOneTimeNonTunableParamChange = true;
                return ;
            end

            modelName = simInput.getModelNameForApply(  );
            fastRestartIsEnabledForModel = Simulink.Simulation.internal.DesktopSimHelper.isFastRestartEnabledForModel( modelName );

            if fastRestartIsEnabledForModel
                simInput.SimInfo.AllowOneTimeNonTunableParamChange = false;
            else
                if simInput.SimInfo.UseFastRestart
                    if ~bdIsLoaded( modelName )
                        simInput.loadModelToRun(  );
                    end
                    set_param( modelName, "FastRestart", "on" );
                    simInput.SimInfo.AllowOneTimeNonTunableParamChange = true;
                end
            end
        end

        function fastRestartIsEnabled = isFastRestartEnabledForModel( modelName )
            isModelLoaded = bdIsLoaded( modelName );
            if ~isModelLoaded
                fastRestartIsEnabled = false;
            else
                fastRestartState = get_param( modelName, "FastRestart" );
                fastRestartIsEnabled = logical( matlab.lang.OnOffSwitchState( fastRestartState ) );
            end
        end

        function disableFastRestartSettingIfModelDoesNotSupportIt( simInput )
            simInfo = simInput.SimInfo;
            if ~isempty( simInfo ) && simInfo.AllowOneTimeNonTunableParamChange




                modelName = simInput.getModelNameForApply(  );
                simStatus = get_param( modelName, "SimulationStatus" );
                isModelInitializedInFastRestart = strcmp( simStatus, "compiled" );
                if ~isModelInitializedInFastRestart
                    set_param( modelName, "FastRestart", "off" );
                end
            end
        end
    end
end

function errorIfSimulationAlreadyStarted( modelName )
if bdIsLoaded( modelName )
    status = get_param( modelName, 'SimulationStatus' );
    if ~strcmpi( status, 'stopped' ) &&  ...
            ~strcmpi( status, 'compiled' )
        throwAsCaller( MException( message( 'Simulink:Commands:CannotStartNewSimWhileStarted' ) ) );
    end
end
end

function p = getVariableWorkspaceAndContextParser(  )
p = inputParser;
isScalarText = @( x )validateattributes( x, { 'char', 'string' }, { 'scalartext' } );
addParameter( p, 'Workspace', 'global-workspace', isScalarText );
addParameter( p, 'context', '', isScalarText );
end

function simInputForSILPIL = transformSimInputForSILPIL( simInput )
simInputForSILPIL = Simulink.SimulationInput( simInput.ModelName );
simInputForSILPIL.InitialState = simInput.InitialState;
simInputForSILPIL.ExternalInput = simInput.ExternalInput;
simInputForSILPIL.ModelParameters = simInput.ModelParameters;
simInputForSILPIL.Variables = simInput.Variables;
simInputForSILPIL.PostSimFcn = [  ];
simInputForSILPIL.UserString = simInput.UserString;



simInputForSILPIL = simInputForSILPIL.setModelParameter( "RecordCoverage", "off" );
end

function dataSources = getPotentialDataSources( varName, da, modelStr )

vars = da.identifyByName( varName );
dataSources = arrayfun( @( x )x.getDataSourceFriendlyName,  ...
    vars, 'UniformOutput', false );
if numel( dataSources ) == 0


    ddName = get_param( modelStr, 'DataDictionary' );
    if isempty( ddName )
        allLibDD = slprivate( 'getAllDictionariesOfLibrary', modelStr );
        if ~isempty( allLibDD )
            ddName = allLibDD{ 1 };
        end
    end
    dataSources = { ddName };
end
end


function ex = checkIfValidDataSource( varName, modelName, potentialDataSources, ex )

if iscell( potentialDataSources )
    if numel( potentialDataSources ) == 1
        if isempty( potentialDataSources{ 1 } )

            ex = ex.addCause( MException( message( 'Simulink:Commands:SimInputUnableToCreateVariable',  ...
                varName, modelName ) ) );
        else
            if strcmp( potentialDataSources{ 1 }, 'base workspace' )

                ex = ex.addCause( MException( message( 'Simulink:Commands:SimInputUnableToModifyVariable',  ...
                    varName, modelName ) ) );
            end
        end
    else

        sourceMsg = potentialDataSources{ 1 };
        for i = 2:numel( potentialDataSources )
            sourceMsg = [ sourceMsg, '''', ', ', '''', potentialDataSources{ i } ];%#ok<*AGROW>
        end
        ex = ex.addCause( MException( message( 'Simulink:Commands:SimInputDuplicateSymbolWithSource',  ...
            varName, modelName, sourceMsg ) ) );
    end
end
end

