classdef TabularVariableDocument < matlab.internal.preprocessingApp.base.PreprocessingDocument




properties 
VariableSelectionChangedFcn
DocumentDataChangedFcn
TableView matlab.internal.preprocessingApp.tabular.PreprocessingTableView
SparklinesSwitchLabel
SparklinesSwitch
end 

properties 
GridLayout matlab.ui.container.GridLayout
end 

properties ( Dependent )
Data
VizScript
VariableName
SelectedTableVariables
Workspace
end 
methods 
function data = get.Data( obj )
data = table.empty;
if ~isempty( obj.TableView )
data = obj.TableView.Data;
end 
end 
function set.Data( obj, newData )
if ~isempty( obj.TableView )
obj.TableView.Data = newData;
end 
end 

function workspace = get.Workspace( obj )
if ~isempty( obj.TableView )
workspace = obj.TableView.Workspace;
end 
end 
function set.Workspace( obj, newWorkspace )
if ~isempty( obj.TableView )
obj.TableView.Workspace = newWorkspace;
end 
end 

function varName = get.VariableName( obj )
varName = "";
if ~isempty( obj.TableView )
varName = obj.TableView.VariableName;
end 
end 
function set.VariableName( obj, varName )
if ~isempty( obj.TableView )
obj.TableView.VariableName = varName;
end 
end 

function varName = get.VizScript( obj )
varName = "";
if ~isempty( obj.TableView )
varName = obj.TableView.VizScript;
end 
end 
function set.VizScript( obj, script )
if ~isempty( obj.TableView )
obj.TableView.setVizScript( script );
end 
end 












end 

methods 
function this = TabularVariableDocument( varargin )
this@matlab.internal.preprocessingApp.base.PreprocessingDocument( varargin{ : } );
this.setup( varargin{ : } );
end 

function setSelectedTableVariables( this, val )
this.SelectedTableVariables = val;
this.TableView.SelectedTableVariables( val );
end 

function cacheChildren( this )
if ~isempty( this.TableView )
this.TableView.reparentToPlaceHolder(  );
end 
end 

function disableUpdateInteractions( ~ )
end 

function enableUpdateInteractions( ~ )
end 

function clearInteractionCodeBuffer( this )
this.TableView.clearInteractionCodeBuffer(  );
end 
end 

methods ( Access = protected )
function setup( obj, nvpairs )
R36
obj
nvpairs
end 
obj.GridLayout = uigridlayout( obj.Figure, [ 1, 1 ], 'BackgroundColor', 'white' );
obj.GridLayout.RowHeight = { '1x' };
obj.GridLayout.ColumnWidth = { '1x' };













if isfield( nvpairs, 'TableView' )
nvpairs.TableView.Parent = obj.Figure;
obj.TableView = nvpairs.TableView;
else 
obj.TableView = matlab.internal.preprocessingApp.tabular.PreprocessingTableView( 'Parent', obj.GridLayout );
end 

obj.TableView.SelectionChangedFcn = @( s, v )obj.callVariableSelectionChangedFcn( s, v );
obj.TableView.DataChangedFcn = @( evt )obj.callDataChangedFcn( evt );
obj.Closable = true;
end 

function setSparklinesState( obj, ~, evt )
if isequal( evt.Value, false )

obj.TableView.SparkLinesVisible = 'off';
obj.SparklinesSwitch.Icon = fullfile( matlabroot, 'toolbox', 'matlab', 'datatools', 'preprocessing', '+matlab', '+internal', '+preprocessingApp', '+images', 'sparklineOFF.png' );
else 
obj.TableView.SparkLinesVisible = 'on';
obj.SparklinesSwitch.Icon = fullfile( matlabroot, 'toolbox', 'matlab', 'datatools', 'preprocessing', '+matlab', '+internal', '+preprocessingApp', '+images', 'sparklineON.png' );
end 
end 

function UserDataInteractionUpdateCallBack( this, d )
this.UserDataInteractionUpdate( d );
end 

function callVariableSelectionChangedFcn( obj, selection, selectedVariables )

selectedVariables = string( selectedVariables{ 1 } );

if ~isempty( obj.VariableSelectionChangedFcn )
try 
inputArgs = { obj, obj.VariableName, selectedVariables, selection };
numArgs = nargin( obj.VariableSelectionChangedFcn );
if numArgs > 0
obj.VariableSelectionChangedFcn( obj,  ...
struct( 'Columns', selectedVariables ) );
else 
obj.VariableSelectionChangedFcn(  );
end 
catch e
disp( e );
end 
end 
end 

function callDataChangedFcn( obj, evt )
if ~isempty( obj.DocumentDataChangedFcn )
try 
obj.DocumentDataChangedFcn( evt );
catch e
disp( e );
end 
end 
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmppJBBlL.p.
% Please follow local copyright laws when handling this file.

