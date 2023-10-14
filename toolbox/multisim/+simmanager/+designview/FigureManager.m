classdef FigureManager < handle
    properties ( SetObservable, SetAccess = private )
        FigureObjects
    end

    properties ( SetObservable )
        IsDirty = false
        SelectedRuns
    end

    properties ( Dependent )
        FigureData
    end

    properties
        DataSourceLabels( 1, 1 ) = struct
    end

    properties ( Access = private )
        JobStatusDB
        JobUUID
        ModelName
        ActualFigureData
        DataSourcesFinalized
    end

    properties ( Hidden = true, SetAccess = private, Transient = true )
        DataModel
    end

    properties ( Access = private, Transient = true )
        DesignView
        Sync
        MF0Channel
        CommandModel
        CommandSync
        MF0CommandChannel
        EventListeners

        PlotRegistrar
    end

    properties ( GetAccess = ?simmanager.designview.internal.CustomPlot, SetAccess = private )
        MultiSimJob
    end

    properties ( Access = private )
        DataModelJSON
    end

    properties ( Hidden )
        TestingMode = false
    end

    events
        FigureCreated
    end

    methods
        function obj = FigureManager( multiSimJob, plotRegistrar )
            arguments
                multiSimJob
                plotRegistrar = simmanager.designview.internal.CustomPlotRegistrar.Instance;
            end

            obj.ModelName = multiSimJob.ModelName;
            obj.JobStatusDB = multiSimJob.JobStatusDB;
            obj.JobUUID = multiSimJob.UUID;
            obj.MultiSimJob = multiSimJob;

            obj.PlotRegistrar = plotRegistrar;

            obj.setupDataModel(  );
            obj.setupCommandModel(  );
        end

        function set.FigureData( obj, newFigureData )
            obj.ActualFigureData = newFigureData;
            obj.DataSourcesFinalized = false;
            delete( obj.EventListeners );
            obj.EventListeners = addlistener( obj.ActualFigureData, "DataSourcesUpdated",  ...
                @( ~, eventData )obj.updateDataSources( eventData.Data ) );
            obj.EventListeners( 2 ) = addlistener( obj.ActualFigureData, "DataSourcesFinalized",  ...
                @( ~, ~ )obj.finalizeDataSources(  ) );
        end

        function figData = get.FigureData( obj )
            figData = obj.ActualFigureData;
        end



        function createFigure( obj, figureType )
            switch ( figureType )
                case slsim.design.FigureType.ScatterPlot
                    obj.createScatterPlot(  )
                case slsim.design.FigureType.Histogram

                case slsim.design.FigureType.SurfPlot
                    obj.createSurfPlot(  );
                otherwise


                    obj.createCustomPlot( figureType );
            end
            obj.IsDirty = true;
        end

        function createCustomPlotInstance( obj, plotConfigId )
            plotConfig = obj.PlotRegistrar.getPlotConfig( plotConfigId );
            plotClass = plotConfig.PlotClass;

            classExists = logical( exist( plotClass, 'class' ) );
            isSubClassOfCustomPlot =  ...
                ismember( "MultiSim.CustomPlot", superclasses( plotClass ) );

            if classExists && isSubClassOfCustomPlot
                plotObj = eval( plotClass );
                plotObj.PlotConfigId = plotConfigId;
            else


                error( "Unable to use custom plot class '%s'. Ensure that the class is on the MATLAB path.", plotClass );
            end

            obj.createFigure( plotObj );
        end



        function deselectRuns( obj, runIds )
            for i = 1:numel( runIds )
                obj.SelectedRuns( obj.SelectedRuns == runIds( i ) ) = [  ];
            end
            for figIndex = 1:numel( obj.FigureObjects )
                obj.FigureObjects( figIndex ).deselectRuns( runIds );
            end
        end





        function selectRuns( obj, runIds, append )
            if ~append
                obj.SelectedRuns = [  ];
            end
            obj.SelectedRuns = [ obj.SelectedRuns, runIds ];
            for figIndex = 1:numel( obj.FigureObjects )
                obj.FigureObjects( figIndex ).selectRuns( runIds, append );
            end
        end

        function deleteFigure( obj, canvasId )
            for i = 1:numel( obj.FigureObjects )
                curFig = obj.FigureObjects( i );
                if strcmp( curFig.CanvasId, canvasId )
                    delete( curFig );
                    obj.FigureObjects( i ) = [  ];
                    break ;
                end
            end


            for i = 1:obj.DesignView.Figures.Size(  )
                curFig = obj.DesignView.Figures( i );
                if strcmp( curFig.Id, canvasId )
                    destroy( curFig );
                    break ;
                end
            end
            obj.IsDirty = true;
        end

        function resetFigures( obj )
            for i = 1:numel( obj.FigureObjects )
                obj.FigureObjects( i ).reset(  );
            end
        end

        function delete( obj )
            if obj.TestingMode
                return
            end

            delete( obj.EventListeners );
            delete( obj.FigureData );
            delete( obj.FigureObjects );
            delete( obj.Sync );
            delete( obj.DataModel );
            delete( obj.CommandSync );
            delete( obj.CommandModel );
        end

        function savedObj = saveobj( obj )
            savedObj = obj;
            serializer = mf.zero.io.JSONSerializer;
            savedObj.DataModelJSON = serializer.serializeToString( obj.DataModel );
            obj.IsDirty = false;
        end

        function simInputs = getSimulationInputs( obj )
            simInputsVector = obj.MultiSimJob.SimulationManager.SimulationInputs;
            simInputsOrigSize = obj.MultiSimJob.SimulationManager.SimInputSize;
            simInputs = reshape( simInputsVector, simInputsOrigSize );
        end
    end

    methods ( Hidden = true )
        function updateDataModel( obj, dataModel )
            obj.DataModel = dataModel;
            obj.DesignView = dataModel.topLevelElements;

            delete( obj.Sync );
            delete( obj.MF0Channel );
            delete( obj.FigureObjects );
            obj.FigureObjects = [  ];
            obj.IsDirty = false;

            syncChannel = [ '/slsim/design/simmanager/', obj.JobUUID ];
            connectorChannel = mf.zero.io.ConnectorChannelMS( syncChannel, syncChannel );
            obj.Sync = mf.zero.io.ModelSynchronizer( obj.DataModel, connectorChannel );
            obj.MF0Channel = connectorChannel;
            obj.Sync.start(  );
        end

        function addFigureWithProperties( obj, figNum, MATLABFig, figProperties )
            figureType = obj.DesignView.Figures( figNum ).Type;
            parser = mf.zero.io.JSONParser;
            parser.parseString( figProperties );

            switch ( figureType )
                case slsim.design.FigureType.ScatterPlot
                    newFigObject = obj.addScatterPlotWithProperties( MATLABFig, parser.Model );
                case slsim.design.FigureType.SurfPlot
                    newFigObject = obj.addSurfPlotWithProperties( MATLABFig, parser.Model );
                case slsim.design.FigureType.CustomPlot
                    newFigObject = obj.addCustomPlotWithProperties( MATLABFig, parser.Model );
            end

            obj.DesignView.Figures( figNum ).Id = newFigObject.CanvasId;
            obj.DesignView.Figures( figNum ).Metadata = newFigObject.Metadata;
        end

        function newFigObject = addScatterPlotWithProperties( obj, MATLABFig, figPropertiesDataModel )
            newFigObject = simmanager.designview.ScatterPlot( obj.SelectedRuns, obj.FigureData, MATLABFig, figPropertiesDataModel );

            addlistener( newFigObject, "RunSelected",  ...
                @( ~, evt )obj.selectRuns( evt.Data, true ) );
            addlistener( newFigObject, "RunDeselected",  ...
                @( ~, evt )obj.deselectRuns( evt.Data ) );

            obj.FigureObjects = [ obj.FigureObjects, newFigObject ];

            newFigObject.createConnector(  );
        end

        function newFigObject = addSurfPlotWithProperties( obj, MATLABFig, figPropertiesDataModel )
            newFigObject = simmanager.designview.SurfPlot( obj.SelectedRuns, obj.FigureData, MATLABFig, figPropertiesDataModel );
            obj.FigureObjects = [ obj.FigureObjects, newFigObject ];

            newFigObject.createConnector(  );
        end

        function newFigObject = addCustomPlotWithProperties( obj, MATLABFig, figPropertiesDataModel )
            plotConfigId = figPropertiesDataModel.topLevelElements.PlotConfigId;
            plotConfig = obj.PlotRegistrar.getPlotConfig( plotConfigId );
            plotClass = plotConfig.PlotClass;

            try
                customPlotObj = eval( plotClass );
                customPlotObj.PlotConfigId = plotConfigId;
            catch ME


                error( "Unable to use custom plot class '%s'. Ensure that the class is on the MATLAB path.", plotClass );
            end

            newFigObject = simmanager.designview.internal.CustomPlot(  ...
                obj, customPlotObj, MATLABFig, figPropertiesDataModel );

            obj.FigureObjects = [ obj.FigureObjects, newFigObject ];

            newFigObject.createConnector(  );
        end



        function figureData = getFigureData( obj )
            figureData = obj.FigureData;
        end

        function addFigure( obj, designViewFig )
            obj.DesignView.Figures.add( designViewFig );
        end
    end

    methods ( Access = private )


        function runSelectedListener( obj, evt )
            runId = evt.Data;
            obj.SelectedRuns = [ obj.SelectedRuns, runId ];
            for figIndex = 1:numel( obj.FigureObjects )
                obj.FigureObjects( figIndex ).selectRuns( runId );
            end
        end

        function createPlot( obj, newFigObject, designViewFig )
            obj.FigureObjects = [ obj.FigureObjects,  ...
                newFigObject ];

            newFigObject.createConnector(  );

            eventData = simmanager.designview.EventData( newFigObject.CanvasId );
            notify( obj, 'FigureCreated', eventData );

            dataSources = obj.DesignView.DataSources;
            newFigObject.addDataSources( dataSources.toArray(  ) );

            obj.addFigure( designViewFig );

            if ( obj.DataSourcesFinalized )
                newFigObject.finalizeDataSources;
            end
        end

        function createScatterPlot( obj )
            newFigObject = simmanager.designview.ScatterPlot( obj.SelectedRuns, obj.FigureData );

            addlistener( newFigObject, "RunSelected",  ...
                @( ~, evt )obj.selectRuns( evt.Data, true ) );
            addlistener( newFigObject, "RunDeselected",  ...
                @( ~, evt )obj.deselectRuns( evt.Data ) );

            designViewFig = slsim.design.Figure( obj.DataModel,  ...
                struct( 'Id', newFigObject.CanvasId, 'DocumentId', newFigObject.CanvasId,  ...
                'Metadata', newFigObject.Metadata, 'Type', slsim.design.FigureType.ScatterPlot ) );

            obj.createPlot( newFigObject, designViewFig );
        end

        function createSurfPlot( obj )
            newFigObject = simmanager.designview.SurfPlot( obj.SelectedRuns, obj.FigureData );

            designViewFig = slsim.design.Figure( obj.DataModel,  ...
                struct( 'Id', newFigObject.CanvasId, 'DocumentId', newFigObject.CanvasId,  ...
                'Metadata', newFigObject.Metadata, 'Type', slsim.design.FigureType.SurfPlot ) );

            obj.createPlot( newFigObject, designViewFig );
        end

        function createCustomPlot( obj, figureObj )
            newFigObject = simmanager.designview.internal.CustomPlot( obj, figureObj );

            designViewFig = slsim.design.Figure( obj.DataModel,  ...
                struct( 'Id', newFigObject.CanvasId, 'DocumentId', newFigObject.CanvasId,  ...
                'Metadata', newFigObject.Metadata, 'Type', slsim.design.FigureType.CustomPlot ) );

            obj.createPlot( newFigObject, designViewFig );
        end

        function setupDataModel( obj )
            obj.DataModel = mf.zero.Model;
            obj.DesignView = slsim.design.DesignView( obj.DataModel );

            syncChannel = [ '/slsim/design/simmanager/', obj.JobUUID ];
            connectorChannel = mf.zero.io.ConnectorChannelMS( syncChannel, syncChannel );



            obj.Sync = mf.zero.io.ModelSynchronizer( obj.DataModel, connectorChannel );
            obj.MF0Channel = connectorChannel;
            obj.Sync.start(  );
        end

        function setupCommandModel( obj )
            obj.CommandModel = mf.zero.Model;
            obj.CommandModel.addObservingListener( @obj.commandHandler );

            syncChannel = [ '/slsim/design/simmanager/', obj.JobUUID ];
            commandSyncChannel = [ syncChannel, '/command' ];
            commandChannel = mf.zero.io.ConnectorChannelMS( commandSyncChannel, commandSyncChannel );
            obj.CommandSync = mf.zero.io.ModelSynchronizer( obj.CommandModel, commandChannel );
            obj.MF0CommandChannel = commandChannel;
            obj.CommandSync.start(  );
        end

        function commandHandler( obj, report )
            command = report.Created;
            switch class( command )
                case 'slsim.design.internal.command.CreateFigure'
                    obj.createFigure( command.FigureType );

                case 'slsim.design.internal.command.DeleteFigure'
                    obj.deleteFigure( command.FigureId );

                case 'slsim.design.internal.command.SelectRuns'
                    runIds = command.RunIds.toArray(  );
                    obj.selectRuns( runIds, command.AppendToExistingSelection );

                case 'slsim.design.internal.command.DeselectRuns'
                    runIds = command.RunIds.toArray(  );
                    obj.deselectRuns( runIds );

                case 'slsim.design.internal.command.CreateCustomPlot'
                    plotConfigId = command.PlotConfigId;
                    obj.createCustomPlotInstance( plotConfigId );
            end
        end

        function updateDataSources( obj, data )
            newSourceNames = data.names;
            oldSources = obj.DesignView.DataSources.toArray;
            oldSourceNames = arrayfun( @( source ){ source.value }, oldSources );

            sourcesToBeAdded = setdiff( newSourceNames, oldSourceNames );
            for i = 1:numel( sourcesToBeAdded )
                sourceName = sourcesToBeAdded{ i };
                if isfield( obj.DataSourceLabels, sourceName )
                    itemString = obj.DataSourceLabels.( sourceName );
                else
                    itemString = sourceName;
                end
                newFigData = slsim.design.FigureDataSource( obj.DataModel,  ...
                    struct( 'value', sourceName,  ...
                    'label', itemString,  ...
                    'type', data.type ) );
                obj.DesignView.DataSources.add( newFigData );
                for figIndex = 1:numel( obj.FigureObjects )
                    obj.FigureObjects( figIndex ).addDataSources( newFigData );
                end
            end
        end

        function finalizeDataSources( obj )
            obj.DataSourcesFinalized = true;
            for figIndex = 1:numel( obj.FigureObjects )
                obj.FigureObjects( figIndex ).finalizeDataSources(  );
            end
        end

        function initPlotRegistrar( obj )


            obj.PlotRegistrar =  ...
                simmanager.designview.internal.CustomPlotRegistrar.Instance;
        end
    end
end

