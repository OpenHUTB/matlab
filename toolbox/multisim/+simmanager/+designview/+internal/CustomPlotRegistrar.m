classdef ( AllowedSubclasses = { ?matlab.mock.classes.CustomPlotRegistrarMock } ) ...
        CustomPlotRegistrar < handle

    properties ( Constant )
        Instance = simmanager.designview.internal.CustomPlotRegistrar(  )
    end


    properties ( Access = private )
        DataModel
        Sync
        MF0Channel
    end


    properties ( SetAccess =  ...
            ?simmanager.designview.internal.PlotConfigDataStore )
        ConfigRegistry
    end


    properties ( Access = private )
        Listeners
        PlotConfigRegistryStore
    end


    methods ( Access = ?matlab.mock.classes.CustomPlotRegistrarMock )
        function obj = CustomPlotRegistrar( configRegistryStore,  ...
                registryDataModel )



            arguments
                configRegistryStore =  ...
                    simmanager.designview.internal.PreferencesDataStore(  );
                registryDataModel = mf.zero.Model
            end

            obj.PlotConfigRegistryStore = configRegistryStore;
            obj.setupDataModel( registryDataModel );
        end
    end



    methods

        function register( obj, plotConfigData )
            arguments
                obj
                plotConfigData.PlotClass{ mustBeTextScalar,  ...
                    mustBeValidVariableName } = ""
                plotConfigData.GalleryIcon{ mustBeTextScalar } = ''
                plotConfigData.GalleryLabel{ mustBeTextScalar,  ...
                    mustBeNonzeroLengthText } = 'Custom Plot'
            end

            obj.registerPlot( plotConfigData );
        end


        function deregister( obj, plotConfigData )
            arguments
                obj
                plotConfigData.PlotClass{ mustBeTextScalar,  ...
                    mustBeValidVariableName }
            end

            [ inRegistry, idx ] = obj.isInRegistry( plotConfigData );

            if inRegistry
                obj.ConfigRegistry.PlotConfigs.at( idx ).destroy;
                obj.PlotConfigRegistryStore.persist( obj.ConfigRegistry );
            end
        end


        function plotConfig = getPlotConfig( obj, plotConfigId )
            registeredConfigs = obj.ConfigRegistry.PlotConfigs.toArray(  );
            plotConfig = slsim.design.internal.PlotConfig.empty;

            for idx = 1:numel( registeredConfigs )
                if strcmp( registeredConfigs( idx ).UUID, plotConfigId )
                    plotConfig = registeredConfigs( idx );
                    break ;
                end
            end
        end


        function [ TF, idx ] = isInRegistry( obj, plotConfig )
            registeredConfigs = obj.ConfigRegistry.PlotConfigs.toArray(  );

            if isempty( registeredConfigs )
                TF = false;
                idx =  - 1;
                return ;
            end

            exists = @( config )obj.configsEquivalent( plotConfig, config );
            exist = arrayfun( exists, registeredConfigs );
            TF = any( exist );
            idx = find( exist );
        end

    end



    methods ( Hidden )

        function registerPlot( obj, plotConfig )
            [ inRegistry, idx ] = obj.isInRegistry( plotConfig );

            txn = obj.DataModel.beginTransaction(  );
            if inRegistry
                obj.ConfigRegistry.PlotConfigs.removeAt( idx );
            end

            iconURI = '';

            if ~isequal( plotConfig.GalleryIcon, "" )
                iconURI = obj.iconURIFromFile( plotConfig.GalleryIcon );
            end

            newConfig = slsim.design.internal.PlotConfig( obj.DataModel );
            newConfig.PlotClass = plotConfig.PlotClass;
            newConfig.GalleryIcon = iconURI;
            newConfig.GalleryLabel = plotConfig.GalleryLabel;

            obj.ConfigRegistry.PlotConfigs.add( newConfig );

            txn.commit(  );

            obj.PlotConfigRegistryStore.persist( obj.ConfigRegistry );
        end

    end



    methods ( Access = private )

        function setupDataModel( obj, registryDataModel )
            import mf.zero.io.ConnectorChannelMS;
            import mf.zero.io.ModelSynchronizer;

            obj.DataModel = registryDataModel;

            syncChannel = "/slsim/design/simmanager/customplots";
            connectorChannel = ConnectorChannelMS( syncChannel, syncChannel );



            obj.Sync = ModelSynchronizer( obj.DataModel, connectorChannel );
            obj.MF0Channel = connectorChannel;







            obj.ConfigRegistry =  ...
                obj.PlotConfigRegistryStore.load( obj.DataModel );

            obj.Sync.start(  );
        end

    end



    methods ( Access = private, Static )

        function TF = configsEquivalent( lhs, rhs )
            TF = ~strcmp( lhs.PlotClass, "" ) &&  ...
                strcmp( lhs.PlotClass, rhs.PlotClass );
        end


        function iconURI = iconURIFromFile( iconFile )
            import MultiSim.internal.ImageUtils.getImageDataURIFromFile;

            iconURI = '';
            try
                iconURI = getImageDataURIFromFile( iconFile );
            catch ME
                error( "Unable to use provided icon: " + ME.message );
            end
        end

    end



end

