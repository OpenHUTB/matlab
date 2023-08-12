classdef FigureToolstripManager



properties ( Constant )
DEFAULT_COLOR = "#FF0000";

UNDO_KEY = 'uitools_FigureToolManager';

FIGURE_ID_PROP = "MOLToolstripMggId";
end 

methods ( Static )

function channel = getChannel(  )
channel = '/figure/toolstrip/state';
end 

function channel = getGalleryChannel(  )
channel = '/figure/toolstrip/gallery/state';
end 

function channel = getContextChannel(  )
channel = '/figure/toolstrip/contexts';
end 

function channel = getFocusChannel(  )
channel = '/figure/toolstrip/focus';
end 

function publishToFigure( fig, channel, msg )
import matlab.graphics.internal.toolstrip.*;



if isprop( fig, FigureToolstripManager.FIGURE_ID_PROP )
channelID = get( fig, FigureToolstripManager.FIGURE_ID_PROP );
else 
channelID = [  ];
end 

if ~isempty( channelID )
msgChannel = [ channel, channelID ];

message.publish( msgChannel, msg );
end 
end 

function obj = isMATLABOnline(  )
import matlab.internal.lang.capability.Capability;

obj = ~Capability.isSupported( Capability.LocalClient );
end 

function features = getSupportedFeatures( ax )
service = matlab.plottools.service.MetadataService.getInstance(  );
adapter = service.getMetaDataAccessor( ax );

features = adapter.getSupportedFeatures(  );
end 

function updateGalleryState( tag, state )
import matlab.graphics.internal.toolstrip.*;

channel = FigureToolstripManager.getGalleryChannel(  );

msg = struct( 'name', tag, 'state', state );
message.publish( channel, msg );
end 

function updateToolstripState( hFig, curAx )
import matlab.graphics.internal.toolstrip.*;
import matlab.graphics.internal.*;

try 

if isempty( hFig )
return ;
end 


itemContainer = containers.Map;

if ~isempty( curAx ) && strcmpi( hFig.HandleVisibility, 'on' )
[ numCart, numGeo, numPolar, has3D ] = FigureToolstripManager.getAxesClassCountandType( hFig );

feature = FigureToolstripManager.getSupportedFeatures( curAx );

linesInAxes = findall( curAx, 'type', 'line', '-or', 'type', 'lineshape' );


lineWidth = '.5';

if numel( linesInAxes ) >= 1
lineWidth = get( linesInAxes( 1 ), 'LineWidth' );
end 

itemContainer( "tools.fitting" ) = feature.BasicFitting;
itemContainer( "tools.stats" ) = feature.DataStats && ( numCart + numGeo + numPolar ) == 1;
itemContainer( "link.linkData" ) = feature.DataLinking && ( numCart + numGeo + numPolar ) == 1;
itemContainer( "tools.cameratoolbar" ) = feature.CameraTools;

itemContainer( "annotations.xlabel" ) = feature.XLabel && numCart >= 1;
itemContainer( "annotations.ylabel" ) = feature.YLabel && numCart >= 1;
itemContainer( "annotations.zlabel" ) = feature.ZLabel || ( numCart >= 1 && has3D );
itemContainer( "annotations.title" ) = feature.Title;
itemContainer( "annotations.legend" ) = feature.Legend;
itemContainer( "annotations.removelegend" ) = feature.Legend;
itemContainer( "annotations.colorbar" ) = feature.Colorbar;
itemContainer( "annotations.removecolorbar" ) = feature.Colorbar;
itemContainer( "annotations.grid" ) = feature.Grid;
itemContainer( "annotations.xgrid" ) = feature.XGrid && numCart >= 1;
itemContainer( "annotations.ygrid" ) = feature.YGrid && numCart >= 1;
itemContainer( "annotations.zgrid" ) = feature.ZGrid || ( numCart >= 1 && has3D );
itemContainer( "annotations.removegrid" ) = feature.Grid;


itemContainer( "annotations.rgrid" ) = feature.RGrid || numPolar >= 1;
itemContainer( "annotations.thetagrid" ) = feature.ThetaGrid || numPolar >= 1;

itemContainer( "tools.colormapeditor" ) = true;
itemContainer( "annotations.textArrow" ) = true;
itemContainer( "annotations.arrow" ) = true;
itemContainer( "annotations.doublearrow" ) = true;
itemContainer( "annotations.line" ) = true;
itemContainer( "tools.linkedplot" ) = true;
itemContainer( "style.font" ) = struct( 'enabled', true, 'type', 'selectedItem', 'value', get( curAx, 'FontName' ), 'tooltip', get( curAx, 'FontName' ) );
itemContainer( "style.fontIncrease" ) = true;
itemContainer( "style.fontDecrease" ) = true;
itemContainer( "lineWidthLabel" ) = ~isempty( curAx ) && numel( linesInAxes ) >= 1;
itemContainer( "all.line.width" ) = struct( 'enabled', ~isempty( curAx ) && numel( linesInAxes ) >= 1, 'type', 'value', 'value', lineWidth );
itemContainer( "all.line.color" ) = ~isempty( curAx ) && numel( linesInAxes ) >= 1;
else 


itemContainer( "tools.fitting" ) = false;
itemContainer( "tools.stats" ) = false;
itemContainer( "link.linkData" ) = false;
itemContainer( "tools.cameratoolbar" ) = false;
itemContainer( "annotations.legend" ) = false;
itemContainer( "annotations.removelegend" ) = false;
itemContainer( "annotations.colorbar" ) = false;
itemContainer( "annotations.removecolorbar" ) = false;
itemContainer( "annotations.grid" ) = false;
itemContainer( "annotations.xgrid" ) = false;
itemContainer( "annotations.ygrid" ) = false;
itemContainer( "annotations.zgrid" ) = false;
itemContainer( "annotations.xlabel" ) = false;
itemContainer( "annotations.ylabel" ) = false;
itemContainer( "annotations.zlabel" ) = false;
itemContainer( "annotations.title" ) = false;
itemContainer( "annotations.removegrid" ) = false;
itemContainer( "annotations.textArrow" ) = true;
itemContainer( "annotations.arrow" ) = true;
itemContainer( "annotations.doublearrow" ) = true;
itemContainer( "annotations.line" ) = true;
itemContainer( "tools.linkedplot" ) = false;
itemContainer( "style.font" ) = struct( 'enabled', false, 'type', 'selectedItem', 'value', '' );
itemContainer( "style.fontIncrease" ) = false;
itemContainer( "style.fontDecrease" ) = false;
itemContainer( "lineWidthLabel" ) = false;
itemContainer( "all.line.width" ) = struct( 'enabled', false, 'type', 'value', 'value', 0 );
itemContainer( "all.line.color" ) = false;

itemContainer( "annotations.rgrid" ) = false;
itemContainer( "annotations.thetagrid" ) = false;
end 


itemContainer( "file.copyFigure" ) = ~FigureToolstripManager.isMATLABOnline(  );
itemContainer( "file.print" ) = ~FigureToolstripManager.isMATLABOnline(  );




if isempty( hFig.isCodeGenCheckboxSelected )
hFig.isCodeGenCheckboxSelected = ~FigureToolstripManager.isMATLABOnline(  );
end 

widgetEnabled = logical( FigureToolstripManager.isMATLABOnline(  ) );


itemContainer( "file.showCode" ) = struct( 'enabled', widgetEnabled,  ...
'type', 'selected', 'value', logical( hFig.isCodeGenCheckboxSelected ) );



itemContainer = FigureToolstripManager.updateToolstripQAB( itemContainer, hFig );


itemContainer = FigureToolstripManager.getCameraTabState( itemContainer, hFig );

modeManager = uigetmodemanager( hFig );

if ~isempty( modeManager ) && ~isempty( modeManager.CurrentMode ) &&  ...
strcmp( modeManager.CurrentMode.Name, 'Standard.EditPlot' )

isSelected = true;

hMode = modeManager.CurrentMode;

if ~isempty( hMode.ModeStateData ) && ~isempty( hMode.ModeStateData.CreateMode ) &&  ...
~isempty( hMode.ModeStateData.CreateMode.ModeStateData ) &&  ...
~isempty( hMode.ModeStateData.CreateMode.ModeStateData.ObjectName )



isSelected = false;
end 

if isSelected
itemContainer = FigureToolstripManager.getPlotEditTabState( itemContainer, hFig );
end 

itemContainer( "tools.plotEdit" ) = struct( 'enabled', true, 'type', 'selected', 'value', isSelected );
else 
itemContainer( "tools.plotEdit" ) = struct( 'enabled', true, 'type', 'selected', 'value', false );
end 


list = repmat( struct( 'name', '', 'value', '', 'enabled', '', 'type', '', 'tooltip', '' ), [ itemContainer.length, 1 ] );

itemContainerKeys = itemContainer.keys;

for i = 1:itemContainer.length
list( i ).name = itemContainerKeys{ i };
element = itemContainer( itemContainerKeys{ i } );


if ~isstruct( element )
list( i ).enabled = element;
else 
list( i ).enabled = element.enabled;
list( i ).type = element.type;
list( i ).value = element.value;

if isfield( element, 'tooltip' )
list( i ).tooltip = element.tooltip;
end 

end 
end 

FigureToolstripManager.publishToFigure( hFig,  ...
FigureToolstripManager.getChannel(  ),  ...
list );
catch 

end 
end 

function [ numCartesian, numGeo, numPolar, has3D ] = getAxesClassCountandType( hFig )
numGeo = numel( findall( hFig, '-isa', "matlab.graphics.axis.GeographicAxes" ) );
numPolar = numel( findall( hFig, '-isa', "matlab.graphics.axis.PolarAxes" ) );

baseAxes = findall( hFig, '-isa', "matlab.graphics.axis.Axes" );

numCartesian = numel( baseAxes );

has3D = ~isempty( baseAxes ) && any( ~is2D( baseAxes ) );
end 

function items = getPlotEditTabState( curItems, curFig )
import matlab.graphics.internal.toolstrip.*;

items = curItems;


selObj = findall( curFig, 'Selected', 'on' );

if ~isempty( selObj )

items( 'text.font' ) = FigureToolstripManager.getPropertyStruct( selObj, 'selectedItem', 'FontName', '' );
items( 'text.bold' ) = FigureToolstripManager.getPropertyStruct( selObj, 'selected', 'FontWeight', 'bold' );
items( 'text.italics' ) = FigureToolstripManager.getPropertyStruct( selObj, 'selected', 'FontAngle', 'italic' );
items( 'text.alignLeft' ) = FigureToolstripManager.getPropertyStruct( selObj, 'selected', 'HorizontalAlignment', 'left' );
items( 'text.alignCenter' ) = FigureToolstripManager.getPropertyStruct( selObj, 'selected', 'HorizontalAlignment', 'center' );
items( 'text.alignRight' ) = FigureToolstripManager.getPropertyStruct( selObj, 'selected', 'HorizontalAlignment', 'right' );
items( 'text.fontSize' ) = FigureToolstripManager.getPropertyStruct( selObj, 'value', 'FontSize', '' );

items( 'text.fontColor' ) = FigureToolstripManager.getColorPropertyStruct( selObj, 'FontColor' );

items( 'color.backgroundColor' ) = FigureToolstripManager.getColorPropertyStruct( selObj, 'BackgroundColor' );
items( 'color.edgeColor' ) = FigureToolstripManager.getColorPropertyStruct( selObj, 'EdgeColor' );

lineWidthStruct = FigureToolstripManager.getPropertyStruct( selObj, 'value', 'LineWidth', '' );
lineWidthStruct.enabled = ~isempty( selObj ) && all( isprop( selObj, 'LineWidth' ) );
items( 'line.width' ) = lineWidthStruct;
items( 'line.WidthLabel' ) = lineWidthStruct.enabled;
items( 'line.style' ) = ~isempty( selObj ) && all( isprop( selObj, 'LineStyle' ) );
items( 'line.marker' ) = ~isempty( selObj ) && all( isprop( selObj, 'Marker' ) );
end 
end 

function items = getCameraTabState( curItems, curFig )
items = curItems;

if isprop( curFig, 'CameraToolbarManager' )
curMode = curFig.CameraToolbarManager.mode;

items( 'orbit' ) = struct( 'enabled', true, 'type', 'selected', 'value', strcmpi( curMode, 'orbit' ) );
items( 'setmodeguipan' ) = struct( 'enabled', true, 'type', 'selected', 'value', strcmpi( curMode, 'pan' ) );
items( 'setmodeguidollyhv' ) = struct( 'enabled', true, 'type', 'selected', 'value', strcmpi( curMode, 'dollyhv' ) );
items( 'setmodeguidollyfb' ) = struct( 'enabled', true, 'type', 'selected', 'value', strcmpi( curMode, 'dollyfb' ) );
items( 'setmodeguizoom' ) = struct( 'enabled', true, 'type', 'selected', 'value', strcmpi( curMode, 'zoom' ) );
items( 'setmodeguiroll' ) = struct( 'enabled', true, 'type', 'selected', 'value', strcmpi( curMode, 'roll' ) );
items( "setcoordsysx" ) = true;
items( "setcoordsysy" ) = true;
items( "setcoordsysz" ) = true;
items( "setcoordsysnone" ) = true;
items( "orthographic" ) = true;
items( "perspective" ) = true;
items( "resetcameralight" ) = true;
end 
end 

function items = updateToolstripQAB( curItems, fig )
items = curItems;


key = matlab.graphics.internal.toolstrip.FigureToolstripManager.UNDO_KEY;


undoEnabled = false;
redoEnabled = false;

if isprop( fig, key )
undoRedoMgr = fig.( key );
if ~isempty( undoRedoMgr )
undocmd = undoRedoMgr.CommandManager.peekundo;
redocmd = undoRedoMgr.CommandManager.peekredo;
undoEnabled = isa( undocmd, 'matlab.uitools.internal.uiundo.FunctionCommand' ) && isvalid( undocmd );
redoEnabled = isa( redocmd, 'matlab.uitools.internal.uiundo.FunctionCommand' ) && isvalid( redocmd );
end 
end 

items( 'motw.embeddedfigures.redo1' ) = redoEnabled;
items( 'motw.embeddedfigures.undo1' ) = undoEnabled;
end 

function s = getPropertyStruct( selectedObj, returnType, property, newValue )

s = struct;


isValidProp = all( isprop( selectedObj, property ) );


s.enabled = ~isempty( selectedObj ) && isValidProp;


s.type = returnType;


s.value = '';


if isValidProp

testValue = get( selectedObj( 1 ), property );
allValues = get( selectedObj, property );

allSameValues = all( strcmpi( testValue, allValues ) );

if isempty( newValue )
if numel( selectedObj ) > 1 && allSameValues
s.value = testValue;
elseif numel( selectedObj ) == 1
s.value = get( selectedObj, property );
end 
else 


if numel( selectedObj ) > 1 && allSameValues
s.value = strcmpi( testValue, newValue );
else 
s.value = strcmpi( get( selectedObj, property ), newValue );
end 
end 
end 
end 

function s = getColorPropertyStruct( selectedObjs, property )
propName = '';


colorValue = matlab.graphics.internal.toolstrip.FigureToolstripManager.DEFAULT_COLOR;

if ~isempty( selectedObjs )

hasLines = any( isa( selectedObjs, 'matlab.graphics.chart.primitive.Line' ) ) ||  ...
any( isa( selectedObjs, 'matlab.graphics.shape.Line' ) ) ||  ...
any( isa( selectedObjs, 'matlab.graphics.shape.Arrow' ) ) ||  ...
any( isa( selectedObjs, 'matlab.graphics.shape.TextArrow' ) ) ||  ...
any( isa( selectedObjs, 'matlab.graphics.shape.DoubleEndArrow' ) );

hasColor = all( isprop( selectedObjs, 'Color' ) );

isColorbar = all( isa( selectedObjs, 'matlab.graphics.illustration.ColorBar' ) );

switch property
case 'FontColor'

hasFontColor = all( isprop( selectedObjs, 'FontColor' ) );
hasFontName = all( isprop( selectedObjs, 'FontName' ) );
hasTextColor = all( isprop( selectedObjs, 'TextColor' ) );

if hasFontColor && hasFontName
propName = 'FontColor';
elseif ~hasFontColor && hasFontName && hasTextColor
propName = 'TextColor';
elseif hasFontName &&  ...
all( isa( selectedObjs, 'matlab.graphics.primitive.Text' ) )
propName = 'Color';
end 
case 'BackgroundColor'

hasBackgroundColor = all( isprop( selectedObjs, 'BackgroundColor' ) );
hasFaceColor = all( isprop( selectedObjs, 'FaceColor' ) );
hasMarkerFaceColor = all( isprop( selectedObjs, 'MarkerFaceColor' ) );

if hasBackgroundColor
propName = 'BackgroundColor';
elseif ~hasBackgroundColor && hasFaceColor && ~hasLines
propName = 'FaceColor';
elseif ~hasBackgroundColor && hasMarkerFaceColor && ~hasLines
propName = 'MarkerFaceColor';
elseif ~hasLines && ~hasBackgroundColor && hasColor && ~isColorbar
propName = 'Color';
end 
case 'EdgeColor'

hasEdgeColor = all( isprop( selectedObjs, 'EdgeColor' ) );
hasMarkerEdgeColor = all( isprop( selectedObjs, 'MarkerEdgeColor' ) );

if hasEdgeColor
propName = 'EdgeColor';
elseif ~hasEdgeColor && hasMarkerEdgeColor && ~hasColor
propName = 'MarkerEdgeColor';
elseif ~hasEdgeColor && hasColor && hasLines
propName = 'Color';
end 
end 

if isprop( selectedObjs( 1 ), propName )

cVal = get( selectedObjs( 1 ), propName );

if isstring( cVal ) || ischar( cVal )
colorValue = cVal;
else 
if max( cVal( : ) ) <= 1
cVal = round( cVal * 255 );
else 
cVal = round( cVal );
end 

hex( :, 2:7 ) = reshape( sprintf( '%02X', cVal.' ), 6, [  ] ).';
hex( :, 1 ) = '#';

colorValue = hex;
end 
end 
end 


s = struct;


s.enabled = ~isempty( selectedObjs ) && ~isempty( propName );


s.type = 'selectedColor';


s.value = colorValue;
end 

function createMggId( id )
import matlab.graphics.internal.toolstrip.*;

f = get( groot, 'CurrentFigure' );
if isempty( f )
return 
end 

if ~isprop( f, FigureToolstripManager.FIGURE_ID_PROP )
pMOLToolstripMggId = addprop( f, FigureToolstripManager.FIGURE_ID_PROP );
pMOLToolstripMggId.Transient = true;
pMOLToolstripMggId.Hidden = true;
end 

f.MOLToolstripMggId = id;
end 

function start


gcfListener = currentFigureListener;
if isempty( gcfListener )
r = groot;
gcfListener = event.proplistener( r, r.findprop( 'CurrentFigure' ), 'PostSet',  ...
@( e, d )matlab.graphics.internal.toolstrip.FigureToolstripManager.updategcf );





matlab.graphics.internal.toolstrip.FigureToolstripManager.updategcf;


currentFigureListener( gcfListener );
end 
end 

function stop
gcfListener = currentFigureListener;
if ~isempty( gcfListener )
delete( gcfListener );


currentFigureListener( [  ] );
end 
end 

function updategcf
import matlab.graphics.internal.toolstrip.*;



f = get( groot, 'CurrentFigure' );
if isempty( f ) || ~FigureToolstripManager.isMOLSupportedFigure( f )
return 
end 


if ~isprop( f, 'MOLToolstripAxesListener' )
pMOLToolstripAxesListener = addprop( f, 'MOLToolstripAxesListener' );
pMOLToolstripAxesListener.Transient = true;
pMOLToolstripAxesListener.Hidden = true;

f.MOLToolstripAxesListener = event.proplistener( f, f.findprop( 'CurrentAxes' ), 'PostSet',  ...
@( e, d )FigureToolstripManager.coalescedCurrentAxesCallback( d.AffectedObject ) );
end 


factory = FigureToolstripActionFactory.getInstance(  );
isCodeGenEnabled = factory.isCodeGenEnabled(  );


if ~isprop( f, 'isCodeGenCheckboxSelected' )
em = addprop( f, 'isCodeGenCheckboxSelected' );
em.Hidden = true;
em.Transient = true;
em.SetObservable = true;
em.AbortSet = true;
end 
if ~isprop( f, 'SidePanelCodeGenInstance' )
em = addprop( f, 'SidePanelCodeGenInstance' );
em.Hidden = true;
em.Transient = true;
end 

if ~isprop( f, 'FigureCodeGenController' ) && isCodeGenEnabled
pMOLFigureCodeGenController = addprop( f, 'FigureCodeGenController' );
pMOLFigureCodeGenController.Transient = true;
pMOLFigureCodeGenController.Hidden = true;
f.FigureCodeGenController = matlab.graphics.internal.codegenwidget.controls.FigureCodeGenController( f );



if ~isprop( f, 'MOLToolstripShowCodeButtonStateListener' )
pMOLToolstripShowCodeButtonStateListener = addprop( f, 'MOLToolstripShowCodeButtonStateListener' );
pMOLToolstripShowCodeButtonStateListener.Transient = true;
pMOLToolstripShowCodeButtonStateListener.Hidden = true;
f.MOLToolstripShowCodeButtonStateListener = event.listener( f.FigureCodeGenController, 'CodeGenWidgetStateChanged',  ...
@( ~, ~ )matlab.graphics.internal.toolstrip.FigureToolstripManager.updategca( f ) );
end 
end 


if ~isprop( f, 'MOLToolstripPlotSelectionListener' )
pMOLToolstripPlotSelectionListener = addprop( f, 'MOLToolstripPlotSelectionListener' );
pMOLToolstripPlotSelectionListener.Transient = true;
pMOLToolstripPlotSelectionListener.Hidden = true;

plotmgr = matlab.graphics.annotation.internal.getplotmanager;

f.MOLToolstripPlotSelectionListener = event.listener( plotmgr, 'PlotSelectionChange',  ...
@( ~, ~ )localPlotSelectionChange );
end 


modeManager = uigetmodemanager( f );

if ~isempty( modeManager )
if ~isprop( f, 'MOLToolstripModeListener' )
pMOLToolstripModeListener = addprop( f, 'MOLToolstripModeListener' );
pMOLToolstripModeListener.Transient = true;
pMOLToolstripModeListener.Hidden = true;

f.MOLToolstripModeListener = event.proplistener( modeManager, modeManager.findprop( 'CurrentMode' ),  ...
'PostSet', @( mm, ed )localCurrentModeChange( ed.AffectedObject ) );
end 
end 



if ~isprop( f, 'MOLFigChildAddedListener' )
pMOLChildAddedListener = addprop( f, 'MOLFigChildAddedListener' );
pMOLChildAddedListener.Transient = true;
pMOLChildAddedListener.Hidden = true;
end 

if ~isprop( f, 'MOLFigChildRemovedListener' )
pMOLChildRemovedListener = addprop( f, 'MOLFigChildRemovedListener' );
pMOLChildRemovedListener.Transient = true;
pMOLChildRemovedListener.Hidden = true;
end 

if isempty( f.MOLFigChildAddedListener )
f.MOLFigChildAddedListener = event.listener( f, 'ChildAdded',  ...
@( e, d )FigureToolstripManager.coalescedCurrentAxesCallback( f ) );
end 

if isempty( f.MOLFigChildRemovedListener )
f.MOLFigChildRemovedListener = event.listener( f, 'ObjectChildRemoved',  ...
@( e, d )FigureToolstripManager.coalescedCurrentAxesCallback( f ) );
end 

FigureToolstripManager.coalescedCurrentAxesCallback( f );
end 

function coalescedCurrentAxesCallback( hFig )
cb = @( ~, ~ )matlab.graphics.internal.toolstrip.FigureToolstripManager.updategca( hFig );
matlab.graphics.internal.DrawnowCallbackThrottle.postCallback( cb );
end 


function updategca( hFig )



if ~isvalid( hFig ) || ( isprop( hFig, 'BeingDeleted' ) && strcmp( hFig.BeingDeleted, 'on' ) )
return 
end 
curAx = [  ];



if isprop( hFig, 'CurrentAxes' )
curAx = hFig.CurrentAxes;
end 


if ~isprop( hFig, 'MOLChildAddedListener' )
pMOLChildAddedListener = addprop( hFig, 'MOLChildAddedListener' );
pMOLChildAddedListener.Transient = true;
pMOLChildAddedListener.Hidden = true;
end 

if ~isprop( hFig, 'MOLChildRemovedListener' )
pMOLChildRemovedListener = addprop( hFig, 'MOLChildRemovedListener' );
pMOLChildRemovedListener.Transient = true;
pMOLChildRemovedListener.Hidden = true;
end 

if ~isprop( hFig, 'MOLDecorationContainerAddedListener' )
pMOLDecorationContainerAddedListener = addprop( hFig, 'MOLDecorationContainerAddedListener' );
pMOLDecorationContainerAddedListener.Transient = true;
pMOLDecorationContainerAddedListener.Hidden = true;
end 


if ~isempty( curAx )
hFig.MOLChildAddedListener = event.listener( curAx, 'ChildAdded',  ...
@( e, d )matlab.graphics.internal.toolstrip.FigureToolstripManager.coalescedCurrentAxesCallback( hFig ) );


if isprop( curAx, 'ChildContainer' ) && ~isempty( curAx.ChildContainer )
hFig.MOLChildRemovedListener = event.listener( curAx.ChildContainer, 'ObjectChildRemoved',  ...
@( e, d )matlab.graphics.internal.toolstrip.FigureToolstripManager.coalescedCurrentAxesCallback( hFig ) );
end 

if isprop( curAx, 'DecorationContainer' ) && ~isempty( curAx.DecorationContainer )
hFig.MOLDecorationContainerAddedListener = event.listener( curAx.DecorationContainer, 'ObjectChildAdded',  ...
@( e, d )matlab.graphics.internal.toolstrip.FigureToolstripManager.coalescedCurrentAxesCallback( hFig ) );
end 
else 
delete( hFig.MOLChildAddedListener );
if isprop( hFig, 'MOLChildRemovedListener' )
delete( hFig.MOLChildRemovedListener );
end 
end 


matlab.graphics.internal.toolstrip.FigureToolstripManager.updateToolstripState( hFig, curAx );




if ~isempty( hFig )
matlab.graphics.internal.FigureScreenReaderManager.updateFigureAriaLabel( hFig );
end 
end 

function state = isMOLSupportedFigure( f )



import matlab.graphics.internal.FigureScreenReaderManager;
state = false;
if isvalid( f ) && f.BeingDeleted == "off" && f.Visible == "on"
isEditorFigure = matlab.internal.editor.figure.FigureUtils.isEditorFigure( f );
if ~isEditorFigure
if FigureScreenReaderManager.isTesting
state = true;
else 
if isWebFigureType( f, 'EmbeddedMorphableFigure' )
state = true;
elseif ~isWebFigureType( f, 'UIFigure' )
state = true;
end 
end 
end 
end 
end 

function setFigureFocus( fig )
import matlab.graphics.internal.toolstrip.*;



if isprop( fig, FigureToolstripManager.FIGURE_ID_PROP )
channelID = get( fig, FigureToolstripManager.FIGURE_ID_PROP );
else 
channelID = [  ];
end 

if ~isempty( channelID )

FigureToolstripManager.publishToFigure( fig,  ...
FigureToolstripManager.getFocusChannel(  ),  ...
struct( 'eventType', 'FigureFocus',  ...
'FigureId', channelID ) );
end 
end 

function setContext( fig, tag, context, msg )
import matlab.graphics.internal.toolstrip.*;



if isprop( fig, FigureToolstripManager.FIGURE_ID_PROP )
channelID = get( fig, FigureToolstripManager.FIGURE_ID_PROP );
else 
channelID = [  ];
end 

if ~isempty( msg ) && ~isempty( channelID )

FigureToolstripManager.publishToFigure( fig,  ...
FigureToolstripManager.getContextChannel(  ),  ...
struct( 'eventType', 'ContextualToolstrip',  ...
'ToolstripTag', tag, 'ToolstripContextId', context,  ...
'FigureId', channelID,  ...
'Action', msg ) );
end 
end 

function dismissSelectors(  )
factory = matlab.graphics.internal.toolstrip.FigureToolstripActionFactory.getInstance(  );

factory.dismissSelectors(  );
end 

function toggleCallback( actionID, val )
factory = matlab.graphics.internal.toolstrip.FigureToolstripActionFactory.getInstance(  );

factory.executeAction( actionID, val );


matlab.graphics.internal.toolstrip.FigureToolstripManager.updategcf;
end 

function pushCallback( actionId )
factory = matlab.graphics.internal.toolstrip.FigureToolstripActionFactory.getInstance(  );

factory.executeAction( actionId );

matlab.graphics.internal.toolstrip.FigureToolstripManager.updateGalleryState(  ...
"motwToolstrip.figureToolstripToolsGallery.tools.gallery", "normal" );
end 

function listChangeCallback( actionId, value )
factory = matlab.graphics.internal.toolstrip.FigureToolstripActionFactory.getInstance(  );

factory.executeAction( actionId, value );

matlab.graphics.internal.toolstrip.FigureToolstripManager.updategcf;
end 

function textChangeCallback( actionId, value )
factory = matlab.graphics.internal.toolstrip.FigureToolstripActionFactory.getInstance(  );

factory.executeAction( actionId, value );

matlab.graphics.internal.toolstrip.FigureToolstripManager.updategcf;
end 

function [ list, listName ] = generateList( listName )
list = [  ];

switch lower( listName )
case { 'font', 'text.font' }
list = repmat( struct( 'label', '', 'value', '', 'selected', '' ), [ 0, 0 ] );
fonts = listfonts;

currentFont = get( groot, 'FixedWidthFontName' );

f = get( groot, 'CurrentFigure' );
if ~isempty( f ) && ~isempty( f.CurrentAxes )
currentFont = f.CurrentAxes.FontName;
end 

for i = 1:numel( fonts )
list( i ).label = fonts{ i };
list( i ).value = fonts{ i };

if strcmp( fonts{ i }, currentFont )
list( i ).selected = true;
else 
list( i ).selected = false;
end 
end 
end 
end 
end 
end 


function listener = currentFigureListener( listenertoadd )


persistent gcfListener;
mlock
if nargin >= 1
gcfListener = listenertoadd;
end 
listener = gcfListener;

end 

function localCurrentModeChange( modeManager )
if isempty( modeManager.CurrentMode )
currentMode = '';
else 
currentMode = modeManager.CurrentMode.Name;
end 

if ~strcmp( currentMode, 'Standard.EditPlot' )
msg = 'hide';
else 
msg = 'select';
end 

matlab.graphics.internal.toolstrip.FigureToolstripManager.setContext(  ...
modeManager.FigureHandle,  ...
'motwToolstrip.plotEditTabGroup', 'motwToolstrip.plotEditContext', msg );

end 

function localPlotSelectionChange(  )

matlab.graphics.internal.toolstrip.FigureToolstripManager.updategcf;
drawnow update;
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp1lC7Ty.p.
% Please follow local copyright laws when handling this file.

