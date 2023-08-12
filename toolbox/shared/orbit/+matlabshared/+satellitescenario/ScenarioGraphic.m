classdef ScenarioGraphic < handle





properties ( Transient, Access = { ?satelliteScenario,  ...
?matlabshared.satellitescenario.Viewer,  ...
?matlabshared.satellitescenario.internal.AddAssetsAndAnalyses,  ...
?satcom.satellitescenario.internal.AddAssetsAndAnalyses,  ...
?matlabshared.satellitescenario.ScenarioGraphic,  ...
?matlabshared.satellitescenario.internal.AssetWrapper,  ...
?matlabshared.satellitescenario.Access,  ...
?satcom.satellitescenario.Link } )
Scenario = 0
end 

properties ( Hidden )
ZoomHeight = 0
ColorConverter = matlabshared.satellitescenario.internal.ColorConverter
end 

properties ( Constant, Hidden )
DefaultColors = struct(  ...
"SatelliteMarkerColor", [ 0.059, 1, 1 ],  ...
"OrbitLineColor", [ 0.059, 1, 1 ],  ...
"SatelliteLabelFontColor", [ 1, 1, 1 ],  ...
"GroundStationMarkerColor", [ 1, .4118, .1608 ],  ...
"GroundStationLabelFontColor", [ 1, 1, 1 ],  ...
"GroundtrackLeadColor", [ 1, 1, .067 ],  ...
"GroundtrackTrailColor", [ 1, 1, .067 ],  ...
"AccessLineColor", [ 0.3922, 0.8314, 0.0745 ],  ...
"LinkLineColor", [ 0.3922, 0.8314, 0.0745 ],  ...
"FieldOfViewColor", [ 1, 0.0745, 0.6510 ] )
end 

methods ( Abstract, Hidden )

updateVisualizations( obj, viewer )



ID = getGraphicID( obj )




addCZMLGraphic( obj, writer, times, initiallyVisible )
end 

methods ( Hidden )






function IDs = getChildGraphicsIDs( obj )%#ok<MANU> 
IDs = [  ];
end 




function objs = getChildObjects( obj )%#ok<MANU> 
objs = {  };
end 



function removeGraphic( obj )
if isa( obj.Scenario, "satelliteScenario" ) && isvalid( obj.Scenario )
hide( obj );
viewers = obj.Scenario.Viewers;
for viewer = viewers
viewer.removeGraphic( obj.getGraphicID );
end 
end 
end 



function ids = hideInViewerState( obj, viewer )
childIDs = obj.getChildGraphicsIDs;
ids = [ obj.getGraphicID, childIDs ];




viewer.setGraphicVisibility( obj.getGraphicID, false );





for kc = 1:numel( childIDs )
if ( viewer.graphicExists( childIDs( kc ) ) )
viewer.setGraphicVisibility( childIDs( kc ), false );
end 
end 
end 




function [ lat, lon ] = getGeodeticLocation( obj )
if isa( obj, 'matlabshared.satellitescenario.internal.AssetWrapper' ) || isa( obj, 'matlabshared.satellitescenario.internal.Asset' )
lat = obj.pLatitude;
lon = obj.pLongitude;
elseif isprop( obj, 'Parent' ) ...
 && ( isa( obj.Parent, 'matlabshared.satellitescenario.internal.AssetWrapper' ) ...
 || isa( obj.Parent, 'matlabshared.satellitescenario.internal.Asset' ) )
lat = obj.Parent.pLatitude;
lon = obj.Parent.pLongitude;
else 
lat = 0;
lon = 0;
end 
end 



function hideGraphicIfParentInvisible( obj, parent, viewer )
parentVisibility = viewer.getGraphicVisibility( parent.getGraphicID );
isVisibleUnderParent = parentVisibility || strcmp( obj.VisibilityMode, 'manual' );
if ~isVisibleUnderParent
viewer.setGraphicVisibility( obj.getGraphicID, false );
end 
end 



function showIfAutoShow( objs, scenario, viewer )
if ~isa( scenario, 'satelliteScenario' )

return 
end 
if ~isempty( scenario.Viewers ) && scenario.AutoShow
show( objs, viewer );
else 


for k = 1:numel( scenario.Viewers )
scenario.Viewers( k ).initializeGraphicVisibility( objs, false );
end 
end 
end 




function updateViewersIfAutoShow( obj )
if ~isa( obj( 1 ).Scenario, 'satelliteScenario' )

return ;
end 
if ~isempty( obj( 1 ).Scenario.Viewers ) && obj( 1 ).Scenario.AutoShow
updateViewers( obj, obj( 1 ).Scenario.Viewers, false, true );
else 


for k = 1:numel( obj( 1 ).Scenario.Viewers )
obj( 1 ).Scenario.Viewers( k ).initializeGraphicVisibility( obj, false );
end 
end 
end 





function color = convertColor( obj, value, property, classname )
try 
obj.ColorConverter.ConvertedColor = value;
color = obj.ColorConverter.ConvertedColor;
catch ME



msgPrefix = message( 'MATLAB:type:ErrorSettingProperty', property, classname, '' ).getString;
throwAsCaller( MException( ME.identifier, [ msgPrefix, newline, message( ME.identifier ).getString ] ) );
end 
end 





function addGraphicToClutterMap( ~, ~ )


end 
end 

methods 
function show( objs, viewers )

















































R36
objs{ mustBeNonempty }
viewers matlabshared.satellitescenario.Viewer = getViewersInScenario( objs )
end 
scenario = objs( 1 ).Scenario;
validateSameScenario( objs, scenario );

numObjs = numel( objs );
viewers = removeInvalidViewers( viewers );
matlabshared.satellitescenario.ScenarioGraphic.validateViewerScenario( viewers, scenario );

if isempty( viewers )
viewers = satelliteScenarioViewer( scenario );
end 





for k = 1:numel( scenario.Viewers )
scenario.Viewers( k ).initializeGraphicVisibility( objs, false );
for k2 = 1:numel( objs )
addGraphicToClutterMap( objs( k2 ), scenario.Viewers( k ) );
end 
end 


updateViewers( objs, viewers, true );


ids = strings( numObjs, 1 );
if ( numObjs == 1 )


ids = { { objs( 1 ).getGraphicID } };
else 
for objidx = 1:numObjs
ids( objidx ) = objs( objidx ).getGraphicID;
end 
end 

if nargin < 2

viewer = scenario.CurrentViewer;
else 
viewer = viewers( 1 );
end 


matlabshared.satellitescenario.ScenarioGraphic.flyToGraphic( viewer, objs, ids );
figure( viewer.UIFigure );
end 

function hide( objs, viewers )










































R36
objs{ mustBeNonempty }
viewers matlabshared.satellitescenario.Viewer = getViewersInScenario( objs )
end 
scenario = objs( 1 ).Scenario;
validateSameScenario( objs, scenario );
viewers = removeInvalidViewers( viewers );
matlabshared.satellitescenario.ScenarioGraphic.validateViewerScenario( viewers, scenario );
if isempty( viewers )
return ;
end 
numViewers = numel( viewers );
numObjs = numel( objs );


waitForResponse = false;
for idx = 1:numViewers
viewer = viewers( idx );

if ( idx == numViewers )
waitForResponse = true;
end 

queuePlots( viewer.GlobeViewer );

matlabshared.satellitescenario.ScenarioGraphic.hideGraphics( objs, viewer );

submitPlots( viewer.GlobeViewer, "WaitForResponse", waitForResponse, "Animation", 'none' );


if nargin < 2
viewer = scenario.CurrentViewer;
else 
viewer = viewers( 1 );
end 
figure( viewer.UIFigure );
end 
end 



function set( obj, propertyName, propertyValue )

if all( isprop( obj, propertyName ) )
for k = 1:numel( obj )
obj( k ).( propertyName ) = propertyValue;
end 
else 
error( message( 'MATLAB:class:InvalidProperty', propertyName, class( obj ) ) );
end 
end 

function prop = get( obj, propertyName )

if isprop( obj, propertyName )
prop = obj.( propertyName );
else 
error( message( 'MATLAB:class:InvalidProperty', propertyName, class( obj ) ) );
end 
end 
end 

methods ( Access = { ?matlabshared.satellitescenario.ScenarioGraphic, ?matlabshared.satellitescenario.internal.ObjectArray } )







function updateViewers( objs, viewers, setVisible, forceUpdate )
if ( isempty( viewers ) )
return 
end 
if nargin < 3
setVisible = false;
end 
if nargin < 4
forceUpdate = false;
end 
scenario = objs( 1 ).Scenario;

numViewers = numel( viewers );



myTimer = timer( 'TimerFcn', @( ~, ~ )addWaitBars( viewers ), 'StartDelay', 1 );
start( myTimer );

waitForResponse = false;
try 
for idx = 1:numViewers
viewer = viewers( idx );


if ( idx == numViewers )
waitForResponse = true;
end 



currentViewerTime = viewer.CurrentTime;
if scenario.Simulator.Time ~= currentViewerTime
advance( scenario.Simulator, currentViewerTime );
end 




if setVisible
updateGraphicsAndSimulationState( viewer, objs );
end 


if viewer.IsDynamic && ( viewer.NeedToSimulate || forceUpdate )



viewer.makeViewStatic(  );
show( scenario, "Viewer", viewer, "WaitForResponse", waitForResponse, "Animation", 'none' );
elseif ( ~viewer.IsDynamic )

queuePlots( viewer.GlobeViewer );
numObjs = numel( objs );
for objidx = 1:numObjs

updateVisualizations( objs( objidx ), viewer );




if mod( objidx, 10000 ) == 0
submitPlots( viewer.GlobeViewer, "WaitForResponse", waitForResponse, "Animation", 'none' );
queuePlots( viewer.GlobeViewer );
end 
end 
submitPlots( viewer.GlobeViewer, "WaitForResponse", waitForResponse, "Animation", 'none' );
end 
end 

if isvalid( myTimer )
stop( myTimer );
delete( myTimer );
end 
removeWaitBars( viewers );
catch ME
removeWaitBars( viewers );
rethrow( ME );
end 
end 
end 

methods ( Static, Access = { ?satelliteScenario, ?matlabshared.satellitescenario.ScenarioGraphic,  ...
?matlabshared.satellitescenario.Viewer, ?matlabshared.satellitescenario.internal.AddAssetsAndAnalyses,  ...
?satcom.satellitescenario.internal.AddAssetsAndAnalyses,  ...
?matlabshared.satellitescenario.internal.ObjectArray } )




function [ viewer, args ] = parseViewerInput( viewers, scenario, varargin )
[ viewer, args ] = matlabshared.satellitescenario.ScenarioGraphic.extractParamFromVarargin(  ...
"Viewer", viewers,  ...
@( v )validateattributes( v, { 'matlabshared.satellitescenario.Viewer' }, {  } ),  ...
varargin{ : } );
matlabshared.satellitescenario.ScenarioGraphic.validateViewerScenario( viewer, scenario );
end 



function validateViewerScenario( viewer, scenario )
validateattributes( viewer, { 'matlabshared.satellitescenario.Viewer' }, {  } );
if ~isempty( viewer ) && ~isequal( scenario, viewer.Scenario )
msg = message(  ...
'shared_orbit:orbitPropagator:SatelliteScenarioViewerDifferentScenario' );
error( msg );
end 
end 



function [ paramValue, otherArgs ] = extractParamFromVarargin( paramName, defaultValue, validationFcn, varargin )
p = inputParser;
p.KeepUnmatched = true;
p.addParameter( paramName, defaultValue, validationFcn )
p.parse( varargin{ : } );
paramValue = p.Results.( paramName );

otherArgs = [ fieldnames( p.Unmatched ), struct2cell( p.Unmatched ) ];
otherArgs = otherArgs';
otherArgs = otherArgs( : );
end 

function flyToGraphic( viewer, objs, ids )
numObjs = numel( objs );
if ( numObjs == 1 && objs.ZoomHeight >= 0 )



currentViewerTime = viewer.CurrentTime;
if objs.Scenario.Simulator.Time ~= currentViewerTime
advance( objs.Scenario.Simulator, currentViewerTime );
end 


[ lat, lon ] = objs.getGeodeticLocation;




height = objs.ZoomHeight;
currentHeight = camheight( viewer );




if ( height > currentHeight )
viewer.GlobeViewer.flyToLocation( [ lat, lon ], "Height", height );
else 


viewer.GlobeViewer.flyToLocation( [ lat, lon ] );
end 
else 





if isempty( viewer.CZMLFileID )
czmlFileID = '';
else 
czmlFileID = viewer.CZMLFileID{ end  };
end 
viewer.GlobeViewer.viewGraphics( ids, 'fly', viewer.IsDynamic, czmlFileID )
end 
end 


function acs = getAllRelatedAccesses( obj )
scenario = obj.Scenario;
allAccesses = scenario.Accesses;
numGraphics = numel( allAccesses );
acs = matlabshared.satellitescenario.Access;


for k = 1:numGraphics
ac = allAccesses{ k };



for k2 = 2:numel( ac.Sequence )
if ac.Sequence( k2 ) == obj.ID
acs( end  + 1 ) = ac;%#ok<AGROW> 
end 
end 
end 
end 



function setGraphicalField( graphics, fieldname, value )
numGraphics = numel( graphics );
pfield = "p" + fieldname;
for idx = 1:numGraphics
graphics( idx ).( pfield ) = value;
end 



if isa( graphics( 1 ).Scenario, 'satelliteScenario' )
updateViewers( graphics, graphics( 1 ).Scenario.Viewers, false, true );
end 
end 

function hideGraphics( objs, viewer )
numObjs = numel( objs );
ids = strings( 0 );
for k = 1:numObjs
if iscell( objs )
obj = objs{ k };
else 
obj = objs( k );
end 
ids = [ ids, obj.hideInViewerState( viewer ) ];
end 


if ( numel( ids ) == 1 )
ids = { { ids } };
end 


if viewer.IsDynamic
for idx2 = 1:numel( viewer.CZMLFileID )
viewer.GlobeViewer.toggleCZMLVisibility( ids, viewer.CZMLFileID{ idx2 }, false );
end 
else 
viewer.GlobeViewer.remove( ids )
end 
end 

end 

end 

function validateSameScenario( objs, scenario )
numObjs = numel( objs );
for idx = 1:numObjs
if ~isequal( scenario, objs( idx ).Scenario )
msg = message(  ...
'shared_orbit:orbitPropagator:ScenarioGraphicShowDifferentScenario' );
error( msg );
end 
end 
end 

function updateGraphicsAndSimulationState( viewer, objs )
numObjs = numel( objs );
for objidx = 1:numObjs


if ~viewer.getGraphicVisibility( objs( objidx ).getGraphicID )
viewer.NeedToSimulate = true;
end 
viewer.setGraphicVisibility( objs( objidx ).getGraphicID, true );


if viewer.ShowDetails
childIDs = objs( objidx ).getChildGraphicsIDs;
for kc = 1:numel( childIDs )
if ( viewer.graphicExists( childIDs( kc ) ) )
viewer.setGraphicVisibility( childIDs( kc ), true );
end 
end 
end 
end 
end 

function viewersOut = removeInvalidViewers( viewers )
viewersOut = matlabshared.satellitescenario.Viewer.empty;
numViewers = numel( viewers );
for k = 1:numViewers
viewer = viewers( k );
if isvalid( viewer ) && isvalid( viewer.GlobeViewer )
viewersOut( end  + 1 ) = viewer;%#ok<AGROW> 
end 
end 
end 

function addWaitBars( viewers )
for viewer = viewers
viewer.addWaitBar( "plotting" );
end 
end 

function removeWaitBars( viewers )
for viewer = viewers
viewer.removeWaitBar(  );
end 
end 

function viewers = getViewersInScenario( objs )
scenario = objs( 1 ).Scenario;
if ( ~isa( scenario, 'satelliteScenario' ) || ~isvalid( scenario ) )
msg = message(  ...
'shared_orbit:orbitPropagator:ScenarioGraphicVisualizeOrphan' );
error( msg );
end 
viewers = scenario.Viewers;
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpzCfk7i.p.
% Please follow local copyright laws when handling this file.

