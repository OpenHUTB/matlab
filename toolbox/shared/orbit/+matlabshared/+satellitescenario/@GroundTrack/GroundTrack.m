classdef GroundTrack < handle & matlabshared.satellitescenario.ScenarioGraphic



properties ( Dependent )




LeadTime( 1, 1 )double{ mustBeNonnegative, mustBeFinite }




TrailTime( 1, 1 )double{ mustBeNonnegative, mustBeFinite }



LineWidth( 1, 1 )double{ mustBeGreaterThanOrEqual( LineWidth, 1 ), mustBeLessThanOrEqual( LineWidth, 10 ) }




LeadLineColor matlab.internal.datatype.matlab.graphics.datatype.RGBColor




TrailLineColor matlab.internal.datatype.matlab.graphics.datatype.RGBColor
end 

properties 

















VisibilityMode{ mustBeMember( VisibilityMode, { 'inherit', 'manual', 'auto' } ) } = 'auto'
end 

properties ( Access = { ?matlabshared.satellitescenario.ScenarioGraphic } )
pLeadTime( 1, 1 )double{ mustBeNonnegative, mustBeFinite }
pTrailTime( 1, 1 )double{ mustBeNonnegative, mustBeFinite }
pLineWidth( 1, 1 )double{ mustBeGreaterThanOrEqual( pLineWidth, 1 ), mustBeLessThanOrEqual( pLineWidth, 10 ) } = 1
pTrailLineColor = matlabshared.satellitescenario.ScenarioGraphic.DefaultColors.GroundtrackTrailColor
pLeadLineColor = matlabshared.satellitescenario.ScenarioGraphic.DefaultColors.GroundtrackLeadColor
end 

properties ( Access = { ?matlabshared.satellitescenario.ScenarioGraphic,  ...
?matlabshared.satellitescenario.Viewer,  ...
?matlabshared.satellitescenario.Satellite } )
GroundTrackGraphic
GroundTrackTrailGraphic
Parent
end 

methods 
function gt = GroundTrack( sat, scenario, varargin )
gt.Parent = sat;
gt.Scenario = scenario;

initializeLeadTrailTime( gt, sat );
parseShowInputs( gt, varargin{ : } );

gt.GroundTrackGraphic = "satellite" + sat.ID + "GroundTrack";
gt.GroundTrackTrailGraphic = gt.GroundTrackGraphic + "Trail";
end 

function leadTime = get.LeadTime( gt )
leadTime = gt.pLeadTime;
end 

function trailTime = get.TrailTime( gt )
trailTime = gt.pTrailTime;
end 

function lineWidth = get.LineWidth( gt )
lineWidth = gt.pLineWidth;
end 

function trailLineColor = get.TrailLineColor( gt )
trailLineColor = gt.pTrailLineColor;
end 

function leadLineColor = get.LeadLineColor( gt )
leadLineColor = gt.pLeadLineColor;
end 

function set.LeadTime( gt, leadTime )
gt.pLeadTime = leadTime;
if isa( gt.Scenario, 'satelliteScenario' )
updateViewers( gt, gt.Scenario.Viewers, false, true );
end 
end 

function set.TrailTime( gt, trailTime )
gt.pTrailTime = trailTime;
if isa( gt.Scenario, 'satelliteScenario' )
updateViewers( gt, gt.Scenario.Viewers, false, true );
end 
end 

function set.LineWidth( gt, lineWidth )
gt.pLineWidth = lineWidth;
if isa( gt.Scenario, 'satelliteScenario' )
updateViewers( gt, gt.Scenario.Viewers, false, true );
end 
end 

function set.TrailLineColor( gt, trailLineColor )
gt.pTrailLineColor = trailLineColor;
if isa( gt.Scenario, 'satelliteScenario' )
updateViewers( gt, gt.Scenario.Viewers, false, true );
end 
end 

function set.LeadLineColor( gt, leadLineColor )
gt.pLeadLineColor = leadLineColor;
if isa( gt.Scenario, 'satelliteScenario' )
updateViewers( gt, gt.Scenario.Viewers, false, true );
end 
end 


function show( objs, viewers )
arguments
objs{ mustBeNonempty }
viewers matlabshared.satellitescenario.Viewer = objs( 1 ).Scenario.Viewers
end 


for k = 1:numel( objs )
if strcmp( objs( k ).VisibilityMode, 'auto' )
objs( k ).VisibilityMode = 'inherit';
end 
end 
show@matlabshared.satellitescenario.ScenarioGraphic( objs, viewers );
end 
end 
methods ( Access = ?matlabshared.satellitescenario.Satellite )
function parseShowInputs( gt, varargin )
paramNames = { 'LeadTime', 'TrailTime', 'LineWidth', 'TrailLineColor', 'LeadLineColor' };
pstruct = coder.internal.parseParameterInputs( paramNames, satelliteScenario.InputParserOptions, varargin{ : } );
leadTime = coder.internal.getParameterValue( pstruct.LeadTime, gt.LeadTime, varargin{ : } );
trailTime = coder.internal.getParameterValue( pstruct.TrailTime, gt.TrailTime, varargin{ : } );
lineWidth = coder.internal.getParameterValue( pstruct.LineWidth, gt.LineWidth, varargin{ : } );
trailLineColor = coder.internal.getParameterValue( pstruct.TrailLineColor, gt.TrailLineColor, varargin{ : } );
trailLineColor = convertColor( gt, trailLineColor, 'TrailLineColor', 'GroundTrack' );
leadLineColor = coder.internal.getParameterValue( pstruct.LeadLineColor, gt.LeadLineColor, varargin{ : } );
leadLineColor = convertColor( gt, leadLineColor, 'LeadLineColor', 'GroundTrack' );


if ( pstruct.LeadTime > 0 && ~isequal( gt.pLeadTime, leadTime ) ) ||  ...
( pstruct.TrailTime > 0 && ~isequal( gt.pTrailTime, trailTime ) ) ||  ...
( pstruct.LineWidth > 0 && ~isequal( gt.pLineWidth, lineWidth ) ) ||  ...
( pstruct.TrailLineColor > 0 && ~isequal( gt.pTrailLineColor, trailLineColor ) ) ||  ...
( pstruct.LeadLineColor > 0 && ~isequal( gt.pLeadLineColor, leadLineColor ) )
gt.Scenario.NeedToSimulate = true;
gt.Scenario.Simulator.NeedToSimulate = true;
end 




gt.pLeadTime = leadTime;
gt.pTrailTime = trailTime;
gt.pLineWidth = lineWidth;
gt.pTrailLineColor = trailLineColor;
gt.pLeadLineColor = leadLineColor;
end 
end 

methods ( Hidden )
updateVisualizations( gt, viewer )
function ID = getGraphicID( gt )
ID = gt.GroundTrackGraphic;
end 
function IDs = getChildGraphicsIDs( gt )
IDs = gt.GroundTrackTrailGraphic;
end 
function addCZMLGraphic( gt, writer, times, initiallyVisible )

sat = gt.Parent;
groundTrack = [ sat.pLatitudeHistory', sat.pLongitudeHistory',  ...
zeros( numel( times ), 1 ) ];


if gt.LeadTime > 0

name = gt.getGraphicID;


addPath( writer, name, groundTrack, times, gt.LeadTime, 0,  ...
'Width', gt.LineWidth,  ...
'Interpolation', 'lagrange',  ...
'InterpolationDegree', 5,  ...
'Color', [ gt.LeadLineColor, 1 ],  ...
'ID', name,  ...
'Dashed', true,  ...
'InitiallyVisible', initiallyVisible );
end 


if gt.TrailTime > 0

name = "Ground track history of " + sat.Name;

gtTrailID = gt.getChildGraphicsIDs;


addPath( writer, name, groundTrack, times, 0, gt.TrailTime,  ...
'Width', gt.LineWidth,  ...
'Interpolation', 'lagrange',  ...
'InterpolationDegree', 5,  ...
'Color', [ gt.TrailLineColor, 1 ],  ...
'ID', gtTrailID,  ...
'Dashed', false,  ...
'InitiallyVisible', initiallyVisible );
end 
end 

function initializeLeadTrailTime( gt, sat )


elements = orbitalElements( sat );
if isfield( elements, 'Period' )
gt.pLeadTime = elements.Period;
gt.pTrailTime = elements.Period;
else 
gt.pLeadTime = double( seconds( elements.EphemerisStopTime - elements.EphemerisStartTime ) );
gt.pTrailTime = gt.pLeadTime;
end 
end 

function addGraphicToClutterMap( gt, viewer )
if strcmp( viewer.Dimension, '2D' ) || ~strcmp( gt.VisibilityMode, 'auto' )
sat = gt.Parent;
addGraphicToClutterMap( sat, viewer );
if ~isfield( viewer.DeclutterMap.( sat.getGraphicID ), gt.getGraphicID )
viewer.DeclutterMap.( sat.getGraphicID ).( gt.getGraphicID ) = gt;
end 
end 
end 
end 

methods ( Access = ?matlabshared.satellitescenario.internal.Satellite )
function delete( gt )
removeGraphic( gt );
if ( isa( gt.Scenario, 'satelliteScenario' ) )
removeFromScenarioGraphics( gt.Scenario, gt );
end 
gt.Parent.GroundTrack = [  ];
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpw_SaWM.p.
% Please follow local copyright laws when handling this file.

