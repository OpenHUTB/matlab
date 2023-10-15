classdef ResultsExplorerView < handle


    properties ( Access = private )
        AppContainer matlab.ui.container.internal.AppContainer
        TabGroup matlab.ui.internal.toolstrip.TabGroup
        HomeTab matlab.ui.internal.toolstrip.Tab
        MdlStructPanel matlab.ui.internal.FigurePanel
        NodeStatisticsPanel matlab.ui.internal.FigurePanel
        PlotFigure matlab.ui.internal.FigureDocumentGroup
        FigureDocument matlab.ui.internal.FigureDocument
        FigureVisual matlab.ui.Figure
        HelpButton matlab.ui.internal.toolstrip.qab.QABHelpButton
    end


    properties ( Access = private )
        AppStateChanged
    end


    properties ( Access = private )
        DataSection matlab.ui.internal.toolstrip.Section
        PlotSection matlab.ui.internal.toolstrip.Section
        AxesSection matlab.ui.internal.toolstrip.Section
        ExportSection matlab.ui.internal.toolstrip.Section
    end


    properties ( Access = private )
        MarkerBtnGrp matlab.ui.internal.toolstrip.ButtonGroup
        LayoutBtnGrp matlab.ui.internal.toolstrip.ButtonGroup
        UnitsBtnGrp matlab.ui.internal.toolstrip.ButtonGroup
        PlotTypeBtnGrp matlab.ui.internal.toolstrip.ButtonGroup
        ShowLegendBtnGrp matlab.ui.internal.toolstrip.ButtonGroup
        LimitTimeAxesBtnGrp matlab.ui.internal.toolstrip.ButtonGroup
    end


    properties ( Access = private )
        ImportButton matlab.ui.internal.toolstrip.Button
        SaveButton matlab.ui.internal.toolstrip.Button
        LinkUnlinkButton matlab.ui.internal.toolstrip.Button
    end


    properties ( Access = private )
        MarkerButton matlab.ui.internal.toolstrip.SplitButton
        LayoutButton matlab.ui.internal.toolstrip.SplitButton
        UnitsButton matlab.ui.internal.toolstrip.SplitButton
        PlotTypeButton matlab.ui.internal.toolstrip.SplitButton
        ShowLegendButton matlab.ui.internal.toolstrip.SplitButton
    end


    properties ( Access = private )
        LinkTimeAxesButton matlab.ui.internal.toolstrip.CheckBox
        LimitTimeAxesButton matlab.ui.internal.toolstrip.SplitButton
        ExportFigButton matlab.ui.internal.toolstrip.Button
    end


    properties ( Access = private )
        MarkerPopup matlab.ui.internal.toolstrip.PopupList
        LayoutPopup matlab.ui.internal.toolstrip.PopupList
        UnitsPopup matlab.ui.internal.toolstrip.PopupList
        PlotTypePopup matlab.ui.internal.toolstrip.PopupList
        ShowLegendPopup matlab.ui.internal.toolstrip.PopupList
        LimitTimeAxesPopup matlab.ui.internal.toolstrip.PopupList
    end


    properties ( Access = private )
        NoneMkr matlab.ui.internal.toolstrip.ListItemWithRadioButton
        DotMkr matlab.ui.internal.toolstrip.ListItemWithRadioButton
        StarMkr matlab.ui.internal.toolstrip.ListItemWithRadioButton
        CircleMkr matlab.ui.internal.toolstrip.ListItemWithRadioButton
        PlusMkr matlab.ui.internal.toolstrip.ListItemWithRadioButton
        CrossMkr matlab.ui.internal.toolstrip.ListItemWithRadioButton
        SquareMkr matlab.ui.internal.toolstrip.ListItemWithRadioButton
        DiamondMkr matlab.ui.internal.toolstrip.ListItemWithRadioButton
    end


    properties ( Access = private )
        VShapeMkr matlab.ui.internal.toolstrip.ListItemWithRadioButton
        InvVShapeMkr matlab.ui.internal.toolstrip.ListItemWithRadioButton
        GreaterThanMkr matlab.ui.internal.toolstrip.ListItemWithRadioButton
        LessThanMkr matlab.ui.internal.toolstrip.ListItemWithRadioButton
        PentagramMkr matlab.ui.internal.toolstrip.ListItemWithRadioButton
        HexagramMkr matlab.ui.internal.toolstrip.ListItemWithRadioButton
        VerticalMkr matlab.ui.internal.toolstrip.ListItemWithRadioButton
        HorizontalMkr matlab.ui.internal.toolstrip.ListItemWithRadioButton
    end


    properties ( Access = private )
        OverlayLayout matlab.ui.internal.toolstrip.ListItemWithRadioButton
        SeperateLayout matlab.ui.internal.toolstrip.ListItemWithRadioButton
        DefaultUnit matlab.ui.internal.toolstrip.ListItemWithRadioButton
        SIUnit matlab.ui.internal.toolstrip.ListItemWithRadioButton
        USCustomaryUnit matlab.ui.internal.toolstrip.ListItemWithRadioButton
        CustomUnit matlab.ui.internal.toolstrip.ListItemWithRadioButton
    end


    properties ( Access = private )
        LineType matlab.ui.internal.toolstrip.ListItemWithRadioButton
        StairsType matlab.ui.internal.toolstrip.ListItemWithRadioButton
        StemType matlab.ui.internal.toolstrip.ListItemWithRadioButton
        AutoOption matlab.ui.internal.toolstrip.ListItemWithRadioButton
        AlwaysOption matlab.ui.internal.toolstrip.ListItemWithRadioButton
        NeverOption matlab.ui.internal.toolstrip.ListItemWithRadioButton
    end


    properties ( Access = private )
        StartTime matlab.ui.internal.toolstrip.ListItemWithEditField
        StopTime matlab.ui.internal.toolstrip.ListItemWithEditField
    end


    properties ( Access = private )
        treeStructGridLayout
        NodeStatsTitle
        RootNodeDescription
        NodeStatsDescription
        NodeStatsUnit
        NodeStatsValue
        NodeStatsSource
    end

    properties ( Access = private )
        Options
        IsLinked

        MarkerList
        UnitList
        PlotTypeList
        ShowLegendList
    end

    properties ( Dependent )
        Busy
    end

    events
        ImportButtonPushed
        SaveButtonPushed
        LinkUnlinkButtonPushed
        MarkerSelection
        LayoutSelection
        UnitSelection
        PlotTypeSelection
        ViewClosed
    end

    events
        LegendSelection
        LinkAxesButtonToggled
        LimitTimeAxesValueChanged
        ExportButtonPushed
        SourceLinkClicked
        DescriptionLinkClicked
    end


    methods
        function app = ResultsExplorerView(  )



        end

        function createGUIComponents( app )


            app.createComponents(  );

            app.AppStateChanged = event.listener(  ...
                app.AppContainer, 'StateChanged', @app.stateChangedCallback );
        end

        function setAppVisible( app )
            app.AppContainer.Visible = true;
        end

        function setTitle( app, resultsExplorerTitle )
            app.AppContainer.Title = getMessageFromCatalog( 'ExplorerTitle',  ...
                resultsExplorerTitle );
        end

        function isLinked = getLinkedVal( app )
            isLinked = app.IsLinked;
        end

        function setLinkUnlinkButton( app, islinked )
            arguments
                app( 1, 1 )
                islinked( 1, 1 )logical
            end
            app.IsLinked = islinked;
            if ( islinked )
                app.LinkUnlinkButton.Icon = getIconPath( 'appDesignerLink_24.png' );
                app.LinkUnlinkButton.Tag = 'LinkData';
                app.LinkUnlinkButton.Text = getMessageFromCatalog( 'LinkButton' );
                app.LinkUnlinkButton.Description = getMessageFromCatalog( 'UnlinkExplorer' );
            else
                app.LinkUnlinkButton.Icon = getIconPath( 'Unlink_24.png' );
                app.LinkUnlinkButton.Tag = 'UnlinkData';
                app.LinkUnlinkButton.Text = getMessageFromCatalog( 'UnlinkButton' );
                app.LinkUnlinkButton.Description = getMessageFromCatalog( 'LinkExplorer' );
            end
        end

        function setMultiNodeStatsValue( app, multiNodeStatsValues )


            app.NodeStatsDescription.Visible = "off";
            app.NodeStatsSource.Visible = "off";
            app.RootNodeDescription.Visible = "on";

            app.NodeStatsTitle.Text = multiNodeStatsValues.StatusTitle;
            app.RootNodeDescription.Text = multiNodeStatsValues.StatusDesc;
            app.NodeStatsUnit.Text = multiNodeStatsValues.StatusUnit;
            app.NodeStatsValue.Text = multiNodeStatsValues.StatusStats;
        end

        function setRootNodeStatsValue( app, rootNodeStatsValues )


            app.RootNodeDescription.Visible = "on";
            app.NodeStatsDescription.Visible = "off";
            app.NodeStatsSource.Visible = "on";

            app.RootNodeDescription.Text = rootNodeStatsValues.StatusDesc;


            app.setNodeStats( rootNodeStatsValues );
        end

        function setNodeStatsValue( app, nodeStatsValues )


            app.RootNodeDescription.Visible = "off";
            app.NodeStatsDescription.Visible = "on";
            app.NodeStatsSource.Visible = "on";

            app.NodeStatsDescription.Text = nodeStatsValues.StatusDesc;


            app.setNodeStats( nodeStatsValues );
        end

        function setDefaultOptions( app, options )
            app.Options = options;
        end

        function setTimeAxesLimits( app, startTime, stopTime )
            app.StartTime.Value = startTime;
            app.StopTime.Value = stopTime;
        end

        function [ startTime, stopTime ] = getTimeAxesLimits( app )
            startTime = app.StartTime.Value;
            stopTime = app.StopTime.Value;
        end

        function apphandle = getAppHandle( app )
            apphandle = app.AppContainer;
        end

        function enablePlotOptions( app )
            app.MarkerButton.Enabled = true;
            app.LayoutButton.Enabled = true;
            app.UnitsButton.Enabled = true;
            app.PlotTypeButton.Enabled = true;
            app.ShowLegendButton.Enabled = true;
        end

        function enableAxesControlOptions( app )
            app.LinkTimeAxesButton.Enabled = true;
            app.LimitTimeAxesButton.Enabled = true;
        end

        function exportButton = getExportButton( app )
            exportButton = app.ExportFigButton;
        end

        function plotOptions = getPlotOptions( app )
            plotOptions = app.Options;
        end

        function setLinkTimeAxesValue( app )
            app.Options.link = app.LinkTimeAxesButton.Value;
        end

        function link = getLinkTimeAxesValue( app )
            link = app.Options.link;
        end

        function [ startTime, stopTime ] =  ...
                getLimitTimeAxesValues( app )
            startTime = str2double( app.StartTime.Value );
            stopTime = str2double( app.StopTime.Value );
        end

        function setUITreeParent( app, tree )
            if isvalid( app.treeStructGridLayout )
                tree.Parent = app.treeStructGridLayout;
            end
        end

        function out = get.Busy( app )
            out = app.AppContainer.Busy;
        end

        function set.Busy( app, value )
            app.AppContainer.Busy = value;
        end

        function bringToFront( app )
            app.AppContainer.bringToFront(  );
        end
    end

    methods ( Access = private )
        function createComponents( app )


            createAppContainer( app );


            createHomeTab( app );


            app.AppContainer.add( app.TabGroup );


            createQAB( app );


            createPanels( app );


            createPlotFigure( app );
        end

        function createAppContainer( app )

            appOptions.Tag = "ResultsExplorer" + "_" + matlab.lang.internal.uuid;
            app.AppContainer = matlab.ui.container.internal.AppContainer( appOptions );
        end

        function createHomeTab( app )
            app.TabGroup = matlab.ui.internal.toolstrip.TabGroup(  );
            app.TabGroup.Tag = 'ResultsExplorerTabGroup';
            app.HomeTab = matlab.ui.internal.toolstrip.Tab( getMessageFromCatalog( 'Home' ) );
            app.HomeTab.Tag = 'ResultsExplorerHomeTab';
            app.TabGroup.add( app.HomeTab );


            createDataSection( app );


            createPlotOptionsSection( app );


            createAxesControlSection( app );


            createExportSection( app );
        end

        function createDataSection( app )
            app.DataSection = app.HomeTab.addSection( getMessageFromCatalog( 'Data' ) );
            app.DataSection.Tag = 'DataSection';


            importIconPath = getIconPath( 'importData_24.png' );
            app.ImportButton = matlab.ui.internal.toolstrip.Button ...
                ( getMessageFromCatalog( 'ImportDataTitle' ),  ...
                importIconPath );
            app.ImportButton.Tag = 'ImportData';
            app.ImportButton.Description = getMessageFromCatalog( 'ImportDataTooltip' );
            app.ImportButton.ButtonPushedFcn = @( varargin )app.importButtonPushed;
            importColumn = app.DataSection.addColumn(  );
            importColumn.add( app.ImportButton );


            saveIconPath = getIconPath( 'saveData_24.png' );
            app.SaveButton = matlab.ui.internal.toolstrip.Button ...
                ( getMessageFromCatalog( 'ExportDataTitle' ),  ...
                saveIconPath );
            app.SaveButton.Tag = 'ExportData';
            app.SaveButton.Description = getMessageFromCatalog( 'ExportDataTooltip' );
            app.SaveButton.ButtonPushedFcn = @( varargin )app.saveButtonPushed;
            saveColumn = app.DataSection.addColumn(  );
            saveColumn.add( app.SaveButton );


            linkIconPath = getIconPath( 'appDesignerLink_24.png' );
            app.LinkUnlinkButton = matlab.ui.internal.toolstrip.Button ...
                ( getMessageFromCatalog( 'LinkButton' ), linkIconPath );
            app.LinkUnlinkButton.Tag = 'LinkData';
            app.LinkUnlinkButton.Description = getMessageFromCatalog( 'UnlinkExplorer' );
            app.LinkUnlinkButton.ButtonPushedFcn = @( varargin )app.linkUnlinkButtonPushed;
            app.IsLinked = true;
            dataColumn = app.DataSection.addColumn( 'HorizontalAlignment', 'center' );
            dataColumn.add( app.LinkUnlinkButton );
        end

        function createPlotOptionsSection( app )


            app.PlotSection = app.HomeTab.addSection(  ...
                getMessageFromCatalog( 'PlotOptions' ) );
            app.PlotSection.Tag = 'ResultsExplorerPlotOptsSection';


            createMarkerButton( app );


            createLayoutButton( app );


            plotOptsColumn = getPlotOptsColumn( app );
            plotOptsColumn.Tag = 'ResultsExplorerPlotOptsColumn';


            createUnitsButton( app, plotOptsColumn );


            createPlotTypeButton( app, plotOptsColumn );


            createShowLegendButton( app, plotOptsColumn );
        end

        function createMarkerButton( app )


            markerColumn = app.PlotSection.addColumn(  );
            markerColumn.Tag = 'ResultsExplorerMarkerColumn';


            app.MarkerBtnGrp = matlab.ui.internal.toolstrip.ButtonGroup(  );
            app.MarkerPopup = matlab.ui.internal.toolstrip.PopupList(  );


            app.createMkrOptsListOne;
            app.createMkrOptsListTwo;
            app.NoneMkr.Value = true;
            app.createMkrOptsCallback;
            app.addMkrOptsListToPopup;


            MarkerIconPath = getIconPath( 'editPoint_24.png' );


            app.MarkerButton = matlab.ui.internal.toolstrip.SplitButton(  ...
                getMessageFromCatalog( 'PlotMarker' ),  ...
                MarkerIconPath );
            markerColumn.add( app.MarkerButton );
            app.MarkerButton.Popup = app.MarkerPopup;
            app.MarkerButton.Tag = 'ResultsExplorerMarkerButton';


            app.MarkerButton.Enabled = false;
        end

        function createMkrOptsListOne( app )
            import matlab.ui.internal.toolstrip.*;
            app.NoneMkr = ListItemWithRadioButton( app.MarkerBtnGrp,  ...
                getMessageFromCatalog( 'PlotMarkerNone' ) );
            app.PlusMkr = ListItemWithRadioButton( app.MarkerBtnGrp, "+" );
            app.CircleMkr = ListItemWithRadioButton( app.MarkerBtnGrp, "o" );
            app.StarMkr = ListItemWithRadioButton( app.MarkerBtnGrp, "*" );
            app.DotMkr = ListItemWithRadioButton( app.MarkerBtnGrp, "." );
            app.CrossMkr = ListItemWithRadioButton( app.MarkerBtnGrp, "x" );
            app.SquareMkr = ListItemWithRadioButton( app.MarkerBtnGrp, "square" );
            app.DiamondMkr = ListItemWithRadioButton( app.MarkerBtnGrp, "diamond" );
        end

        function createMkrOptsListTwo( app )
            import matlab.ui.internal.toolstrip.*;
            app.VShapeMkr = ListItemWithRadioButton( app.MarkerBtnGrp, "v" );
            app.InvVShapeMkr = ListItemWithRadioButton( app.MarkerBtnGrp, "^" );
            app.GreaterThanMkr = ListItemWithRadioButton( app.MarkerBtnGrp, ">" );
            app.LessThanMkr = ListItemWithRadioButton( app.MarkerBtnGrp, "<" );
            app.PentagramMkr = ListItemWithRadioButton( app.MarkerBtnGrp, 'pentagram' );
            app.HexagramMkr = ListItemWithRadioButton( app.MarkerBtnGrp, 'hexagram' );
            app.VerticalMkr = ListItemWithRadioButton( app.MarkerBtnGrp, '|' );
            app.HorizontalMkr = ListItemWithRadioButton( app.MarkerBtnGrp, '_' );
        end

        function createMkrOptsCallback( app )
            app.MarkerList = { app.NoneMkr, app.PlusMkr, app.CircleMkr, app.StarMkr,  ...
                app.DotMkr, app.CrossMkr, app.SquareMkr, app.DiamondMkr ...
                , app.VShapeMkr, app.InvVShapeMkr, app.GreaterThanMkr,  ...
                app.LessThanMkr, app.PentagramMkr, app.HexagramMkr,  ...
                app.VerticalMkr, app.HorizontalMkr };
            for i = 1:numel( app.MarkerList )
                app.MarkerList{ i }.ValueChangedFcn =  ...
                    @( src, event )app.setMarker( src, event );
            end
        end

        function addMkrOptsListToPopup( app )
            for i = 1:numel( app.MarkerList )
                app.MarkerPopup.add( app.MarkerList{ i } );
            end
        end

        function createLayoutButton( app )


            layoutColumn = app.PlotSection.addColumn(  );
            layoutColumn.Tag = 'ResultsExplorerLayoutColumn';


            app.LayoutBtnGrp = matlab.ui.internal.toolstrip.ButtonGroup(  );
            app.LayoutPopup = matlab.ui.internal.toolstrip.PopupList(  );


            app.createLayoutOpts;
            app.OverlayLayout.Value = true;
            app.createLayoutCallback;
            app.addLayoutOptsToPopup;


            PlotOptionsIconPath = getIconPath( 'configureViewLayout_24.png' );


            app.LayoutButton = matlab.ui.internal.toolstrip.SplitButton(  ...
                getMessageFromCatalog( 'LayoutButton' ),  ...
                PlotOptionsIconPath );
            layoutColumn.add( app.LayoutButton )
            app.LayoutButton.Popup = app.LayoutPopup;
            app.LayoutButton.Tag = 'ResultsExplorerLayoutButton';
            app.LayoutButton.Enabled = false;
        end

        function createLayoutOpts( app )
            import matlab.ui.internal.toolstrip.*;
            app.OverlayLayout = ListItemWithRadioButton( app.LayoutBtnGrp,  ...
                getMessageFromCatalog( 'PlotOverlay' ) );
            app.SeperateLayout = ListItemWithRadioButton( app.LayoutBtnGrp,  ...
                getMessageFromCatalog( 'PlotSeparate' ) );
        end

        function createLayoutCallback( app )
            app.OverlayLayout.ValueChangedFcn = @( src, event ) ...
                app.setLayout( src, event );
            app.SeperateLayout.ValueChangedFcn = @( src, event ) ...
                app.setLayout( src, event );
        end

        function addLayoutOptsToPopup( app )
            app.LayoutPopup.add( app.OverlayLayout );
            app.LayoutPopup.add( app.SeperateLayout );
        end

        function createUnitsButton( app, unitsColumn )


            app.UnitsBtnGrp = matlab.ui.internal.toolstrip.ButtonGroup(  );
            app.UnitsPopup = matlab.ui.internal.toolstrip.PopupList(  );


            app.createUnitsOpts;
            app.DefaultUnit.Value = true;
            app.createUnitsCallback;
            app.addUnitsOptsToPopup;


            UnitsIconPath = getIconPath( 'unitConversion_16.png' );


            app.UnitsButton = matlab.ui.internal.toolstrip.SplitButton(  ...
                getMessageFromCatalog( 'PlotUnits' ),  ...
                UnitsIconPath );
            unitsColumn.add( app.UnitsButton );
            app.UnitsButton.Popup = app.UnitsPopup;
            app.UnitsButton.Tag = 'ResultsExplorerUnitsButton';
            app.UnitsButton.Enabled = false;
        end

        function createUnitsOpts( app )
            import matlab.ui.internal.toolstrip.*;
            app.DefaultUnit = ListItemWithRadioButton( app.UnitsBtnGrp,  ...
                getMessageFromCatalog( 'PlotUnitsDefault' ) );
            app.SIUnit = ListItemWithRadioButton( app.UnitsBtnGrp,  ...
                getMessageFromCatalog( 'PlotUnitsSI' ) );
            app.USCustomaryUnit = ListItemWithRadioButton( app.UnitsBtnGrp,  ...
                getMessageFromCatalog( 'PlotUnitsUSCustomary' ) );
            app.CustomUnit = ListItemWithRadioButton( app.UnitsBtnGrp,  ...
                getMessageFromCatalog( 'PlotUnitsCustom' ) );
        end

        function createUnitsCallback( app )
            app.UnitList = { app.DefaultUnit, app.SIUnit, app.USCustomaryUnit ...
                , app.CustomUnit };
            for i = 1:numel( app.UnitList )
                app.UnitList{ i }.ValueChangedFcn =  ...
                    @( src, event )app.setUnit( src, event );
            end
        end

        function addUnitsOptsToPopup( app )
            for i = 1:numel( app.UnitList )
                app.UnitsPopup.add( app.UnitList{ i } );
            end
        end

        function createPlotTypeButton( app, plotTypeColumn )


            app.PlotTypeBtnGrp = matlab.ui.internal.toolstrip.ButtonGroup(  );
            app.PlotTypePopup = matlab.ui.internal.toolstrip.PopupList(  );


            createPlotTypeOpts( app );
            app.LineType.Value = true;
            app.createPlotTypeCallback;
            addPlotTypeOptsToPopup( app );


            PlotTypeIconPath = getIconPath( 'plotEdit_16.png' );


            app.PlotTypeButton = matlab.ui.internal.toolstrip.SplitButton(  ...
                getMessageFromCatalog( 'PlotType' ),  ...
                PlotTypeIconPath );
            plotTypeColumn.add( app.PlotTypeButton );
            app.PlotTypeButton.Popup = app.PlotTypePopup;
            app.PlotTypeButton.Tag = 'ResultsExplorerPlotTypeButton';
            app.PlotTypeButton.Enabled = false;
        end

        function createPlotTypeOpts( app )
            import matlab.ui.internal.toolstrip.*;
            app.LineType = ListItemWithRadioButton( app.PlotTypeBtnGrp,  ...
                getMessageFromCatalog( 'PlotTypeLine' ) );
            app.StairsType = ListItemWithRadioButton( app.PlotTypeBtnGrp,  ...
                getMessageFromCatalog( 'PlotTypeStairs' ) );
            app.StemType = ListItemWithRadioButton( app.PlotTypeBtnGrp,  ...
                getMessageFromCatalog( 'PlotTypeStem' ) );
        end

        function createPlotTypeCallback( app )
            app.PlotTypeList = { app.LineType, app.StairsType, app.StemType };
            for i = 1:numel( app.PlotTypeList )
                app.PlotTypeList{ i }.ValueChangedFcn =  ...
                    @( src, event )app.setPlotType( src, event );
            end
        end

        function addPlotTypeOptsToPopup( app )
            for i = 1:numel( app.PlotTypeList )
                app.PlotTypePopup.add( app.PlotTypeList{ i } );
            end
        end

        function createShowLegendButton( app, showLegendColumn )


            app.ShowLegendBtnGrp = matlab.ui.internal.toolstrip.ButtonGroup(  );
            app.ShowLegendPopup = matlab.ui.internal.toolstrip.PopupList(  );


            app.createShowLegendOpts;
            app.AutoOption.Value = true;
            app.createShowLegendOptsCallback;
            app.addShowLegendOptsToPopup;


            ShowLegendIconPath = getIconPath( 'legendView_16.png' );


            app.ShowLegendButton = matlab.ui.internal.toolstrip.SplitButton(  ...
                getMessageFromCatalog( 'PlotLegend' ),  ...
                ShowLegendIconPath );
            showLegendColumn.add( app.ShowLegendButton );
            app.ShowLegendButton.Popup = app.ShowLegendPopup;
            app.ShowLegendButton.Tag = 'ResultsExplorerShowLegendButton';
            app.ShowLegendButton.Enabled = false;
        end

        function createShowLegendOpts( app )
            import matlab.ui.internal.toolstrip.*;
            app.AutoOption = ListItemWithRadioButton( app.ShowLegendBtnGrp,  ...
                getMessageFromCatalog( 'PlotLegendAuto' ) );
            app.AlwaysOption = ListItemWithRadioButton( app.ShowLegendBtnGrp,  ...
                getMessageFromCatalog( 'PlotLegendAlways' ) );
            app.NeverOption = ListItemWithRadioButton( app.ShowLegendBtnGrp,  ...
                getMessageFromCatalog( 'PlotLegendNever' ) );
        end

        function createShowLegendOptsCallback( app )
            app.ShowLegendList = { app.AutoOption, app.AlwaysOption,  ...
                app.NeverOption };
            for i = 1:numel( app.ShowLegendList )
                app.ShowLegendList{ i }.ValueChangedFcn =  ...
                    @( src, event )app.setShowLegend( src, event );
            end
        end

        function addShowLegendOptsToPopup( app )
            for i = 1:numel( app.ShowLegendList )
                app.ShowLegendPopup.add( app.ShowLegendList{ i } );
            end
        end

        function plotOptsColumn = getPlotOptsColumn( app )
            plotOptsColumn = app.PlotSection.addColumn(  );
        end

        function createAxesControlSection( app )


            app.AxesSection = app.HomeTab.addSection(  ...
                getMessageFromCatalog( 'OptionsAxes' ) );
            app.AxesSection.Tag = 'ResultsExplorerAxesCtrlSection';


            axesCtrlColumn = getAxesCtrlColumn( app );
            axesCtrlColumn.Tag = 'ResultsExplorerAxesCtrlColumn';


            createLinkTimeAxesButton( app, axesCtrlColumn );


            createLimitTimeAxesButton( app, axesCtrlColumn );
        end

        function createLinkTimeAxesButton( app, axesCtrlColumn )

            app.LinkTimeAxesButton = matlab.ui.internal.toolstrip.CheckBox(  ...
                getMessageFromCatalog( 'OptionsLink' ) );
            app.LinkTimeAxesButton.Value = true;
            app.LinkTimeAxesButton.Tag = 'ResultsExplorerLinkTimeAxesButton';
            app.LinkTimeAxesButton.Enabled = false;


            app.LinkTimeAxesButtonCallback;


            axesCtrlColumn.add( app.LinkTimeAxesButton );
        end

        function LinkTimeAxesButtonCallback( app )
            app.LinkTimeAxesButton.ValueChangedFcn =  ...
                @( varargin )app.toggleLinkTimeButton;
        end

        function createLimitTimeAxesButton( app, axesCtrlColumn )


            app.LimitTimeAxesBtnGrp = matlab.ui.internal.toolstrip.ButtonGroup(  );
            app.LimitTimeAxesPopup = matlab.ui.internal.toolstrip.PopupList(  );


            app.createLimitTimeAxesOpts;
            app.createLimitTimeCallback;
            app.addLimitTimeAxesOptsToPopup;


            LimitTimeAxesIconPath = getIconPath( 'showGroupDistance_16.png' );


            app.LimitTimeAxesButton = matlab.ui.internal.toolstrip.SplitButton(  ...
                getMessageFromCatalog( 'OptionsLimitTime' ),  ...
                LimitTimeAxesIconPath );
            app.LimitTimeAxesButton.Tag = 'ResultsExplorerLimitTimeAxesButton';
            app.LimitTimeAxesButton.Enabled = false;
            axesCtrlColumn.add( app.LimitTimeAxesButton );
            app.LimitTimeAxesButton.Popup = app.LimitTimeAxesPopup;
        end

        function createLimitTimeAxesOpts( app )
            import matlab.ui.internal.toolstrip.*;
            app.StartTime = ListItemWithEditField( getMessageFromCatalog( 'OptionsStartTime' ) );
            app.StopTime = ListItemWithEditField( getMessageFromCatalog( 'OptionsStopTime' ) );
        end

        function createLimitTimeCallback( app )
            app.StartTime.ValueChangedFcn = @( varargin )app.editTimeAxesLimits;
            app.StopTime.ValueChangedFcn = @( varargin )app.editTimeAxesLimits;
        end

        function addLimitTimeAxesOptsToPopup( app )
            app.LimitTimeAxesPopup.add( app.StartTime );
            app.LimitTimeAxesPopup.add( app.StopTime );
        end

        function axesCtrlColumn = getAxesCtrlColumn( app )
            axesCtrlColumn = app.AxesSection.addColumn(  );
        end

        function createExportSection( app )
            app.ExportSection = app.HomeTab.addSection(  ...
                getMessageFromCatalog( 'Export' ) );
            app.ExportSection.Tag = 'ExportSection';


            app.ExportFigButton = matlab.ui.internal.toolstrip.Button ...
                ( getMessageFromCatalog( 'ExportFigure' ),  ...
                matlab.ui.internal.toolstrip.Icon.EXPORT_24 );
            app.ExportFigButton.Tag = 'ExportFigure';
            app.ExportFigButton.Description = getMessageFromCatalog( 'ExtractPlot' );
            app.ExportFigButton.Enabled = false;
            app.ExportFigButton.ButtonPushedFcn = @( varargin )app.exportFigButtonPushed;
            exportFigColumn = app.ExportSection.addColumn(  );
            exportFigColumn.add( app.ExportFigButton );
        end

        function createQAB( app )
            import matlab.ui.internal.toolstrip.qab.*;
            app.HelpButton = QABHelpButton(  );
            app.HelpButton.DocName = 'simscape/using-simscape-results-explorer';
            app.AppContainer.add( app.HelpButton );
        end

        function createPanels( app )
            createTreeStructPanel( app );
            createNodeStatisticsPanel( app );
        end

        function createTreeStructPanel( app )

            mdlStructPanelOpts.Title = getMessageFromCatalog( 'TreeTitle' );
            mdlStructPanelOpts.Tag = 'MdlTreeStructure';
            mdlStructPanelOpts.Region = "left";
            app.MdlStructPanel = matlab.ui.internal.FigurePanel( mdlStructPanelOpts );
            app.AppContainer.add( app.MdlStructPanel );
            treestruct = app.AppContainer.getPanels{ 1 }.Figure;


            app.treeStructGridLayout = uigridlayout( treestruct );
            app.treeStructGridLayout.ColumnWidth = { '1x' };
            app.treeStructGridLayout.RowHeight = { '1x' };


            nodeStatisticsPanelOpts.Title = getMessageFromCatalog( 'NodeStatsTitle' );
            nodeStatisticsPanelOpts.Tag = 'NodeStatistics';
            nodeStatisticsPanelOpts.Region = "left";
            app.NodeStatisticsPanel = matlab.ui.internal.FigurePanel( nodeStatisticsPanelOpts );
            app.AppContainer.add( app.NodeStatisticsPanel );
        end

        function createNodeStatisticsPanel( app )
            nodeStatistics = app.AppContainer.getPanels{ 2 }.Figure;


            nodeStatsGridLayout = uigridlayout( nodeStatistics );
            nodeStatsGridLayout.ColumnWidth = { '1x' };
            nodeStatsGridLayout.RowHeight = { 'fit', 'fit', 'fit', 'fit', 'fit' };
            nodeStatsGridLayout.RowSpacing = 0;
            nodeStatsGridLayout.Scrollable = "on";

            app.NodeStatsTitle = uilabel( nodeStatsGridLayout );
            app.NodeStatsTitle.FontSize = 14;
            app.NodeStatsTitle.FontWeight = 'bold';
            app.NodeStatsTitle.Layout.Row = 1;
            app.NodeStatsTitle.Layout.Column = 1;

            app.RootNodeDescription = uilabel( nodeStatsGridLayout );
            app.RootNodeDescription.Layout.Row = 2;
            app.RootNodeDescription.Layout.Column = 1;
            app.RootNodeDescription.WordWrap = "on";
            app.RootNodeDescription.Visible = "off";

            app.NodeStatsDescription = uihyperlink( nodeStatsGridLayout );
            app.NodeStatsDescription.HyperlinkClickedFcn = @( varargin ) ...
                app.descLinkClicked;
            app.NodeStatsDescription.Visible = "off";
            app.NodeStatsDescription.Layout.Row = 2;
            app.NodeStatsDescription.Layout.Column = 1;

            app.NodeStatsUnit = uilabel( nodeStatsGridLayout );
            app.NodeStatsUnit.Layout.Row = 3;
            app.NodeStatsUnit.Layout.Column = 1;
            app.NodeStatsUnit.WordWrap = "on";

            app.NodeStatsValue = uilabel( nodeStatsGridLayout );
            app.NodeStatsValue.Layout.Row = 4;
            app.NodeStatsValue.Layout.Column = 1;
            app.NodeStatsValue.WordWrap = "on";

            app.NodeStatsSource = uihyperlink( nodeStatsGridLayout );
            app.NodeStatsSource.HyperlinkClickedFcn = @( varargin ) ...
                app.sourceLinkClicked;
            app.NodeStatsSource.Layout.Row = 5;
            app.NodeStatsSource.Layout.Column = 1;
        end

        function createPlotFigure( app )

            app.PlotFigure = matlab.ui.internal.FigureDocumentGroup(  );
            app.AppContainer.add( app.PlotFigure );
            figOptions.DocumentGroupTag = app.PlotFigure.Tag;
            app.FigureDocument = matlab.ui.internal.FigureDocument( figOptions );
            app.FigureDocument.Closable = false;
            app.FigureDocument.Figure.AutoResizeChildren = "off";
            app.AppContainer.add( app.FigureDocument );
            app.AppContainer.ShowSingleDocumentTab = false;

            app.FigureVisual = app.FigureDocument.Figure;
            app.FigureVisual.Tag = 'Visualization_Plot';


            figGridLayout = uigridlayout( app.FigureVisual );
            figGridLayout.ColumnWidth = { '1x' };
            figGridLayout.RowHeight = { '1x' };
            placeholdertext = uitextarea( figGridLayout );
            placeholdertext.Value = { '';'';'';'';'';''; ...
                '';'';'';'';'';''; ...
                getMessageFromCatalog( 'PlotPlaceholderText' ) };
            placeholdertext.Layout.Row = 1;
            placeholdertext.Layout.Column = 1;
            placeholdertext.Editable = "off";
            placeholdertext.HorizontalAlignment = 'center';
            placeholdertext.FontWeight = 'bold';
            placeholdertext.FontSize = 19;
            placeholdertext.FontName = 'Arial';
            placeholdertext.WordWrap = 'on';
            placeholdertext.BackgroundColor = [ 0.651, 0.651, 0.651 ];
            placeholdertext.FontColor = [ 0, 0, 0 ];
        end

        function setNodeStats( app, nodeStatsValues )
            app.NodeStatsTitle.Text = nodeStatsValues.StatusTitle;
            app.NodeStatsUnit.Text = nodeStatsValues.StatusUnit;
            app.NodeStatsValue.Text = nodeStatsValues.StatusStats;
            app.NodeStatsSource.Text = nodeStatsValues.SourceStr;
        end

        function importButtonPushed( app )
            app.notify( 'ImportButtonPushed' );
        end

        function stateChangedCallback( app, varargin )
            state = app.AppContainer.State;
            if strcmp( state, 'RUNNING' )
                app.NodeStatisticsPanel.Collapsed = true;
            elseif strcmp( state, 'TERMINATED' )
                notify( app, 'ViewClosed' );
            end
        end

        function saveButtonPushed( app )
            app.notify( 'SaveButtonPushed' );
        end

        function linkUnlinkButtonPushed( app )
            app.notify( 'LinkUnlinkButtonPushed' );
        end

        function setMarker( app, src, ~ )
            if ( src.Selected )
                app.Options.marker = src.Text;
                app.notify( 'MarkerSelection' );
            end
        end

        function setLayout( app, src, ~ )
            if ( src.Selected )
                app.Options.layout = src.Text;
                app.notify( 'LayoutSelection' );
            end
        end

        function setUnit( app, src, ~ )
            if ( src.Selected )
                app.Options.unit = src.Text;
                app.notify( 'UnitSelection' );
            end
        end

        function setPlotType( app, src, ~ )
            if ( src.Selected )
                app.Options.plotType = src.Text;
                app.notify( 'PlotTypeSelection' );
            end
        end

        function setShowLegend( app, src, ~ )
            if ( src.Selected )
                app.Options.legend = src.Text;
                app.notify( 'LegendSelection' );
            end
        end

        function toggleLinkTimeButton( app )
            app.notify( 'LinkAxesButtonToggled' );
        end

        function editTimeAxesLimits( app )
            app.notify( 'LimitTimeAxesValueChanged' );
        end

        function exportFigButtonPushed( app )
            app.notify( 'ExportButtonPushed' );
        end

        function descLinkClicked( app )
            app.notify( 'DescriptionLinkClicked' );
        end

        function sourceLinkClicked( app )
            app.notify( 'SourceLinkClicked' );
        end
    end
end



function path = getIconPath( filename )

path = fullfile( matlabroot, 'toolbox', 'physmod', 'common',  ...
    'logging', 'sli', 'm', 'resources', 'icons', filename );
end

