classdef ( Hidden )GlobeViewer < globe.internal.GlobeModelViewer &  ...
globe.internal.GlobeGraphicsViewer






































properties 
GraphicsMap
end 
properties ( SetAccess = private )
Queue = false
CompositeModel
CompositeController
MouseController
end 

methods ( Access = public )
function listener = addlistener( obj, type, fcn )
listener = addlistener( obj.MouseController, type, fcn );
end 
end 

methods 
function viewer = GlobeViewer( varargin )








controller = globe.internal.GlobeController(  );
viewer@globe.internal.GlobeModelViewer( controller, varargin{ : } );
viewer@globe.internal.GlobeGraphicsViewer( controller );
globe.internal.GlobeViewer.current( viewer );
viewer.GraphicsMap = containers.Map( 'KeyType', 'char', 'ValueType', 'any' );



viewer.addViewer( 'Line', globe.internal.LineViewer( controller ) );
viewer.addViewer( 'Marker', globe.internal.MarkerViewer( controller ) );
viewer.addViewer( 'Point', globe.internal.PointViewer( controller ) );
viewer.addViewer( 'Image', globe.internal.ImageViewer( controller ) );
viewer.addViewer( 'Surface', globe.internal.SurfaceViewer( controller ) );
viewer.addViewer( 'PointCollection', globe.internal.PointCollectionViewer( controller ) );
viewer.addViewer( 'LineCollection', globe.internal.LineCollectionViewer( controller ) );
viewer.addViewer( 'LabelCollection', globe.internal.LabelCollectionViewer( controller ) );
viewer.addViewer( 'Ellipsoid', globe.internal.EllipsoidViewer( controller ) );
viewer.addViewer( 'Legend', globe.internal.LegendViewer( controller ) );
viewer.addViewer( 'GeoModel3D', globe.internal.Geographic3DModelViewer( controller ) );
viewer.addViewer( 'Buildings3DModel', globe.internal.Buildings3DModelViewer( controller ) );
viewer.addViewer( 'Label', globe.internal.LabelViewer( controller ) );
viewer.CompositeModel = globe.internal.CompositeModel;
viewer.CompositeController = globe.internal.CompositeController( controller );
viewer.MouseController = globe.internal.MouseController( controller );
end 

function viewer = addViewer( viewer, viewerName, graphicViewer )
viewer.GraphicsMap( viewerName ) = graphicViewer;
end 

function visualizationViewer = getViewer( viewer, viewerName )
visualizationViewer = viewer.GraphicsMap( viewerName );
end 

function IDs = marker( viewer, location, icon, varargin )
markerViewer = viewer.getViewer( 'Marker' );
if ( viewer.Queue )
[ IDs, data ] = markerViewer.buildPlotDescriptors( location, icon, varargin{ : } );
viewer.CompositeModel.addGraphic( 'marker', data );
else 
IDs = markerViewer.marker( location, icon, varargin{ : } );
end 
end 

function IDs = line( viewer, locations, varargin )
lineViewer = viewer.getViewer( 'Line' );
if ( viewer.Queue )
[ IDs, data ] = lineViewer.buildPlotDescriptors( locations, varargin{ : } );
viewer.CompositeModel.addGraphic( 'line', data );
else 
IDs = lineViewer.line( locations, varargin{ : } );
end 
end 

function ID = lineCollection( viewer, locations, varargin )
lineCollectionViewer = viewer.getViewer( 'LineCollection' );
if ( viewer.Queue )
[ ID, data ] = lineCollectionViewer.buildPlotDescriptors( locations, varargin{ : } );
viewer.CompositeModel.addGraphic( 'lineCollection', data );
else 
ID = lineCollectionViewer.lineCollection( locations, varargin{ : } );
end 
end 

function IDs = point( viewer, location, varargin )
pointViewer = viewer.getViewer( 'Point' );
if ( viewer.Queue )
[ IDs, data ] = pointViewer.buildPlotDescriptors( location, varargin{ : } );
viewer.CompositeModel.addGraphic( 'point', data );
else 
IDs = pointViewer.point( location, varargin{ : } );
end 
end 

function ID = label( viewer, text, location, varargin )
labelViewer = viewer.getViewer( 'Label' );
if ( viewer.Queue )
[ ID, data ] = labelViewer.buildPlotDescriptors( text, location, varargin{ : } );
viewer.CompositeModel.addGraphic( 'label', data );
else 
ID = labelViewer.label( text, location, varargin{ : } );
end 
end 

function ID = pointCollection( viewer, locations, varargin )
pointCollectionViewer = viewer.getViewer( 'PointCollection' );
if ( viewer.Queue )
[ ID, data ] = pointCollectionViewer.buildPlotDescriptors( locations, varargin{ : } );
viewer.CompositeModel.addGraphic( 'pointCollection', data );
else 
ID = pointCollectionViewer.pointCollection( locations, varargin{ : } );
end 
end 

function ID = labelCollection( viewer, locations, labels, varargin )
labelCollectionViewer = viewer.getViewer( 'LabelCollection' );
if ( viewer.Queue )
[ ID, data ] = labelCollectionViewer.buildPlotDescriptors( locations, labels, varargin{ : } );
viewer.CompositeModel.addGraphic( 'labelCollection', data );
else 
ID = labelCollectionViewer.labelCollection( locations, labels, varargin{ : } );
end 
end 

function IDs = image( viewer, imageFile, cornerLocations, varargin )
imageViewer = viewer.getViewer( 'Image' );
if ( viewer.Queue )
[ IDs, data ] = imageViewer.buildPlotDescriptors( imageFile, cornerLocations, varargin{ : } );
viewer.CompositeModel.addGraphic( 'image', data );
else 
IDs = imageViewer.image( imageFile, cornerLocations, varargin{ : } );
end 
end 

function IDs = surface( viewer, location, xyzCoordinates, indices, colors, varargin )
surfaceViewer = viewer.getViewer( 'Surface' );
if ( viewer.Queue )
[ IDs, data ] = surfaceViewer.buildPlotDescriptors( location, xyzCoordinates, indices, colors, varargin{ : } );
viewer.CompositeModel.addGraphic( 'surface', data );
else 
IDs = surfaceViewer.surface( location, xyzCoordinates, indices, colors, varargin{ : } );
end 
end 

function IDs = ellipsoid( viewer, location, radii, varargin )
ellipsoidViewer = viewer.getViewer( 'Ellipsoid' );
if ( viewer.Queue )
[ IDs, data ] = ellipsoidViewer.buildPlotDescriptors( location, radii, varargin{ : } );
viewer.CompositeModel.addGraphic( 'ellipsoid', data );
else 
IDs = ellipsoidViewer.ellipsoid( location, radii, varargin{ : } );
end 
end 

function ID = geoModel3D( viewer, model, location, varargin )
geoModel3DViewer = viewer.getViewer( 'GeoModel3D' );


[ forcePlot, args ] = extractParamFromVarargin( 'ForcePlot', false, varargin{ : } );
if ( viewer.Queue && ~forcePlot )
[ ID, data ] = geoModel3DViewer.buildPlotDescriptors( model, location, args{ : } );
viewer.CompositeModel.addGraphic( 'show3DModel', data );
else 
ID = geoModel3DViewer.geoModel3D( model, location, args{ : } );
end 

end 

function buildings3DModel( viewer, model )
bldgsViewer = viewer.getViewer( "Buildings3DModel" );
bldgsViewer.buildings3DModel( model );
end 

function ID = legend( viewer, title, colors, values, varargin )
legendViewer = viewer.getViewer( 'Legend' );
if ( viewer.Queue )
[ ID, data ] = legendViewer.buildPlotDescriptors( title, colors, values, varargin{ : } );
if legendViewer.InfoboxLegend
viewer.CompositeModel.addGraphic( 'infoboxColorLegend', data );
else 
viewer.CompositeModel.addGraphic( 'colorLegend', data );
end 
else 
ID = legendViewer.legend( title, colors, values, varargin{ : } );
end 
end 

function queuePlots( viewer )
viewer.Queue = true;
end 

function unqueuePlots( viewer )
viewer.Queue = false;
viewer.CompositeModel.clearModel(  );
end 

function submitPlots( viewer, varargin )
viewer.Queue = false;
if ( isempty( viewer.CompositeModel.PlotTypes ) )

return ;
end 
p = inputParser;
p.addParameter( "Animation", 'fly' );
p.addParameter( "WaitForResponse", true );
p.parse( varargin{ : } );
data = viewer.CompositeModel.buildPlotDescriptors( p.Results.WaitForResponse );
data.Animation = p.Results.Animation;
viewer.CompositeController.composite( data );
viewer.CompositeModel.clearModel(  );
end 

function remove( viewer, id, waitForResponse )
if ( viewer.Queue )
data = remove@globe.internal.GlobeGraphicsViewer( viewer, id, false, true );
viewer.CompositeModel.PlotDescriptors{ end  + 1 } = data;
viewer.CompositeModel.PlotTypes{ end  + 1 } = 'remove';
else 
if ( nargin < 3 )
waitForResponse = true;
end 
remove@globe.internal.GlobeGraphicsViewer( viewer, id, waitForResponse, false );
end 
end 

function delete( viewer )
delete@globe.internal.GlobeModelViewer( viewer );
delete( viewer.MouseController );
end 

function flyToLocation( viewer, location, nameValueArgs )
R36
viewer
location( 1, 2 )double
nameValueArgs.Height( 1, 1 )double
nameValueArgs.Duration( 1, 1 )double = 1
end 
if ~isfield( nameValueArgs, 'Height' )


nameValueArgs.Height = 'maintain';
end 
viewer.Controller.visualRequest( 'flyToLocation', struct(  ...
'EnableWindowLaunch', true,  ...
'Animation', 'fly',  ...
'Location', location,  ...
'Height', nameValueArgs.Height,  ...
'Duration', nameValueArgs.Duration ) );
end 

function setInertialCamera( viewer, onOrOff )
viewer.Controller.visualRequest( 'setInertialCamera', struct(  ...
'EnableWindowLaunch', true,  ...
'Animation', 'none',  ...
'On', onOrOff ) );
end 

function setDayNightLighting( viewer, onOrOff )
viewer.Controller.visualRequest( 'setDayNightLighting', struct(  ...
'EnableWindowLaunch', true,  ...
'Animation', 'none',  ...
'On', onOrOff ) );
end 

function setEnableRotate( viewer, onOrOff )
viewer.Controller.visualRequest( 'setEnableRotate', struct(  ...
'EnableWindowLaunch', true,  ...
'Animation', 'none',  ...
'On', onOrOff ) );
end 

function setDate( viewer, date )
[ julianDay, seconds ] = julianDaySeconds( date );
viewer.Controller.visualRequest( 'setDate', struct(  ...
'EnableWindowLaunch', true,  ...
'Animation', 'none',  ...
'JulianDay', julianDay,  ...
'Seconds', seconds ) );
end 

function setClockBounds( viewer, minTime, maxTime )
[ startTime.julianDay, startTime.seconds ] = julianDaySeconds( minTime );
[ stopTime.julianDay, stopTime.seconds ] = julianDaySeconds( maxTime );
viewer.Controller.visualRequest( 'setClockBounds', struct(  ...
'EnableWindowLaunch', true,  ...
'Animation', 'none',  ...
'StartTime', startTime,  ...
'StopTime', stopTime ) );
end 

function date = getDate( viewer )
julianDate = viewer.Controller.getParameterRequest( 'getDate' );
jd = julianDate.Date.dayNumber;
date = datetime( jd, 'ConvertFrom', 'juliandate', 'TimeZone', 'UTC' );

date = date + seconds( julianDate.Date.secondsOfDay );
end 

function setDimension( viewer, dimension )
viewer.Controller.visualRequest( 'setDimension', struct(  ...
'EnableWindowLaunch', true,  ...
'Animation', 'none',  ...
'Dimension', dimension ) );
end 

function setCameraTarget( viewer, ID, CZMLID )
if ( nargin < 3 )
CZMLID = "";
end 
viewer.Controller.visualRequest( 'setCameraTarget', struct(  ...
'EnableWindowLaunch', true,  ...
'Animation', 'none',  ...
'ID', ID,  ...
'CZMLID', CZMLID ) );
end 

function setPlaybackSpeed( viewer, speed )
viewer.Controller.visualRequest( 'setPlaybackSpeed', struct(  ...
'EnableWindowLaunch', true,  ...
'Animation', 'none',  ...
'Speed', speed ) );
end 

function speed = getPlaybackSpeed( viewer )
speed = viewer.Controller.getParameterRequest( 'getPlaybackSpeed' );
end 

function setTimelineWidget( viewer, onOrOff )
viewer.Controller.visualRequest( 'setTimelineWidget', struct(  ...
'EnableWindowLaunch', true,  ...
'Animation', 'none',  ...
'On', onOrOff ) );
end 

function setAnimationWidget( viewer, onOrOff )
viewer.Controller.visualRequest( 'setAnimationWidget', struct(  ...
'EnableWindowLaunch', true,  ...
'Animation', 'none',  ...
'On', onOrOff ) );
end 

function viewGraphics( viewer, graphicsIDs, animation, isCZML, CZMLID )
if ( nargin < 5 )
CZMLID = "";
end 
viewer.Controller.visualRequest( 'viewGraphics', struct(  ...
'EnableWindowLaunch', true,  ...
'Animation', animation,  ...
'IDs', graphicsIDs,  ...
'IsCZML', isCZML,  ...
'CZMLID', CZMLID ) );
end 

function toggleCZMLVisibility( viewer, graphicsIDs, CZMLID, visibility )
data = struct(  ...
'EnableWindowLaunch', true,  ...
'Animation', 'none',  ...
'IDs', graphicsIDs,  ...
'Visibility', visibility,  ...
'CZMLID', CZMLID );
if viewer.Queue
viewer.CompositeModel.addGraphic( 'toggleCZMLVisibility', data );
else 
viewer.Controller.visualRequest( 'toggleCZMLVisibility', data );
end 
end 
end 


methods ( Static )
function viewer = current( newCurrent )






manager = globe.internal.LifeCycleManager;
oldObjects = manager.AllObjects;


if isempty( oldObjects )
viewer = globe.internal.GlobeViewer.empty;
else 
viewer = manager.CurrentObject;
end 



if isempty( viewer ) && nargin == 0
viewer = globe.internal.GlobeViewer(  );
end 


if nargin > 0


makeCurrent( manager, newCurrent );


viewer = newCurrent;
end 
end 


function oldViewers = all


manager = globe.internal.LifeCycleManager;
oldViewers = manager.AllObjects;
end 


function URL = debug( varargin )












p = inputParser;
isLogicalScalar = @( x )islogical( x ) && isscalar( x );
p.addParameter( 'UseDebug', true, isLogicalScalar );
p.parse( varargin{ : } );
inputs = p.Results;




viewer = globe.internal.GlobeViewer(  ...
'UseDebug', inputs.UseDebug,  ...
'LaunchWebWindow', false );
viewer.Controller.launch;
URL = viewer.URL;
end 
end 
end 

function [ julianDay, jdSeconds ] = julianDaySeconds( date )


dayStart = dateshift( date, 'start', 'day' );
julianDay = juliandate( dayStart );



jdSeconds = seconds( date - dayStart );
end 



function [ paramValue, otherArgs ] = extractParamFromVarargin( paramName, defaultValue, varargin )
p = inputParser;
p.KeepUnmatched = true;
p.addParameter( paramName, defaultValue )
p.parse( varargin{ : } );
paramValue = p.Results.( paramName );

otherArgs = [ fieldnames( p.Unmatched ), struct2cell( p.Unmatched ) ];
otherArgs = otherArgs';
otherArgs = otherArgs( : );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpYjLE2j.p.
% Please follow local copyright laws when handling this file.

