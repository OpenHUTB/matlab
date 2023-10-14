classdef TaskPanel < matlab.internal.preprocessingApp.base.PreprocessingPanel





properties 
GridLayout matlab.ui.container.GridLayout
AxesGridLayout matlab.ui.container.GridLayout
OriginalTableGridLayout matlab.ui.container.GridLayout
PreprocessedTableGridLayout matlab.ui.container.GridLayout
TabGroup matlab.ui.container.TabGroup
AxesTab matlab.ui.container.Tab
OriginalTableTab matlab.ui.container.Tab
PreprocessedTableTab matlab.ui.container.Tab
UIAxes matlab.ui.control.UIAxes
OriginalTableView
PreprocessedTableView matlab.internal.preprocessingApp.tabular.PreprocessingTableView
HasVisualization( 1, 1 )logical = true

OriginalTableData;
TableData;
OrigData;
PreprocessedTableWorkspace
OriginalTableWorkspace
TableName = "";
InputTableNames

OrigDataDirty( 1, 1 )logical = true
DataDirty( 1, 1 )logical = true

appStateChangedEventListener
appStateChangeEventAggregator
end 

methods 
function obj = TaskPanel( varargin )
obj@matlab.internal.preprocessingApp.base.PreprocessingPanel( varargin{ : } );
panelHeight = round( ( 1 / 2 ) * obj.ParentSize( 4 ) );
obj.PreferredHeight = panelHeight;
args = varargin{ : };

obj.setup(  );
end 

function setup( obj )
end 

function initializaLayout( obj )
obj.Figure.Color = 'white';
obj.GridLayout = uigridlayout( obj.Figure );
obj.GridLayout.ColumnWidth = { '1x' };
obj.GridLayout.RowHeight = { '1x' };
obj.GridLayout.Padding = [ 1, 1, 1, 1 ];

obj.TabGroup = matlab.ui.container.TabGroup( 'Parent', obj.GridLayout );
obj.TabGroup.Layout.Row = 1;
obj.TabGroup.Layout.Column = 1;
if obj.HasVisualization
obj.AxesTab = matlab.ui.container.Tab( 'Parent', obj.TabGroup, 'Title', 'Plot' );
obj.AxesGridLayout = uigridlayout( obj.AxesTab, [ 1, 1 ] );

obj.UIAxes = uiaxes( 'Parent', obj.AxesGridLayout );
end 
obj.PreprocessedTableTab = matlab.ui.container.Tab( 'Parent', obj.TabGroup, 'Title',  ...
getString( message( 'MATLAB:datatools:preprocessing:tasks:tasks:CLEANED_TABLE_TITLE' ) ) );
obj.PreprocessedTableGridLayout = uigridlayout( obj.PreprocessedTableTab, [ 1, 1 ] );

obj.OriginalTableTab = matlab.ui.container.Tab( 'Parent', obj.TabGroup, 'Title',  ...
getString( message( 'MATLAB:datatools:preprocessing:tasks:tasks:ORIGINAL_TABLE_TITLE' ) ) );


obj.TabGroup.SelectionChangedFcn = @( e, d )obj.updateTab;
end 

function updateVisualization( obj, visScript, workspace )
arguments
obj
visScript = ""
workspace = "base"
end 

obj.Figure.Internal = false;
obj.Figure.HandleVisibility = 'on';
figure( obj.Figure );
try 
evalin( workspace, visScript );
catch e
disp( e );
end 
obj.Figure.HandleVisibility = 'off';
obj.Figure.Internal = true;

axtoolbar( obj.Figure.CurrentAxes, { 'pan', 'restoreview', 'zoomin', 'zoomout' } );
end 

function setTableData( obj, tableData, tableName, origTableData )
arguments
obj
tableData{ matlab.internal.preprocessingApp.tabular.mustBeTabularOrNumericMatrix( tableData ) }
tableName( 1, 1 )string
origTableData
end 
obj.TableData = tableData;
obj.TableName = tableName;
obj.OrigData = origTableData;

obj.OrigDataDirty = true;
obj.DataDirty = true;
obj.updateTab(  );
end 

function selectOriginalTable( obj )
obj.TabGroup.SelectedTab = obj.OriginalTableTab;
end 

function selectPreprocessedTable( obj )
obj.TabGroup.SelectedTab = obj.PreprocessedTableTab;
end 

function updateTab( obj )
if isempty( obj.GridLayout )
obj.initializaLayout(  );
end 

if obj.TabGroup.SelectedTab == obj.OriginalTableTab && obj.OrigDataDirty
if ~isempty( obj.OriginalTableView ) &&  ...
~isempty( obj.TableName )
for i = 1:length( obj.OriginalTableView )
delete( obj.OriginalTableView{ i } );
end 
obj.OriginalTableView = [  ];
end 

if isempty( obj.OriginalTableView ) &&  ...
~isempty( obj.TableName ) &&  ...
~isempty( obj.OriginalTableWorkspace )
obj.OriginalTableGridLayout = uigridlayout( obj.OriginalTableTab, [ 1, max( 1, length( obj.InputTableNames ) ) ] );
for i = 1:length( obj.InputTableNames )
obj.OriginalTableView{ i } = matlab.internal.preprocessingApp.tabular.PreprocessingTableView(  ...
'Parent', obj.OriginalTableGridLayout,  ...
'Workspace', obj.OriginalTableWorkspace,  ...
'Variable', obj.InputTableNames( i ),  ...
'SparkLinesVisible', 'off' );
obj.OriginalTableView{ i }.Layout.Row = 1;
obj.OriginalTableView{ i }.Layout.Column = i;
obj.OriginalTableView{ i }.Data = obj.OrigData{ i };
end 
end 
obj.OrigDataDirty = false;
end 

if obj.TabGroup.SelectedTab == obj.PreprocessedTableTab && obj.DataDirty
if ~isempty( obj.PreprocessedTableView ) &&  ...
~isempty( obj.TableName ) &&  ...
~strcmp( obj.PreprocessedTableView.VariableName, obj.TableName )
delete( obj.PreprocessedTableView );
end 

if ( isempty( obj.PreprocessedTableView ) || ~isvalid( obj.PreprocessedTableView ) ) &&  ...
~isempty( obj.TableName ) &&  ...
~isempty( obj.PreprocessedTableWorkspace )
obj.PreprocessedTableView = matlab.internal.preprocessingApp.tabular.PreprocessingTableView( 'Parent',  ...
obj.PreprocessedTableGridLayout, 'Workspace', obj.PreprocessedTableWorkspace,  ...
'Variable', obj.TableName,  ...
'SparkLinesVisible', 'off' );
end 
obj.PreprocessedTableView.Data = obj.TableData;
obj.DataDirty = false;
end 
end 

function setOriginalTableWorkspace( obj, originalWorkspace )
obj.OriginalTableWorkspace = originalWorkspace;
end 

function setPreprocessedTableWorkspace( obj, previewWorkspace )


if ~isempty( obj.PreprocessedTableView )
obj.PreprocessedTableView.Workspace = previewWorkspace.clone( obj.PreprocessedTableView.Workspace );
else 
obj.PreprocessedTableWorkspace = previewWorkspace;
end 
end 

function disableUpdateInteractions( ~ )
end 

function enableUpdateInteractions( ~ )
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpx6SPIP.p.
% Please follow local copyright laws when handling this file.

