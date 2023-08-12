classdef ( Hidden )Geographic3DModelViewer < globe.internal.VisualizationViewer




















methods 
function viewer = Geographic3DModelViewer( globeController )

if nargin < 1
globeController = globe.internal.GlobeController;
end 

viewer = viewer@globe.internal.VisualizationViewer( globeController );
primitiveController = globe.internal.PrimitiveController( globeController );
viewer.PrimitiveController = primitiveController;
end 


function [ ID, plotDescriptors ] = geoModel3D( viewer, model, location, varargin )
[ ID, plotDescriptors ] = viewer.buildPlotDescriptors( model, location, varargin{ : } );
viewer.PrimitiveController.plot( 'show3DModel', plotDescriptors );
end 

function [ ID, data ] = buildPlotDescriptors( viewer, geomodel, location, NameValueArgs )

R36
viewer %#ok<INUSA> 
geomodel
location
NameValueArgs.Animation = ''
NameValueArgs.EnableWindowLaunch = true
NameValueArgs.MinPixelSize( 1, 1 )double{ mustBeNonnegative, mustBeFinite, mustBeNonsparse } = 0
NameValueArgs.Scale( 1, 1 )double{ mustBeNonnegative, mustBeFinite, mustBeNonsparse } = 1
NameValueArgs.RenderWireframe( 1, 1 )logical{ mustBeNonsparse } = false
NameValueArgs.Color = [ 1, 1, 1 ]
NameValueArgs.Transparency( 1, 1 )double{ mustBeInRange( NameValueArgs.Transparency, 0, 1 ) } = 1
NameValueArgs.ColorBlendMode{ mustBeMember( NameValueArgs.ColorBlendMode, { 'replace', 'mix', 'highlight' } ) } = 'highlight'
NameValueArgs.ColorBlendAmount( 1, 1 )double{ mustBeInRange( NameValueArgs.ColorBlendAmount, 0, 1 ) } = 0.5
NameValueArgs.Persistent( 1, 1 )logical{ mustBeNonsparse } = false
NameValueArgs.BoundingSphereRadius = geomodel.BoundingSphereRadius
NameValueArgs.ID
NameValueArgs.ShowIn2D( 1, 1 )logical{ mustBeNonsparse } = false
NameValueArgs.Rotation = [ 0;0;0 ]
NameValueArgs.AllowPicking( 1, 1 )logical = false
NameValueArgs.FlashlightOn( 1, 1 )logical = true
end 

animation = NameValueArgs.Animation;
enableWindowLaunch = NameValueArgs.EnableWindowLaunch;
minSize = NameValueArgs.MinPixelSize;
scale = NameValueArgs.Scale;
renderWireframe = NameValueArgs.RenderWireframe;
geomodel.Color = NameValueArgs.Color;
transparency = NameValueArgs.Transparency;
colorBlendMode = NameValueArgs.ColorBlendMode;
colorBlendAmount = NameValueArgs.ColorBlendAmount;
persistentModel = NameValueArgs.Persistent;
boundingSphereRadius = NameValueArgs.BoundingSphereRadius;
rotation = NameValueArgs.Rotation;
showIn2D = NameValueArgs.ShowIn2D;
allowPicking = NameValueArgs.AllowPicking;
flashlightOn = NameValueArgs.FlashlightOn;
if ( isfield( NameValueArgs, 'ID' ) )
geomodel.UID = NameValueArgs.ID;
end 




file = [ tempname, '.glb' ];
writer = globe.internal.GLBFileWriter( file, geomodel.Model, 'VertexColors', geomodel.VertexColors,  ...
'EnableLighting', geomodel.EnableLighting, 'YUpCoordinate', geomodel.YUpCoordinate,  ...
'MetallicFactor', geomodel.MetallicFactor, 'RoughnessFactor', geomodel.RoughnessFactor,  ...
'Opacity', transparency );
write( writer );
ID = geomodel.UID;
url = globe.internal.ConnectorServiceProvider.getResourceURL( file, [ 'geo3dmodel', ID ] );
geomodel.File = file;



rotation( 1 ) =  - rotation( 1 );


data = struct(  ...
'ID', ID,  ...
'EnableWindowLaunch', enableWindowLaunch,  ...
'Animation', animation,  ...
'Location', location,  ...
'URL', url,  ...
'Angle', rotation,  ...
'RenderWireframe', renderWireframe,  ...
'MinSize', minSize,  ...
'Scale', scale,  ...
'Color', geomodel.Color,  ...
'ColorBlendMode', colorBlendMode,  ...
'ColorBlendAmount', colorBlendAmount,  ...
'Persistent', persistentModel,  ...
'BoundingSphereRadius', boundingSphereRadius,  ...
'ShowIn2D', showIn2D,  ...
'AllowPicking', allowPicking,  ...
'FlashlightOn', flashlightOn );
end 


function delete( viewer )
if ~isempty( viewer ) && ~isempty( viewer.PrimitiveController ) ...
 && isvalid( viewer.PrimitiveController )
delete( viewer.PrimitiveController )
end 
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpUZ1mDA.p.
% Please follow local copyright laws when handling this file.

