






classdef ( Sealed, ConstructOnLoad, UseClassDefaultsOnLoad )GeographicGlobe ...
 < matlab.graphics.primitive.world.Group ...
 & matlab.graphics.mixin.UIParentable ...
 & matlab.graphics.internal.GraphicsBaseFunctions

properties ( Access = public, Dependent, SetObservable, AbortSet, AffectsObject )








Basemap( 1, 1 )string = globe.internal.GlobeModel.defaultBasemap
end 

properties ( Access = public, Dependent, SetObservable, AbortSet, AffectsObject )












Terrain{ mustBeTerrain } = globe.internal.GlobeModel.defaultTerrainName
end 

properties ( Access = public, Dependent, SetObservable )





Position matlab.internal.datatype.matlab.graphics.datatype.Position







Units matlab.internal.datatype.matlab.graphics.datatype.Units























NextPlot matlab.internal.datatype.matlab.graphics.datatype.AxesNextPlot





ColorOrder matlab.internal.datatype.matlab.graphics.datatype.ColorOrder
end 



properties ( Hidden, Access = public, Dependent, SetObservable, AffectsObject )











CameraPosition matlab.internal.datatype.matlab.graphics.datatype.Point3 = globe.internal.GlobeOptions.DefaultCameraPosition
end 

properties ( Hidden, Access = public, SetObservable )














CameraPositionMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'auto'
end 

properties ( Hidden, Access = public, Dependent, SetObservable )
ColorSpace matlab.graphics.axis.colorspace.MapColorSpace
end 

properties ( SetAccess = public, GetAccess = ?tGeographicGlobe, Hidden )




GlobeOptions globe.internal.GlobeOptions = globe.internal.GlobeOptions
end 

properties ( SetAccess = private, Dependent )
NextSeriesIndex matlab.internal.datatype.matlab.graphics.datatype.PositiveIntegerWithZero
end 

properties ( Hidden, SetAccess = private, NonCopyable, Transient )






GlobeViewer globe.internal.GlobeViewer = globe.internal.GlobeViewer.empty
end 

properties ( Hidden, SetAccess = private, Dependent )





PositionInPixels
end 

properties ( Hidden )
BasemapMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'auto'
PositionMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'auto'
TerrainMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'auto'
UnitsMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'auto'
NextPlotMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'auto'
ColorSpaceMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'auto'
ColorOrderMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'auto'
ViewMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'auto'
end 

properties ( Access = private, Dependent, AbortSet, AffectsObject )

CameraOrientation matlab.internal.datatype.matlab.graphics.datatype.Point3 = globe.internal.GlobeOptions.DefaultCameraOrientation
CameraRoll( 1, 1 )double = 0
CameraPitch( 1, 1 )double =  - 90
CameraHeading( 1, 1 )double = 0
end 


properties ( Access = private )


Basemap_I( 1, 1 )string = globe.internal.GlobeModel.defaultBasemap
Terrain_I( 1, 1 )string = globe.internal.GlobeModel.defaultTerrainName
end 

properties ( Access = private, AffectsObject )


Position_I matlab.internal.datatype.matlab.graphics.datatype.Position = [ 0, 0, 1, 1 ]
Units_I matlab.internal.datatype.matlab.graphics.datatype.Units = 'normalized'
NextPlot_I matlab.internal.datatype.matlab.graphics.datatype.AxesNextPlot = 'replace'
ColorOrder_I matlab.internal.datatype.matlab.graphics.datatype.ColorOrder
NextSeriesIndex_I matlab.internal.datatype.matlab.graphics.datatype.PositiveIntegerWithZero = 1


NextSeriesIndexMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'auto'
end 

properties ( Access = private )

CameraPosition_I matlab.internal.datatype.matlab.graphics.datatype.Point3 = globe.internal.GlobeOptions.DefaultCameraPosition
end 

properties ( Access = private, AffectsObject, Transient )
ColorSpace_I matlab.graphics.axis.colorspace.MapColorSpace
end 

properties ( Access = private, Transient, NonCopyable, AffectsObject, AbortSet )


ViewRequiresUpdate( 1, 1 )logical = false
end 

properties ( Access = private, Transient, NonCopyable )

PostUpdateSource = [  ]
SourceObjectListener = [  ]
ParentListener = [  ]
CleanListener = [  ]


Initialized( 1, 1 )logical = false


CameraIsEnabled( 1, 1 )logical = true



MaxWidth( 1, 1 )double
MaxHeight( 1, 1 )double
end 

properties ( Access = ?tGeographicGlobeGraphics, Transient, NonCopyable )

HTMLController matlab.ui.control.HTML = matlab.ui.control.HTML.empty
CameraListeners = event.listener.empty
end 

properties ( Access = ?map.graphics.globe.Data, Dependent )

ChildGraphicsID uint64 = 0
end 

properties ( Access = private )


ParentHasChanged( 1, 1 )logical = false


ChildGraphicsID_I uint64 = 0


CameraOrientation_I = globe.internal.GlobeOptions.DefaultCameraOrientation
CameraOrientationMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'auto'

CameraRoll_I( 1, 1 )double = 0
CameraPitch_I( 1, 1 )double =  - 90
CameraHeading_I( 1, 1 )double = 0
end 

properties ( SetAccess = private, GetAccess = ?tGeographicGlobeGraphics, Dependent )

CameraRollMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'auto'
CameraPitchMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'auto'
CameraHeadingMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'auto'
CameraHeightMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'auto'
CameraPosition2DMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'auto'
end 

properties ( Access = private )

CameraRollMode_I matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'auto'
CameraPitchMode_I matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'auto'
CameraHeadingMode_I matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'auto'
CameraHeightMode_I matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'auto'
CameraPosition2DMode_I matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'auto'
end 

properties ( Access = private, Constant )
DefaultCameraPosition = globe.internal.GlobeOptions.DefaultCameraPosition
end 

methods 

function obj = GeographicGlobe( varargin )






obj.Type = 'globe';
obj.Basemap_I = globe.internal.GlobeModel.defaultBasemap;
obj.Terrain_I = globe.internal.GlobeModel.defaultTerrainName;
obj.ColorSpace_I = matlab.graphics.axis.colorspace.MapColorSpace;
obj.ColorOrder_I = obj.ColorSpace_I.ColorOrder;

obj.HTMLController = matlab.ui.control.HTML(  ...
'Internal', true,  ...
'Parent', [  ],  ...
'HTMLSource', '<html></html>',  ...
'Visible', 'off',  ...
'HandleVisibility', 'off' );



screenSize = get( groot, 'ScreenSize' );
factor = 2;
obj.MaxWidth = factor * screenSize( 3 );
obj.MaxHeight = factor * screenSize( 4 );



try 
matlab.graphics.chart.internal.ctorHelper( obj, varargin );












if strcmpi( obj.CameraPositionMode, 'auto' )
obj.CameraPosition_I = obj.GlobeOptions.CameraPosition;
end 

setupGlobeViewer( obj )
obj.Initialized = true;
catch e



delete( obj.HTMLController )
throwAsCaller( e )
end 


addDependencyConsumed( obj, { 'ref_frame' } );
end 


function reset( obj )









gv = obj.GlobeViewer;
html = obj.HTMLController;
position = obj.Position_I;
units = obj.Units_I;
opt = obj.GlobeOptions;





parentListener = obj.ParentListener;
cameraListener = obj.CameraListeners;


obj.reset@matlab.graphics.primitive.world.Group(  );




obj.GlobeOptions = opt;
obj.GlobeViewer = gv;
obj.HTMLController = html;
obj.Initialized = true;
obj.Units_I = units;
obj.Position_I = position;
obj.ParentListener = parentListener;
obj.CameraListeners = cameraListener;
end 


function varargout = geobasemap( obj, varargin )
















narginchk( 1, 2 )


classes = { 'globe.graphics.GeographicGlobe' };
matlab.graphics.internal.validateScalarArray( obj, classes, mfilename, 'gl' )


if nargin > 1

basemap = varargin{ 1 };
set( obj, 'Basemap', basemap );
end 


if nargout > 0 || nargin == 1

varargout{ 1 } = obj.Basemap;
end 
end 


function outRoll = camroll( obj, varargin )




































R36
obj( 1, 1 )
end 
R36( Repeating )
varargin
end 

narginchk( 1, 2 )
if nargin == 2
value = varargin{ 1 };
if ~istext( value )

roll = validateAngle( value );




obj.CameraRollMode_I = 'manual';
obj.CameraRoll = roll;
else 






mode = validateMode( value );
roll = obj.CameraRoll;
obj.CameraRollMode = mode;
end 
else 

roll = obj.CameraRoll;
end 

if nargout > 0 || nargin == 1


outRoll = roll;
end 
end 


function outPitch = campitch( obj, varargin )







































R36
obj( 1, 1 )
end 
R36( Repeating )
varargin
end 

narginchk( 1, 2 )
if nargin == 2
value = varargin{ 1 };
if ~istext( value )

angleRange = [  - 90, 90 ];
pitch = validateAngle( value, angleRange );




obj.CameraPitchMode_I = 'manual';
obj.CameraPitch = pitch;
else 






mode = validateMode( value );
pitch = obj.CameraPitch;
obj.CameraPitchMode = mode;
end 
else 

pitch = obj.CameraPitch;
end 

if nargout > 0 || nargin == 1


outPitch = pitch;
end 
end 


function outHeading = camheading( obj, varargin )


































R36
obj( 1, 1 )
end 
R36( Repeating )
varargin
end 

narginchk( 1, 2 )
if nargin == 2
value = varargin{ 1 };
if ~istext( value )

heading = validateAngle( value );




obj.CameraHeadingMode_I = 'manual';
obj.CameraHeading = heading;
else 






mode = validateMode( value );
heading = obj.CameraHeading;
obj.CameraHeadingMode = mode;
end 
else 

heading = obj.CameraHeading;
end 

if nargout > 0 || nargin == 1


outHeading = heading;
end 
end 

function varargout = campos( obj, varargin )





































R36
obj( 1, 1 )
end 
R36( Repeating )

varargin
end 

narginchk( 1, 4 )
switch nargin
case 1

pos = obj.CameraPosition;

case 2

mode = validateMode( varargin{ 1 } );
obj.CameraPositionMode = mode;
obj.CameraPosition2DMode = mode;
if nargout > 0
pos = obj.CameraPosition;
end 

case 3

[ lat, lon ] = validateLatLon( varargin{ : } );
pos = obj.CameraPosition;
pos( 1:2 ) = [ lat, lon ];
obj.CameraPosition = pos;
obj.CameraPosition2DMode_I = 'manual';

case 4

[ lat, lon, height ] = validateLatLonHeight( varargin{ : } );
pos = [ lat, lon, height ];
obj.CameraPosition = pos;
obj.CameraPosition2DMode_I = 'manual';
obj.CameraHeightMode_I = 'manual';
end 

if nargout > 0 || nargin == 1
if nargout > 0

varargout = cell( 1, nargout );
for k = 1:nargout
varargout{ k } = pos( k );
end 
else 



varargout{ 1 } = pos;
end 
end 
end 


function outHeight = camheight( obj, varargin )




































R36
obj( 1, 1 )
end 
R36( Repeating )
varargin
end 

narginchk( 1, 2 )
if nargin == 2
value = varargin{ 1 };
if ~istext( value )

height = validateHeight( value );
obj.CameraPosition( 3 ) = height;
obj.CameraHeightMode_I = 'manual';
else 


mode = validateMode( value );
obj.CameraPositionMode = mode;
obj.CameraHeightMode = mode;
if nargout > 0
pos = obj.CameraPosition;
height = pos( 3 );
end 
end 
else 

pos = obj.CameraPosition;
height = pos( 3 );
end 

if nargout > 0 || nargin == 1


outHeight = height;
end 
end 

function hold( obj, varargin )



















narginchk( 1, 2 );

matlab.graphics.internal.markFigure( obj );
fig = get( obj, 'Parent' );
if ~strcmp( get( fig, 'Type' ), 'figure' )
fig = ancestor( fig, 'figure' );
end 

if ~isempty( varargin )
opt_hold_state = varargin{ 1 };
end 

nexta = get( obj, 'NextPlot' );
nextf = get( fig, 'NextPlot' );
hold_state = strcmp( nexta, 'add' ) && strcmp( nextf, 'add' );

replace_state = 'replace';

nargs = length( varargin );
if ( nargs == 0 )
if ( hold_state )
set( obj, 'NextPlot', replace_state );
disp( getString( message( 'MATLAB:hold:CurrentPlotReleased' ) ) );
else 
set( fig, 'NextPlot', 'add' );
set( obj, 'NextPlot', 'add' );
disp( getString( message( 'MATLAB:hold:CurrentPlotHeld' ) ) );
end 

elseif ( strcmpi( opt_hold_state, 'on' ) )
set( fig, 'NextPlot', 'add' );
set( obj, 'NextPlot', 'add' );

elseif ( strcmpi( opt_hold_state, 'off' ) )
set( obj, 'NextPlot', replace_state );

elseif ( strcmpi( opt_hold_state, 'all' ) )
set( fig, 'NextPlot', 'add' );
set( obj, 'NextPlot', 'add' );
else 
error( message( 'MATLAB:hold:UnknownOption' ) );
end 
end 


function delete( obj )
if ~isempty( obj.GlobeViewer ) && isvalid( obj.GlobeViewer )
delete( obj.GlobeViewer )
end 

if ~isempty( obj.SourceObjectListener ) && isvalid( obj.SourceObjectListener )
delete( obj.SourceObjectListener )
end 

if ~isempty( obj.HTMLController ) && isvalid( obj.HTMLController )
delete( obj.HTMLController )
end 

if ~isempty( obj.ParentListener ) && isvalid( obj.ParentListener )
delete( obj.ParentListener )
end 

if ~isempty( obj.CleanListener ) && isvalid( obj.CleanListener )
delete( obj.CleanListener )
end 

deleteCameraListeners( obj );
end 


function set.Basemap( obj, basemap )









usingPicker = logical( obj.GlobeOptions.EnableBaseLayerPicker );
try 
if ~usingPicker
basemap = mustBeBasemap( basemap );
else 
basemap = validateBaseLayerPickerBasemap( obj, basemap );
end 
catch e
throwAsCaller( e )
end 
obj.Basemap_I = basemap;
obj.BasemapMode = 'manual';
end 


function basemap = get.Basemap( obj )
if logical( obj.GlobeOptions.EnableBaseLayerPicker ) ...
 && ~isempty( obj.GlobeViewer ) && isvalid( obj.GlobeViewer ) ...
 && ~obj.ParentHasChanged



basemap = char( obj.GlobeViewer.Basemap );
else 
basemap = char( obj.Basemap_I );
end 
end 


function set.Terrain( obj, terrain )
terrain = mustBeTerrain( terrain );
obj.Terrain_I = terrain;
obj.TerrainMode = 'manual';

end 


function terrain = get.Terrain( obj )
terrain = char( obj.Terrain_I );
end 


function set.Position( obj, value )
obj.Position_I = value;
obj.PositionMode = 'manual';
end 


function value = get.Position( obj )
value = double( obj.Position_I );
end 


function set.Units( obj, value )
pos = convertUnits( obj.Parent, obj.Units_I, obj.Position_I, value );
obj.Position_I = pos;
obj.Units_I = value;
obj.UnitsMode = 'manual';
end 


function value = get.Units( obj )
value = char( obj.Units_I );
end 


function pos = get.PositionInPixels( obj )


pos = convertUnits( obj.Parent_I, obj.Units_I, obj.Position_I );
pos( 3 ) = min( pos( 3 ), obj.MaxWidth );
pos( 3 ) = max( pos( 3 ), 0 );
pos( 4 ) = min( pos( 4 ), obj.MaxHeight );
pos( 4 ) = max( pos( 4 ), 0 );
end 


function set.NextPlot( obj, value )
obj.NextPlot_I = value;
obj.NextPlotMode = 'manual';
end 


function value = get.NextPlot( obj )
value = obj.NextPlot_I;
end 


function set.ColorOrder( obj, value )
if isempty( value )





id = 'MATLAB:hg:shaped_arrays:ColorOrderSize';
msg = message( 'MATLAB:ClassUstring:InvalidValue',  ...
'ColorOrder', 'GeographicGlobe', getString( message( id ) ) );
e = MException( 'MATLAB:hg:shaped_arrays:ColorOrderSize', msg );
throwAsCaller( e )
end 
obj.ColorOrder_I = value;
obj.ColorOrderMode = 'manual';
addDependencyProduced( obj, 'colororder_linestyleorder' )
end 


function value = get.ColorOrder( obj )
value = obj.ColorOrder_I;
end 


function set.ColorSpace( obj, cs )
obj.ColorSpace_I = cs;
colorOrder = obj.ColorOrder_I;




obj.ColorSpace_I.ColorOrder = colorOrder;
obj.ColorSpaceMode = 'manual';
end 


function value = get.ColorSpace( obj )
value = obj.ColorSpace_I;
end 


function value = get.NextSeriesIndex( obj )
value = obj.NextSeriesIndex_I;
obj.NextSeriesIndexMode = 'manual';
end 


function set.NextSeriesIndex( obj, value )
obj.NextSeriesIndex_I = value;
end 


function set.CameraPosition( obj, value )
obj.CameraPosition_I = value;
obj.CameraPositionMode = 'manual';
end 


function value = get.CameraPosition( obj )
forceFullUpdate( obj, 'all', 'CameraPosition' );








value = getCameraPosition( obj, obj.CameraPosition_I );
end 


function value = get.CameraPosition_I( obj )
if strcmp( obj.CameraPositionMode, 'auto' )
value = getCameraPosition( obj, obj.CameraPosition_I );
else 
value = obj.CameraPosition_I;
end 
end 

function set.CameraPosition2DMode( obj, mode )
obj.CameraPosition2DMode_I = mode;
if matches( mode, "manual" )

obj.CameraPosition_I = getCameraPosition( obj, obj.CameraPosition_I );
end 
end 


function mode = get.CameraPosition2DMode( obj )
mode = obj.CameraPosition2DMode_I;
end 


function set.CameraHeightMode( obj, mode )
obj.CameraHeightMode_I = mode;
if matches( mode, "manual" )


obj.CameraPosition_I = getCameraPosition( obj, obj.CameraPosition_I );
end 
end 


function mode = get.CameraHeightMode( obj )
mode = obj.CameraHeightMode_I;
end 


function set.CameraOrientation( obj, value )


obj.CameraOrientation_I = value;
obj.CameraOrientationMode = 'manual';
end 


function value = get.CameraOrientation( obj )


value = obj.CameraOrientation_I;
end 


function value = get.CameraOrientation_I( obj )
if strcmp( obj.CameraOrientationMode, 'auto' )
[ roll, pitch, heading ] = getCameraOrientation(  ...
obj, obj.CameraOrientation_I );
value = [ roll, pitch, heading ];
else 
value = obj.CameraOrientation_I;
end 
end 

function set.CameraRoll( obj, value )
obj.CameraRoll_I = value;
obj.CameraRollMode_I = 'manual';
end 


function roll = get.CameraRoll( obj )
if strcmp( obj.CameraRollMode_I, 'auto' )
obj.CameraRoll_I = getCameraOrientation( obj );
end 
roll = obj.CameraRoll_I;
end 


function set.CameraRollMode( obj, mode )
obj.CameraRollMode_I = mode;
if matches( mode, "manual" )

obj.CameraRoll_I = getCameraOrientation( obj );
end 
end 


function mode = get.CameraRollMode( obj )
mode = obj.CameraRollMode_I;
end 


function set.CameraPitch( obj, value )
obj.CameraPitch_I = value;
obj.CameraPitchMode_I = 'manual';
end 


function pitch = get.CameraPitch( obj )
if strcmp( obj.CameraPitchMode_I, 'auto' )
[ ~, obj.CameraPitch_I ] = getCameraOrientation( obj );
end 
pitch = obj.CameraPitch_I;
end 


function set.CameraPitchMode( obj, mode )
obj.CameraPitchMode_I = mode;
if matches( mode, "manual" )

[ ~, obj.CameraPitch_I ] = getCameraOrientation( obj );
end 
end 


function mode = get.CameraPitchMode( obj )
mode = obj.CameraPitchMode_I;
end 


function set.CameraHeading( obj, value )
obj.CameraHeading_I = value;
obj.CameraHeadingMode_I = 'manual';
end 


function heading = get.CameraHeading( obj )
if strcmp( obj.CameraHeadingMode_I, 'auto' )
[ ~, ~, obj.CameraHeading_I ] = getCameraOrientation( obj );
end 
heading = obj.CameraHeading_I;
end 


function set.CameraHeadingMode( obj, mode )
obj.CameraHeadingMode_I = mode;
if matches( mode, "manual" )

[ ~, ~, obj.CameraHeading_I ] = getCameraOrientation( obj );
end 
end 


function mode = get.CameraHeadingMode( obj )
mode = obj.CameraHeadingMode_I;
end 


function value = get.ChildGraphicsID( obj )
value = obj.ChildGraphicsID_I + 1;
obj.ChildGraphicsID_I = value;
end 
end 

methods ( Access = public, Hidden )
function resetplotview( obj, ~ )





if ~isempty( obj.Parent_I ) && isvalid( obj.Parent_I ) ...
 && ~isempty( obj.GlobeViewer ) && isvalid( obj.GlobeViewer )
updateViewExtent( obj )
end 
end 

function doUpdate( obj, ~ )








postUpdateSource = ancestor( obj, 'matlab.graphics.primitive.canvas.Canvas', 'node' );
if ~isequal( postUpdateSource, obj.PostUpdateSource ) || obj.ParentHasChanged



if ~isempty( obj.SourceObjectListener )
delete( obj.SourceObjectListener )
end 
obj.PostUpdateSource = postUpdateSource;
obj.SourceObjectListener = event.listener( postUpdateSource, 'PostUpdate',  ...
@( src, data )sourceObjectPostUpdateHandler( obj, src, data ) );
end 



updateGlobeViewerProperties( obj )


updateHTMLController( obj )
end 


function hParent = setParentImpl( obj, hParent )


if ~isempty( hParent )
parent = ancestor( hParent, 'figure' );
if ~matlab.ui.internal.isUIFigure( parent )
e = MException( message(  ...
'shared_globe:viewer:UnsupportedFunctionality' ) );
throwAsCaller( e )
end 



if isa( hParent, 'matlab.ui.container.GridLayout' )
e = MException( message(  ...
'MATLAB:HandleGraphics:UnsupportedComponentUsePanel',  ...
'GridLayout', 'GeographicGlobe' ) );
throwAsCaller( e )
end 








if isempty( obj.HTMLController.Parent )
obj.HTMLController.Parent = hParent;
end 



hParent = obj.setParentImpl@matlab.graphics.mixin.UIParentable( hParent );



obj.ParentHasChanged = true;
elseif ~isempty( obj.HTMLController ) && isvalid( obj.HTMLController )








updateCameraProperties( obj )

hParent = obj.setParentImpl@matlab.graphics.mixin.UIParentable( hParent );
obj.ParentHasChanged = true;
end 
end 

function objReturn = newplot( obj )










fig = ancestor( obj, 'figure' );

if ~isempty( fig )

fig = observeFigureNextPlot( fig, obj );


fig.NextPlot = 'add';
end 

observedObj = observeGeoglobeNextPlot( obj );

if strcmpi( obj.NextPlot, 'replace' )
obj.NextSeriesIndex = 1;
end 

if nargout
objReturn = observedObj;
end 
end 

function index = getNextSeriesIndex( obj )
index = obj.NextSeriesIndex;
obj.NextSeriesIndex = index + 1;
end 
end 

methods ( Access = ?map.graphics.globe.Data )
function updateViewExtent( obj )
latlim = [ 90,  - 90 ];
lonlim = [ inf,  - inf ];
children = obj.Children;

for k = 1:length( children )
child = children( k );
[ childLatlim, childLonlim ] = getDataExtent( child );

if ~isempty( childLatlim )
latlim( 1 ) = min( latlim( 1 ), childLatlim( 1 ) );
latlim( 2 ) = max( latlim( 2 ), childLatlim( 2 ) );
end 

if ~isempty( childLonlim )
lonlim( 1 ) = min( lonlim( 1 ), childLonlim( 1 ) );
lonlim( 2 ) = max( lonlim( 2 ), childLonlim( 2 ) );
end 
end 

if obj.CameraIsEnabled
if all( isfinite( latlim ) ) && all( isfinite( lonlim ) )


gv = obj.GlobeViewer;
if ~isempty( gv ) && isvalid( gv )
controller = gv.Controller;
camposIsAuto = strcmp( obj.CameraPosition2DMode_I, 'auto' );
camheightIsAuto = strcmp( obj.CameraHeightMode_I, 'auto' );

if ~isempty( controller ) && isvalid( controller ) ...
 && ( camposIsAuto || camheightIsAuto )




anyPositionModeIsManual =  ...
~camheightIsAuto || ~camposIsAuto;
if anyPositionModeIsManual

savepos = obj.CameraPosition_I;
end 








setViewRectangle( controller, latlim, lonlim )



orientationModes = [  ...
string( obj.CameraRollMode_I ),  ...
string( obj.CameraPitchMode_I ),  ...
string( obj.CameraHeadingMode_I ) ];
anyOrientationModeIsManual =  ...
any( matches( orientationModes, "manual" ) );
anyModeIsManual =  ...
anyPositionModeIsManual || anyOrientationModeIsManual;
if anyModeIsManual
pos = getCameraPosition( obj );
if strcmp( obj.CameraPosition2DMode_I, 'manual' )
pos( 1:2 ) = savepos( 1:2 );
end 

if strcmpi( obj.CameraHeightMode_I, 'manual' )
pos( 3 ) = savepos( 3 );
end 
obj.CameraPosition_I = pos;



mode = obj.CameraPositionMode;
obj.CameraPositionMode = 'manual';



updateCameraPropertiesOnGlobeViewer( obj )


obj.CameraPositionMode = mode;
end 
end 
end 
else 



setCameraDefaultPosition( obj );
end 
end 
end 
end 


methods ( Access = protected, Hidden )

function basemap = validateBaseLayerPickerBasemap( obj, basemap )















basemap = strrep( basemap, '-', '_' );
choices = globe.internal.GlobeModel.basemapchoices;
basemap = validatestring( basemap, choices, '', 'Basemap' );





gv = obj.GlobeViewer;
if ~isempty( gv ) && isvalid( gv )


gv.Basemap = basemap;



basemap = gv.Basemap;
end 
end 

function updateGlobeViewerProperties( obj )

gv = obj.GlobeViewer;
if ~isempty( gv ) && isvalid( gv )


updateBasemapPropertyOnGlobeViewer( obj, gv )



updateTerrainPropertyOnGlobeViewer( obj, gv )


updateCameraPropertiesOnGlobeViewer( obj )
end 
end 

function updateHTMLController( obj )





html = obj.HTMLController;
if ~isempty( html ) && isvalid( html ) && ~obj.ParentHasChanged
try 

set( html, 'Position', obj.PositionInPixels );
catch 
end 
set( html, 'Visible', obj.Visible_I );
end 
end 

function updateCameraProperties( obj )









if ~isempty( obj.HTMLController ) && isvalid( obj.HTMLController )
htmlParent = obj.HTMLController.Parent;
if ~isempty( htmlParent ) && isvalid( htmlParent )
obj.CameraPosition_I = getCameraPosition( obj );

[ roll, pitch, heading ] = getCameraOrientation( obj );
value = [ roll, pitch, heading ];
obj.CameraOrientation_I = value;
end 
end 
end 

function updateBasemapPropertyOnGlobeViewer( obj, gv )




if ~logical( obj.GlobeOptions.EnableBaseLayerPicker )



basemap = gv.Basemap;
if ~strcmpi( basemap, obj.Basemap_I )



gv.Basemap = obj.Basemap_I;
obj.Basemap_I = gv.Basemap;
end 
end 
end 

function updateTerrainPropertyOnGlobeViewer( obj, gv )




terrain = gv.Terrain;
if ~strcmp( terrain, obj.Terrain_I )



controller = gv.Controller;
obj.Terrain_I = updateTerrain( controller, obj.Terrain_I );
end 
end 

function updateCameraPropertiesOnGlobeViewer( obj )




heightMode = string( obj.CameraHeightMode_I );
position2DMode = string( obj.CameraPosition2DMode_I );
positionMode = string( obj.CameraPositionMode );

modes = [ heightMode, position2DMode, positionMode ];
updateCameraPosition = any( contains( modes, "manual" ) );

if updateCameraPosition
pos = getCameraPosition( obj );
pos_I = obj.CameraPosition_I;

if positionMode == "manual"
pos = pos_I;
end 

if heightMode == "manual"
pos( 3 ) = pos_I( 3 );
end 

if position2DMode == "manual"
pos( 1:2 ) = pos_I( 1:2 );
end 


pos = adjustCameraHeightToTerrain( obj, pos );
end 


rollMode = string( obj.CameraRollMode_I );
pitchMode = string( obj.CameraPitchMode_I );
headingMode = string( obj.CameraHeadingMode_I );

modes = [ rollMode, pitchMode, headingMode ];
updateCameraOrientation =  ...
strcmp( obj.CameraOrientationMode, 'manual' ) ||  ...
any( contains( modes, 'manual' ) );

if updateCameraOrientation
cameraOrientation = obj.CameraOrientation_I;

if rollMode == "manual"
cameraOrientation( 1 ) = obj.CameraRoll_I;
end 

if pitchMode == "manual"
cameraOrientation( 2 ) = obj.CameraPitch_I;
end 

if headingMode == "manual"
cameraOrientation( 3 ) = obj.CameraHeading_I;
end 
end 

if updateCameraPosition && updateCameraOrientation
setCamera( obj, pos, cameraOrientation )
elseif updateCameraPosition
setCameraPosition( obj, pos )
elseif updateCameraOrientation
setCameraOrientation( obj, cameraOrientation )
end 

setCameraListeners( obj, updateCameraPosition || updateCameraOrientation );
end 


function updateCameraModeProperties( obj )

obj.CameraPositionMode = 'auto';
obj.CameraOrientationMode = 'auto';
obj.CameraRollMode_I = 'auto';
obj.CameraPitchMode_I = 'auto';
obj.CameraHeadingMode_I = 'auto';
obj.CameraHeightMode_I = 'auto';
obj.CameraPosition2DMode_I = 'auto';


setCameraListeners( obj, false );
end 

function sourceObjectPostUpdateHandler( obj, ~, ~ )






gv = obj.GlobeViewer;
parent = obj.Parent_I;
if isscalar( parent ) && ishghandle( parent ) && obj.Initialized
if isempty( gv ) || ~isvalid( gv )









obj.Initialized = false;
setupGlobeViewer( obj )
obj.Initialized = true;

ch = obj.Children_I;
if ~isempty( ch )


















modes = string( { obj.CameraPositionMode, obj.CameraOrientationMode } );
defpos = globe.internal.GlobeOptions.DefaultCameraPosition;
defori = globe.internal.GlobeOptions.DefaultCameraOrientation;
obj.CameraIsEnabled =  ...
all( contains( modes, [ "auto", "auto" ] ) ) &&  ...
isequal( obj.CameraPosition_I, defpos ) &&  ...
isequal( obj.CameraOrientation_I, defori );







obj.CleanListener = event.listener( obj, 'MarkedClean',  ...
@( s, e )resetCameraIsEnabledPropertyHandler( obj ) );
updateChildrenHandler( obj )
end 

elseif ~isempty( gv ) && isvalid( gv ) && obj.ParentHasChanged

updateCameraProperties( obj )
reparentGlobeViewer( obj )
end 

elseif isempty( parent ) && ~isempty( obj.GlobeViewer ) && isvalid( obj.GlobeViewer )







obj.HTMLController.Parent = [  ];
delete( obj.GlobeViewer )
end 


obj.ParentHasChanged = false;
end 


function updateChildrenHandler( obj, ~, ~ )





ch = obj.Children_I;
if ~isempty( ch )


MarkDirty( obj, 'Children' )






forceFullUpdate( obj, 'all', 'Children' )
end 
end 


function setupGlobeViewer( obj, updateChildrenRequest )
parent = obj.Parent_I;
if ~isempty( parent )



initialCameraPosition = obj.CameraPosition_I;
initialCameraOrientation = obj.CameraOrientation_I;





set( obj.HTMLController,  ...
'Parent', parent,  ...
'Visible', 'off',  ...
'Position', obj.PositionInPixels );

try 


obj.GlobeViewer = globe.internal.GlobeViewer(  ...
'Parent', obj.HTMLController,  ...
'GlobeOptions', obj.GlobeOptions,  ...
'Basemap', obj.Basemap_I,  ...
'Terrain', obj.Terrain_I );
catch e
throwAsCaller( e )
end 


obj.Basemap_I = obj.GlobeViewer.Basemap;
obj.Terrain_I = obj.GlobeViewer.Terrain;


obj.HTMLController.Visible = obj.Visible_I;


obj.ParentHasChanged = false;










if ~isempty( obj.ParentListener ) && isvalid( obj.ParentListener )
delete( obj.ParentListener )
end 


containers = getParentContainers( parent );
if isempty( containers )
obj.ParentListener = event.proplistener.empty(  );
else 
parentProp = findprop( containers( 1 ), 'Parent' );
obj.ParentListener = event.proplistener( containers, parentProp,  ...
'PreSet', @( src, e )reparentGlobeViewerRequest( obj ) );
end 


deleteCameraListeners( obj );
obj.CameraListeners( 1 ) = addlistener( obj.GlobeViewer,  ...
'LeftMouseUp', @( ~, ~ )updateCameraModeProperties( obj ) );
obj.CameraListeners( 2 ) = addlistener( obj.GlobeViewer,  ...
'RightMouseUp', @( ~, ~ )updateCameraModeProperties( obj ) );
obj.CameraListeners( 3 ) = addlistener( obj.GlobeViewer,  ...
'MouseWheel', @( ~, ~ )updateCameraModeProperties( obj ) );
setCameraListeners( obj, false );



setCameraPosition( obj, initialCameraPosition );
setCameraOrientation( obj, initialCameraOrientation );


updateCameraPropertiesOnGlobeViewer( obj )

if ~isempty( obj.Children ) && nargin > 1 && updateChildrenRequest

MarkDirty( obj, 'Children' )
end 

addDependencyProduced( obj, 'dataspace' )
end 
end 


function reparentGlobeViewer( obj, varargin )











if obj.ParentHasChanged

obj.HTMLController.Parent = [  ];
obj.HTMLController.HTMLSource = '<html></html>';



delete( obj.GlobeViewer );
updateChildrenRequest = true;
setupGlobeViewer( obj, updateChildrenRequest )
end 
end 

function reparentGlobeViewerRequest( obj )









updateCameraProperties( obj )
obj.HTMLController.Parent = [  ];
obj.HTMLController.HTMLSource = '';
obj.ParentHasChanged = true;
end 

function resetCameraIsEnabledPropertyHandler( obj )

obj.CameraIsEnabled = true;
obj.CleanListener = [  ];
end 

function obj = observeGeoglobeNextPlot( obj )


switch obj.NextPlot
case 'replaceall'

clo( obj )
reset( obj )

case 'replace'
clo( obj )


basemap = obj.Basemap_I;
terrain = obj.Terrain_I;


reset( obj )

if ~matches( obj.Basemap_I, basemap )





obj.Basemap = basemap;
end 

if ~matches( obj.Terrain_I, terrain )





obj.Terrain = terrain;
end 


case 'replacechildren'
clo( obj )
obj.NextSeriesIndex_I = 1;

case 'add'

end 
end 

function groups = getPropertyGroups( obj )%#ok<MANU>
groups = matlab.mixin.util.PropertyGroup(  ...
[ "Basemap";"Terrain";"Position";"Units" ] );
end 
end 

methods ( Access = private )
function setCameraDefaultPosition( obj )
cameraPosition = obj.GlobeOptions.CameraPosition;
setCameraPosition( obj, cameraPosition );
obj.CameraPosition_I = cameraPosition;
end 

function setCameraPosition( obj, cameraPosition )
gv = obj.GlobeViewer;
if ~isempty( gv ) && isvalid( gv )
controller = gv.Controller;
if ~isempty( controller ) && isvalid( controller )
args.CameraPosition = cameraPosition;
setCameraPosition( controller, args )
end 
end 
end 

function cameraPosition = getCameraPosition( obj, defaultCameraPosition )
if nargin == 1
defaultCameraPosition = obj.GlobeOptions.CameraPosition;
end 
cameraPosition = defaultCameraPosition;

gv = obj.GlobeViewer;
if ~isempty( gv ) && isvalid( gv )
controller = gv.Controller;
if ~isempty( controller ) && isvalid( controller )
position = getCameraPosition( controller );
if isstruct( position )
cameraPosition = [ position.latitude, position.longitude, position.height ];
else 
cameraPosition = position;
end 
end 
end 
end 

function setCameraOrientation( obj, value )
gv = obj.GlobeViewer;
if ~isempty( gv ) && isvalid( gv )
controller = gv.Controller;
if ~isempty( controller ) && isvalid( controller )
roll = value( 1 );
pitch = value( 2 );
heading = value( 3 );
args.CameraOrientation.Roll = deg2rad( roll );
args.CameraOrientation.Pitch = deg2rad( pitch );
args.CameraOrientation.Heading = deg2rad( heading );
setCameraOrientation( controller, args )
end 
end 
end 

function setCamera( obj, position, orientation )
gv = obj.GlobeViewer;
if ~isempty( gv ) && isvalid( gv )
controller = gv.Controller;
if ~isempty( controller ) && isvalid( controller )
args.CameraPosition = position;
roll = orientation( 1 );
pitch = orientation( 2 );
heading = orientation( 3 );
args.CameraOrientation.Roll = deg2rad( roll );
args.CameraOrientation.Pitch = deg2rad( pitch );
args.CameraOrientation.Heading = deg2rad( heading );
setCamera( controller, args )
end 
end 
end 


function [ roll, pitch, heading ] = getCameraOrientation( obj, cameraOrientation )
if nargin == 1
cameraOrientation = globe.internal.GlobeOptions.DefaultCameraOrientation;
end 
roll = cameraOrientation( 1 );
pitch = cameraOrientation( 2 );
heading = cameraOrientation( 3 );

gv = obj.GlobeViewer;
if ~isempty( gv ) && isvalid( gv )
controller = gv.Controller;
if ~isempty( controller ) && isvalid( controller )
orientation = getCameraOrientation( controller );
if isstruct( orientation )
roll = orientation.roll;
pitch = orientation.pitch;
heading = orientation.heading;
else 
roll = orientation( 1 );
pitch = orientation( 2 );
heading = orientation( 3 );
end 
end 
end 
end 

function pos = adjustCameraHeightToTerrain( obj, pos )









minimumHeightAboveTerrain = 1.0;

gv = obj.GlobeViewer;
if isempty( gv ) || strcmp( obj.Terrain, 'none' )


minimumCameraHeight = minimumHeightAboveTerrain;
else 

model = gv.Controller.GlobeModel;
terrainHeight = queryTerrainHeightReferencedToEllipsoid(  ...
model, pos( 1 ), pos( 2 ) );





minimumCameraHeight = terrainHeight + minimumHeightAboveTerrain;
end 
if pos( 3 ) < minimumCameraHeight
pos( 3 ) = minimumCameraHeight;
end 
end 

function setCameraListeners( obj, enabled )
for k = 1:numel( obj.CameraListeners )
obj.CameraListeners( k ).Enabled = enabled;
end 
end 

function deleteCameraListeners( obj )
for k = 1:numel( obj.CameraListeners )
if ~isempty( obj.CameraListeners( k ) ) && isvalid( obj.CameraListeners( k ) )
delete( obj.CameraListeners( k ) );
end 
end 
end 

end 
end 


function toPosition = convertUnits( parent, fromUnits, fromPosition, toUnits )
viewport = matlab.graphics.general.UnitPosition;
viewport.ScreenResolution = get( groot, 'ScreenPixelsPerInch' );
viewport.RefFrame = parent.Position;
viewport.Units = fromUnits;
viewport.Position = fromPosition;
if nargin == 3
toUnits = 'pixels';
end 
viewport.Units = toUnits;
toPosition = viewport.Position;
end 


function fig = observeFigureNextPlot( fig, obj )



switch fig.NextPlot
case 'new'


case 'replace'
clf( fig, obj );

case 'replacechildren'
clf( fig, obj );

case 'add'

end 
end 

function basemap = mustBeBasemap( basemap )


choices = matlab.graphics.chart.internal.maps.basemapNames;
if istext( basemap ) && ~any( ismissing( basemap ) ) && ~isempty( which( basemap + "_configuration.xml" ) )
choices = [ choices;basemap ];
end 
basemap = validatestring( basemap, choices, '', 'Basemap' );
end 


function terrainName = mustBeTerrain( terrainName )
terrainName = validatestring( terrainName, terrain.internal.TerrainSource.terrainchoices );
end 


function containers = getParentContainers( parent )

containers = matlab.ui.control.Component.empty(  );
while isscalar( parent ) && ~isgraphics( parent, 'figure' )
if isa( parent, 'matlab.ui.control.Component' )
if any( parent == containers )
break 
end 
containers( end  + 1 ) = parent;%#ok<AGROW>
end 
parent = parent.NodeParent;
end 
end 






function angle = mustBeAngle( angleRange, angle )





R36
angleRange( 1, 2 )%#ok<INUSA>
angle( 1, 1 ){ mustBeBetween( angle, angleRange ) }
end 
end 


function mode = mustBeMode( ~, mode )
R36
~
mode( 1, 1 )string{ partialModeMatch }
end 
end 


function mustBeBetween( value, minMaxValues )
minval = minMaxValues( 1 );
maxval = minMaxValues( 2 );
mustBeNumeric( value )
mustBeFinite( value )
mustBeGreaterThanOrEqual( value, minval )
mustBeLessThanOrEqual( value, maxval )
end 


function [ lat, lon ] = mustBeLatLon( ~, lat, lon )
R36
~
lat( 1, 1 ){ mustBeLatitude( lat ) }
lon( 1, 1 ){ mustBeLongitude( lon ) }
end 
end 


function [ lat, lon, height ] = mustBeLatLonHeight( ~, lat, lon, height )
R36
~
lat( 1, 1 ){ mustBeLatitude }
lon( 1, 1 ){ mustBeLongitude }
height( 1, 1 ){ mustBeReal, mustBeFinite, mustBeNumeric }
end 
end 


function mustBeLatitude( lat )
mustBeNumeric( lat )
mustBeFinite( lat )
mustBeGreaterThanOrEqual( lat,  - 90 )
mustBeLessThanOrEqual( lat, 90 )
end 


function mustBeLongitude( lon )
mustBeNumeric( lon )
mustBeFinite( lon )
mustBeGreaterThanOrEqual( lon,  - 360 )
mustBeLessThanOrEqual( lon, 360 )
end 


function height = mustBeHeight( ~, height )
R36
~
height( 1, 1 ){ mustBeReal, mustBeFinite, mustBeNumeric }
end 
end 


function mode = partialModeMatch( mode )



modes = [ "auto";"manual" ];
index = startsWith( modes, mode, 'IgnoreCase', true );
mode = modes( index );
if isempty( mode )



value = "nomatch";
mustBeMember( value, [ "auto", "manual" ] )
end 
end 






function mode = validateMode( mode )
try 
dummyFirstArg = [  ];
mustBeMode( dummyFirstArg, mode );
mode = partialModeMatch( mode );
catch e
throwAsCaller( e )
end 
end 

function angle = validateAngle( angle, angleRange )
try 
if nargin == 1
angleRange = [  - 360, 360 ];
end 
angle = mustBeAngle( angleRange, angle );
catch e
throwAsCaller( e )
end 
end 

function height = validateHeight( height )
try 
dummyFirstArg = [  ];
height = mustBeHeight( dummyFirstArg, height );
catch e
throwAsCaller( e )
end 
end 

function [ lat, lon ] = validateLatLon( lat, lon )
try 
dummyFirstArg = [  ];
[ lat, lon ] = mustBeLatLon( dummyFirstArg, lat, lon );
catch e
throwAsCaller( e )
end 
end 


function [ lat, lon, height ] = validateLatLonHeight( lat, lon, height )
try 
dummyFirstArg = [  ];
[ lat, lon, height ] = mustBeLatLonHeight( dummyFirstArg, lat, lon, height );
catch e
throwAsCaller( e )
end 
end 

function tf = istext( value )
tf = ischar( value ) || isstring( value ) || iscellstr( value );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpBe9jKw.p.
% Please follow local copyright laws when handling this file.

