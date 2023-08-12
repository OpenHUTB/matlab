classdef InspectorTaskDocument < matlab.internal.preprocessingApp.base.PreprocessingDocument





properties 
GridLayout matlab.ui.container.GridLayout
OriginalTableGridLayout matlab.ui.container.GridLayout
PreprocessedTableGridLayout matlab.ui.container.GridLayout
TabGroup matlab.ui.container.TabGroup
AxesTab matlab.ui.container.Tab
AxesOuterSubpanel matlab.ui.container.Panel
AxesInnerSubpanel matlab.ui.container.Panel
TiledLayout matlab.graphics.layout.TiledChartLayout
OriginalTableTab matlab.ui.container.Tab
PreprocessedTableTab matlab.ui.container.Tab
OriginalTableView matlab.internal.preprocessingApp.tabular.PreprocessingTableView
PreprocessedTableView matlab.internal.preprocessingApp.tabular.PreprocessingTableView
HasVisualization( 1, 1 )logical = true

OriginalTableData;
TableData;
OrigData;
PreprocessedTableWorkspace
OriginalTableWorkspace
TableName = "";

OrigDataDirty( 1, 1 )logical = true
DataDirty( 1, 1 )logical = true

appStateChangedEventListener
appStateChangeEventAggregator

UseAllDataCheckBox
RowsSpinnerLabel
RowsSpinner
ColumnsSpinnerLabel
ColumnsSpinner
Button
end 

methods 
function obj = InspectorTaskDocument( varargin )
obj@matlab.internal.preprocessingApp.base.PreprocessingDocument( varargin{ : } );
obj.setup(  );
end 

function setup( obj )
end 

function initializaLayout( obj )
obj.Figure.Color = 'white';
obj.Figure.AutoResizeChildren = 'off';
obj.GridLayout = uigridlayout( obj.Figure, [ 1, 6 ] );
obj.GridLayout.ColumnWidth = { 85, 45, 100, 50, 100, 20, '1x' };
obj.GridLayout.RowHeight = { 20, '1x' };

obj.createSubsetControls(  );



obj.TabGroup = matlab.ui.container.TabGroup( 'Parent', obj.GridLayout );
obj.TabGroup.Layout.Row = 2;
obj.TabGroup.Layout.Column = [ 1, 7 ];
obj.TabGroup.AutoResizeChildren = 'off';
if obj.HasVisualization
obj.AxesTab = matlab.ui.container.Tab( 'Parent', obj.TabGroup, 'Title', 'Plot' );
obj.AxesTab.AutoResizeChildren = 'off';
obj.AxesOuterSubpanel = uipanel( obj.AxesTab, 'Units', 'normalized', 'Position', [ 0, 0, 1, 1 ],  ...
'Scrollable', 'on', 'BorderType', 'none' );
obj.AxesOuterSubpanel.AutoResizeChildren = 'off';

obj.AxesInnerSubpanel = uipanel( obj.AxesOuterSubpanel, 'Units', 'normalized',  ...
'Position', [ 0, 0, 1, 1 ], 'BorderType', 'none' );
obj.AxesInnerSubpanel.AutoResizeChildren = 'off';

obj.TiledLayout = tiledlayout( obj.AxesInnerSubpanel, 1, 1, 'Padding', 'compact' );
end 










end 

function createSubsetControls( obj )


obj.UseAllDataCheckBox = uicheckbox( obj.GridLayout );
obj.UseAllDataCheckBox.Text = 'Use All Data';
obj.UseAllDataCheckBox.Layout.Row = 1;
obj.UseAllDataCheckBox.Layout.Column = 1;


obj.RowsSpinnerLabel = uilabel( obj.GridLayout );
obj.RowsSpinnerLabel.HorizontalAlignment = 'right';
obj.RowsSpinnerLabel.Layout.Row = 1;
obj.RowsSpinnerLabel.Layout.Column = 2;
obj.RowsSpinnerLabel.Text = 'Rows';


obj.RowsSpinner = uispinner( obj.GridLayout );
obj.RowsSpinner.Layout.Row = 1;
obj.RowsSpinner.Layout.Column = 3;


obj.ColumnsSpinnerLabel = uilabel( obj.GridLayout );
obj.ColumnsSpinnerLabel.HorizontalAlignment = 'right';
obj.ColumnsSpinnerLabel.Layout.Row = 1;
obj.ColumnsSpinnerLabel.Layout.Column = 4;
obj.ColumnsSpinnerLabel.Text = 'Columns';


obj.ColumnsSpinner = uispinner( obj.GridLayout );
obj.ColumnsSpinner.Layout.Row = 1;
obj.ColumnsSpinner.Layout.Column = 5;


obj.Button = uibutton( obj.GridLayout, 'push' );
obj.Button.Layout.Row = 1;
obj.Button.Layout.Column = 6;
obj.Button.Icon = fullfile( matlabroot, 'toolbox', 'matlab', 'datatools', 'preprocessing', '+matlab', '+internal', '+preprocessingApp', '+images', 'settings_16.png' );
obj.Button.IconAlignment = 'center';
obj.Button.Text = '';
obj.Button.BackgroundColor = [ 1, 1, 1 ];
end 

function updateVisualization( obj, visScript, workspace )
R36
obj
visScript = [  ]
workspace = "base"
end 
if isempty( obj.GridLayout )
obj.initializaLayout(  );
end 

obj.Figure.Internal = false;
obj.Figure.HandleVisibility = 'on';
figure( obj.Figure );
if ~isempty( visScript )

obj.AxesOuterSubpanel.Position = [ 0, 0, 1, 1 ];

delete( obj.TiledLayout.Children );
if isequal( visScript, "cla" )
obj.TiledLayout.GridSize = [ 1, 1 ];
obj.AxesInnerSubpanel.Position = [ 0, 0, 1, 1 ];
nexttile( obj.TiledLayout );
evalin( workspace, "cla" );

else 
plotCodeMap = visScript;
N = plotCodeMap.Count;
if N < 4
panelHeight = 1;
else 
panelHeight = N / 3;
end 
obj.AxesInnerSubpanel.Position = [ 0, 1 - panelHeight, 1, panelHeight ];
obj.TiledLayout.GridSize = double( [ N, 1 ] );
for var = keys( plotCodeMap )
nexttile( obj.TiledLayout );
try 
s = plotCodeMap( var{ 1 } );
s = s + ";set(gca, 'Toolbar', []);";
evalin( workspace, s );

catch e
disp( e )
end 
end 
end 
end 
obj.Figure.HandleVisibility = 'off';
obj.Figure.Internal = true;

end 

function setTableData( obj, tableData, tableName, origTableData )
R36
obj
tableData{ matlab.internal.preprocessingApp.tabular.mustBeTabularOrNumericMatrix( tableData ) }
tableName( 1, 1 )string
origTableData{ matlab.internal.preprocessingApp.tabular.mustBeTabularOrNumericMatrix( origTableData ) }
end 
obj.TableData = tableData;
obj.TableName = tableName;
obj.OrigData = origTableData;

obj.OrigDataDirty = true;
obj.DataDirty = true;
obj.updateTab(  );
end 

function updateTab( obj )
if isempty( obj.GridLayout )
obj.initializaLayout(  );
end 

if obj.TabGroup.SelectedTab == obj.OriginalTableTab && obj.OrigDataDirty
if isempty( obj.OriginalTableView ) &&  ...
~isempty( obj.TableName ) &&  ...
~isempty( obj.OriginalTableWorkspace )



end 


end 

if obj.TabGroup.SelectedTab == obj.PreprocessedTableTab && obj.DataDirty
if isempty( obj.PreprocessedTableView ) &&  ...
~isempty( obj.TableName ) &&  ...
~isempty( obj.PreprocessedTableWorkspace )



end 


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


% Decoded using De-pcode utility v1.2 from file /tmp/tmpQgMukv.p.
% Please follow local copyright laws when handling this file.

