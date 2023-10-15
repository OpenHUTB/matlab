classdef TransmissionLineDesigner < handle

    properties
        App
        Model
        Logger
    end


    properties

        EventController

        NewController
        OpenController
        SaveController
        ImportController
        TransmissionLineController
        SingleDifferentialController
        CouplingCheckboxController
        NumberOfAgressorsController
        StackConfigurationController
        DesignController
        SettingsController
        DefaultLayoutController
        ExportController
        PlotInputsController
        UnitDropdownController

        PropertiesController

        ResultsController
        FeedCurrentController
        CouplingCoefficientController
        PropagationDelayController
        CharacteristicImpedanceController
        CapacitanceController
        ResistanceController
        InductanceController

        ChargeController
        CurrentController
        SparametersController

        View2DController
        View3DController

        CloseController
    end

    methods

        function obj = TransmissionLineDesigner( Logger, Model, App, options )


            arguments
                Logger( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Logger = rfpcb.internal.apps.transmissionLineDesigner.model.Logger;
                Model( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.AppModel = rfpcb.internal.apps.transmissionLineDesigner.model.AppModel( Logger );
                App( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.AppView = rfpcb.internal.apps.transmissionLineDesigner.view.AppView( Logger );
                options.DebuggingMode( 1, : ){ mustBeTextScalar, mustBeMember( options.DebuggingMode, [ 'on', 'off' ] ) } = 'off';
            end


            obj.Model.AppLoading = true;


            obj.Logger = Logger;
            if strcmp( options.DebuggingMode, 'on' )

                startingTime = tic;

                obj.Logger.Display = true;
            end

            obj.Model = Model;
            obj.App = App;


            build( obj );
            registerListener( obj );


            add( obj.App.TabGroup, obj.App.DesignTab );
            log( obj.Logger, '% Add DesignTab to TabGroup.' )


            addGroup2Container( obj.App, 'Group', 'All' );
            addComponent2Container( obj.App, 'Component', 'All' );


            obj.App.AppContainer.Visible = true;
            debug( obj.Logger, 'AppContainer.Visible = true;' );

            if strcmp( options.DebuggingMode, 'on' )

                obj.Logger.LoadingTime = toc( startingTime );
            end


            obj.Model.AppLoading = false;
        end
    end

    methods ( Access = private )

        function build( obj )




            buildModel( obj );


            buildView( obj );


            buildController( obj );
        end


        function buildModel( obj )




            obj.Model.Visualization = rfpcb.internal.apps.transmissionLineDesigner.model.Visualization( obj.Logger );
            obj.Model.View2DModel = rfpcb.internal.apps.transmissionLineDesigner.model.View2DModel( obj.Model.TransmissionLine, obj.Logger );
            obj.Model.View3DModel = rfpcb.internal.apps.transmissionLineDesigner.model.View3DModel( obj.Model.TransmissionLine, obj.Logger );


            obj.Model.Analysis = rfpcb.internal.apps.transmissionLineDesigner.model.Analysis( obj.Logger );
            obj.Model.Properties = rfpcb.internal.apps.transmissionLineDesigner.model.Properties( obj.Model.TransmissionLine, obj.Logger );


            obj.Model.Design = rfpcb.internal.apps.transmissionLineDesigner.model.Design( obj.Model.TransmissionLine, obj.Logger );
            obj.Model.Capacitance = rfpcb.internal.apps.transmissionLineDesigner.model.Capacitance( obj.Model.TransmissionLine, obj.Logger );
            obj.Model.PropagationDelay = rfpcb.internal.apps.transmissionLineDesigner.model.PropagationDelay( obj.Model.TransmissionLine, obj.Logger );
            obj.Model.CharacteristicImpedance = rfpcb.internal.apps.transmissionLineDesigner.model.CharacteristicImpedance( obj.Model.TransmissionLine, obj.Logger );
            obj.Model.FeedCurrent = rfpcb.internal.apps.transmissionLineDesigner.model.FeedCurrent( obj.Model.TransmissionLine, obj.Logger );
            obj.Model.Inductance = rfpcb.internal.apps.transmissionLineDesigner.model.Inductance( obj.Model.TransmissionLine, obj.Logger );
            obj.Model.Resistance = rfpcb.internal.apps.transmissionLineDesigner.model.Resistance( obj.Model.TransmissionLine, obj.Logger );
            obj.Model.Results = rfpcb.internal.apps.transmissionLineDesigner.model.Results( obj.Model.TransmissionLine, obj.Logger,  ...
                'Capacitance', obj.Model.Capacitance,  ...
                'PropagationDelay', obj.Model.PropagationDelay,  ...
                'CharacteristicImpedance', obj.Model.CharacteristicImpedance,  ...
                'FeedCurrent', obj.Model.FeedCurrent,  ...
                'Inductance', obj.Model.Inductance,  ...
                'Resistance', obj.Model.Resistance );
            obj.Model.Sparameters = rfpcb.internal.apps.transmissionLineDesigner.model.Sparameters( obj.Model.TransmissionLine, obj.Logger );
            obj.Model.Current = rfpcb.internal.apps.transmissionLineDesigner.model.Current( obj.Model.TransmissionLine, obj.Logger );
            obj.Model.Charge = rfpcb.internal.apps.transmissionLineDesigner.model.Charge( obj.Model.TransmissionLine, obj.Logger );
            obj.Model.AnalysisPlots = rfpcb.internal.apps.transmissionLineDesigner.model.AnalysisPlots( obj.Model.TransmissionLine, obj.Logger );

            obj.Model.FileSectionModel = rfpcb.internal.apps.transmissionLineDesigner.model.FileSectionModel( obj.Model.TransmissionLine, obj.Logger );
            obj.Model.TransmissionLineGalleryModel = rfpcb.internal.apps.transmissionLineDesigner.model.TransmissionLineGalleryModel( obj.Model.TransmissionLine, obj.Logger,  ...
                'Names', obj.Model.Names,  ...
                'NickNames', obj.Model.NickNames,  ...
                'Families', obj.Model.Families );
            obj.Model.Settings = rfpcb.internal.apps.transmissionLineDesigner.model.Settings( obj.Logger );
            obj.Model.ExportSectionModel = rfpcb.internal.apps.transmissionLineDesigner.model.ExportSectionModel( obj.Model.TransmissionLine, obj.Logger );
        end


        function buildView( obj )




            obj.App.PropertyPanel = rfpcb.internal.apps.transmissionLineDesigner.view.PropertyPanel( obj.Model.Properties );


            obj.App.VisualizationGroup = rfpcb.internal.apps.transmissionLineDesigner.view.VisualizationGroup( obj.Model.Visualization );
            obj.App.View2DDocument = rfpcb.internal.apps.transmissionLineDesigner.view.View2D( obj.Model.View2DModel );
            obj.App.View3DDocument = rfpcb.internal.apps.transmissionLineDesigner.view.View3D( obj.Model.View3DModel );


            obj.App.AnalysisGroup = rfpcb.internal.apps.transmissionLineDesigner.view.AnalysisGroup( obj.Model.Analysis );

            obj.App.ChargeDocument = rfpcb.internal.apps.transmissionLineDesigner.view.ChargeView( obj.Model.Charge );

            obj.App.CurrentDocument = rfpcb.internal.apps.transmissionLineDesigner.view.CurrentView( obj.Model.Current );

            obj.App.SparametersDocument = rfpcb.internal.apps.transmissionLineDesigner.view.SparametersView( obj.Model.Sparameters );

            obj.App.ResultsDocument = rfpcb.internal.apps.transmissionLineDesigner.view.ResultsView( obj.Model.Results );

            obj.App.TransmissionLineGallery = rfpcb.internal.apps.transmissionLineDesigner.view.TransmissionLineGallery( obj.Model.TransmissionLineGalleryModel );
            obj.App.thisToolstrip = rfpcb.internal.apps.transmissionLineDesigner.view.Toolstrip( obj.Model, obj.App );
        end


        function buildController( obj )




            obj.EventController = rfpcb.internal.apps.transmissionLineDesigner.controller.EventController( obj.Model, obj.App );

            obj.PropertiesController = rfpcb.internal.apps.transmissionLineDesigner.controller.PropertiesController( obj.Model, obj.App );


            obj.View2DController = rfpcb.internal.apps.transmissionLineDesigner.controller.View2DController( obj.Model, obj.App );
            obj.View3DController = rfpcb.internal.apps.transmissionLineDesigner.controller.View3DController( obj.Model, obj.App );


            obj.ResultsController = rfpcb.internal.apps.transmissionLineDesigner.controller.ResultsController( obj.Model, obj.App );
            obj.CouplingCoefficientController = rfpcb.internal.apps.transmissionLineDesigner.controller.CouplingCoefficientController( obj.Model, obj.App );
            obj.PropagationDelayController = rfpcb.internal.apps.transmissionLineDesigner.controller.PropagationDelayController( obj.Model, obj.App );
            obj.CharacteristicImpedanceController = rfpcb.internal.apps.transmissionLineDesigner.controller.CharacteristicImpedanceController( obj.Model, obj.App );
            obj.CapacitanceController = rfpcb.internal.apps.transmissionLineDesigner.controller.CapacitanceController( obj.Model, obj.App );
            obj.ResistanceController = rfpcb.internal.apps.transmissionLineDesigner.controller.ResistanceController( obj.Model, obj.App );
            obj.InductanceController = rfpcb.internal.apps.transmissionLineDesigner.controller.InductanceController( obj.Model, obj.App );
            obj.FeedCurrentController = rfpcb.internal.apps.transmissionLineDesigner.controller.FeedCurrentController( obj.Model, obj.App );


            obj.NewController = rfpcb.internal.apps.transmissionLineDesigner.controller.NewController( obj.Model, obj.App );
            obj.OpenController = rfpcb.internal.apps.transmissionLineDesigner.controller.OpenController( obj.Model, obj.App );
            obj.SaveController = rfpcb.internal.apps.transmissionLineDesigner.controller.SaveController( obj.Model, obj.App );
            obj.ImportController = rfpcb.internal.apps.transmissionLineDesigner.controller.ImportController( obj.Model, obj.App );
            obj.TransmissionLineController = rfpcb.internal.apps.transmissionLineDesigner.controller.TransmissionLineController( obj.Model, obj.App );
            obj.DesignController = rfpcb.internal.apps.transmissionLineDesigner.controller.DesignController( obj.Model, obj.App );
            obj.PlotInputsController = rfpcb.internal.apps.transmissionLineDesigner.controller.PlotInputsController( obj.Model, obj.App );
            obj.SparametersController = rfpcb.internal.apps.transmissionLineDesigner.controller.SparametersController( obj.Model, obj.App );
            obj.ChargeController = rfpcb.internal.apps.transmissionLineDesigner.controller.ChargeController( obj.Model, obj.App );
            obj.CurrentController = rfpcb.internal.apps.transmissionLineDesigner.controller.CurrentController( obj.Model, obj.App );
            obj.SettingsController = rfpcb.internal.apps.transmissionLineDesigner.controller.SettingsController( obj.Model, obj.App );
            obj.DefaultLayoutController = rfpcb.internal.apps.transmissionLineDesigner.controller.DefaultLayoutController( obj.Model, obj.App );
            obj.ExportController = rfpcb.internal.apps.transmissionLineDesigner.controller.ExportController( obj.Model, obj.App );


            obj.CloseController = rfpcb.internal.apps.transmissionLineDesigner.controller.CloseController( obj.Model, obj.App );
        end


        function registerListener( obj )










            addlistener( obj.Model, 'TransmissionLine', 'PostSet', @( src, evt )onModelChange( obj.EventController, src, evt ) );
            addlistener( obj.Model, 'DesignFrequency', 'PostSet', @( src, evt )onModelChange( obj.EventController, src, evt ) );
            addlistener( obj.Model, 'PlotFrequency', 'PostSet', @( src, evt )onModelChange( obj.EventController, src, evt ) );
            addlistener( obj.Model, 'FrequencyRange', 'PostSet', @( src, evt )onModelChange( obj.EventController, src, evt ) );
            addlistener( obj.Model, 'Errored', @( src, evt )onError( obj.EventController, src, evt ) );

            addlistener( obj.App, 'View3DChanged', @( src, evt )execute( obj.View3DController, src, evt ) );
            addlistener( obj.App, 'PropertiesChanged', @( src, evt )execute( obj.PropertiesController, src, evt ) );

            addlistener( obj.Model, 'RunningStage', @( src, evt )onAppState( obj.EventController, src, evt ) );
            addlistener( obj.Model, 'CompletedStage', @( src, evt )onAppState( obj.EventController, src, evt ) );




            addlistener( obj.App.FileSectionView.NewButton,  ...
                'ButtonPushed',  ...
                @( src, evt )obj.NewController.execute( src, evt ) );

            addlistener( obj.App.FileSectionView.OpenButton,  ...
                'ButtonPushed',  ...
                @( src, evt )obj.OpenController.execute( src, evt ) );

            addlistener( obj.App.FileSectionView.SaveButton,  ...
                'ButtonPushed',  ...
                @( src, evt )obj.SaveController.execute( src, evt ) );
            addlistener( obj.App.FileSectionView.SaveItem,  ...
                'ItemPushed',  ...
                @( src, evt )obj.SaveController.execute( src, evt ) );
            addlistener( obj.App.FileSectionView.SaveToDisk,  ...
                'ItemPushed',  ...
                @( src, evt )obj.SaveController.saveToDiskCallback( src, evt ) );

            addlistener( obj.App.FileSectionView.ImportButton,  ...
                'ButtonPushed',  ...
                @( src, evt )obj.ImportController.execute( src, evt ) );
            addlistener( obj.App.FileSectionView.ImportMATFile,  ...
                'ItemPushed',  ...
                @( src, evt )obj.ImportController.execute( src, evt ) );

            for i = 1:length( obj.App.TransmissionLineGallery.GalleryItems )
                item = obj.App.TransmissionLineGallery.GalleryItems{ i };
                addlistener( item,  ...
                    'ValueChanged',  ...
                    @( src, evt )obj.TransmissionLineController.execute( src, evt ) );
            end


            addlistener( obj.App.DesignView.DesignFrequencyEditField,  ...
                'ValueChanged',  ...
                @( src, evt )obj.DesignController.execute( src, evt ) );

            addlistener( obj.App.DesignView.ImpedanceEditField,  ...
                'ValueChanged',  ...
                @( src, evt )obj.CharacteristicImpedanceController.execute( src, evt ) );

            addlistener( obj.App.DesignView.DesignFrequencyUnitDropdown,  ...
                'ValueChanged',  ...
                @( src, evt )obj.DesignController.execute( src, evt ) );

            addlistener( obj.App.DesignView.UpdateDesignButton,  ...
                'ButtonPushed',  ...
                @( src, evt )obj.DesignController.execute( src, evt ) );


            addlistener( obj.App.PlotInputsView.PlotFrequencyEditField,  ...
                'ValueChanged',  ...
                @( src, evt )obj.PlotInputsController.execute( src, evt ) );

            addlistener( obj.App.PlotInputsView.FrequencyRangeEditField,  ...
                'ValueChanged',  ...
                @( src, evt )obj.PlotInputsController.execute( src, evt ) );

            addlistener( obj.App.PlotInputsView.PlotFrequencyUnitDropdown,  ...
                'ValueChanged',  ...
                @( src, evt )obj.PlotInputsController.execute( src, evt ) );

            addlistener( obj.App.PlotInputsView.FrequencyRangeUnitDropdown,  ...
                'ValueChanged',  ...
                @( src, evt )obj.PlotInputsController.execute( src, evt ) );


            addlistener( obj.App.PlotInputsView.SparametersButton,  ...
                'ValueChanged',  ...
                @( src, evt )obj.SparametersController.execute( src, evt ) );

            addlistener( obj.App.PlotInputsView.ChargeButton,  ...
                'ValueChanged',  ...
                @( src, evt )obj.ChargeController.execute( src, evt ) );

            addlistener( obj.App.PlotInputsView.CurrentButton,  ...
                'ValueChanged',  ...
                @( src, evt )obj.CurrentController.execute( src, evt ) );


            addlistener( obj.App.SettingsView.SettingsButton,  ...
                'ButtonPushed',  ...
                @( src, evt )obj.SettingsController.execute( src, evt ) );


            addlistener( obj.App.DefaultLayoutButton,  ...
                'ButtonPushed',  ...
                @( src, evt )obj.DefaultLayoutController.execute( src, evt ) );


            addlistener( obj.App.ExportSectionView.ExportSplitButton,  ...
                'ButtonPushed',  ...
                @( src, evt )obj.ExportController.execute( src, evt ) );
            addlistener( obj.App.ExportSectionView.ExportWorkspaceButton,  ...
                'ItemPushed',  ...
                @( src, evt )obj.ExportController.execute( src, evt ) );
            addlistener( obj.App.ExportSectionView.ExportScriptButton,  ...
                'ItemPushed',  ...
                @( src, evt )obj.ExportController.execute( src, evt ) );
        end
    end
end




