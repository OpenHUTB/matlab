classdef View < matlab.mixin.SetGet & handle





properties ( Constant = true )


DocumentOptions = struct( 'Closable', false,  ...
'Visible', false );


FigureOptions = struct( 'NumberTitle', 'off',  ...
'HandleVisibility', 'off',  ...
'IntegerHandle', 'off',  ...
'Visible', 'off',  ...
'DeleteFcn', @( src, evt )obj.Model.CloseController.deleteApp( src, evt ) );
end 

properties ( Access = protected )
FigureHandleCell
end 

properties 

Model

TabGroup
thisToolstrip



AppContainer



PropertyPanel
PropertyFigure

StatusBar
StatusLabel
ProgressBar

PanelToFigureRatio = 0.3;
isControlDisabled = false;
end 

properties ( SetObservable )

CanBeClosed = false;
end 

properties ( Dependent )

CurrentSelectedFigure
IsDesignFieldEmpty
end 

properties ( Access = private )
pCurrentSelectedFigure
end 

methods 

function obj = View( varargin )



end 


function set.CurrentSelectedFigure( obj, newFigure )
obj.pCurrentSelectedFigure = newFigure;
end 

function rtn = get.CurrentSelectedFigure( obj )
docs = getDocuments( obj.AppContainer );
rtn = docs{ cell2mat( cellfun( @( x )x.Selected, docs, 'UniformOutput', false ) ) };
end 

function rtn = get.IsDesignFieldEmpty( obj )
if isempty( obj.DesignFrequencyEditField.Value )
rtn = true;
else 
rtn = false;
end 
end 

function setFigure( obj, figureCell )



p = inputParser;
validTypes = @( x )isa( x, 'matlab.ui.Figure' ) ||  ...
isa( x, 'matlab.ui.internal.FigureDocument' ) || iscell( x );
p.addRequired( 'figureCell', validTypes );
parse( p, figureCell );
obj.FigureHandleCell = p.Results.figureCell;
end 

function rtn = getFigure( obj, varargin )









p = inputParser;
p.addOptional( 'Name', 'All', @( x )ischar( x ) || isstring( x ) );
parse( p, varargin{ : } );

figureCell = obj.FigureHandleCell;
switch p.Results.Name
case 'All'
rtn = figureCell;
case 'Visible'
rtn = figureCell{ cell2mat( cellfun( @( x )x.Visible, figureCell,  ...
'UniformOutput', false ) ) };
case 'Analysis'
[ i, ~, ~ ] = find( strcmpi( obj.Model.PlotList, 'analysis' ) );
supportedPlots = obj.Model.PlotList( i, 5 );
rtn = {  };
rtn = figureCell( cell2mat( cellfun( @( x )any( strcmp( supportedPlots, x.Title ) ), figureCell,  ...
'UniformOutput', false ) ) );
otherwise 
[ i, ~, ~ ] = find( strcmpi( obj.Model.PlotList, p.Results.Name ) );
i = i( 1 );
displayName = obj.Model.PlotList{ i, 5 };
rtn = figureCell( cell2mat( cellfun( @( x )strcmp( x.Title, displayName ), figureCell,  ...
'UniformOutput', false ) ) );
end 
if numel( rtn ) == 1
rtn = rtn{ end  };
end 
end 


function disableControl( obj )
disableAll( obj.TabGroup );
obj.isControlDisabled = true;
end 

function enableControl( obj )
enableAll( obj.TabGroup );
obj.isControlDisabled = false;

enable( obj.thisToolstrip );
end 

function rtn = getIsControlDisabled( obj )
rtn = obj.isControlDisabled;
end 


function setStatusBarMsg( obj, message )


obj.StatusLabel.Text = message;
end 

function initStatusBar( obj )



import matlab.ui.internal.toolstrip.*

obj.StatusBar = matlab.ui.internal.statusbar.StatusBar(  );
obj.StatusBar.Tag = "statusBar";
obj.StatusLabel = matlab.ui.internal.statusbar.StatusLabel(  );
obj.StatusLabel.Tag = "statusLabel";
obj.StatusLabel.Text = "";
obj.StatusLabel.Description = getString( message( "rfpcb:transmissionlinedesigner:StatusBarDescription" ) );
obj.ProgressBar = matlab.ui.internal.statusbar.StatusProgressBar(  );
obj.ProgressBar.Tag = 'progressBar';
obj.ProgressBar.Region = 'right';
obj.AppContainer.add( obj.ProgressBar );
obj.StatusBar.add( obj.StatusLabel );
obj.AppContainer.add( obj.StatusBar );


ProgressBarContext = matlab.ui.container.internal.appcontainer.ContextDefinition(  );
ProgressBarContext.Tag = 'progressBarContext';
ProgressBarContext.StatusComponentTags = 'progressBar';
obj.AppContainer.Contexts = { ProgressBarContext };
end 


function updateDocuments( obj, tabName, varargin )
p = inputParser;
p.addRequired( 'tabName', @ischar );
p.addParameter( 'Type', 'Normal', @ischar );
parse( p, tabName, varargin{ : } );
switch p.Results.tabName
case 'NewTab'

case 'DesignerTab'
switch p.Results.Type
case 'Normal'
obj.Model.IsDesignerOccupied = true;
case 'AppLoading'
end 
end 

refreshPlots( obj, p.Results.tabName, 'Type', p.Results.Type );

updateLayout( obj, p.Results.tabName, 'Type', p.Results.Type );
end 


function rtn = noOfFigures( obj, varargin )








p = inputParser;
validOptions = @( x )validatestring( x, { 'on', 'off' },  ...
'noOFFigures', 'Visible' );
p.addOptional( 'Visible', 'off', @( x )~isempty( validOptions( x ) ) );
parse( p, varargin{ : } );

switch p.Results.Visible
case 'on'
allFigures = getFigure( obj );
rtn = length( find( cellfun( @( x )x.Visible, allFigures,  ...
'UniformOutput', false ) ) );
otherwise 
rtn = length( getFigure( obj ) );
end 
end 

function addFigure2app( obj, figHandle, DisableClose )










R36
obj
figHandle
DisableClose = true;
end 
if ~strcmp( figHandle.Tag, 'propertyFigure' )

obj.FigureHandleCell{ end  + 1 } = figHandle;
end 

if ~isa( figHandle, 'matlab.ui.internal.FigurePanel' ) &&  ...
~strcmpi( figHandle.Tag, 'canvasFigure' )
figHandle.Closable = ~DisableClose;
add( obj.AppContainer, figHandle );
elseif isa( figHandle, 'matlab.ui.internal.FigurePanel' )
addPanel( obj.AppContainer, obj.PropertyPanel );
end 
end 


function deleteFigure( ~, figHandle )



if iscell( figHandle )


cellfun( @( x )deleteThis( x ), figHandle, 'UniformOutput', false );
figHandle = {  };
else 

deleteThis( figHandle )
figHandle = [  ];
end 
function deleteThis( thisfigHandle )
if ~isempty( thisfigHandle )
if isa( thisfigHandle, 'matlab.ui.Figure' )
if isvalid( thisfigHandle )
thisfigHandle.DeleteFcn = '';
delete( thisfigHandle );
end 
end 
end 
end 
end 

function produceToolbarComponents( ~, figHandle )


figDoc = figHandle;
figHandle = figHandle.Figure;

axesHandle = findall( figHandle, 'Type', 'Axes' );
if ~isempty( axesHandle )
axtoolbar( axesHandle,  ...
{ 'datacursor', 'zoomin',  ...
'zoomout', 'restoreview' } );
else 

figDoc.Visible = false;
end 
end 


function sync( obj, varargin )















p = inputParser;
p.addOptional( 'Type', 'matlab.internal.yield', @ischar );
p.addParameter( 'Item', [  ] );
parse( p, varargin{ : } );
switch p.Results.Type
case 'matlab.internal.yield'

matlab.internal.yield;
case 'update'
drawnow update;
case 'waitfor'
waitfor( p.Results.Item );
case 'App'
waitfor( obj.AppContainer, 'State', matlab.ui.container.internal.appcontainer.AppState.RUNNING );
end 
matlab.internal.yield
end 

end 

methods ( Access = protected )

function setFrameSize( obj )

screenSize = get( groot, 'Screensize' );
obj.AppContainer.WindowBounds = [ 0.1 * screenSize( 3 ),  ...
0.1 * screenSize( 4 ),  ...
0.8 * screenSize( 3 ),  ...
0.85 * screenSize( 4 ) ];
end 


function [ figHandle, DisableClose ] = validateAddingFigure( ~, varargin )




parserObject = inputParser;
validFigure = @( x )isa( x, 'matlab.ui.Figure' ) ||  ...
isa( x, 'matlab.ui.internal.FigureDocument' ) || ischar( x );
parserObject.addOptional( 'figHandle', 'All', validFigure );
parserObject.addParameter( 'DisableClose', true, @( x )islogical( x ) );
parserObject.parse( varargin{ : } );
figHandle = parserObject.Results.figHandle;
DisableClose = parserObject.Results.DisableClose;
end 

end 
end 














% Decoded using De-pcode utility v1.2 from file /tmp/tmpx47lhq.p.
% Please follow local copyright laws when handling this file.

