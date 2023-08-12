classdef Orbit < handle & matlabshared.satellitescenario.ScenarioGraphic



properties ( Dependent )



LineWidth( 1, 1 )double{ mustBeGreaterThanOrEqual( LineWidth, 1 ), mustBeLessThanOrEqual( LineWidth, 10 ) }




LineColor matlab.internal.datatype.matlab.graphics.datatype.RGBColor
end 

properties ( Access = { ?matlabshared.satellitescenario.ScenarioGraphic ...
, ?matlabshared.satellitescenario.Satellite } )
pLineColor = matlabshared.satellitescenario.ScenarioGraphic.DefaultColors.OrbitLineColor
pLineWidth = 1
Parent
end 

properties ( Access = { ?satelliteScenario, ?matlabshared.satellitescenario.Viewer } )
OrbitGraphic
Name
end 

properties 















VisibilityMode{ mustBeMember( VisibilityMode, { 'inherit', 'manual' } ) } = 'inherit'
end 

methods ( Hidden )
updateVisualizations( orb, viewer )
function ID = getGraphicID( orb )
ID = orb.OrbitGraphic;
end 

function addCZMLGraphic( orb, writer, times, initiallyVisible )
orbEls = orbitalElements( orb.Parent );
if isfield( orbEls, 'Period' )
period = orbEls.Period;
leadTime = period;
trailTime = period;
posHistory = orb.Parent.pPositionHistory';
else 
leadTime = double( seconds( orbEls.EphemerisStopTime - orbEls.EphemerisStartTime ) );
trailTime = leadTime;


[ posHistory, uIdx ] = unique( orb.Parent.pPositionHistory', 'rows' );
sizeNewPos = size( posHistory, 1 );
if sizeNewPos ~= size( orb.Parent.pPositionHistory', 1 )



msgID = 'shared_orbit:orbitPropagator:EphemerisTimeDoesNotCoverScenario';
wStruct = warning( 'off', 'backtrace' );
wClean = onCleanup( @(  )warning( wStruct ) );
warning( message( msgID, orb.Parent.Name, orb.Parent.ID ) );
delete( wClean );
end 
times = times( uIdx );
if size( posHistory, 1 ) < 2
posHistory = [ posHistory;posHistory ];
times = [ times;times ];
end 
end 
addPath(  ...
writer, orb.getGraphicID, posHistory, times, leadTime, trailTime,  ...
'Interpolation', 'lagrange',  ...
'InterpolationDegree', 5,  ...
'CoordinateDefinition', 'cartesian',  ...
'ReferenceFrame', 'inertial',  ...
'Color', [ orb.LineColor, 1 ],  ...
'Width', orb.LineWidth,  ...
'ID', orb.getGraphicID,  ...
'InitiallyVisible', initiallyVisible );
end 

function addGraphicToClutterMap( orb, viewer )
if strcmp( viewer.Dimension, '3D' )
sat = orb.Parent;
addGraphicToClutterMap( sat, viewer );
if ~isfield( viewer.DeclutterMap.( sat.getGraphicID ), orb.getGraphicID )
viewer.DeclutterMap.( sat.getGraphicID ).( orb.getGraphicID ) = orb;
end 
end 
end 

end 

methods 
function orb = Orbit( sat )
orb.Parent = sat;
orb.OrbitGraphic = "satellite" + sat.ID + "Orbit";
orb.Scenario = sat.Scenario;
orb.Name = sat.Name + " Orbit";
end 

function orbitLineColor = get.LineColor( orb )
orbitLineColor = orb.pLineColor;
end 

function lineWidth = get.LineWidth( orb )
lineWidth = orb.pLineWidth;
end 

function set.LineColor( orb, orbitLineColor )
orb.pLineColor = orbitLineColor;
if isa( orb.Scenario, 'satelliteScenario' )
updateViewers( orb, orb.Scenario.Viewers, false, true );
end 
end 

function set.LineWidth( orb, LineWidth )
orb.pLineWidth = LineWidth;
if isa( orb.Scenario, 'satelliteScenario' )
updateViewers( orb, orb.Scenario.Viewers, false, true );
end 
end 

function show( objs, viewers )

















































R36
objs{ mustBeNonempty }
viewers matlabshared.satellitescenario.Viewer = objs( 1 ).Scenario.Viewers
end 

numViewers = numel( viewers );
all2D = true;
for k = 1:numViewers
if strcmp( viewers( k ).Dimension, '3D' )
all2D = false;
end 
end 
if all2D
msg = message( 'shared_orbit:orbitPropagator:SatelliteScenarioUnsupportedOrbitShow2D' );
error( msg );
end 
show@matlabshared.satellitescenario.ScenarioGraphic( objs, viewers );
end 
end 

methods ( Access = ?matlabshared.satellitescenario.internal.Satellite )
function delete( orb )
removeGraphic( orb );
if ( isa( orb.Scenario, 'satelliteScenario' ) )
removeFromScenarioGraphics( orb.Scenario, orb );
end 
orb.Parent.Orbit = [  ];
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpGL3VbL.p.
% Please follow local copyright laws when handling this file.

