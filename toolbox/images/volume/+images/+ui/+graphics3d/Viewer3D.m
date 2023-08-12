classdef ( Sealed, ConstructOnLoad, UseClassDefaultsOnLoad )Viewer3D < matlab.ui.componentcontainer.ComponentContainer




events ( ListenAccess = public, NotifyAccess = private )

CameraMoving
CameraMoved

ClippingPlanesChanging
ClippingPlanesChanged

ViewerRefreshed
WarningThrown

end 

properties ( Dependent, UsedInUpdate = false )

Lighting( 1, 1 )matlab.lang.OnOffSwitchState
LightPosition( 1, 3 ){ mustBeNumeric, mustBeFinite, mustBeNonNan, mustBeReal, mustBeNonsparse }
LightPositionMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual
LightColor matlab.internal.datatype.matlab.graphics.datatype.RGBColor

CameraPosition( 1, 3 ){ mustBeNumeric, mustBeFinite, mustBeNonNan, mustBeReal, mustBeNonsparse }
CameraUpVector( 1, 3 ){ mustBeNumeric, mustBeFinite, mustBeNonNan, mustBeReal, mustBeNonsparse }
CameraZoom( 1, 1 ){ mustBeNumeric, mustBePositive, mustBeFinite, mustBeNonNan, mustBeNonsparse }
CameraTarget( 1, 3 ){ mustBeNumeric, mustBeFinite, mustBeNonNan, mustBeReal, mustBeNonsparse }

CameraPositionMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual
CameraUpVectorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual
CameraZoomMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual
CameraTargetMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual

BackgroundGradient( 1, 1 )matlab.lang.OnOffSwitchState
GradientColor matlab.internal.datatype.matlab.graphics.datatype.RGBColor

Interactions{ mustBeText, mustBeVector }
ClippingInteractions{ mustBeText, mustBeVector }
SliceInteractions{ mustBeText, mustBeVector }
CurrentObject( 1, 1 ){ mustBeA( CurrentObject, [ "images.ui.graphics3d.Volume", "images.ui.graphics3d.Surface", "images.ui.graphics3d.internal.Points" ] ) }

Toolbar( 1, 1 )matlab.lang.OnOffSwitchState
OrientationAxes( 1, 1 )matlab.lang.OnOffSwitchState
Box( 1, 1 )matlab.lang.OnOffSwitchState
ScaleBar( 1, 1 )matlab.lang.OnOffSwitchState
ScaleBarUnits{ mustBeTextScalar }
Tooltip

ClippingPlanes( :, 4 ){ mustBeFinite, mustBeNonNan, mustBeReal, mustBeNonsparse }
GlobalClipping( 1, 1 )matlab.lang.OnOffSwitchState
ClipIntersection( 1, 1 )matlab.lang.OnOffSwitchState

RenderingQuality

end 

properties ( Dependent, Hidden, UsedInUpdate = false )









DepthPeeling( 1, 1 )matlab.lang.OnOffSwitchState








DepthPeelingMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual









ViewDepth( 1, 1 )single{ mustBeNonnegative, mustBeInteger, mustBeNonNan, mustBeNonsparse }













KeepDataReference( 1, 1 )matlab.lang.OnOffSwitchState






MaxCanvasSize( 1, 2 )single{ mustBeNonnegative, mustBeInteger, mustBeNonNan, mustBeNonsparse }





Badge( 1, 1 )string{ mustBeMember( Badge, [ "none", "warning" ] ) }





Antialiasing( 1, 1 )string{ mustBeMember( Antialiasing, [ "none", "msaa", "ssaa" ] ) }






OrientationAxesLabels( 1, 3 )string

end 

properties ( Dependent, Hidden, SetAccess = private, UsedInUpdate = false )









Busy

end 

properties ( Hidden, SetAccess = private, Transient, NonCopyable, UsedInUpdate = false )






BoundingBox( 2, 3 )single = [ 0, 0, 0;0, 0, 0 ];








ResponseReceived( 1, 1 )logical = true;





RendererInfo( 1, 1 )struct







SceneDirty( 1, 1 )logical = false;







ChildrenDirty( 1, 1 )logical = false;






ClearRequired( 1, 1 )logical = false;

end 

properties ( Dependent, Hidden, SetAccess = private )





Dirty( 1, 1 )logical

end 

properties ( Hidden, Transient, NonCopyable, UsedInUpdate = false )








UseDebug( 1, 1 )logical = false;











UseBrowser( 1, 1 )logical = false;







ShowWarnings( 1, 1 )logical = true;

end 

properties ( Access = private, Transient, NonCopyable, UsedInUpdate = false )


CameraPosition_I( 1, 3 )single = [ 1, 1, 1 ];
CameraTarget_I( 1, 3 )single = [ 0, 0, 0 ];
CameraUpVector_I( 1, 3 )single = [ 0, 0, 1 ];
CameraZoom_I( 1, 1 )single = 1;
CameraAutoMode_I( 1, 5 )logical = [ true, true, true, true, true ];


Lighting_I( 1, 1 )logical = true;
LightPosition_I( 1, 3 )single = [ 1, 1, 1 ];
LightColor_I( 1, 3 )double = [ 1.0, 1.0, 1.0 ];


BackgroundGradient_I( 1, 1 )logical = true;
GradientColor_I( 1, 3 )double = [ 0.0, 0.5610, 1.0 ];
OrientationAxes_I( 1, 1 )logical = true;
OrientationAxesLabels_I( 1, 3 )string = [ "X", "Y", "Z" ];
ScaleBar_I( 1, 1 )logical = false;
ScaleBarUnits_I( 1, 1 )string = "Voxels";
Box_I( 1, 1 )logical = false;
Busy_I( 1, 1 )logical = false;
RenderingQuality_I = "auto";


ClippingPlanes_I( 4, : )single = [  ];
GlobalClipping_I( 1, 1 )logical = true;
ClippingInteractions_I( 1, 4 )logical = [ true, true, true, true ];
SliceInteractions_I( 1, 4 )logical = [ false, false, false, true ];
CurrentObject_I( 1, 1 )double = 0;
Interactions_I( 1, 4 )logical = [ true, true, true, true ];
Toolbar_I( 1, 1 )logical = true;
ClippingAllowed_I( 1, 1 )logical = true;
SlicingAllowed_I( 1, 1 )logical = true;
ClipIntersection_I( 1, 1 )logical = false;


DepthPeeling_I( 1, 1 )logical = false;
DepthPeelingMode_I matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'auto';
ViewDepth_I( 1, 1 )single = 0;


KeepInMemory_I( 1, 1 )logical = true;
MaxCanvasSize_I( 1, 2 )single = [ 3840, 2160 ];
Badge_I( 1, 1 )string = "none";
Antialiasing_I( 1, 1 )string = "none";
Dirty_I( 1, 1 )logical = false;


HTML matlab.ui.control.HTML = matlab.ui.control.HTML.empty;
GridLayout matlab.ui.container.GridLayout = matlab.ui.container.GridLayout.empty;
ChildrenInternal( :, 1 ) = [  ];


PlaneContextMenu matlab.ui.container.ContextMenu = matlab.ui.container.ContextMenu.empty;
FlipMenuItem
RemoveMenuItem
SnapPopupItem
SnapXItem
SnapYItem
SnapZItem
SnapPositiveXItem
SnapNegativeXItem
SnapPositiveYItem
SnapNegativeYItem
SnapPositiveZItem
SnapNegativeZItem

Max3DTextureSize( 1, 1 )double = 2048;
NumTimesContextLost( 1, 1 )double = 0;

ViewerReady( 1, 1 )logical = false;
BoundingBoxUpdateRequired( 1, 1 )logical = false;
CachedBackgroundColor( 1, 3 )double
ColorIndex( 1, 1 )double = 1;


MessageService
MessageToken( 1, : )char
MessageServiceChannel( 1, : )char
BinaryChannel

end 

methods 




function self = Viewer3D( varargin )



self@matlab.ui.componentcontainer.ComponentContainer( varargin{ : } );





self.HTML.Parent.BackgroundColor = self.BackgroundColor_I;


initializeClient( self );
end 




function clear( self )
self.ClearRequired = true;
self.Dirty = true;
end 




function delete( self )
deleteUIComponents( self );
delete( self.ChildrenInternal );
end 

end 

methods ( Access = protected )


function setup( self )





hFig = ancestor( self.Parent, 'figure' );

if isa( getCanvas( hFig ), 'matlab.graphics.primitive.canvas.JavaCanvas' )
error( message( 'images:volume:javaGraphics' ) );
end 





self.BackgroundColor_I = [ 0.0, 0.329, 0.529 ];

self.CachedBackgroundColor = self.BackgroundColor_I;
createUIComponents( self );
end 


function update( self )




if ~self.ViewerReady || ~self.ResponseReceived ||  ...
( ~self.Dirty_I && isequal( self.CachedBackgroundColor, self.BackgroundColor_I ) )



return ;
end 

self.Dirty_I = false;

if self.ClearRequired

self.ClearRequired = false;
resetScene( self );
return ;
end 





updateScene = self.SceneDirty || ~isequal( self.CachedBackgroundColor, self.BackgroundColor_I );


if ~updateScene && ~self.ChildrenDirty
if self.Busy_I
self.Busy = false;
end 
return ;
end 



removedIndices = removeChildren( self );

arrayOfDirtyObjects = arrayfun( @( x )get( x, 'Dirty' ), self.ChildrenInternal );
arrayOfObjectsWithData = arrayfun( @( x )get( x, 'DataUpdateRequired' ), self.ChildrenInternal );

if any( arrayOfObjectsWithData )




if ~self.Busy_I
self.Busy = true;
end 
self.BoundingBoxUpdateRequired = true;
end 



arrayOfVisibleObjects = ~arrayfun( @( x )get( x, 'Empty' ), self.ChildrenInternal );
if matches( self.DepthPeelingMode_I, "auto" )
priorDepthPeeling = self.DepthPeeling_I;
self.DepthPeeling_I = sum( arrayOfVisibleObjects ) > 1;
if priorDepthPeeling ~= self.DepthPeeling_I
updateScene = true;
end 
end 


n = sum( arrayOfDirtyObjects );
dirtyIdx = find( arrayOfDirtyObjects );
binaryInstructionSet = {  };
emptyInstructionSet = {  };
s = struct( 'UpdateScene', updateScene, 'NumObjects', n, 'BoundingBox', [  ], 'RemovedIndices', removedIndices, 'CurrentObject', getCurrentObjectInfo( self ) );


if updateScene
s.SceneData = getPropertyStruct( self );
self.CachedBackgroundColor = self.BackgroundColor_I;
end 


set( self.ChildrenInternal, 'Dirty', false );
set( self, 'SceneDirty', false, 'ChildrenDirty', false );



arrayOfOpaqueObjects = arrayfun( @( x )get( x, 'Opaque' ), self.ChildrenInternal );
s.OpaqueObjectsOnly = all( arrayOfOpaqueObjects | ~arrayOfVisibleObjects );


for idx = 1:n
dataUpdateRequired = self.ChildrenInternal( dirtyIdx( idx ) ).DataUpdateRequired;
data = appendIndexToData( self, self.ChildrenInternal( dirtyIdx( idx ) ), getContainerProperties( self.ChildrenInternal( dirtyIdx( idx ) ) ) );
if dataUpdateRequired

instructionSet = appendIndexToData( self, self.ChildrenInternal( dirtyIdx( idx ) ), getContainerInstructions( self.ChildrenInternal( dirtyIdx( idx ) ) ) );



if instructionSet.UseBinaryChannel
binaryInstructionSet{ end  + 1 } = instructionSet;%#ok<AGROW>
else 
emptyInstructionSet{ end  + 1 } = instructionSet;%#ok<AGROW>
end 
end 
s.( "ObjectData" + ( idx - 1 ) ) = data;
end 

s.InstructionSet = binaryInstructionSet;
s.EmptyInstructionSet = emptyInstructionSet;

if self.BoundingBoxUpdateRequired



self.BoundingBoxUpdateRequired = false;
bbox = self.BoundingBox;
updateSceneBoundary( self );



if ~isequal( bbox, self.BoundingBox )
s.BoundingBox = self.BoundingBox;
end 
end 


if self.ViewerReady


request( self, 'drawnow', s );






for idx = 1:numel( binaryInstructionSet )
sendBinaryData( self, binaryInstructionSet{ idx } );
end 
end 



if self.Busy_I
self.Busy = false;
end 

end 

end 


methods ( Hidden )


function addChild( self, h )

if ~any( contains( superclasses( h ), 'images.ui.graphics3d.GraphicsContainer' ) )
error( message( 'images:volume:invalidChild' ) );
end 


addlistener( h, 'ContainerUpdated', @( src, evt )markContainerDirty( self, src ) );
addlistener( h, 'DataBeingUpdated', @( ~, ~ )dataBeingUpdated( self ) );
addlistener( h, 'TransformationUpdated', @( ~, ~ )boundingBoxUpdated( self ) );
addlistener( h, 'ObjectBeingDestroyed', @( src, evt )markContainerDirty( self, src ) );


set( h, 'KeepOriginalDataCopy', self.KeepInMemory_I, 'Max3DTextureSize', self.Max3DTextureSize );



if ( isa( h, 'images.ui.graphics3d.Surface' ) || isa( h, 'images.ui.graphics3d.internal.Points' ) ) && isempty( h.Color )
set( h, 'Color', getNextColor( self ) );
end 



self.ChildrenInternal = [ self.ChildrenInternal;h ];
self.CurrentObject_I = numel( self.ChildrenInternal );
end 


function c = doCollectChildren( self )


c = self.ChildrenInternal;
end 

end 

methods ( Access = private )


function clearConnectors( self )

if ~isempty( self.MessageService )
message.unsubscribe( self.MessageService );
self.ViewerReady = false;
end 
delete( self.BinaryChannel );
end 


function createUIComponents( self )
if isempty( self.GridLayout )


self.GridLayout = uigridlayout( self, 'RowHeight', "1x", 'ColumnWidth', "1x",  ...
'Padding', [ 0, 0, 0, 0 ], 'BackgroundColor', self.BackgroundColor_I );
end 
self.HTML = uihtml( self.GridLayout,  ...
'HandleVisibility', 'off', 'Visible', 'off' );
end 


function deleteUIComponents( self )
clearConnectors( self );
delete( self.PlaneContextMenu );
delete( self.HTML );
end 


function resetScene( self )

delete( self.ChildrenInternal );
self.ChildrenInternal = [  ];
self.CurrentObject_I = 0;
self.BoundingBox = [ 0, 0, 0;0, 0, 0 ];
if self.ViewerReady
request( self, 'clear', struct );
end 
end 


function request( self, requestedMethod, data )



self.ResponseReceived = false;
message.publish( self.MessageServiceChannel, struct(  ...
'Token', self.MessageToken,  ...
'Type', requestedMethod,  ...
'Args', data ) );




waitForMessageService( self );
end 


function removedIndices = removeChildren( self )



removedIndices = find( arrayfun( @( x )~isvalid( x ), self.ChildrenInternal ) );

if isempty( removedIndices )
return ;
end 

self.ChildrenInternal( removedIndices ) = [  ];

if any( removedIndices == self.CurrentObject_I )
self.CurrentObject_I = numel( self.ChildrenInternal );
end 

removedIndices = single( removedIndices - 1 );
self.BoundingBoxUpdateRequired = true;
end 


function finishHandshake( self )




markAllChildrenDirty( self );

hFig = ancestor( self.Parent_I, 'figure' );
if ~isempty( self.PlaneContextMenu ) && hFig ~= self.PlaneContextMenu.Parent
self.PlaneContextMenu.Parent = hFig;
end 

s = getPropertyStruct( self );
s.HardwareSupport = self.RendererInfo.HardwareSupport;
request( self, 'start', s );

notifyRefresh( self );
end 


function notifyRefresh( self )
if self.Busy_I
request( self, 'busy', struct( 'Busy', true ) );
end 

self.ViewerReady = true;
markViewerDirty( self );

notify( self, 'ViewerRefreshed' );
end 


function waitForMessageService( self )





if self.UseDebug
while ~self.ResponseReceived
pause( 0.01 );

if ~isvalid( self )
return ;
end 
end 
else 
waitfor( self, 'ResponseReceived', true );
end 
end 


function onMessageServiceResponse( self, msg )


if isfield( msg, 'Token' )
switch msg.Token
case self.MessageToken



if isfield( msg.Message, 'CameraPosition' )
hideContextMenu( self );
updateCameraProperties( self, msg.Message, 'CameraMoved' );
end 

case { "CameraMoving", "CameraMoved" }



hideContextMenu( self );
updateCameraProperties( self, msg.Message, msg.Token );
return ;

case { "ClippingPlanesChanging", "ClippingPlanesChanged", "ClippingPlaneAdded" }



hideContextMenu( self );
updateClippingPlanes( self, msg.Message, msg.Token );
return ;

case { "SlicePlanesChanging", "SlicePlanesChanged", "SlicePlaneAdded" }



hideContextMenu( self );
updateSlicePlanes( self, self.CurrentObject, msg.Message, msg.Token );
return ;

case "BinaryDataReceived"




case "WebGLContextLost"







self.ViewerReady = false;
throwWarning( self, message( 'images:volume:contextLost' ), [  ] );







case "ClientInitialized"
self.ViewerReady = false;
self.RendererInfo = msg.Message;
if msg.Message.WebGL2Supported
if contains( msg.Message.RendererDevice, 'SwiftShader' )


self.MaxCanvasSize_I = [ 1024, 1024 ];
msg.Message.HardwareSupport = false;
else 
msg.Message.HardwareSupport = true;
end 
self.Max3DTextureSize = msg.Message.Max3DTextureSize;
self.RendererInfo = msg.Message;
finishHandshake( self );
else 
msg.Message.HardwareSupport = false;
self.RendererInfo = msg.Message;
throwWarning( self, message( 'images:volume:webGL2NotSupported' ), msg.Message );
end 

case "ErrorThrown"

if msg.Message.Name == "RangeError"

throwWarning( self, message( 'images:volume:outOfMemory' ), msg.Message );
restore( self, "partial" );
else 

throwWarning( self, message( 'images:volume:errorEncountered', string( msg.Message.Message ) ), msg.Message );
end 

case "ContextMenuClicked"
showContextMenu( self, msg.Message.Position, msg.Message.ID );
return ;

otherwise 
return ;
end 






self.ResponseReceived = true;
end 

end 


function s = getPropertyStruct( self )


if self.ClippingAllowed_I
clip = self.ClippingInteractions_I;
else 
clip = [ false, false, false, false ];
end 

s = struct( 'BackgroundColor', single( self.BackgroundColor_I ),  ...
'Lighting', self.Lighting_I,  ...
'LightColor', single( self.LightColor_I ),  ...
'LightPosition', self.LightPosition_I,  ...
'CameraPosition', self.CameraPosition_I,  ...
'CameraTarget', self.CameraTarget_I,  ...
'CameraUpVector', self.CameraUpVector_I,  ...
'CameraZoom', self.CameraZoom_I,  ...
'CameraAutoMode', self.CameraAutoMode_I,  ...
'Interactions', self.Interactions_I,  ...
'Toolbar', self.Toolbar_I,  ...
'ClippingPlanes', self.ClippingPlanes_I( : ),  ...
'GlobalClipping', self.GlobalClipping_I,  ...
'ClippingInteractions', clip,  ...
'ClipIntersection', self.ClipIntersection_I,  ...
'SliceInteractions', self.SliceInteractions_I,  ...
'ScaleBar', self.ScaleBar_I,  ...
'ScaleBarUnits', self.ScaleBarUnits_I,  ...
'OrientationAxes', self.OrientationAxes_I,  ...
'OrientationAxesLabels', self.OrientationAxesLabels_I,  ...
'Box', self.Box_I,  ...
'GradientBackground', self.BackgroundGradient_I,  ...
'GradientColor', single( self.GradientColor_I ),  ...
'Quality', self.RenderingQuality_I,  ...
'DepthPeeling', self.DepthPeeling_I,  ...
'ViewDepth', self.ViewDepth_I,  ...
'MaxCanvasSize', self.MaxCanvasSize_I,  ...
'Badge', self.Badge_I,  ...
'Antialiasing', self.Antialiasing_I );
end 


function s = getCurrentObjectInfo( self )



obj = self.CurrentObject;

if isempty( obj )
s = struct(  );
else 
allowSlices = false;
if isa( obj, 'images.ui.graphics3d.Volume' )
if self.SlicingAllowed_I && obj.RenderingStyle == "SlicePlanes"
allowSlices = any( self.SliceInteractions_I );
end 
slices = obj.SlicePlanes_I( : );
box = [ 0.5, 0.5, 0.5;obj.OriginalSize + 0.5 ];
else 
slices = [  ];
box = zeros( [ 2, 3 ] );
end 
s = struct( 'ID', self.CurrentObject_I - 1,  ...
'ClippingPlanes', obj.ClippingPlanes_I( : ),  ...
'SlicePlaneInteractions', allowSlices,  ...
'SlicePlanes', slices,  ...
'BoundingBox', box,  ...
'Transform', single( obj.Transformation.T ) );
end 
end 


function markContainerDirty( self, src )

if ~isvalid( self )
return ;
end 

if isvalid( src )
set( self.ChildrenInternal( getChildIndex( self, src ) ), 'Dirty', true );
end 
self.ChildrenDirty = true;
self.Dirty = true;
end 


function markAllChildrenDirty( self )





set( self.ChildrenInternal, 'Dirty', true, 'IsContainerConstructed', false, 'DataUpdateRequired', true );
self.BoundingBox = [ 0, 0, 0;0, 0, 0 ];
self.Busy_I = true;
self.BoundingBoxUpdateRequired = true;
end 


function markViewerDirty( self )
self.SceneDirty = true;
self.Dirty = true;
end 


function restore( self, style )





if style == "partial"
request( self, 'clear', struct );
else 
deleteUIComponents( self );
end 



self.NumTimesContextLost = self.NumTimesContextLost + 1;

self.ViewerReady = false;

switch self.NumTimesContextLost
case 1


self.MaxCanvasSize_I = [ max( 500, round( self.MaxCanvasSize_I( 1 ) / 2 ) ), max( 500, round( self.MaxCanvasSize_I( 2 ) / 2 ) ) ];
set( self.ChildrenInternal, 'DownsampleLevel', 2 );
case 2

self.MaxCanvasSize_I = [ max( 500, round( self.MaxCanvasSize_I( 1 ) / 2 ) ), max( 500, round( self.MaxCanvasSize_I( 2 ) / 2 ) ) ];
set( self.ChildrenInternal, 'DownsampleLevel', 4 );
otherwise 

throwWarning( self, message( 'images:volume:contextLostFinal' ), [  ] );
return ;
end 

if style == "partial"
markAllChildrenDirty( self );
notifyRefresh( self );
else 
createUIComponents( self );
initializeClient( self );
end 
end 


function dataBeingUpdated( self )



if ~isvalid( self )
return ;
end 

if ~self.Busy_I
self.Busy = true;
end 
end 


function boundingBoxUpdated( self )



if ~isvalid( self )
return ;
end 

self.BoundingBoxUpdateRequired = true;
end 


function updateSceneBoundary( self )



bbox = [ Inf, Inf, Inf; - Inf,  - Inf,  - Inf ];



for idx = 1:numel( self.ChildrenInternal )
bbox = [ min( [ bbox( 1, 1:3 );self.ChildrenInternal( idx ).BoundingBox( 1, 1:3 ) ], [  ], 1 );max( [ bbox( 2, 1:3 );self.ChildrenInternal( idx ).BoundingBox( 2, 1:3 ) ], [  ], 1 ) ];
end 


bbox( ~isfinite( bbox ) ) = 0;
self.BoundingBox = bbox;
end 


function idx = getChildIndex( self, src )
idx = find( self.ChildrenInternal == src );
end 


function data = appendIndexToData( self, src, data )
data.Index = getChildIndex( self, src ) - 1;
end 


function updateCameraProperties( self, props, eventName )



oldPosition = self.CameraPosition_I;
oldTarget = self.CameraTarget_I;
oldUpVector = self.CameraUpVector_I;
oldZoom = self.CameraZoom_I;

self.CameraPosition_I = props.CameraPosition;
self.CameraTarget_I = props.CameraTarget;
self.CameraUpVector_I = props.CameraUpVector;
self.CameraZoom_I = props.CameraZoom;
self.LightPosition_I = props.LightPosition;

evt = images.ui.graphics3d.events.CameraMovedEventData(  ...
self.CameraPosition_I, self.CameraTarget_I, self.CameraUpVector_I, self.CameraZoom_I,  ...
oldPosition, oldTarget, oldUpVector, oldZoom );

notify( self, eventName, evt );
end 


function updateClippingPlanes( self, props, eventName )



if self.GlobalClipping
obj = self;
else 
obj = self.CurrentObject;
if isempty( obj )
return ;
end 
end 



oldPlanes = obj.ClippingPlanes_I;

if eventName == "ClippingPlaneAdded"


addClippingPlane( self );
eventName = 'ClippingPlanesChanged';
planes = obj.ClippingPlanes_I;
else 
planes = oldPlanes;
if isfield( props, 'ClippingPlane' )
planes( :, props.Index ) = props.ClippingPlane;
end 
obj.ClippingPlanes_I = planes;
end 

notify( obj, eventName, images.ui.graphics3d.events.ClippingPlanesChangedEventData(  ...
planes', oldPlanes' ) );
end 


function updateSlicePlanes( ~, obj, props, eventName )



if isempty( obj ) || ~isvalid( obj ) || ~isprop( obj, 'SlicePlaneValues' )
return ;
end 



oldPlanes = obj.SlicePlanes_I;

switch eventName
case "SlicePlaneAdded"


if any( obj.Size > 0 )
bbox = [ 0, 0, 0;obj.Size ];
elseif any( obj.OverlaySize > 0 )
bbox = [ 0, 0, 0;obj.OverlaySize ];
else 
return ;
end 
planes = obj.SlicePlaneValues;
if size( planes, 1 ) < 6
planes = images.ui.graphics3d.internal.addNewPlane( planes, bbox );
end 
obj.SlicePlaneValues = planes;
eventName = 'SlicePlanesChanged';
planes = obj.SlicePlanes_I;

case "SlicePlaneRemoved"
planes = obj.SlicePlaneValues;
if size( planes, 1 ) >= props.Index
planes( props.Index, : ) = [  ];
obj.SlicePlaneValues = planes;
end 
planes = planes';
eventName = 'SlicePlanesChanged';

case "SlicePlaneSnapped"
planes = obj.SlicePlaneValues;
bbox = obj.BoundingBox;
if size( planes, 1 ) >= props.Index
centroid = bbox( 1, : ) + ( ( bbox( 2, : ) - bbox( 1, : ) ) / 2 );
planes( props.Index, : ) = [ props.Vector,  - dot( props.Vector, centroid ) ];
obj.SlicePlaneValues = planes;
end 
planes = planes';
eventName = 'SlicePlanesChanged';

otherwise 
planes = oldPlanes;
if isfield( props, 'SlicePlane' )
planes( :, props.Index ) = props.SlicePlane;
end 
obj.SlicePlanes_I = planes;
end 

notify( obj, eventName, images.ui.graphics3d.events.SlicePlanesChangedEventData(  ...
planes', oldPlanes' ) );
end 


function sendBinaryData( self, instructionSet )


data = getContainerData( self.ChildrenInternal( instructionSet.Index + 1 ) );
self.ResponseReceived = false;
self.BinaryChannel.send( data );
waitForMessageService( self );
end 


function showContextMenu( self, pos, id )



positionInFigureCoords = getpixelposition( self.HTML, true );
menuPosition = [ positionInFigureCoords( 1 ) + pos( 1 ), positionInFigureCoords( 2 ) + positionInFigureCoords( 4 ) - pos( 2 ) ];
if id < 0
if ~isempty( self.ContextMenu )

self.ContextMenu.Position = menuPosition;
set( self.ContextMenu, 'Visible', 'on' );
end 
elseif ~isempty( self.PlaneContextMenu )

if ~isempty( self.CurrentObject ) && isa( self.CurrentObject, 'images.ui.graphics3d.Volume' ) &&  ...
self.SlicingAllowed_I && any( self.SliceInteractions_I ) && self.CurrentObject.RenderingStyle == "SlicePlanes"
sliceVisible = "on";
clipVisible = "off";
obj = self.CurrentObject;
removeEnable = matlab.lang.OnOffSwitchState( self.SliceInteractions_I( 2 ) );
rotateEnable = matlab.lang.OnOffSwitchState( self.SliceInteractions_I( 3 ) );
removeFcn = @( ~, ~ )updateSlicePlanes( self, obj, struct( 'Index', id + 1 ), 'SlicePlaneRemoved' );
else 
sliceVisible = "off";
clipVisible = "on";
removeEnable = matlab.lang.OnOffSwitchState( self.ClippingInteractions_I( 2 ) );
rotateEnable = matlab.lang.OnOffSwitchState( self.ClippingInteractions_I( 3 ) );
if self.GlobalClipping
obj = self;
else 
obj = self.CurrentObject;
if isempty( obj )
return ;
end 
end 
removeFcn = @( ~, ~ )removePlane( self, obj, id + 1 );
end 

if ~( removeEnable || rotateEnable )



return ;
end 





set( self.RemoveMenuItem, 'MenuSelectedFcn', removeFcn, 'Enable', removeEnable );
set( self.FlipMenuItem, 'MenuSelectedFcn', @( ~, ~ )flipPlane( self, obj, id + 1 ), 'Visible', clipVisible, 'Enable', rotateEnable );
set( self.SnapPositiveXItem, 'MenuSelectedFcn', @( ~, ~ )snapPlane( self, obj, id + 1, [ 1, 0, 0 ] ), 'Visible', clipVisible );
set( self.SnapNegativeXItem, 'MenuSelectedFcn', @( ~, ~ )snapPlane( self, obj, id + 1, [  - 1, 0, 0 ] ), 'Visible', clipVisible );
set( self.SnapPositiveYItem, 'MenuSelectedFcn', @( ~, ~ )snapPlane( self, obj, id + 1, [ 0, 1, 0 ] ), 'Visible', clipVisible );
set( self.SnapNegativeYItem, 'MenuSelectedFcn', @( ~, ~ )snapPlane( self, obj, id + 1, [ 0,  - 1, 0 ] ), 'Visible', clipVisible );
set( self.SnapPositiveZItem, 'MenuSelectedFcn', @( ~, ~ )snapPlane( self, obj, id + 1, [ 0, 0, 1 ] ), 'Visible', clipVisible );
set( self.SnapNegativeZItem, 'MenuSelectedFcn', @( ~, ~ )snapPlane( self, obj, id + 1, [ 0, 0,  - 1 ] ), 'Visible', clipVisible );
set( self.SnapXItem, 'MenuSelectedFcn', @( ~, ~ )updateSlicePlanes( self, obj, struct( 'Index', id + 1, 'Vector', [  - 1, 0, 0 ] ), 'SlicePlaneSnapped' ), 'Visible', sliceVisible );
set( self.SnapYItem, 'MenuSelectedFcn', @( ~, ~ )updateSlicePlanes( self, obj, struct( 'Index', id + 1, 'Vector', [ 0,  - 1, 0 ] ), 'SlicePlaneSnapped' ), 'Visible', sliceVisible );
set( self.SnapZItem, 'MenuSelectedFcn', @( ~, ~ )updateSlicePlanes( self, obj, struct( 'Index', id + 1, 'Vector', [ 0, 0,  - 1 ] ), 'SlicePlaneSnapped' ), 'Visible', sliceVisible );
set( self.SnapPopupItem, 'Enable', rotateEnable );

open( self.PlaneContextMenu, menuPosition );
end 
end 


function hideContextMenu( self )

if ~isempty( self.ContextMenu ) && self.ContextMenu.Visible == "on"
self.ContextMenu.Visible = 'off';
end 
if ~isempty( self.PlaneContextMenu ) && self.PlaneContextMenu.Visible == "on"
self.PlaneContextMenu.Visible = 'off';
end 
end 


function flipPlane( ~, obj, id )

if ~isempty( obj ) && isvalid( obj )
oldPlanes = obj.ClippingPlanes;
planes = oldPlanes;
if size( planes, 1 ) >= id
planes( id, : ) =  - planes( id, : );
obj.ClippingPlanes = planes;
notify( obj, 'ClippingPlanesChanged',  ...
images.ui.graphics3d.events.ClippingPlanesChangedEventData(  ...
planes, oldPlanes ) );
end 
end 
end 


function snapPlane( ~, obj, id, vec3 )


if ~isempty( obj ) && isvalid( obj )
oldPlanes = obj.ClippingPlanes;
planes = oldPlanes;
bbox = obj.BoundingBox;
if size( planes, 1 ) >= id
centroid = bbox( 1, : ) + ( ( bbox( 2, : ) - bbox( 1, : ) ) / 2 );
planes( id, : ) = [ vec3,  - dot( vec3, centroid ) ];
obj.ClippingPlanes = planes;
notify( obj, 'ClippingPlanesChanged',  ...
images.ui.graphics3d.events.ClippingPlanesChangedEventData(  ...
planes, oldPlanes ) );
end 
end 
end 


function removePlane( ~, obj, id )

if ~isempty( obj ) && isvalid( obj )
oldPlanes = obj.ClippingPlanes;
planes = oldPlanes;
if size( planes, 1 ) >= id
planes( id, : ) = [  ];
obj.ClippingPlanes = planes;
notify( obj, 'ClippingPlanesChanged',  ...
images.ui.graphics3d.events.ClippingPlanesChangedEventData(  ...
planes, oldPlanes ) );
end 
end 
end 


function setAllInteractions( self, TF )
self.Interactions_I = [ TF, TF, TF, TF ];
self.ClippingAllowed_I = TF;
self.SlicingAllowed_I = TF;
end 


function addClippingPlane( self )



if self.GlobalClipping
obj = self;
bbox = self.BoundingBox;
else 
obj = self.CurrentObject;
if isempty( obj )
return ;
end 
bbox = self.CurrentObject.BoundingBox;
end 
planes = obj.ClippingPlanes;
if size( planes, 1 ) < 6
planes = images.ui.graphics3d.internal.addNewPlane( planes, bbox );
end 
obj.ClippingPlanes = planes;
end 


function color = getNextColor( self )

colors = lines( 7 );
color = colors( self.ColorIndex, : );
if self.ColorIndex == 7
self.ColorIndex = 1;
else 
self.ColorIndex = self.ColorIndex + 1;
end 
end 


function throwWarning( self, msg, details )



if self.ShowWarnings
s = warning( 'off', 'backtrace' );
warning( msg );
warning( s );
end 
notify( self, 'WarningThrown', images.ui.graphics3d.events.WarningThrownEventData( msg.Identifier, getString( msg ), details ) );
end 


function initializeClient( self )

if ~self.UseBrowser
switch class( self.Parent_I )
case "matlab.ui.Figure"
if self.Units_I == "pixels" && self.Parent_I.Units == "pixels"
self.Position_I = [ 0, 0, self.Parent_I.Position( 3:4 ) + 1 ];
else 
self.Position_I = hgconvertunits( self.Parent_I,  ...
[ 0, 0, 1, 1 ], "normalized", self.Units_I, self.Parent_I );
end 
case { "matlab.ui.container.Panel", "matlab.ui.container.Tab" }
if self.Units_I == "normalized"
self.Position_I = [ 0, 0, 1, 1 ];
else 
pos = [ self.Parent_I.InnerPosition( 1:2 ) - self.Parent_I.Position( 1:2 ), self.Parent_I.InnerPosition( 3:4 ) ];
self.Position_I = hgconvertunits( ancestor( self.Parent_I, 'figure' ),  ...
pos, self.Parent_I.Units, self.Units_I, self.Parent_I );
end 
otherwise 


end 
set( self.HTML, 'Visible', 'on' );
createPlaneContextMenu( self );
end 



connector.ensureServiceOn;
connector.newNonce;
[ ~, channelName ] = fileparts( tempname );
self.MessageServiceChannel = [ '/images-threejs-ui/', channelName ];
self.MessageToken = channelName;


self.BinaryChannel = connector.internal.binary.BinaryStream( [ channelName, 'Binary' ] );

self.MessageService = message.subscribe( self.MessageServiceChannel,  ...
@( msg )self.onMessageServiceResponse( msg ) );
self.ResponseReceived = false;

if self.UseDebug
url = "toolbox/images/volume/web/images-threejs/index-debug.html?clientid=" + channelName;
else 
url = "toolbox/images/volume/web/images-threejs/index.html?clientid=" + channelName;
end 

if self.UseBrowser
web( connector.getUrl( url ), '-browser' );
else 
self.HTML.HTMLSource = connector.getUrl( url );
end 
end 


function createPlaneContextMenu( self )

hFig = ancestor( self.Parent_I, 'figure' );
self.PlaneContextMenu = uicontextmenu( hFig, 'Tag', 'IPTPlaneContextMenu', 'HandleVisibility', 'off' );

self.FlipMenuItem = uimenu( self.PlaneContextMenu, 'Text', getString( message( 'images:volume:flipPlane' ) ) );
self.SnapPopupItem = uimenu( self.PlaneContextMenu, 'Text', getString( message( 'images:volume:snapPlane' ) ) );
self.RemoveMenuItem = uimenu( self.PlaneContextMenu, 'Text', getString( message( 'images:volume:removePlane' ) ), 'Separator', 'on' );
self.SnapPositiveXItem = uimenu( self.SnapPopupItem, 'Text', getString( message( 'images:volume:planeDirection', '+x' ) ) );
self.SnapNegativeXItem = uimenu( self.SnapPopupItem, 'Text', getString( message( 'images:volume:planeDirection', '-x' ) ) );
self.SnapPositiveYItem = uimenu( self.SnapPopupItem, 'Text', getString( message( 'images:volume:planeDirection', '+y' ) ) );
self.SnapNegativeYItem = uimenu( self.SnapPopupItem, 'Text', getString( message( 'images:volume:planeDirection', '-y' ) ) );
self.SnapPositiveZItem = uimenu( self.SnapPopupItem, 'Text', getString( message( 'images:volume:planeDirection', '+z' ) ) );
self.SnapNegativeZItem = uimenu( self.SnapPopupItem, 'Text', getString( message( 'images:volume:planeDirection', '-z' ) ) );
self.SnapXItem = uimenu( self.SnapPopupItem, 'Text', getString( message( 'images:volume:planeDirection', 'x' ) ) );
self.SnapYItem = uimenu( self.SnapPopupItem, 'Text', getString( message( 'images:volume:planeDirection', 'y' ) ) );
self.SnapZItem = uimenu( self.SnapPopupItem, 'Text', getString( message( 'images:volume:planeDirection', 'z' ) ) );
end 

end 

methods ( Sealed, Access = protected )

function group = getPropertyGroups( self )

propList = { 'Parent', 'Position', 'Children' };
if self.GlobalClipping_I
otherList = { 'BackgroundColor', 'BackgroundGradient', 'GradientColor', 'OrientationAxes', 'ClippingPlanes', 'Lighting', 'LightPosition' };
else 
otherList = { 'BackgroundColor', 'BackgroundGradient', 'GradientColor', 'OrientationAxes', 'Lighting' };
end 
cameraList = { 'CameraPosition', 'CameraTarget', 'CameraUpVector', 'CameraZoom' };

group = [ matlab.mixin.util.PropertyGroup( propList ),  ...
matlab.mixin.util.PropertyGroup( otherList ),  ...
matlab.mixin.util.PropertyGroup( cameraList ) ];

end 

end 

methods ( Hidden )



function openDevTools( self )

assert( ~self.UseBrowser, 'Not supported in browser. Use the browser''s native dev tools.' );
figURL = matlab.ui.internal.FigureServices.getFigureURL( ancestor( self.Parent_I, 'figure' ) );
wmgr = matlab.internal.webwindowmanager.instance;
window = findobj( wmgr.windowList, 'URL', figURL );
window.executeJS( 'cefclient.sendMessage("openDevTools");' );
end 

end 

methods ( Hidden, Access = ?matlab.uitest.TestCase )


function receiveClientMessage( self, msg )


onMessageServiceResponse( self, msg );
end 


function loseContext( self )


request( self, 'testWebGLContext', struct(  ) );
end 


function forceRecovery( self )
restore( self, "full" );
end 


function menu = getPlaneMenu( self )

menu = self.PlaneContextMenu;
end 

end 

methods 




function set.CameraPosition( self, val )
self.CameraPosition_I = val;
self.CameraAutoMode_I( 1 ) = false;
markViewerDirty( self );
end 

function val = get.CameraPosition( self )
val = self.CameraPosition_I;
end 




function set.CameraTarget( self, val )
self.CameraTarget_I = val;
self.CameraAutoMode_I( 2 ) = false;
markViewerDirty( self );
end 

function val = get.CameraTarget( self )
val = self.CameraTarget_I;
end 




function set.CameraUpVector( self, val )
self.CameraUpVector_I = val;
self.CameraAutoMode_I( 3 ) = false;
markViewerDirty( self );
end 

function val = get.CameraUpVector( self )
val = self.CameraUpVector_I;
end 




function set.CameraZoom( self, val )
self.CameraZoom_I = val;
self.CameraAutoMode_I( 4 ) = false;
markViewerDirty( self );
end 

function val = get.CameraZoom( self )
val = self.CameraZoom_I;
end 




function set.CameraPositionMode( self, val )
self.CameraAutoMode_I( 1 ) = val == "auto";
markViewerDirty( self );
end 

function val = get.CameraPositionMode( self )
if self.CameraAutoMode_I( 1 )
val = "auto";
else 
val = "manual";
end 
end 




function set.CameraTargetMode( self, val )
self.CameraAutoMode_I( 2 ) = val == "auto";
markViewerDirty( self );
end 

function val = get.CameraTargetMode( self )
if self.CameraAutoMode_I( 2 )
val = "auto";
else 
val = "manual";
end 
end 




function set.CameraUpVectorMode( self, val )
self.CameraAutoMode_I( 3 ) = val == "auto";
markViewerDirty( self );
end 

function val = get.CameraUpVectorMode( self )
if self.CameraAutoMode_I( 3 )
val = "auto";
else 
val = "manual";
end 
end 




function set.CameraZoomMode( self, val )
self.CameraAutoMode_I( 4 ) = val == "auto";
markViewerDirty( self );
end 

function val = get.CameraZoomMode( self )
if self.CameraAutoMode_I( 4 )
val = "auto";
else 
val = "manual";
end 
end 




function set.BackgroundGradient( self, TF )
self.BackgroundGradient_I = TF;
markViewerDirty( self );
end 

function TF = get.BackgroundGradient( self )
TF = matlab.lang.OnOffSwitchState( self.BackgroundGradient_I );
end 




function set.GradientColor( self, color )
self.GradientColor_I = color;
markViewerDirty( self );
end 

function color = get.GradientColor( self )
color = self.GradientColor_I;
end 




function set.Lighting( self, TF )
self.Lighting_I = TF;
markViewerDirty( self );
end 

function TF = get.Lighting( self )
TF = matlab.lang.OnOffSwitchState( self.Lighting_I );
end 




function set.LightColor( self, color )
self.LightColor_I = color;
markViewerDirty( self );
end 

function color = get.LightColor( self )
color = self.LightColor_I;
end 




function set.LightPosition( self, val )
self.LightPosition_I = val;
self.CameraAutoMode_I( 5 ) = false;
markViewerDirty( self );
end 

function val = get.LightPosition( self )
val = self.LightPosition_I;
end 




function set.LightPositionMode( self, val )
self.CameraAutoMode_I( 5 ) = val == "auto";
markViewerDirty( self );
end 

function val = get.LightPositionMode( self )
if self.CameraAutoMode_I( 5 )
val = "auto";
else 
val = "manual";
end 
end 




function set.DepthPeeling( self, TF )
self.DepthPeeling_I = TF;
self.DepthPeelingMode_I = "manual";
markViewerDirty( self );
end 

function TF = get.DepthPeeling( self )
TF = matlab.lang.OnOffSwitchState( self.DepthPeeling_I );
end 




function set.DepthPeelingMode( self, mode )
self.DepthPeelingMode_I = mode;
markViewerDirty( self );
end 

function mode = get.DepthPeelingMode( self )
mode = string( self.DepthPeelingMode_I );
end 




function set.ViewDepth( self, val )
self.ViewDepth_I = val;
if self.ViewDepth_I > 0
self.DepthPeeling_I = true;
self.DepthPeelingMode_I = "manual";
else 
self.DepthPeelingMode_I = "auto";
end 
markViewerDirty( self );
end 

function TF = get.ViewDepth( self )
TF = self.ViewDepth_I;
end 




function set.KeepDataReference( self, TF )
self.KeepInMemory_I = TF;
set( self.ChildrenInternal, 'KeepOriginalDataCopy', self.KeepInMemory_I );
end 

function TF = get.KeepDataReference( self )
TF = matlab.lang.OnOffSwitchState( self.KeepInMemory_I );
end 




function set.ClippingInteractions( self, str )
self.ClippingInteractions_I = images.ui.graphics3d.internal.setPlaneInteractions( str, "clip" );
markViewerDirty( self );
end 

function str = get.ClippingInteractions( self )
str = images.ui.graphics3d.internal.getPlaneInteractions( self.ClippingInteractions_I );
end 




function set.Interactions( self, str )
R36
self
str( :, 1 )string
end 

setAllInteractions( self, false );
if ~isempty( str )
validStrings = { 'all', 'none', 'rotate', 'zoom', 'pan', 'axes', 'clip', 'slice' };

for idx = 1:numel( str )
validString = validatestring( str( idx ), validStrings );

switch validString
case "all"
if numel( str ) > 1
error( message( 'images:volume:interactionsString' ) );
end 
setAllInteractions( self, true );

case "none"
if numel( str ) > 1
error( message( 'images:volume:interactionsString' ) );
end 
setAllInteractions( self, false );

case "rotate"
self.Interactions_I( 1 ) = true;

case "zoom"
self.Interactions_I( 2 ) = true;

case "pan"
self.Interactions_I( 3 ) = true;

case "axes"
self.Interactions_I( 4 ) = true;

case "clip"
self.ClippingAllowed_I = true;

case "slice"
self.SlicingAllowed_I = true;


end 
end 
end 
markViewerDirty( self );
end 

function str = get.Interactions( self )
n = sum( [ self.Interactions_I, self.ClippingAllowed_I, self.SlicingAllowed_I ] );
switch n
case 6
str = "all";
case 0
str = "none";
otherwise 
str = [  ];
if self.Interactions_I( 1 )
str = [ str, "rotate" ];
end 
if self.Interactions_I( 2 )
str = [ str, "zoom" ];
end 
if self.Interactions_I( 3 )
str = [ str, "pan" ];
end 
if self.Interactions_I( 4 )
str = [ str, "axes" ];
end 
if self.ClippingAllowed_I
str = [ str, "clip" ];
end 
if self.SlicingAllowed_I
str = [ str, "slice" ];
end 
end 
end 




function set.SliceInteractions( self, str )
self.SliceInteractions_I = images.ui.graphics3d.internal.setPlaneInteractions( str, "slice" );
markViewerDirty( self );
end 

function str = get.SliceInteractions( self )
str = images.ui.graphics3d.internal.getPlaneInteractions( self.SliceInteractions_I );
end 




function set.Toolbar( self, TF )
self.Toolbar_I = TF;
markViewerDirty( self );
end 

function TF = get.Toolbar( self )
TF = matlab.lang.OnOffSwitchState( self.Toolbar_I );
end 




function set.OrientationAxes( self, TF )
self.OrientationAxes_I = TF;
markViewerDirty( self );
end 

function TF = get.OrientationAxes( self )
TF = matlab.lang.OnOffSwitchState( self.OrientationAxes_I );
end 




function set.OrientationAxesLabels( self, str )
self.OrientationAxesLabels_I = str;
markViewerDirty( self );
end 

function str = get.OrientationAxesLabels( self )
str = self.OrientationAxesLabels_I;
end 




function set.MaxCanvasSize( self, sz )
self.MaxCanvasSize_I = sz;
markViewerDirty( self );
end 

function sz = get.MaxCanvasSize( self )
sz = self.MaxCanvasSize_I;
end 




function set.Badge( self, str )
self.Badge_I = str;
markViewerDirty( self );
end 

function str = get.Badge( self )
str = self.Badge_I;
end 




function set.Antialiasing( self, str )
self.Antialiasing_I = str;
markViewerDirty( self );
end 

function str = get.Antialiasing( self )
str = self.Antialiasing_I;
end 




function set.Box( self, TF )
self.Box_I = TF;
markViewerDirty( self );
end 

function TF = get.Box( self )
TF = matlab.lang.OnOffSwitchState( self.Box_I );
end 




function set.Busy( self, TF )
self.Busy_I = TF;
if self.ViewerReady
request( self, 'busy', struct( 'Busy', TF ) );
end 
end 

function TF = get.Busy( self )
TF = self.Busy_I;
end 




function set.ClippingPlanes( self, planes )
if size( planes, 1 ) > 6
error( message( 'images:volume:clippingPlaneMax' ) );
end 
planes = images.ui.graphics3d.internal.validatePlanes( planes, [  ], false );
self.ClippingPlanes_I = planes';
markViewerDirty( self );
end 

function planes = get.ClippingPlanes( self )
planes = self.ClippingPlanes_I';
end 




function set.GlobalClipping( self, TF )
self.GlobalClipping_I = TF;
markViewerDirty( self );
end 

function TF = get.GlobalClipping( self )
TF = matlab.lang.OnOffSwitchState( self.GlobalClipping_I );
end 




function set.ClipIntersection( self, TF )
self.ClipIntersection_I = TF;
markViewerDirty( self );
end 

function TF = get.ClipIntersection( self )
TF = matlab.lang.OnOffSwitchState( self.ClipIntersection_I );
end 




function set.ScaleBar( self, TF )
self.ScaleBar_I = TF;
markViewerDirty( self );
end 

function TF = get.ScaleBar( self )
TF = matlab.lang.OnOffSwitchState( self.ScaleBar_I );
end 




function set.ScaleBarUnits( self, str )
self.ScaleBarUnits_I = str;
markViewerDirty( self );
end 

function str = get.ScaleBarUnits( self )
str = self.ScaleBarUnits_I;
end 




function set.RenderingQuality( self, val )
if ischar( val ) || isstring( val )
val = string( validatestring( val, { 'auto', 'high', 'medium', 'low' } ) );
else 
validateattributes( val, { 'numeric' }, { 'scalar', 'integer', '>=', 0, '<=', 11, 'real', 'nonsparse' } );
val = uint8( val );
end 

self.RenderingQuality_I = val;
markViewerDirty( self );
end 

function val = get.RenderingQuality( self )
val = self.RenderingQuality_I;
end 




function set.Tooltip( self, val )
self.HTML.Tooltip = val;
end 

function val = get.Tooltip( self )
val = self.HTML.Tooltip;
end 




function set.CurrentObject( self, obj )
idx = find( self.ChildrenInternal == obj, 1 );

if isempty( idx )
error( message( 'images:volume:invalidCurrentObject' ) );
end 

self.CurrentObject_I = idx;
markViewerDirty( self );
end 

function obj = get.CurrentObject( self )
if self.CurrentObject_I > 0
obj = self.ChildrenInternal( self.CurrentObject_I );
else 
obj = [  ];
end 
end 




function set.Dirty( self, TF )
self.Dirty_I = TF;
end 

function TF = get.Dirty( self )
TF = self.Dirty_I;
end 

end 

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpzQX5YB.p.
% Please follow local copyright laws when handling this file.

