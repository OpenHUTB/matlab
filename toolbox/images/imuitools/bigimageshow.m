



classdef ( Sealed, ConstructOnLoad )bigimageshow < matlab.graphics.primitive.Data & matlab.graphics.mixin.AxesParentable

properties ( Hidden )




CurrentCoalescePeriod = 0;
RequiredCoalescePeriod = 0.2;



DisplayTileManager images.bigdata.internal.DisplayTileManager



FullImageExtentsX
FullImageExtentsY


SpatialReferencing
SpatialReferencing_Alpha
end 

properties ( Transient, GetAccess = public, SetAccess = protected, NonCopyable )
Type matlab.internal.datatype.matlab.graphics.datatype.TypeName = 'bigimageshow';
end 

properties ( AffectsObject, NeverAmbiguous )









ResolutionLevelMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'auto';
end 


properties ( Dependent, AffectsObject )








ResolutionLevel


CData










AlphaData

































CDataMapping


















































AlphaDataMapping
end 

properties ( Dependent, AffectsObject )









Interpolation
end 


properties ( Hidden, AffectsObject, Access = private )
ResolutionLevel_I = [  ]
CData_I = blockedImage.empty(  )
CDataMapping_I = 'direct'
AlphaData_I
AlphaDataMapping_I = 'none'
GrayscaleTiles_I = false;
end 


properties ( Hidden, Dependent )



GrayscaleTiles
end 


properties ( Access = private, Transient, Hidden, NonCopyable )



CoalesceTimer timer


CancelEventTimeStamp


MaskQuads matlab.graphics.primitive.Patch
MaskBlockSize = [ 0, 0 ]
MaskApplyLevel



PreviousUpdateStateInfo



PrintSettingsCache


ChannelInds = 1
end 


properties ( Dependent )








GridLevel
end 



properties ( Hidden, AffectsObject, Access = private )
GridLevel_I = [  ]
end 


properties ( AffectsObject )




GridAlpha matlab.internal.datatype.matlab.graphics.datatype.ZeroToOne = 0.8;



GridLineWidth matlab.internal.datatype.matlab.graphics.datatype.Positive = 1









GridLineStyle matlab.internal.datatype.matlab.graphics.datatype.LineStyle = '-'




GridColor matlab.internal.datatype.matlab.graphics.datatype.RGBAColor = [ 0, 0, 1 ]







GridVisible( 1, 1 )matlab.lang.OnOffSwitchState = 'off'
end 

properties ( AffectsObject, NeverAmbiguous )








GridLevelMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'auto'
end 


properties ( Transient, Hidden, NonCopyable, Access = private )

GridLines matlab.graphics.primitive.world.LineStrip
end 



methods 
function obj = bigimageshow( varargin )

args = {  };
cax = [  ];
if ~isempty( varargin )

[ cax, args ] = axescheck( varargin{ : } );



validateattributes( args{ 1 }, { 'bigimage', 'blockedImage', 'char', 'string' },  ...
{ 'nonempty' }, mfilename );


if numel( args ) >= 1 && ( isa( args{ 1 }, 'blockedImage' ) || isa( args{ 1 }, 'bigimage' ) )
args = [ { 'CData' }, args( : )' ];
end 
end 

obj.DisplayTileManager = images.bigdata.internal.DisplayTileManager(  );


obj.CurrentCoalescePeriod = 0;


info = opengl( 'data' );
if ispc && info.Software == 1

obj.DisplayTileManager.Interpolation = 'nearest';
else 
obj.DisplayTileManager.Interpolation = 'linear';
end 



if ~isempty( args )
set( obj, args{ : } );
end 


if nargin > 0 && ( isempty( cax ) || ishghandle( cax, 'axes' ) )
cax = newplot( cax );
parax = cax;
switch cax.NextPlot
case { 'replaceall', 'replace' }
parax.YDir = 'reverse';
parax.DataAspectRatio = [ 1, 1, 1 ];
axis( parax, 'tight' );
case 'replacechildren'
parax.YDir = 'reverse';
end 
else 
parax = cax;
end 
obj.Parent = parax;



if ~isempty( args )
set( obj, args{ : } );
end 



addNode( obj, obj.DisplayTileManager.BackgroundTile );


addDependencyConsumed( obj, { 'xyzdatalimits', 'dataspace',  ...
'figurecolormap', 'colorspace',  ...
'ref_frame', 'view', 'resolution', 'renderer' } );


behaviorProp = findprop( obj, 'Behavior' );
if isempty( behaviorProp )
behaviorProp = addprop( obj, 'Behavior' );
behaviorProp.Hidden = true;
behaviorProp.Transient = true;
end 
hBehavior = hggetbehavior( obj, 'print' );
hBehavior.PrePrintCallback = @( obj, callbackName )printEvent( obj, callbackName );
hBehavior.PostPrintCallback = @( obj, callbackName )printEvent( obj, callbackName );

if nargout == 0

clear obj
end 
end 

function delete( obj )
if isvalid( obj )
obj.cancelPendingIO(  );
end 
if isscalar( obj.CoalesceTimer ) && isvalid( obj.CoalesceTimer )
stop( obj.CoalesceTimer )
delete( obj.CoalesceTimer );
end 
end 

function showmask( obj, mask, varargin )

narginchk( 2, 9 );

validateattributes( mask, { 'blockedImage', 'bigimage' }, { 'scalar' },  ...
'showmask', 'mask' );



resLevel = obj.ResolutionLevel;%#ok<NASGU>


parser = inputParser;
parser.addOptional( 'ApplyLevel', getFinestLevel( obj.CData ),  ...
@( l )validateattributes( l, { 'numeric' },  ...
{ 'positive', 'scalar', 'integer', '<=', numel( obj.SpatialReferencing ) },  ...
mfilename, 'applyLevel' ) );
parser.addParameter( 'BlockSize', [  ],  ...
@( bs )validateattributes( bs, { 'numeric' },  ...
{ 'positive', 'integer', 'numel', 2 }, mfilename, 'BlockSize' ) );
parser.addParameter( 'InclusionThreshold', 0.5,  ...
@( in )validateattributes( in,  ...
{ 'numeric' }, { 'scalar', 'real', '>=', 0, '<=', 1 } ) );
parser.addParameter( 'Alpha', 0.3,  ...
@( a )validateattributes( a, { 'numeric' },  ...
{ 'scalar', '<=', 1, '>=', 0 }, 'showmask', 'Alpha' ) );

parser.parse( varargin{ : } );
inputs = parser.Results;
if any( strcmp( parser.UsingDefaults, 'BlockSize' ) )
inputs.BlockSize = getBlockSize( obj.CData, inputs.ApplyLevel );
end 

onFaceColor = 'g';
offFaceColor = 'r';

if isequal( obj.MaskBlockSize, inputs.BlockSize ) ...
 && isequal( obj.MaskApplyLevel, inputs.ApplyLevel )


for hPatch = obj.MaskQuads
if hPatch.UserData.pct > 0 ...
 && hPatch.UserData.pct >= inputs.InclusionThreshold
hPatch.FaceColor = onFaceColor;
else 
hPatch.FaceColor = offFaceColor;
end 


hPatch.Visible = 'on';
hPatch.FaceAlpha = inputs.Alpha;
drawnow limitrate
end 

else 

delete( obj.MaskQuads );
obj.MaskBlockSize = inputs.BlockSize;
obj.MaskApplyLevel = inputs.ApplyLevel;

imRef = obj.SpatialReferencing( obj.MaskApplyLevel );


[ r, c ] = imRef.intrinsicToWorldAlgo( obj.MaskBlockSize( 2 ), obj.MaskBlockSize( 1 ) );
blockSizeInWorld = [ r, c ];




xStart = imRef.XWorldLimits( 1 ) + imRef.PixelExtentInWorldX / 2;
yStart = imRef.YWorldLimits( 1 ) + imRef.PixelExtentInWorldY / 2;
xEnd = imRef.XWorldLimits( 2 ) - imRef.PixelExtentInWorldX / 2;
yEnd = imRef.YWorldLimits( 2 ) - imRef.PixelExtentInWorldY / 2;

xLoc = xStart:blockSizeInWorld( 1 ):imRef.XWorldLimits( 2 );
yLoc = yStart:blockSizeInWorld( 2 ):imRef.YWorldLimits( 2 );


if xLoc( end  ) ~= xEnd
xLoc( end  + 1 ) = xEnd;
end 
if yLoc( end  ) ~= yEnd
yLoc( end  + 1 ) = yEnd;
end 

obj.MaskQuads = matlab.graphics.primitive.Patch.empty(  );

for yInd = 1:numel( yLoc ) - 1
for xInd = 1:numel( xLoc ) - 1
px = [ xLoc( xInd ), xLoc( xInd + 1 ), xLoc( xInd + 1 ), xLoc( xInd ) ];
py = [ yLoc( yInd ), yLoc( yInd ), yLoc( yInd + 1 ), yLoc( yInd + 1 ) ];


maskStartWorld = [ xLoc( xInd ), yLoc( yInd ) ];
maskEndWorld = [ xLoc( xInd + 1 ), yLoc( yInd + 1 ) ];


pct = computeWorldRegionNNZ( mask, getFinestLevel( mask ),  ...
maskStartWorld, maskEndWorld );

if pct > 0 && pct >= inputs.InclusionThreshold
faceColor = onFaceColor;
else 
faceColor = offFaceColor;
end 

hPatch = patch( px, py, faceColor,  ...
'Parent', obj.Parent', 'FaceAlpha', inputs.Alpha,  ...
'EdgeColor', 'none',  ...
'HitTest', 'off', 'HandleVisibility', 'off',  ...
'PickableParts', 'none', 'Visible', 'on' );
hPatch.UserData.pct = pct;
obj.MaskQuads( end  + 1 ) = hPatch;
drawnow limitrate
end 
end 
end 

end 

function hidemask( obj )
[ obj.MaskQuads.Visible ] = deal( 'off' );
end 

function showlabels( obj, blabels, params )
R36
obj( 1, 1 )bigimageshow
blabels
params.AlphaData( 1, 1 ) = 1
params.Alphamap( 1, : ){ mustBeInRange( params.Alphamap, 0, 1 ) } = 0.5
params.Colormap = 'jet'
end 


if ~isempty( blabels ) && ismatrix( blabels ) && ( isnumeric( blabels ) || islogical( blabels ) )


blabels = blockedImage( blabels,  ...
'WorldStart', obj.CData.WorldStart( 1, 1:2 ),  ...
'WorldEnd', obj.CData.WorldEnd( 1, 1:2 ) );
else 
validateattributes( blabels, { 'blockedImage' },  ...
{ 'scalar' }, mfilename, 'blabels' );
end 


if isfield( params, 'Colormap' )
images.internal.LabelColormapHelper.validateColormap( params.Colormap );
end 
params.Colormap = images.internal.LabelColormapHelper.normalizeColormap( params.Colormap );


if isa( params.AlphaData, 'blockedImage' )
validateattributes( params.AlphaData, { 'blockedImage' },  ...
{ 'scalar' }, mfilename, 'AlphaData' );
else 
validateattributes( params.AlphaData, { 'numeric', 'logical' },  ...
{ 'scalar', 'finite', 'real' }, mfilename, 'AlphaData' );
end 

obj.hidelabels(  );

hAxes = obj.Parent;


hLabelAxes = axes( 'HitTest', 'off',  ...
'HandleVisibility', "off",  ...
'Parent', hAxes.Parent,  ...
'Units', hAxes.Units );

resizeLabelAxes( hAxes, hLabelAxes );

bigimageshow( blabels, 'Parent', hLabelAxes,  ...
"Interpolation", "nearest",  ...
"AlphaData", params.AlphaData,  ...
"AlphaDataMapping", "direct" );

hLabelAxes.Visible = 'off';

numColors = size( params.Colormap, 1 );
if numColors > 1
hLabelAxes.CLim = [ 0, numColors - 1 ];
end 
colormap( hLabelAxes, params.Colormap );
hLabelAxes.Alphamap = params.Alphamap;


linkaxes( [ obj.Parent, hLabelAxes ] );
addlistener( hAxes, 'MarkedClean', @( ~, ~ )resizeLabelAxes( hAxes, hLabelAxes ) );


addlistener( hAxes, 'Cla', @( ~, ~ )delete( hLabelAxes ) );
addlistener( hAxes, 'ObjectBeingDestroyed', @( ~, ~ )delete( hLabelAxes ) );




set( ancestor( obj, 'Figure' ), 'CurrentAxes', hAxes );

key = 'showLabelLinkedAxes';
setappdata( obj, key, hLabelAxes );

function resizeLabelAxes( hAxes, hLabelAxes )
if isvalid( hLabelAxes ) && (  ...
~isequal( hLabelAxes.Layout, hAxes.Layout ) ||  ...
~isequal( hLabelAxes.Units, hAxes.Units ) ||  ...
~isequal( hLabelAxes.InnerPosition, hAxes.InnerPosition ) )
hLabelAxes.Layout = hAxes.Layout;
if isempty( hAxes.Layout )
hLabelAxes.Units = hAxes.Units;
hLabelAxes.InnerPosition = hAxes.InnerPosition;
hLabelAxes.Parent = hAxes.Parent;
end 
end 
end 
end 

function hidelabels( obj )

key = 'showLabelLinkedAxes';
if isappdata( obj, key )
delete( getappdata( obj, key ) );
end 
end 
end 


methods 


function set.ResolutionLevel( obj, res )
obj.ResolutionLevel_I = obj.resolveResolutionLevelString( res );
obj.ResolutionLevelMode = 'manual';
end 

function res = get.ResolutionLevel( obj )
if strcmp( obj.ResolutionLevelMode, 'auto' )

forceFullUpdate( obj, 'all', 'ResolutionLevel' );
end 
res = obj.ResolutionLevel_I;
end 


function set.CData( obj, bigim )
validateattributes( bigim, { 'blockedImage', 'bigimage' },  ...
{ 'nonempty' }, mfilename, 'CData' );

if numel( bigim ) > 1
error( message( 'images:bigimage:expectedScalar' ) );
end 

isGray = true;
if isa( bigim, 'bigimage' )


if bigim.Channels == 2
warning( message( 'images:bigimage:notGray' ) );
end 
if bigim.Channels > 3
warning( message( 'images:bigimage:notRGB' ) );
end 
obj.ChannelInds = 1;
if bigim.Channels >= 3
isGray = false;
obj.ChannelInds = [ 1, 2, 3 ];
end 
obj.SpatialReferencing = bigim.SpatialReferencing;
else 
isGray = bigim.NumDimensions == 2;


isRGBOrGrayScale = bigim.NumDimensions == 3 && ( all( bigim.Size( :, 3 ) == 3 | bigim.Size( :, 3 ) == 1 ) );
isSupportedType = ~isequal( bigim.ClassUnderlying( 1 ), 'struct' );

if ~isSupportedType || ~( isGray || isRGBOrGrayScale )
error( message( 'images:blockedImage:onlyGrayOrRGBblockedImage' ) )
end 

obj.SpatialReferencing = getSpatialReferencingObject( bigim );
end 

obj.CData_I = bigim;



obj.FullImageExtentsX = [ 
min( [ obj.SpatialReferencing.XWorldLimits ] ),  ...
max( [ obj.SpatialReferencing.XWorldLimits ] ) ];
obj.FullImageExtentsY = [ 
min( [ obj.SpatialReferencing.YWorldLimits ] ),  ...
max( [ obj.SpatialReferencing.YWorldLimits ] ) ];

obj.DisplayTileManager.reset(  );



obj.DisplayTileManager.TileSize = obj.CData_I.BlockSize( 1, 1:2 );



hAxes = ancestor( obj, 'Axes' );
if ~( strcmp( bigim.ClassUnderlying( 1 ), 'uint8' ) || strcmp( bigim.ClassUnderlying( 1 ), 'categorical' ) )
obj.CDataMapping = 'scaled';
hAxes.CLim = getrangefromclass( zeros( 1, bigim.ClassUnderlying( 1 ) ) );
else 
obj.CDataMapping = 'direct';
end 


if strcmp( bigim.ClassUnderlying( 1 ), 'categorical' )
if isa( bigim, 'bigimage' )

hAxes.Colormap = parula( numel( bigim.Classes ) + 1 );
else 
hAxes.Colormap = parula( numel( categories( bigim.InitialValue ) ) + 1 );
end 
elseif isGray
hAxes.Colormap = gray( 256 );
end 


if strcmp( bigim.ClassUnderlying( 1 ), 'logical' ) ||  ...
strcmp( bigim.ClassUnderlying( 1 ), 'categorical' )
obj.Interpolation = 'nearest';
end 

obj.checkAndCreateOverViewIfNeeded( obj.CData );
end 

function bigim = get.CData( obj )
bigim = obj.CData_I;
end 


function set.CDataMapping( obj, str )
obj.CDataMapping_I = validatestring( str,  ...
{ 'direct', 'scaled' }, mfilename, 'CDataMapping' );
obj.DisplayTileManager.reset(  );
end 

function str = get.CDataMapping( obj )
str = obj.CDataMapping_I;
end 


function set.Interpolation( obj, interpString )
info = opengl( 'data' );
if ispc && info.Software == 1

validStrings = { 'nearest' };
else 
validStrings = { 'nearest', 'linear' };
end 
interpString = validatestring( interpString,  ...
validStrings, mfilename, 'Interpolation' );

if ~isempty( obj.CData ) && strcmp( obj.CData.ClassUnderlying( 1 ), 'categorical' )
if strcmp( interpString, 'linear' )
error( message( 'images:bigimage:unsupportedInterpolation' ) );
end 
end 

obj.DisplayTileManager.Interpolation = interpString;
obj.DisplayTileManager.reset(  );
end 
function interpString = get.Interpolation( obj )
interpString = obj.DisplayTileManager.Interpolation;
end 


function set.AlphaData( obj, bimAlpha )
if isempty( bimAlpha )

bimAlpha = bigimage.empty(  );

elseif isa( bimAlpha, 'blockedImage' ) || isa( bimAlpha, 'bigimage' )

if isa( bimAlpha, 'blockedImage' )
notSingleChannel = bimAlpha.NumDimensions > 2;
obj.SpatialReferencing_Alpha = getSpatialReferencingObject( bimAlpha );
else 
notSingleChannel = bimAlpha.Channels ~= 1;
obj.SpatialReferencing_Alpha = bimAlpha.SpatialReferencing;
end 
if ~isempty( bimAlpha ) && notSingleChannel
error( message( 'images:bigimage:singleChannelAlpha' ) );
end 

else 

validateattributes( bimAlpha, { 'numeric', 'logical' },  ...
{ 'scalar', 'finite' }, mfilename, 'AlphaData' );
end 
obj.AlphaData_I = bimAlpha;
if isa( bimAlpha, 'bigimage' ) && ~isempty( bimAlpha )
obj.checkAndCreateOverViewIfNeeded( obj.AlphaData_I );
end 
obj.DisplayTileManager.reset(  );
end 

function bimAlpha = get.AlphaData( obj )
bimAlpha = obj.AlphaData_I;
end 


function set.AlphaDataMapping( obj, str )
obj.AlphaDataMapping_I = validatestring( str,  ...
{ 'none', 'direct', 'scaled' }, mfilename, 'AlphaDataMapping' );
obj.DisplayTileManager.reset(  );
end 

function str = get.AlphaDataMapping( obj )
str = obj.AlphaDataMapping_I;
end 


function set.GridLevel( obj, res )
obj.GridLevel_I = obj.resolveResolutionLevelString( res );
obj.GridLevelMode = 'manual';
end 

function res = get.GridLevel( obj )
if strcmp( obj.GridLevelMode, 'auto' )

forceFullUpdate( obj, 'all', 'GridLevel' );
end 
res = obj.GridLevel_I;
end 


function set.GrayscaleTiles( obj, tf )
obj.GrayscaleTiles_I = tf;
obj.DisplayTileManager.forceGrayScaleRendering( obj.GrayscaleTiles_I );
end 

function tf = get.GrayscaleTiles( obj )
tf = obj.GrayscaleTiles_I;
end 


function set.GridAlpha( obj, alpha )
validateattributes( alpha, { 'numeric', 'logical' },  ...
{ 'scalar', '>=', 0, '<=', 1, 'real' }, mfilename, 'GridAlpha' );
obj.GridAlpha = alpha;
end 
end 



methods ( Access = protected, Hidden )
function groups = getPropertyGroups( obj )

props = { 'CData', 'CDataMapping', 'Parent', 'ResolutionLevel' };
if ~isempty( obj.AlphaData )
props{ end  + 1 } = 'AlphaData';
props{ end  + 1 } = 'AlphaDataMapping';
end 
if strcmp( obj.GridVisible, 'on' )
props{ end  + 1 } = 'GridLevel';
end 
groups = matlab.mixin.util.PropertyGroup( props );
end 

function printEvent( obj, callbackName )
switch callbackName
case 'PrePrintCallback'
obj.PrintSettingsCache.CoalescePeriod = obj.CurrentCoalescePeriod;

obj.CurrentCoalescePeriod = 0;
case 'PostPrintCallback'

obj.CurrentCoalescePeriod = obj.PrintSettingsCache.CoalescePeriod;
end 
end 
end 

methods ( Hidden )

function mcodeConstructor( ~, hCode )

markAsParameter( hCode, { 'CData' } );

generateDefaultPropValueSyntax( hCode );
end 
end 


methods ( Hidden )
function extents = getXYZDataExtents( obj )
extents = [  ];
if ~isempty( obj.CData ) && isvalid( obj.CData )
xExtents = [ 
min( [ obj.SpatialReferencing.XWorldLimits ] ),  ...
max( [ obj.SpatialReferencing.XWorldLimits ] ) ];
yExtents = [ 
min( [ obj.SpatialReferencing.YWorldLimits ] ),  ...
max( [ obj.SpatialReferencing.YWorldLimits ] ) ];
extents = [ 
matlab.graphics.chart.primitive.utilities.arraytolimits( xExtents )
matlab.graphics.chart.primitive.utilities.arraytolimits( yExtents )
NaN, NaN, NaN, NaN ];
end 
end 

function doUpdate( obj, uState )
if isempty( obj.CData ) || isempty( obj.DisplayTileManager )
return 
end 

if isa( obj.Parent, 'matlab.graphics.primitive.Transform' )
error( message( 'images:bigimage:transformNotSupported' ) );
end 

if strcmp( obj.Parent.XScale, 'log' ) || strcmp( obj.Parent.YScale, 'log' )
error( message( 'images:bigimage:logScaleNotSupported' ) );
end 


obj.cancelPendingIO(  );


if ischar( obj.ResolutionLevel_I )
obj.ResolutionLevel_I = obj.resolveResolutionLevelString( obj.ResolutionLevel_I );
end 
if ischar( obj.GridLevel_I )
obj.GridLevel_I = obj.resolveResolutionLevelString( obj.GridLevel_I );
end 

obj.resetIfNeeded( uState );


xExternalWorldLocs = uState.DataSpace.XDataLim;
yExternalWorldLocs = uState.DataSpace.YDataLim;


switch obj.ResolutionLevelMode
case 'auto'
layout = GetLayoutInformation( obj.Parent );
screenSpaceTaken = layout.PlotBox( 3:4 );

pixelExtent = max( [ diff( xExternalWorldLocs ), diff( yExternalWorldLocs ) ] ./ screenSpaceTaken );

availablePixelExtents = [ obj.SpatialReferencing.PixelExtentInWorldX ];
[ ~, useResLevel ] = min( abs( availablePixelExtents - pixelExtent ) );

case 'manual'
useResLevel = obj.ResolutionLevel_I;
end 
obj.ResolutionLevel_I = useResLevel;


obj.gridUpdate( uState );


levelRef = obj.SpatialReferencing( useResLevel );



tileSize = obj.DisplayTileManager.TileSize;
tileSizeInExteralWorld = tileSize .* [ levelRef.PixelExtentInWorldY, levelRef.PixelExtentInWorldX ];
yExtTileSize = tileSizeInExteralWorld( 1 );
xExtTileSize = tileSizeInExteralWorld( 2 );



yTileSubEdge = yExternalWorldLocs / yExtTileSize;
xTileSubEdge = xExternalWorldLocs / xExtTileSize;

yTileSubEdge( 1 ) = floor( yTileSubEdge( 1 ) );yTileSubEdge( 2 ) = ceil( yTileSubEdge( 2 ) );
xTileSubEdge( 1 ) = floor( xTileSubEdge( 1 ) );xTileSubEdge( 2 ) = ceil( xTileSubEdge( 2 ) );



yExternalWorldLocs = yTileSubEdge * yExtTileSize;
xExternalWorldLocs = xTileSubEdge * xExtTileSize;



xExternalWorldLocs = max( levelRef.XWorldLimits( 1 ), xExternalWorldLocs );
yExternalWorldLocs = max( levelRef.YWorldLimits( 1 ), yExternalWorldLocs );
xExternalWorldLocs = min( xExternalWorldLocs, levelRef.XWorldLimits( 2 ) );
yExternalWorldLocs = min( yExternalWorldLocs, levelRef.YWorldLimits( 2 ) );


fullWorldX = levelRef.XWorldLimits;
fullWorldY = levelRef.YWorldLimits;
obj.DisplayTileManager.positionBackgroundTile( fullWorldX, fullWorldY, uState );



obj.DisplayTileManager.updateExistingTiles( xExternalWorldLocs, yExternalWorldLocs, uState, useResLevel );


for xStart = xExternalWorldLocs( 1 ):xExtTileSize:xExternalWorldLocs( 2 )
for yStart = yExternalWorldLocs( 1 ):yExtTileSize:yExternalWorldLocs( 2 )

xExtLim = [ xStart, min( levelRef.XWorldLimits( 2 ), xStart + xExtTileSize ) ];
yExtLim = [ yStart, min( levelRef.YWorldLimits( 2 ), yStart + yExtTileSize ) ];


if diff( xExtLim ) <= eps( xExtLim( 2 ) ) || diff( yExtLim ) <= eps( yExtLim( 2 ) )
continue 
end 


newTile = obj.DisplayTileManager.manageTileAt( xExtLim, yExtLim, useResLevel, uState );
if ~isempty( newTile )
addNode( obj, newTile );
end 
end 
end 

obj.loadImageIntoTiles( uState.ColorSpace );



obj.CurrentCoalescePeriod = obj.RequiredCoalescePeriod;
end 

function gridUpdate( obj, uState )


if strcmp( obj.GridVisible, 'off' )
if ~isempty( obj.GridLines )
obj.GridLines.Visible = 'off';
end 
return 
end 


if isempty( obj.GridLines )
obj.GridLines = matlab.graphics.primitive.world.LineStrip(  );
obj.addNode( obj.GridLines );
set( obj.GridLines, 'HitTest', 'off',  ...
'Visible', 'off',  ...
'LineCap', 'square',  ...
'PickableParts', 'none',  ...
'ColorType', 'truecoloralpha', 'ColorBinding', 'object',  ...
'Layer', 'front', 'HandleVisibility', 'off' );
end 


obj.GridLines.Visible = 'on';

if strcmp( obj.GridLevelMode, 'auto' )
obj.GridLevel_I = obj.ResolutionLevel_I;
end 



tileSizeWorld = getBlockSize( obj.CData, obj.GridLevel_I ) .*  ...
[ obj.SpatialReferencing( obj.GridLevel_I ).PixelExtentInWorldY,  ...
obj.SpatialReferencing( obj.GridLevel_I ).PixelExtentInWorldX ];

[ xLoc, yLoc ] = obj.gridLocations( tileSizeWorld );


x = zeros( [ ( numel( xLoc ) + numel( yLoc ) ) * 2, 1 ] );
y = zeros( [ ( numel( xLoc ) + numel( yLoc ) ) * 2, 1 ] );


lInd = 1;
for xPoint = xLoc
x( lInd ) = xPoint;
y( lInd ) = obj.FullImageExtentsY( 1 );
x( lInd + 1 ) = xPoint;
y( lInd + 1 ) = obj.FullImageExtentsY( 2 );
lInd = lInd + 2;
end 
for yPoint = yLoc
x( lInd ) = obj.FullImageExtentsX( 1 );
y( lInd ) = yPoint;
x( lInd + 1 ) = obj.FullImageExtentsX( 2 );
y( lInd + 1 ) = yPoint;
lInd = lInd + 2;
end 


iter = matlab.graphics.axis.dataspace.XYZPointsIterator;
iter.XData = x';
iter.YData = y';
iter.ZData = zeros( [ numel( x ), 1 ] );
obj.GridLines.VertexData = TransformPoints( uState.DataSpace,  ...
uState.TransformUnderDataSpace,  ...
iter );


obj.GridLines.StripData = uint32( 1:2:numel( x ) + 1 );

obj.GridLines.ColorData = uint8( ( [ obj.GridColor, obj.GridAlpha ] * 255 ).' );
obj.GridLines.LineWidth = obj.GridLineWidth;
hgfilter( 'LineStyleToPrimLineStyle', obj.GridLines, obj.GridLineStyle );
end 
end 



methods ( Hidden )
function cancelPendingIO( obj )
if isscalar( obj.CoalesceTimer ) && isvalid( obj.CoalesceTimer ) ...
 && strcmp( obj.CoalesceTimer.Running, 'on' )

stop( obj.CoalesceTimer )
end 

obj.CancelEventTimeStamp = now;

obj.DisplayTileManager.resetPending(  );
end 

function loadImageIntoTiles( obj, colorspace )
cb = @( varargin )obj.loadTileDataFromFileExceptionSafe( colorspace );

cbhandler = @( e, d )matlab.graphics.internal.drawnow.callback( cb );

if obj.CurrentCoalescePeriod == 0
cbhandler(  );
return 
end 


stop( obj.CoalesceTimer )
delete( obj.CoalesceTimer )
obj.CoalesceTimer = timer(  ...
'Name', 'BD_CoalesceTimer',  ...
'ExecutionMode', 'singleShot',  ...
'ObjectVisibility', 'off',  ...
'TimerFcn', cbhandler,  ...
'StartDelay', obj.CurrentCoalescePeriod );
start( obj.CoalesceTimer );
end 

function loadTileDataFromFileExceptionSafe( obj, colorspace )
try 
obj.loadTileDataFromFile( colorspace )
catch ALL











[ ~, fileNames ] = cellfun( @( x )fileparts( x ), { ALL.stack.file }, 'UniformOutput', false );
isErrorFromBigImage = any( strcmp( fileNames, 'blockedImage' ) ) ...
 || any( strcmp( fileNames, 'bigimage' ) );
if isErrorFromBigImage


rethrow( ALL );
end 
end 
end 

function loadTileDataFromFile( obj, colorspace )
tileInds = obj.DisplayTileManager.getTilesThatNeedDataFromSource(  );

loadTime = now;




ref = obj.SpatialReferencing( obj.ResolutionLevel );
halfPixel = [ ref.PixelExtentInWorldX, ref.PixelExtentInWorldY ] / 2;

for tileInd = tileInds
[ xExtLim, yExtLim, resLevel ] = obj.DisplayTileManager.getExtents( tileInd );
xExtLim( 2 ) = xExtLim( 2 ) - halfPixel( 1 );
yExtLim( 2 ) = yExtLim( 2 ) - halfPixel( 2 );






if obj.haveToCancelThisLoad( loadTime )
break 
end 
rawData = getRegion( obj.CData_I, resLevel,  ...
[ xExtLim( 1 ), yExtLim( 1 ) ], [ xExtLim( 2 ), yExtLim( 2 ) ] );
if size( rawData, 3 ) ~= 1 && size( rawData, 3 ) ~= 3

rawData = rawData( :, :, obj.ChannelInds );
end 


if isempty( obj.AlphaData )
alpha = [  ];
elseif isnumeric( obj.AlphaData ) || islogical( obj.AlphaData )
alpha = obj.AlphaData;
else 


levelRef = obj.SpatialReferencing( obj.ResolutionLevel_I );
pixelExtent = max( [ levelRef.PixelExtentInWorldY, levelRef.PixelExtentInWorldX ] );

availablePixelExtents = [ obj.SpatialReferencing_Alpha.PixelExtentInWorldX ];
[ ~, aLevel ] = min( abs( availablePixelExtents - pixelExtent ) );


aLevelRef = obj.SpatialReferencing_Alpha( aLevel );
xExtLim( 1 ) = max( xExtLim( 1 ), aLevelRef.XWorldLimits( 1 ) );
xExtLim( 2 ) = min( xExtLim( 2 ), aLevelRef.XWorldLimits( 2 ) );
yExtLim( 1 ) = max( yExtLim( 1 ), aLevelRef.YWorldLimits( 1 ) );
yExtLim( 2 ) = min( yExtLim( 2 ), aLevelRef.YWorldLimits( 2 ) );
if obj.haveToCancelThisLoad( loadTime )
break 
end 
alpha = getRegion( obj.AlphaData, aLevel,  ...
[ xExtLim( 1 ), yExtLim( 1 ) ], [ xExtLim( 2 ), yExtLim( 2 ) ] );
if iscategorical( alpha )
alpha = double( alpha );
end 
end 

if obj.haveToCancelThisLoad( loadTime )
break 
end 
obj.DisplayTileManager.updateTileWithData( tileInd,  ...
rawData, obj.CDataMapping_I,  ...
alpha, obj.AlphaDataMapping_I, colorspace );







drawnow limitrate
end 

obj.DisplayTileManager.cleanUpPreviousResolutionTiles(  );
end 
end 



methods ( Access = private, Hidden )

function checkAndCreateOverViewIfNeeded( obj, bim )
if isa( obj.CData_I, 'blockedImage' )



return ;
end 



if strcmp( obj.ResolutionLevelMode, 'auto' )
monitorSizes = get( 0, 'MonitorPositions' );
maxScreenSize = max( monitorSizes( :, 3:4 ), 1 );
maxScreenPixels = max( prod( maxScreenSize ) );


imageSizes = { bim.SpatialReferencing.ImageSize };
imageSizes = cell2mat( imageSizes' );
imagePixels = prod( imageSizes, 2 );
[ smallestImagePixels, smallestLevel ] = min( imagePixels );

overResFactor = smallestImagePixels / maxScreenPixels;
if overResFactor > 3
if isa( bim.Adapter, 'images.internal.adapters.BinAdapter' )

bim.addSubLevel( smallestLevel, [ NaN, maxScreenSize( 2 ) ] );
else 
warning( message( 'images:bigimage:largeFlatFile' ) );
end 
end 
end 
end 

function tf = haveToCancelThisLoad( obj, loadTime )

tf = ~isvalid( obj ) || loadTime < obj.CancelEventTimeStamp;
end 

function res = resolveResolutionLevelString( obj, res )

if isnumeric( res )
validateattributes( res, { 'numeric' }, { 'scalar', 'real', 'positive', 'integer' },  ...
mfilename );
else 
res = validatestring( res, { 'fine', 'coarse' },  ...
mfilename );
end 


if ~isempty( obj.CData )
switch res
case 'coarse'
res = getCoarsestLevel( obj.CData );
case 'fine'
res = getFinestLevel( obj.CData );
otherwise 



validateattributes( res, { 'numeric' },  ...
{ 'positive', '<=', numel( obj.SpatialReferencing ) },  ...
mfilename, 'ResolutionLevel' );
end 
end 
end 

function [ xLoc, yLoc ] = gridLocations( obj, tileSizeWorld )


levelRef = obj.SpatialReferencing( obj.ResolutionLevel_I );
xLoc = levelRef.XWorldLimits( 1 ):tileSizeWorld( 2 ):levelRef.XWorldLimits( 2 );
yLoc = levelRef.YWorldLimits( 1 ):tileSizeWorld( 1 ):levelRef.YWorldLimits( 2 );


if xLoc( end  ) ~= levelRef.XWorldLimits( 2 )
xLoc( end  + 1 ) = levelRef.XWorldLimits( 2 );
end 
if yLoc( end  ) ~= levelRef.YWorldLimits( 2 )
yLoc( end  + 1 ) = levelRef.YWorldLimits( 2 );
end 
end 

function resetIfNeeded( obj, ustate )


newStateInfo.Colormap = ustate.ColorSpace.Colormap;
newStateInfo.Alphamap = ustate.ColorSpace.Alphamap;
newStateInfo.CLimMode = ustate.ColorSpace.CLimMode;
newStateInfo.CLimWithInfs = ustate.ColorSpace.CLimWithInfs_I;
newStateInfo.CLimWithInfsMode = ustate.ColorSpace.CLimWithInfsMode;
newStateInfo.ColorScale = ustate.ColorSpace.ColorScale;
newStateInfo.AlphaScale = ustate.ColorSpace.AlphaScale;
newStateInfo.ALimMode = ustate.ColorSpace.ALimMode;
newStateInfo.ALimWithInfs = ustate.ColorSpace.ALimWithInfs_I;
newStateInfo.ALimWithInfsMode = ustate.ColorSpace.ALimWithInfsMode;

if ~isequal( newStateInfo, obj.PreviousUpdateStateInfo )
obj.DisplayTileManager.reset(  );
obj.PreviousUpdateStateInfo = newStateInfo;
end 
end 
end 
end 



function l = getFinestLevel( bim )
if isa( bim, 'blockedImage' )


l = 1;
else 
l = bim.FinestResolutionLevel;
end 
end 

function l = getCoarsestLevel( bim )
if isa( bim, 'blockedImage' )
l = bim.NumLevels;
else 
l = bim.CoarsestResolutionLevel;
end 
end 

function ref = getSpatialReferencingObject( blockedbim )


xDimInd = 2;
yDimInd = 1;
for ind = 1:blockedbim.NumLevels
imageStart = blockedbim.WorldStart( ind, : );
imageEnd = blockedbim.WorldEnd( ind, : );
xWorldLims = [ imageStart( xDimInd ), imageEnd( xDimInd ) ];
yWorldLims = [ imageStart( yDimInd ), imageEnd( yDimInd ) ];
imageSize = blockedbim.Size( ind, [ yDimInd, xDimInd ] );
ref( ind ) = imref2d( imageSize, xWorldLims, yWorldLims );%#ok<AGROW>
end 
end 

function bs = getBlockSize( bim, level )
if isa( bim, 'blockedImage' )


bs = bim.BlockSize( level, 1:2 );
else 
bs = bim.getBlockSize( level );
end 
end 

function rawData = getRegion( bim, resLevel, worldMin, worldMax )
if isa( bim, 'blockedImage' )

pixelStartWorld = bim.WorldStart( resLevel, : );
pixelEndWorld = bim.WorldEnd( resLevel, : );




pixelStartWorld( 1 ) = worldMin( 2 );
pixelStartWorld( 2 ) = worldMin( 1 );

pixelEndWorld( 1 ) = worldMax( 2 );
pixelEndWorld( 2 ) = worldMax( 1 );

pixelStartSub = bim.world2sub( pixelStartWorld, "Level", resLevel );
pixelEndSub = bim.world2sub( pixelEndWorld, "Level", resLevel );

rawData = bim.getRegion( pixelStartSub, pixelEndSub,  ...
"Level", resLevel );
else 
rawData = bim.getRegion( resLevel, worldMin, worldMax );
end 
end 

function pct = computeWorldRegionNNZ( bim, level, maskStartWorld, maskEndWorld )
if isa( bim, 'blockedImage' )
subs = bim.world2sub( [ maskStartWorld( 2: - 1:1 );maskEndWorld( 2: - 1:1 ) ] );
mblock = bim.getRegionPadded( subs( 1, : ), subs( 2, : ), bim.NumLevels, false, [  ] );
pct = nnz( mblock ) / numel( mblock );

else 
pct = bim.computeWorldRegionNNZ( level, maskStartWorld, maskEndWorld );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpacmVey.p.
% Please follow local copyright laws when handling this file.

