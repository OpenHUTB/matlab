classdef AppView < rfpcb.internal.apps.View







    properties

        Tag = 'transmissionLineDesigner';
        Title = 'Transmission Line Designer';


        DesignTab

        FileSectionView( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.FileSectionView{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.view.FileSectionView;

        TransmissionLineGallery( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.TransmissionLineGallery{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.view.TransmissionLineGallery;

        DesignView( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.DesignView{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.view.DesignView;

        PlotInputsView( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.PlotInputsView{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.view.PlotInputsView;

        SettingsView( 1, 1 )

        DefaultLayoutSection
        DefaultLayoutButton

        ExportSectionView( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.ExportSectionView{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.view.ExportSectionView;


        VisualizationGroup( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.VisualizationGroup = rfpcb.internal.apps.transmissionLineDesigner.view.VisualizationGroup;
        AnalysisGroup( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.AnalysisGroup = rfpcb.internal.apps.transmissionLineDesigner.view.AnalysisGroup;
        ChargeDocument( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.ChargeView{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.view.ChargeView;
        CurrentDocument( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.CurrentView{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.view.CurrentView;
        SparametersDocument( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.SparametersView{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.view.SparametersView;
        View2DDocument( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.View2D{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.view.View2D;
        View3DDocument( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.View3D{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.view.View3D;
        ResultsDocument( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.ResultsView{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.view.ResultsView;


        ComponentNames = { 'PropertyPanel', 'VisualizationGroup', 'View2DDocument', 'View3DDocument', 'AnalysisGroup', 'ChargeDocument', 'CurrentDocument', 'SparametersDocument', 'ResultsDocument' };

        GroupNames = { 'VisualizationGroup', 'AnalysisGroup' };
    end

    properties ( Hidden )
        Logger( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Logger = rfpcb.internal.apps.transmissionLineDesigner.model.Logger;
    end

    events
        View3DChanged
        PropertiesChanged
    end

    methods

        function obj = AppView( Logger )





            arguments
                Logger( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Logger = rfpcb.internal.apps.transmissionLineDesigner.model.Logger;
            end

            import matlab.ui.internal.*;
            import matlab.ui.internal.toolstrip.*;

            obj.Logger = Logger;


            tag = obj.Tag + "_" + matlab.lang.internal.uuid;
            obj.AppContainer = rfpcb.internal.apps.transmissionLineDesigner.view.Container( obj.Logger, 'Tag', tag, 'Title', obj.Title );


            obj.TabGroup = TabGroup(  );
            debug( obj.Logger, 'TabGroup = matlab.ui.internal.toolstrip.TabGroup();' );
            obj.TabGroup.Tag = "transmissionLineDesignTabGroup";
            debug( obj.Logger, 'TabGroup.Tag = "transmissionLineDesignTabGroup";' );
            obj.AppContainer.add( obj.TabGroup );
            debug( obj.Logger, 'AppContainer.add(TabGroup);' );


            helpButton = matlab.ui.internal.toolstrip.qab.QABHelpButton(  );
            debug( obj.Logger, 'helpButton = matlab.ui.internal.toolstrip.qab.QABHelpButton();' );
            helpButton.DocName = 'rfpcb/transmissionlinedesigner_app';
            obj.AppContainer.add( helpButton );
            debug( obj.Logger, 'AppContainer.add(helpButton);' );

            setFrameSize( obj );
        end



        function error( obj, ErrorStack )
            arguments
                obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.AppView;
                ErrorStack( 1, 1 )MException{ mustBeNonempty }
            end


            uialert( obj.View2DDocument.Figure, ErrorStack.message, 'Error', 'Modal', true );
        end



        function addGroup2Container( obj, options )

            arguments
                obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.AppView = rfpcb.internal.apps.transmissionLineDesigner.view.AppView;
                options.Group{ mustBeTextScalar } = 'All';
            end

            switch options.Group
                case 'All'
                    cellfun( @( x )addGroup2Container( obj, 'Group', x ), obj.GroupNames, 'UniformOutput', false );
                otherwise

                    add( obj.AppContainer, obj.( options.Group ) );
            end
        end

        function addComponent2Container( obj, options )
            arguments
                obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.AppView = rfpcb.internal.apps.transmissionLineDesigner.view.AppView;
                options.Component{ mustBeTextScalar } = 'All';
            end

            switch options.Component
                case 'All'
                    cellfun( @( x )addComponent2Container( obj, 'Component', x ), obj.ComponentNames, 'UniformOutput', false );
                otherwise
                    add2AppWithRepro( options.Component );
            end
            function add2AppWithRepro( Name )
                addFigure2app( obj, obj.( Name ) );
                debug( obj.Logger, [ 'add(AppContainer, ', Name, ')' ] );
            end
        end



        function update( obj, ModelPart )




            arguments
                obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.AppView;
                ModelPart( 1, : ){ mustBeTextScalar } = 'TransmissionLine';
            end


            enableControl( obj );


            switch ModelPart
                case 'TransmissionLine'

                    update( obj.TransmissionLineGallery );
                    update( obj.PlotInputsView );

                    updateVisualization( obj );

                    updateResults( obj );

                    update( obj.PlotInputsView );
                    updatePlots( obj );
                case { 'DesignFrequency', 'DesignImpedance' }
                    updateResults( obj );
                case 'PlotFrequency'

                    update( obj.PlotInputsView );
                    updatePlots( obj );
                case 'FrequencyRange'
                    updatePlots( obj );
                case { 'RunningStage', 'CompletedStage' }
                    switch ModelPart
                        case 'RunningStage'
                            obj.CanBeClosed = false;
                            disableControl( obj );
                            pointer( obj, 'watch' );
                        case 'CompletedStage'
                            pointer( obj, 'arrow' );
                            obj.CanBeClosed = true;
                    end

                    status = getString( message( [ 'rfpcb:transmissionlinedesigner:', ModelPart ] ) );
                    obj.setStatusBarMsg( status );
                otherwise
                    update( obj, 'TransmissionLine' );
            end

            update( obj.FileSectionView );
            enable( obj.PlotInputsView );
            update( obj.ExportSectionView );
        end

        function updateLayout( obj, options )











            arguments
                obj
                options.Type = 'Normal';
            end
            import matlab.ui.container.internal.AppContainer;
            import matlab.ui.internal.*;

            switch options.Type
                case 'Analysis'

                case 'Normal'
                    defaultLayout( obj.AppContainer );
                    obj.PropertyPanel.Opened = true;
                    obj.View2DDocument.Tile = 1;
                    obj.View3DDocument.Tile = 2;
                    obj.ResultsDocument.Tile = 3;
            end
        end

        function rtn = confirmClear( obj )
            saveSessionMessage = getString( message( 'rfpcb:transmissionlinedesigner:SaveConfirm' ) );
            rtn = uiconfirm( obj.View2DDocument.Figure,  ...
                saveSessionMessage,  ...
                'Save Design',  ...
                'Icon', 'warning',  ...
                'Options', { 'Yes', 'No', 'Cancel' },  ...
                'CancelOption', 3,  ...
                'CloseFcn', @( src, evt )closeFcn( src, evt ) );

            switch rtn
                case { 'Yes', 'No' }
                    rtn = true;
                case 'Cancel'
                    rtn = false;
            end

            function closeFcn( ~, evt )
                switch evt.SelectedOption
                    case 'Yes'
                        notify( obj.FileSectionView.SaveButton, 'ButtonPushed' );
                        rtn = true;
                    case 'No'
                        rtn = true;
                    case 'Cancel'
                        rtn = false;
                end
            end
        end

        function rtn = getCurrentState( obj )



            rtn = struct;
            rtn.DesignView = getCurrentState( obj.DesignView );
            rtn.PlotInputsView = getCurrentState( obj.PlotInputsView );
            rtn.SettingsView = getCurrentState( obj.SettingsView );
            rtn.Layout = obj.AppContainer.DocumentGridDimensions;
        end
    end

    methods ( Access = private )

        function updateVisualization( obj )
            log( obj.Logger, '% Model for View 2D and View 3D updated.' );

            notify( obj, 'PropertiesChanged' );
            update( obj.View2DDocument );
            update( obj.View3DDocument );

        end

        function updateResults( obj )

            update( obj.DesignView );

            update( obj.ResultsDocument );
        end

        function updatePlots( obj )
            log( obj.Logger, '% Model for plots updated.' );

            update( obj.SparametersDocument );
            update( obj.CurrentDocument );
            update( obj.ChargeDocument );
        end

        function pointer( obj, Type )

            arguments
                obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.AppView
                Type = 'arrow';
            end


            cellfun( @( x )set( x.Figure, 'Pointer', Type ),  ...
                obj.AppContainer.getDocuments, 'UniformOutput', false );
        end
    end
end



