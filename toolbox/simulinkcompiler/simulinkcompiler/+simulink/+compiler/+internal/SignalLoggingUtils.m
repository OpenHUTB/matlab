classdef SignalLoggingUtils < handle

    properties ( Access = private )
        Model
        ModelDataService
    end

    methods


        function obj = SignalLoggingUtils( model, modelDataService )
            arguments
                model( 1, 1 )string
                modelDataService simulink.compiler.internal.ModelDataService =  ...
                    simulink.compiler.internal.ModelDataService.empty(  )
            end

            obj.Model = model;
            obj.setModelDataService( modelDataService );
        end



        function turnOnSignalLogging( obj )
            load_system( obj.Model );
            set_param( obj.Model, 'SignalLogging', 'on' );
        end



        function signals = getLoggedSignals( obj )
            load_system( obj.Model );
            signals = get_param( obj.Model, "InstrumentedSignals" );
        end



        function signalCount = getNumLoggedSignals( obj )
            signalCount = 0;
            load_system( obj.Model );
            signals = obj.getLoggedSignals(  );
            if ~isempty( signals )
                signalCount = double( signals.Count );
            end
        end



        function turnOnLoggingForScopeBlocks( obj )
            load_system( obj.Model );
            blockPaths = obj.ModelDataService.getRootScopeBlockPaths(  );
            blockPaths = blockPaths';
            for idx = 1:numel( blockPaths )
                turnOnDataLoggingForScope( blockPaths{ idx }, idx );
            end
        end



        function limitRootScopeDataPoints( obj, numPoints )
            load_system( obj.Model );
            numPoints = num2str( numPoints );
            blockPaths = obj.ModelDataService.getRootScopeBlockPaths(  );
            for blockPath = blockPaths'
                limitDataPointsForScope( blockPath{ 1 }, numPoints );
            end
        end



        function TF = isAnyScopeLoggingData( obj )
            TF = false;
            load_system( obj.Model );
            scopePaths = obj.ModelDataService.getRootScopeBlockPaths(  );

            if isempty( scopePaths )
                return ;
            end

            for scopePath = scopePaths'
                TF = isequal( get_param( scopePath{ 1 }, 'DataLogging' ), 'on' );
                if TF, return ;end
            end
        end


    end

    methods ( Access = private )



        function setModelDataService( obj, modelDataService )
            obj.ModelDataService = modelDataService;

            if isempty( obj.ModelDataService )
                obj.ModelDataService =  ...
                    simulink.compiler.internal.ModelDataService( obj.Model );
            end
        end



    end

end

function turnOnDataLoggingForScope( blockPath, idx )
varName = [ 'Scope', num2str( idx ), 'Data' ];
set_param( blockPath, 'DataLogging', 'on' );
set_param( blockPath, 'DataLoggingSaveFormat', 'Structure With Time' );
set_param( blockPath, 'DataLoggingVariableName', varName );
end

function limitDataPointsForScope( blockPath, numPoints )
set_param( blockPath, 'DataLoggingLimitDataPoints', 'on' );
set_param( blockPath, 'DataLoggingMaxPoints', num2str( numPoints ) );
end
