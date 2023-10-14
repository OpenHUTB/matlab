classdef PreprocessingTableView < matlab.ui.componentcontainer.ComponentContainer





    properties ( Constant )
        VARIABLE_SUMMARY( 1, 1 )string = string( getString( message( 'MATLAB:datatools:preprocessing:tabular:tableview:VarSummary' ) ) )
        DEFAULT_POSITION = [ 20, 20, 300, 400 ]
        SUMMARY_TABLE_COLUMN_WIDTHS = { 'auto', 'auto', 'auto', 'auto', 125, 125, 'auto', 'auto', 'auto', 'auto', 'auto', 'auto', 'auto' }
        PLOT_VIEW_TITLE( 1, 1 )string = string( getString( message( 'MATLAB:datatools:preprocessing:tabular:tableview:PlotView' ) ) )
    end

    properties
        SelectionChangedFcn
        DataChangedFcn
        UserDataInteractionCallbackFcn
        OriginalUITable
        SummaryUITable
        SelectedTableVariables
        Selection
        InitialData

        ActionCount = struct(  );
    end

    properties ( Dependent = true )
        VariableName( 1, 1 )string = ""
        Data
        SummaryData
        Workspace
        SummaryWorkspace
        SparkLinesVisible

    end

    properties ( SetAccess = 'private', GetAccess = 'public' )
        VizScript
    end

    methods
        function val = get.Data( obj )
            val = obj.OriginalTable;
        end
        function set.Data( obj, val )
            arguments
                obj
                val{ matlab.internal.preprocessingApp.tabular.mustBeTabularOrNumericMatrix( val ) }
            end

            if isempty( val ) && isempty( obj.OriginalTable )
                return ;
            end

            if ~isequal( val, obj.OriginalTable )
                if ~isempty( obj.InitialData )


                    currColumnNames = string( obj.InitialData.Properties.VariableNames );
                    newColumnNames = string( val.Properties.VariableNames );
                    if ~isequal( currColumnNames, newColumnNames )
                        obj.InitialData = val;
                    end
                end

                obj.OriginalTable = val;
                obj.DataDirty = true;
                obj.SummaryDirty = true;
                obj.PlotDirty = true;
                obj.updateTab;
                return ;
            end




            if obj.PlotDirty ||  ...
                    ( ~isempty( obj.Plots ) &&  ...
                    ~isequal( obj.Plots.TableVariables, obj.Selection.SelectedTableVariables ) &&  ...
                    obj.TabGroup.SelectedTab == obj.PlotTab )
                obj.updateTab;
            end
        end

        function val = get.SparkLinesVisible( obj )
            if ~isempty( obj.OriginalUITable )
                val = obj.OriginalUITable.SparkLinesVisible;
            else
                val = obj.SparkLinesI;
            end
        end

        function set.SparkLinesVisible( obj, state )
            obj.SparkLinesI = state;
            if ~isempty( obj.OriginalUITable )
                obj.OriginalUITable.SparkLinesVisible = state;
            end
        end

        function val = get.SummaryData( obj )
            val = obj.SummaryTable;
        end

        function val = get.VariableName( obj )
            val = obj.VariableNameI;
        end
        function set.VariableName( obj, val )
            obj.VariableNameI = val;
            if ~isempty( obj.OriginalUITable )
                obj.OriginalUITable.Variable = val;
            end
            if ~isempty( obj.SummaryUITable )
                obj.SummaryUITable.Variable = val;
            end
        end

        function val = get.Workspace( obj )
            val = obj.WorkspaceI;
        end
        function set.Workspace( obj, val )
            obj.WorkspaceI = val;
            if ~isempty( obj.OriginalUITable )
                obj.OriginalUITable.Workspace = val;
            end
        end

        function val = get.SummaryWorkspace( obj )
            val = obj.SummaryWorkspaceI;
        end
        function set.SummaryWorkspace( obj, val )
            obj.SummaryWorkspaceI = val;
            if ~isempty( obj.SummaryUITable )
                obj.SummaryUITable.Workspace = val;
            end
        end
    end

    properties ( Access = 'public', Transient, NonCopyable, Hidden )
        VariableNameI( 1, 1 )string = ""
        WorkspaceI
        SummaryWorkspaceI
        OriginalTable{ matlab.internal.preprocessingApp.tabular.mustBeTabularOrNumericMatrix( OriginalTable ) } = table.empty
        SummaryTable
        SparkLinesI = 'on'

        OriginalTableGridLayout matlab.ui.container.GridLayout
        SummaryTableGridLayout matlab.ui.container.GridLayout
        SummaryStatsGridLayout matlab.ui.container.GridLayout
        TableStatsGridLayout matlab.ui.container.GridLayout
        TabGroup matlab.ui.container.TabGroup
        OriginalDataTab matlab.ui.container.Tab
        SummaryDataTab matlab.ui.container.Tab
        TableSummaryLabel matlab.ui.control.Label
        TableStatsLabels matlab.ui.control.Label
        TableStatsValues matlab.ui.control.Label
        PlotTab
        PlotTabGrid
        Plots

        OrigTableSelectionListener
        SummaryTableSelectionListener

        PreviousPosition;

        PlotDirty = true;
        DataDirty = true;
        SummaryDirty = true;
    end

    methods
        function obj = PreprocessingTableView( NameValueArgs )
            arguments
                NameValueArgs.?matlab.ui.componentcontainer.ComponentContainer
                NameValueArgs.Parent = uifigure
                NameValueArgs.BackgroundColor = 'white'
                NameValueArgs.Workspace = matlab.internal.datatoolsservices.AppWorkspace
                NameValueArgs.SummaryWorkspace = matlab.internal.datatoolsservices.AppWorkspace
                NameValueArgs.VariableName
                NameValueArgs.Data = table.empty
                NameValueArgs.SparkLinesVisible = 'on'
            end

            obj@matlab.ui.componentcontainer.ComponentContainer( NameValueArgs );
            if ~isa( NameValueArgs.Parent, "matlab.ui.container.GridLayout" ) && ~isfield( NameValueArgs, "Position" )
                obj.Position = matlab.internal.preprocessingApp.tabular.PreprocessingTableView.DEFAULT_POSITION;
            end

            obj.TabGroup.SelectionChangedFcn = @( ~, ~ )obj.updateTab;
            obj.Selection = matlab.internal.preprocessingApp.selection.Selection.getInstance(  );
            obj.Selection.SelectionChanged = @( ~, ~ )obj.updateTab;
        end

        function clearInteractionCodeBuffer( this )
            this.OriginalUITable.clearCodeBuffer(  );
        end

        function setVizScript( obj, vizScript )
            obj.VizScript = vizScript;
        end
    end

    methods ( Access = protected )
        function setupUserDataInteractionListeners( obj, ~, d )
            obj.OriginalUITable.UserDataInteractionCallbackFcn = this.UserDataInteractionUpdate( d );
            obj.SummaryUITable.UserDataInteractionCallbackFcn = this.UserDataInteractionUpdate( d );
        end

        function UserDataInteractionUpdate( ~, d )
            disp( d );
        end

        function setup( obj )

            obj.TabGroup = matlab.ui.container.TabGroup( 'Parent', obj,  ...
                'TabLocation', 'top', 'Units', 'normalized', 'Position', [ 0, 0, 1, 1 ] );

            obj.PlotTab = matlab.ui.container.Tab( 'Parent', obj.TabGroup, 'Tag', 'PlotTab',  ...
                'Title', getString( message( 'MATLAB:datatools:preprocessing:tabular:tableview:PlotView' ) ),  ...
                'Background', 'white' );

            obj.OriginalDataTab = matlab.ui.container.Tab( 'Parent', obj.TabGroup, 'Tag', 'DataTab',  ...
                'Title', getString( message( 'MATLAB:datatools:preprocessing:tabular:tableview:DataView' ) ),  ...
                'Background', 'white' );
            obj.OriginalTableGridLayout = uigridlayout( obj.OriginalDataTab, [ 1, 1 ], 'Padding', [ 0, 0, 0, 0 ], 'BackgroundColor', 'white' );


            obj.SummaryDataTab = matlab.ui.container.Tab( 'Parent', obj.TabGroup, 'Tag', 'SummaryTab',  ...
                'Title', getString( message( 'MATLAB:datatools:preprocessing:tabular:tableview:SummaryView' ) ),  ...
                'Background', 'white' );

            obj.SummaryTableGridLayout = uigridlayout( obj.SummaryDataTab, 'Padding', [ 0, 0, 0, 0 ], 'BackgroundColor', 'white' );
            obj.SummaryTableGridLayout.ColumnWidth = { '1x' };
            obj.SummaryTableGridLayout.RowHeight = { 'fit', '1x' };

            obj.SummaryStatsGridLayout = uigridlayout( obj.SummaryTableGridLayout, 'Padding', [ 5, 5, 5, 5 ], 'BackgroundColor', 'white' );
            obj.SummaryStatsGridLayout.ColumnWidth = { '1x' };
            obj.SummaryStatsGridLayout.RowHeight = { 'fit', 'fit' };
            obj.SummaryStatsGridLayout.RowSpacing = 5;
            obj.TableSummaryLabel = uilabel( 'Parent', obj.SummaryStatsGridLayout,  ...
                'Text', getString( message( 'MATLAB:datatools:preprocessing:tabular:tableview:VarSummary' ) ),  ...
                'FontWeight', 'bold', 'FontSize', 14 );
            obj.TableStatsGridLayout = uigridlayout( obj.SummaryStatsGridLayout, 'Padding', [ 0, 0, 0, 0 ], 'BackgroundColor', 'white' );
            obj.TableStatsGridLayout.ColumnWidth = { 'fit', 'fit' };
            obj.TableStatsGridLayout.RowHeight = { 'fit' };
            obj.TableStatsGridLayout.RowSpacing = 0;
        end

        function update( obj )
            obj.TableStatsGridLayout.Scrollable = true;
            obj.SummaryStatsGridLayout.Scrollable = true;
        end

        function updateTab( obj )


            if ~isvalid( obj )
                return ;
            end

            if obj.TabGroup.SelectedTab == obj.PlotTab
                obj.updatePlotTab;
                obj.PlotDirty = false;
            elseif obj.TabGroup.SelectedTab == obj.SummaryDataTab && obj.SummaryDirty
                obj.updateSummaryView;
                obj.SummaryDirty = false;
            elseif obj.DataDirty
                if isempty( obj.SummaryUITable )
                    obj.updateSummaryView;
                end
                obj.updateOriginalTable;
                obj.DataDirty = false;
            end
        end

        function updatePlotTab( obj )
            obj.PlotTab.Scrollable = 'on';
            if isempty( obj.Plots )
                obj.Plots = matlab.internal.preprocessingApp.figure.VisualizationPanel( 'Parent', obj.PlotTab );
            end

            updateTable = false;
            if isempty( obj.InitialData ) && ~isa( obj.InitialData, 'tabular' )
                initialData = obj.OriginalTable;
                obj.InitialData = initialData;
                updateTable = true;
            end
            data = struct( 'currentData', obj.OriginalTable, 'origData', obj.InitialData, 'display', [ 1, 1 ] );
            if ~isempty( obj.VizScript ) && ~isempty( obj.VizScript.Code )
                obj.Plots.updatePlotView( obj.Selection.SelectedVariable,  ...
                    obj.Selection.SelectedTableVariables, data, obj.VizScript.Workspace, obj.VizScript.Code, true );
            else
                obj.Plots.setData( data, obj.Selection.SelectedVariable, obj.Selection.SelectedTableVariables );
            end
            if updateTable
                w = warning( 'off', 'all' );
                drawnow nocallbacks;
                warning( w );
                obj.createOriginalUITable(  );
            end
        end

        function updateOriginalTable( obj )
            if isempty( obj.OriginalUITable )
                obj.createOriginalUITable(  );
            else
                assignin( obj.OriginalUITable.Workspace, obj.VariableName, obj.OriginalTable );
            end
        end

        function updateSummaryView( obj )
            origTable = obj.OriginalTable;
            if ~isa( obj.OriginalTable, 'tabular' )
                origTable = array2table( obj.OriginalTable );
                origTable.Properties.VariableNames = string( 1:size( obj.OriginalTable, 2 ) );
            end
            [ obj.SummaryTable, tableStats ] = matlab.internal.preprocessingApp.tabular.createSummaryTable( origTable );


            obj.updateTableLevelSummary( tableStats );


            assignin( obj.SummaryWorkspace, obj.VariableName, obj.SummaryTable );
            if isempty( obj.SummaryUITable )
                obj.createSummaryUITable(  );







            end
        end

        function updateTableLevelSummary( obj, tableStats )

            fn = fieldnames( tableStats );
            if ~isempty( obj.TableStatsLabels ) && length( obj.TableStatsLabels ) > length( fn )

                for i = length( obj.TableStatsLabels ): - 1:length( fn ) + 1
                    delete( obj.TableStatsLabels( i ) );
                    delete( obj.TableStatsValues( i ) );
                    obj.TableStatsLabels( i ) = [  ];
                    obj.TableStatsValues( i ) = [  ];
                end
            end
            for i = 1:length( fn )
                statsLabel = matlab.internal.preprocessingApp.tabular.statFieldToDisplayName( fn{ i } );
                statsValue = tableStats.( fn{ i } );
                if isempty( obj.TableStatsLabels ) || length( obj.TableStatsLabels ) < i
                    obj.TableStatsLabels( i ) = uilabel( 'Parent', obj.TableStatsGridLayout, 'FontColor', 'black', 'FontWeight', 'normal', 'FontSize', 14 );
                    obj.TableStatsLabels( i ).Layout.Row = i;
                    obj.TableStatsLabels( i ).Layout.Column = 1;
                    obj.TableStatsValues( i ) = uilabel( 'Parent', obj.TableStatsGridLayout, 'FontColor', 'black', 'FontWeight', 'normal', 'FontSize', 14 );
                    obj.TableStatsValues( i ).Layout.Row = i;
                    obj.TableStatsValues( i ).Layout.Column = 2;
                end
                obj.TableStatsLabels( i ).Text = statsLabel;
                obj.TableStatsValues( i ).Text = statsValue;
            end
        end

        function createOriginalUITable( obj )
            obj.OriginalUITable =  ...
                matlab.internal.datatools.uicomponents.uivariableeditor.UIVariableEditor( 'Parent', obj.OriginalTableGridLayout,  ...
                'Workspace', obj.Workspace, 'Variable', obj.VariableName,  ...
                'RowHeadersVisible', 'on',  ...
                'DataSelectable', 'off',  ...
                'DataFilterable', 'off',  ...
                'DataSortable', 'on',  ...
                'DataTypeChangeable', 'off',  ...
                'SparklinesVisible', 'on',  ...
                'StatisticsVisible', 'on',  ...
                'InfiniteGrid', 'off' );

            obj.OriginalUITable.UserDataInteractionCallbackFcn = @( d )obj.handleTableUserDataInteraction( d );
            obj.OriginalUITable.disableEditing;
        end

        function createSummaryUITable( obj )

            obj.SummaryUITable =  ...
                matlab.internal.datatools.uicomponents.uivariableeditor.UIVariableEditor( 'Parent', obj.SummaryTableGridLayout, 'Workspace', obj.SummaryWorkspace,  ...
                'Variable', obj.VariableName,  ...
                'RowHeadersVisible', 'on',  ...
                'DataSelectable', 'off',  ...
                'DataFilterable', 'off',  ...
                'DataSortable', 'on',  ...
                'InfiniteGrid', 'off' );
            obj.SummaryUITable.SelectionChangedCallbackFcn = @( d )obj.handleSummaryTableSelectionChange( d );
        end

        function selectedTableVariables = getSelectedTableVariables( obj, selectionObj )
            tableVariables = obj.OriginalTable.Properties.VariableNames;
            if istimetable( obj.OriginalTable )
                tableVariables = [ obj.OriginalTable.Properties.DimensionNames( 1 ), tableVariables ];
            end
            if obj.TabGroup.SelectedTab == obj.OriginalDataTab


                if ~isempty( selectionObj.Columns ) &&  ...
                        isequal( selectionObj.Columns( 1 ), selectionObj.Columns( 2 ) )
                    selectedTableVariables = tableVariables( selectionObj.Columns( 1 ) );
                else
                    selectedTableVariables = [  ];
                end
            else




                if ~isempty( selectionObj.Rows ) &&  ...
                        isequal( selectionObj.Columns( 1 ), selectionObj.Columns( 2 ) )
                    selectedTableVariables = tableVariables( selectionObj.Rows( 1 ) );
                else
                    selectedTableVariables = [  ];
                end
            end
        end

        function handleDataTableSelectionChange( obj, selectionObj )
            selectedTableVariables = obj.getSelectedTableVariables( selectionObj );
            if ~isempty( obj.SummaryUITable )
                obj.SummaryUITable.SelectionChangedCallbackFcn = [  ];
                obj.SummaryUITable.Selection = struct( 'Rows', [ selectionObj.Columns( end  ), selectionObj.Columns( end  ) ],  ...
                    'Columns', [ 1, width( obj.SummaryTable ) ] );
                obj.SummaryUITable.SelectionChangedCallbackFcn = @( d )obj.handleSummaryTableSelectionChange( d );
            end
            try
                obj.SelectionChangedFcn( obj.Selection, selectedTableVariables );
            catch e
                disp( e );
            end

        end

        function handleSummaryTableSelectionChange( obj, selectionObj )
            selectedTableVariables = obj.getSelectedTableVariables( selectionObj );
            if ~isempty( obj.OriginalUITable )
                obj.OriginalUITable.SelectionChangedCallbackFcn = [  ];
                obj.OriginalUITable.Selection = struct( 'Rows', [ 1, height( obj.OriginalTable ) ],  ...
                    'Columns', [ selectionObj.Rows( end  ), selectionObj.Rows( end  ) ] );
                obj.OriginalUITable.SelectionChangedCallbackFcn = @( d )obj.handleDataTableSelectionChange( d );
            end
            try
                obj.SelectionChangedFcn( obj.Selection, selectedTableVariables );
            catch e
                disp( e );
            end
        end

        function handleTableUserDataInteraction( obj, interactionObject )
            obj.DataChangedFcn( interactionObject );
        end

        function fireSelectionChanged( obj )

            if ~isempty( obj.SelectionChangedFcn )
                try
                    switch nargin( obj.SelectionChangedFcn )
                        case 0
                            obj.SelectionChangedFcn(  );
                        case 1
                            obj.SelectionChangedFcn( obj.Selection );
                        case 2
                            obj.SelectionChangedFcn( obj.Selection, obj.SelectedTableVariables );
                    end
                catch e
                    disp( e );
                end
            end
        end

        function handleTableDataChange( obj, evt )

            if ~isempty( obj.DataChangedFcn )
                if strcmp( evt.Interaction, 'sort' )
                    index = evt.InteractionColumn;

                    colName = evt.DisplayColumnName{ index };
                    if isfield( obj.ActionCount, colName )
                        obj.ActionCount.( colName ) = obj.ActionCount.( colName ) + 1;
                    else
                        obj.ActionCount.( colName ) = 1;
                    end

                    if isequal( mod( obj.ActionCount.( colName ), 2 ), 0 )
                        direction = 'descend';
                    elseif isequal( mod( obj.ActionCount.( colName ), 3 ), 0 )
                        direction = "";
                        obj.ActionCount = rmfield( obj.ActionCount, colName );
                    else
                        direction = 'ascend';
                    end
                    dataChangeEvt = struct( 'ColumnName',  ...
                        evt.DisplayColumnName{ index }, 'Direction',  ...
                        direction );

                    try
                        obj.DataChangedFcn( dataChangeEvt );
                    catch e
                        disp( e );
                    end
                    obj.updateSummaryView;
                    obj.Selection = index;
                    obj.fireSelectionChanged;
                end
            end
        end
    end
end

