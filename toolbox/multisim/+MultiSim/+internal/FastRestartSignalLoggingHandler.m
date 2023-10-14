classdef FastRestartSignalLoggingHandler < handle

    properties ( Access = private )
        ModelToLoggedSignalsMap
        ModelToDefaultLogSpecMap
        ModelRequiresSetup
        SignalsToUnlog
    end

    methods
        function obj = FastRestartSignalLoggingHandler( simInputs )
            arguments
                simInputs Simulink.SimulationInput{ mustBeNonempty }
            end

            obj.ModelToDefaultLogSpecMap = containers.Map;
            obj.ModelRequiresSetup = containers.Map;
            obj.ModelToLoggedSignalsMap = createLoggedSignalsArrayForEachModel( simInputs );
        end

        function simInput = setupLoggingForFastRestart( obj, simInput )
            modelName = simInput.getModelNameForApply(  );

            if ~isKey( obj.ModelToLoggedSignalsMap, modelName )


                return ;
            end

            obj.setupLoggingForModel( modelName );

            if isempty( simInput.LoggingSpecification )
                simInput.LoggingSpecification = obj.ModelToDefaultLogSpecMap( modelName );
            end
        end

        function delete( obj )
            MultiSim.internal.unmarkSignalsToLog( obj.SignalsToUnlog );
        end
    end

    methods ( Access = private )
        function setupLoggingForModel( obj, modelName )
            if ~isKey( obj.ModelToDefaultLogSpecMap, modelName )
                obj.cacheDefaultLogSpecForModel( modelName );
            end

            if ~isKey( obj.ModelRequiresSetup, modelName )
                obj.markSignalsForLogging( modelName );
                obj.ModelRequiresSetup( modelName ) = false;
            end
        end

        function cacheDefaultLogSpecForModel( obj, modelName )
            simInputWithEmptyLoggingSpec = Simulink.SimulationInput( modelName );
            simInputWithEmptyLoggingSpec.LoggingSpecification = Simulink.Simulation.LoggingSpecification.empty;
            if ~isKey( obj.ModelToLoggedSignalsMap, modelName )
                modelToLoggedSignalsMap = containers.Map;
            else
                modelToLoggedSignalsMap = obj.ModelToLoggedSignalsMap( modelName );
            end
            simInputWithDefaultLoggingSpec = MultiSim.internal.resetLoggingSpec( modelToLoggedSignalsMap, simInputWithEmptyLoggingSpec );
            obj.ModelToDefaultLogSpecMap( modelName ) = simInputWithDefaultLoggingSpec.LoggingSpecification;
        end

        function markSignalsForLogging( obj, modelName )
            if ~isKey( obj.ModelToLoggedSignalsMap, modelName )
                return ;
            end

            loggedSignals = values( obj.ModelToLoggedSignalsMap( modelName ) );
            for idx = 1:numel( loggedSignals )
                bPath = loggedSignals{ idx }.BlockPath.convertToCell;
                blockOwnerModel = getModelNameFromPath( bPath{ end  } );
                load_system( blockOwnerModel );
                if ~strcmp( modelName, blockOwnerModel )
                    obj.cacheDefaultLogSpecForModel( blockOwnerModel );
                end
                ph = get_param( bPath{ end  }, "PortHandles" );
                ph = ph.Outport( loggedSignals{ idx }.OutputPortIndex );
                if strcmp( get_param( ph, "DataLogging" ), "off" )
                    set_param( ph, "DataLogging", "on" );
                    obj.SignalsToUnlog = [ obj.SignalsToUnlog, loggedSignals{ idx } ];
                end
            end
        end
    end
end

function modelToLoggedSignalsMap = createLoggedSignalsArrayForEachModel( simInputs )
modelToLoggedSignalsMap = containers.Map;
modelToLoggingSpecsMap = getLoggingSpecsForEachModel( simInputs );

allModels = modelToLoggingSpecsMap.keys;
for modelIdx = 1:numel( allModels )
    modelName = allModels{ modelIdx };
    loggingSpecsForModel = modelToLoggingSpecsMap( modelName );

    if ~isempty( loggingSpecsForModel )
        sigsMap = containers.Map;
        for logSpecIdx = 1:numel( loggingSpecsForModel )
            logSpec = loggingSpecsForModel( logSpecIdx );
            sigs = logSpec.SignalsToLog;
            for sigIdx = 1:numel( sigs )

                key = sigs( sigIdx ).BlockPath.toPipePath;
                key = [ key, ':', num2str( sigs( sigIdx ).OutputPortIndex ) ];
                if ~sigsMap.isKey( key )
                    sigs( sigIdx ).LoggingInfo.DataLogging = false;
                    sigsMap( key ) = sigs( sigIdx );
                end
            end
        end
        modelToLoggedSignalsMap( modelName ) = sigsMap;
    end
end
end

function modelToLoggingSpecMap = getLoggingSpecsForEachModel( simInputs )
modelToLoggingSpecMap = containers.Map;

for simInputIdx = 1:numel( simInputs )
    simIn = simInputs( simInputIdx );
    addLoggingSpecToMap( simIn, modelToLoggingSpecMap );
end

allModels = modelToLoggingSpecMap.keys;
for modelIdx = 1:numel( allModels )
    modelName = allModels{ modelIdx };
    modelToLoggingSpecMap( modelName ) = unique( modelToLoggingSpecMap( modelName ) );
end
end

function addLoggingSpecToMap( simInput, modelToLoggingSpecMap )
modelName = simInput.getModelNameForApply(  );

if ~isempty( simInput.LoggingSpecification )
    if ~modelToLoggingSpecMap.isKey( modelName )
        modelToLoggingSpecMap( modelName ) = simInput.LoggingSpecification.empty;
    end
    modelToLoggingSpecMap( modelName ) = [ modelToLoggingSpecMap( modelName ), simInput.LoggingSpecification ];%#ok<NASGU>
end
end

function modelName = getModelNameFromPath( path )
[ modelName, ~ ] = strtok( path, '/' );
end

