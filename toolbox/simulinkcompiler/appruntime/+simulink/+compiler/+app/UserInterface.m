






























classdef UserInterface < handle
properties ( Access = private )
App
SimulationHelper
PlotsCaches = simulink.compiler.internal.PlotCache.empty(  );
end 

methods ( Access = { ?simulink.compiler.app.SimulationHelper, ?matlab.mock.classes.UserInterfaceMock } )
function obj = UserInterface( simulationHelper )










R36
simulationHelper( 1, 1 )simulink.compiler.app.SimulationHelper
end 

obj.App = simulationHelper.App;
obj.SimulationHelper = simulationHelper;
end 
end 

methods 

function refreshAxes( ~, uiAxes )
import simulink.compiler.internal.util.refreshAxes;
refreshAxes( uiAxes );
end 

function [ variable, error ] = guardedCellVariableUpdate( ~, updateEvent )




















import simulink.compiler.internal.util.guardedCellVariableUpdate;
[ variable, error ] = guardedCellVariableUpdate( updateEvent );
end 

function deselectAllTableRows( ~, uiTable )


















import simulink.compiler.internal.util.deselectAllTableRows;
deselectAllTableRows( uiTable );
end 

function clearGridAndLegend( ~, uiAxes )







import simulink.compiler.internal.util.clearGridAndLegend;
clearGridAndLegend( uiAxes );
end 

function reportError( obj, me )







R36
obj
me( 1, 1 )MException
end 

app = obj.App;
app.SimApp.Visible = 'on';
uialert( app.SimApp, me.getReport( 'basic', 'hyperlinks', 'off' ), 'Error' );
end 

function setStatusMessage( obj, msg )










binder = obj.SimulationHelper.Binder;
component = binder.getBoundComponent( 'StatusMessage' );

if isempty( component )
return ;
end 

hasTooltip = isprop( component, 'Tooltip' );
hasText = isprop( component, 'Text' );

indentedMsg = " " + join( msg );

if hasText
component.Text = indentedMsg;
end 

if hasTooltip
component.Tooltip = indentedMsg;
end 

if hasText || hasTooltip
drawnow;
end 
end 

function setName = getSelectedSetName( obj, bindable )





























R36
obj
bindable( 1, : ){ isCharStringOrEnum }
end 

import simulink.compiler.internal.util.transformBindableToConfigType;

setName = [  ];
bindable = transformBindableToConfigType( bindable );

if isempty( bindable )
return 
end 

binder = obj.SimulationHelper.Binder;
component = binder.getBoundComponent( bindable );

if isempty( component )
return 
end 

setName = component.Value;
notSpecifiedString =  ...
message( 'simulinkcompiler:genapp:NotSpecified' ).getString;

if strcmp( setName, notSpecifiedString )
setName = [  ];
end 
end 

function [ set, setName ] = getSelectedSet( obj, bindable )





























R36
obj
bindable( 1, : ){ isCharStringOrEnum }
end 

import simulink.compiler.internal.util.transformBindableToConfigType;

set = [  ];
bindable = transformBindableToConfigType( bindable );

if isempty( bindable )
setName = [  ];
return 
end 

setName = obj.getSelectedSetName( bindable );

if isempty( setName )
return 
end 

set = obj.SimulationHelper.Workspace.( bindable.Sets ).( setName );
end 

function plotExternalInputSignalAtIndex( obj, collectionComponent, itemIndex, uiAxes )












bindable = simulink.compiler.internal.AppConfigType.ExternalInput;
set = obj.getSelectedSet( bindable );

if isempty( set )
return 
end 

signals = obj.SimulationHelper.InputOutput.externalInputSignalsForCurrentSet(  );
ts = signals( itemIndex );
ts = ts{ 1 };
obj.plotLineForCollectionItem( collectionComponent, itemIndex, ts, uiAxes );
end 

function plotLoggedSignalAtIndex( obj, collectionComponent, itemIndex, uiAxes )












signals = obj.SimulationHelper.InputOutput.loggedSignals(  );

if isempty( signals )
return 
end 

ts = signals( itemIndex );
ts = ts{ 1 };
obj.plotLineForCollectionItem( collectionComponent, itemIndex, ts, uiAxes );
end 

function clearSignalAtIndex( obj, collectionComponent, itemIndex, uiAxes )












obj.hideLineForCollectionItem( collectionComponent, itemIndex, uiAxes );
end 

function plotSelectedExternalInputSignals( obj, collectionComponent, uiAxes )











bindable = simulink.compiler.internal.AppConfigType.ExternalInput;
set = obj.getSelectedSet( bindable );

if isempty( set )
return 
end 

signals = obj.SimulationHelper.InputOutput.externalInputSignalsForCurrentSet(  );

if isempty( signals )
return 
end 

signalNames = obj.SimulationHelper.InputOutput.externalInputSignalNamesForCurrentSet(  );
obj.plotLinesForSelectedItems( collectionComponent, signals, signalNames, uiAxes );
end 

function plotSelectedLoggedSignals( obj, collectionComponent, uiAxes )











signals = obj.SimulationHelper.InputOutput.loggedSignals(  );

if isempty( signals )
return 
end 

signalNames = obj.SimulationHelper.InputOutput.loggedSignalNames(  );
obj.plotLinesForSelectedItems( collectionComponent, signals, signalNames, uiAxes );
end 

function clearPlotLinesForSelectedSignals( obj, collectionComponent, uiAxes )












obj.clearPlotLinesForSelectedItems( collectionComponent, uiAxes );
end 

function signalsPlotted = anySignalsSelected( obj, collectionComponent, uiAxes )








signalsPlotted = false;

linesCache =  ...
obj.linesCacheForComponentPlotPair( collectionComponent, uiAxes );

if isempty( linesCache )
return 
end 

signalsPlotted = ~linesCache.isEmpty(  );
end 

function clearAllPlots( obj )

obj.clearAllPlotsCaches(  );
end 
end 

methods ( Access = private )

function plotLineForCollectionItem( obj, collectionComponent, itemIndex, ts, uiAxes )
import simulink.compiler.internal.util.plotTimeSeries;
import simulink.compiler.internal.PlotCache;
import simulink.compiler.internal.LinesCache;

plotCache = obj.getPlotCache( uiAxes );

if isempty( plotCache )
plotCache = PlotCache( uiAxes );
obj.addPlotCache( plotCache );
end 

linesCache = plotCache.getLinesCacheForComponent( collectionComponent );

if isempty( linesCache )
linesCache = LinesCache( collectionComponent );
plotCache.addLinesCache( linesCache );
end 

line = linesCache.getLineAt( itemIndex );


if isempty( line ) || ~isvalid( line )
line = plotTimeSeries( ts, uiAxes );
linesCache.addLine( line, itemIndex );
else 
linesCache.showLineAt( itemIndex );
end 

obj.updateLegend( uiAxes );
end 

function clearLineForCollectionItem( obj, collectionComponent, itemIndex, uiAxes )
linesCache =  ...
obj.linesCacheForComponentPlotPair( collectionComponent, uiAxes );

if isempty( linesCache )
return 
end 

linesCache.clearLineAt( itemIndex );
end 

function hideLineForCollectionItem( obj, collectionComponent, itemIndex, uiAxes )
linesCache =  ...
obj.linesCacheForComponentPlotPair( collectionComponent, uiAxes );

if isempty( linesCache )
return 
end 

linesCache.hideLineAt( itemIndex );
obj.updateLegend( uiAxes );
end 

function plotLinesForSelectedItems( obj, collectionComponent, linesArray, itemNames, uiAxes )
selected = obj.getSelectedItems( collectionComponent );
selBitVector = selected;

if iscell( selected )
[ ~, ~, itemIndices ] = intersect( selected, itemNames );
selBitVector = false( length( itemNames ), 1 );
selBitVector( itemIndices ) = true;
end 

numItems = length( selBitVector );

for itemIdx = 1:numItems
isItemSelected = selBitVector( itemIdx );

if isItemSelected
ts = linesArray{ itemIdx };
obj.plotLineForCollectionItem( collectionComponent, itemIdx, ts, uiAxes );
hold( uiAxes, 'on' );
else 
obj.hideLineForCollectionItem( collectionComponent, itemIdx, uiAxes );
end 
end 
end 

function clearPlotLinesForSelectedItems( obj, collectionComponent, uiAxes )
linesCache =  ...
obj.linesCacheForComponentPlotPair( collectionComponent, uiAxes );

if isempty( linesCache )
return 
end 

linesCache.clearAllLines(  );
end 

function linesCache = linesCacheForComponentPlotPair( obj, collectionComponent, uiAxes )
plotCache = obj.getPlotCache( uiAxes );

if isempty( plotCache )
linesCache = [  ];
return 
end 

linesCache = plotCache.getLinesCacheForComponent( collectionComponent );
end 

function nPlotted = plotSignals( ~, signals, uiAxes )
import simulink.compiler.internal.util.plotTimeSeries;

nPlotted = 0;

for sigIdx = 1:length( signals )
signal = signals{ sigIdx };
plotTimeSeries( signal, uiAxes );
nPlotted = nPlotted + 1;
end 
end 

function selected = getSelectedItems( obj, collectionComponent )
selected = [  ];

switch class( collectionComponent )
case 'matlab.ui.control.ListBox'
selected = collectionComponent.Value;
case 'matlab.ui.control.Table'
selected = collectionComponent.Data.selected;
otherwise 
obj.reportError( MException(  ...
'Simulink:Compiler:AppRuntime:UnableToExtractComponentValue',  ...
message( 'simulinkcompiler:genapp:UnableToExtractComponentValue' ) ) );
end 
end 

function addPlotCache( obj, plotCache )
cache = obj.getPlotCache( plotCache.UIAxes );

if ~isempty( cache )
return 
end 

obj.PlotsCaches( end  + 1 ) = plotCache;
end 

function plotCache = getPlotCache( obj, uiAxes )
plotCache = [  ];

for cache = obj.PlotsCaches
if isequal( cache.UIAxes, uiAxes )
plotCache = cache;
return 
end 
end 
end 

function clearAllPlotsCaches( obj )
for idx = 1:numel( obj.PlotsCaches )
obj.PlotsCaches( idx ).clearAllLinesCaches(  );
end 
end 

function updateLegend( obj, uiAxes )
import simulink.compiler.internal.util.clearGridAndLegend;

allHandles = [  ];
plotCache = obj.getPlotCache( uiAxes );
lineCaches = plotCache.getAllLinesCaches(  );

for linesCache = lineCaches
handlesIndexes = linesCache.activeHandles(  );

for idx = handlesIndexes
line = linesCache.getLineAt( idx );
if isempty( line ) || any( ~isvalid( line ) )
continue 
end 
allHandles = [ allHandles, reshape( line, [ 1, numel( line ) ] ) ];%#ok<AGROW>
end 
end 

if isempty( allHandles )
clearGridAndLegend( uiAxes );
else 
uiAxes.XGrid = 'on';
uiAxes.YGrid = 'on';
legend( uiAxes, allHandles );
end 
end 

end 
end 

function isValid = isCharStringOrEnum( toValidate )
isValid = ischar( toValidate ) || isstring( toValidate ) ||  ...
isa( toValidate, 'simulink.compiler.internal.AppConfigType' );

if ~isValid
error( message( 'simulinkcompiler:genapp:MustBeCharStringOrEnum', toValidate ) );
end 
end 








% Decoded using De-pcode utility v1.2 from file /tmp/tmpcowDFE.p.
% Please follow local copyright laws when handling this file.

