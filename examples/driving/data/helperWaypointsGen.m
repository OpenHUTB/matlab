classdef helperWaypointsGen < handle & matlab.mixin.Copyable












properties ( Access = public )

Path;

RouteSegments;
end 
properties ( Access = public, Hidden = true )

RoadGraph;
end 
properties ( Access = private, Hidden = true )

JunctionParam;

DrivingParam;

StartPoints;

EndPoints;


Scenario;

RoadNetwork;

Roads;

Nodes;

ExitCode = 0;

FilePath;

NodeTraverseArray;
end 

methods ( Access = public )



function obj = helperWaypointsGen( scenario, varargin )



obj.DrivingParam = obj.getDrivingStruct(  );





if ( isa( scenario, 'drivingScenario' ) )
obj.DrivingParam.InputType = 'drivingScenario';
obj.Scenario = scenario;
else 
obj.FilePath = scenario;
extensionPoint = strfind( obj.FilePath, '.' );
extension = obj.FilePath( extensionPoint( end  ):end  );
if ( strcmp( extension, '.xodr' ) == 1 )
obj.DrivingParam.InputType = 'xodr';
end 
end 

parser = inputParser;
errorMsg = 'Value must be positive, scalar, and must be less than 10.';
validationFcn = @( x )assert( isnumeric( x ) && isscalar( x ) ...
 && ( x > 0 ) && ( x < 10 ), errorMsg );
expectedMethods = { 'Linear', 'Clothoid', 'Pchip' };
validationFcnMethods = @( x )any( validatestring( x, expectedMethods ) );
addRequired( parser, 'Start' );
addRequired( parser, 'End' );
addParameter( parser, 'Direction', 'Right', @( x )any( validatestring( x, { 'Left', 'Right' } ) ) );
addOptional( parser, 'JctnOffset', 0 );
addOptional( parser, 'JctnInterpPoints', 1, validationFcn );
addOptional( parser, 'JctnInterpMethod', 'Linear', validationFcnMethods );
addOptional( parser, 'JctnShiftStraight', 0 );
addOptional( parser, 'Parking', 1 );
parse( parser, varargin{ : } );
results = parser.Results;

obj.StartPoints = repmat( obj.getPointStruct(  ),  ...
size( results.Start, 1 ), 1 );
obj.EndPoints = repmat( obj.getPointStruct(  ),  ...
size( results.End, 1 ), 1 );
obj.DrivingParam.Direction = results.Direction;
obj.DrivingParam.ParkingLane = results.Parking;
obj.JunctionParam.Modifier = results.JctnOffset;
obj.JunctionParam.InterpolationMethod = results.JctnInterpMethod;
obj.JunctionParam.InterpolationCount = results.JctnInterpPoints;
obj.JunctionParam.ShiftStraight = results.JctnShiftStraight;



if ( size( obj.StartPoints ) ~= size( obj.EndPoints ) )
error( 'Start and End are not of same size.' );
end 

pointsCount = size( results.Start );

if ( pointsCount( 2 ) < 2 || pointsCount( 2 ) > 3 &&  ...
length( pointsCount ) <= 2 )
error( 'Start and End dimensions are not 2D or 3D.' );
end 
if ( pointsCount( 2 ) == 3 )
obj.DrivingParam.Planar = false;
end 
for index = 1:length( obj.StartPoints )
obj.StartPoints( index ).Position = results.Start( index, : );
obj.StartPoints( index ).PointIndex = index;
obj.EndPoints( index ).Position = results.End( index, : );
obj.EndPoints( index ).PointIndex = index;

if ( norm( obj.StartPoints( index ).Position -  ...
obj.EndPoints( index ).Position ) <= eps )
error( [ 'Start and End for index ', int2str( index ),  ...
' are same. Please provide different Coordinates.' ] );
end 
end 

obj.loadRoadNetwork(  );

obj.generatePaths(  );

obj.addJunctionShifts(  );
end 



function figH = plotGraph( obj, mode )


R36
obj;
mode( 1, 1 )int8{ mustBeFinite, mustBeNumeric } = 1;
end 
figH = obj.plotGraphInternal( mode );
end 



function figH = plotScenario( obj )



figH = obj.plotScenarioInternal(  );
end 



function figH = plotRouteSegment( obj, PathIndex, RouteIndex )






figH = obj.plotRouteSegmentInternal( PathIndex, RouteIndex );
end 



function figH = plotRoute( obj, PathIndex )





figH = obj.plotRouteInternal( PathIndex );
end 



function shiftJunctions( obj, PathIndex, JunctionIndexArray, Offset, InterpolationMethod, InterpolationCount, ShiftStraight )












R36
obj;
PathIndex;
JunctionIndexArray;
Offset( 1, 1 )double{ mustBeFinite, mustBeNumeric } = 0;
InterpolationMethod( 1, 1 )string{ mustBeText } = 'None';
InterpolationCount( 1, 1 )double{ mustBeFinite, mustBeNumeric } = 0;
ShiftStraight( 1, 1 )logical = false;
end 
if ( size( Offset, 1 ) == 1 )
Offset = repmat( Offset, length( JunctionIndexArray ), 1 );
end 
if ~( strcmpi( InterpolationMethod, 'Clothoid' ) ||  ...
strcmpi( InterpolationMethod, 'Linear' ) ||  ...
strcmpi( InterpolationMethod, 'pchip' ) )
error( 'Invalid Interpolation method.' );
end 
if ( length( JunctionIndexArray ) ~= size( Offset, 1 ) )
error( 'The input sizes are not equal. Please check inputs.' );
end 
if ( PathIndex > length( obj.Path ) )
error( 'Invalid path index.' );
end 
route = obj.RouteSegments( PathIndex ).Route;
for i = 1:length( JunctionIndexArray )
route = obj.shiftJunction( route, JunctionIndexArray( i ), Offset( i ), InterpolationMethod, InterpolationCount, ShiftStraight );
end 
obj.RouteSegments( PathIndex ).Route = route;


obj.Path = obj.aggregateRoutes(  );
end 



function shiftRouteSegments( obj, PathIndex, RouteSegmentIndexArray, Offset, Dir )







if ( length( RouteSegmentIndexArray ) ~= size( Offset, 1 ) &&  ...
length( RouteSegmentIndexArray ) ~= size( Dir, 1 ) )
error( 'Number of route segments is not equal to number of offsets and Direction given.' );
end 
for i = 1:length( routeSegmentArray )
obj.shiftRouteSegment( PathIndex, RouteSegmentIndexArray( i ), Offset( i ), Dir( i ) );
end 
end 



function generatePath( obj )



obj.Path = obj.aggregateRoutes(  );
end 



end 

methods ( Access = private, Hidden = true )



function Point = getPointStruct( ~ )

Point = struct( 'Position', zeros( 0, 3 ),  ...
'PointIndex',  - 1,  ...
'RoadID',  - 1,  ...
'RoadIndex',  - 1,  ...
'Direction', driving.roadnetwork.DirectionOfTravel( 5 ),  ...
'IsOnJunction', 0,  ...
'Node',  - 1 );
end 



function Junction = getJunctionModifierStruct( ~ )






Junction = struct( 'InterpolationMethod', 'Linear',  ...
'InterpolationCount', 3,  ...
'Modifier', 0,  ...
'ShiftStraight', 0 );
end 



function Road = getRoadStruct( obj )


Road = struct( 'ID',  - 1,  ...
'Weight',  - 1,  ...
'Direction',  - 1,  ...
'StartNode',  - 1,  ...
'StartNodeIndex',  - 1,  ...
'EndNode',  - 1,  ...
'EndNodeIndex',  - 1,  ...
'CentersX', zeros( 0, 1 ),  ...
'CentersY', zeros( 0, 1 ),  ...
'CentersZ', zeros( 0, 1 ),  ...
'IsStraight', zeros( 0, 1 ),  ...
'RoadSegments',  ...
repmat( obj.getRoadSegmentStruct(  ), 0, 1 ) );
end 



function RoadSegment = getRoadSegmentStruct( obj )


RoadSegment = struct( 'CentersX', zeros( 0, 1 ),  ...
'CentersY', zeros( 0, 1 ),  ...
'CentersZ', zeros( 0, 1 ),  ...
'BankingAngles', zeros( 0, 1 ),  ...
'Headings', zeros( 0, 1 ),  ...
'Lanes',  ...
repmat( obj.getLaneStruct(  ), 0, 1 ),  ...
'DrivingForwardLaneWidth', zeros( 0, 1 ),  ...
'DrivingBackwardLaneWidth', zeros( 0, 1 ),  ...
'DrivingBothLaneWidth', zeros( 0, 1 ),  ...
'DrivingForwardLaneCount', 0,  ...
'DrivingBackwardLaneCount', 0,  ...
'DrivingBothLaneCount', 0,  ...
'AllForwardLaneWidth', zeros( 0, 1 ),  ...
'AllBackwardLaneWidth', zeros( 0, 1 ),  ...
'AllBothLaneWidth', zeros( 0, 1 ),  ...
'AllLaneWidth', zeros( 0, 1 ),  ...
'AllForwardLaneCount', 0,  ...
'AllBackwardLaneCount', 0,  ...
'AllBothLaneCount', 0,  ...
'AllLaneCount', 0 );
end 



function Lane = getLaneStruct( ~ )


Lane = struct( 'Direction', driving.roadnetwork.DirectionOfTravel( 5 ),  ...
'Type', driving.roadnetwork.LaneType( 1 ),  ...
'Width',  - 1 );
end 



function Params = getDrivingStruct( ~ )






Params = struct( 'Direction', 'Right',  ...
'ParkingLane', 0,  ...
'Planar', true,  ...
'InputType', 'drivingScenario' );
end 



function Node = getNodeStruct( obj )


Node = struct( 'ID',  - 1,  ...
'Name', '2',  ...
'PositionX', 0,  ...
'PositionY', 0,  ...
'PositionZ', 0,  ...
'OutgoingRoads', zeros( 0, 1 ),  ...
'OutgoingRoadsIndex', zeros( 0, 1 ),  ...
'IncomingRoads', zeros( 0, 1 ),  ...
'IncomingRoadsIndex', zeros( 0, 1 ),  ...
'RoadSegments',  ...
repmat( obj.getRoadSegmentStruct(  ), 0, 1 ),  ...
'Polygon', zeros( 0, 3 ) );
end 



function Route = getRouteStruct( ~ )

Route = struct( 'CentersX', zeros( 0, 1 ),  ...
'CentersY', zeros( 0, 1 ),  ...
'CentersZ', zeros( 0, 1 ),  ...
'RoadCentersX', zeros( 0, 1 ),  ...
'RoadCentersY', zeros( 0, 1 ),  ...
'RoadCentersZ', zeros( 0, 1 ),  ...
'LaneCount', double( 0 ),  ...
'Width', 0,  ...
'ID', 0,  ...
'Index', 0,  ...
'IsJunction', 0 );
end 



function Path = getPathStruct( ~ )

Path = struct( 'waypoints', zeros( 0, 3 ),  ...
'roadCenters', zeros( 0, 3 ) );
end 



function loadRoadNetwork( obj )










if ( obj.ExitCode ==  - 1 )
return ;
end 
if ( strcmp( obj.DrivingParam.InputType, 'drivingScenario' ) )

model = mf.zero.Model;

obj.RoadNetwork = driving.internal.scenarioAdapter.getRoadNetwork( obj.Scenario, model );

obj.RoadGraph = obj.RoadNetwork.getDigraph(  );
elseif ( strcmp( obj.DrivingParam.InputType, 'xodr' ) )

adapterobj = matlabshared.drivingutils.OpenDriveAdapter( obj.FilePath );


obj.RoadNetwork = adapterobj.getRoadNetworkData(  );

obj.Scenario = driving.internal.scenarioAdapter.getDrivingScenario( obj.RoadNetwork );

model = mf.zero.Model;

obj.RoadNetwork = driving.internal.scenarioAdapter.getRoadNetwork( obj.Scenario, model );

obj.RoadGraph = obj.RoadNetwork.getDigraph(  );
if ( strcmpi( obj.DrivingParam.Direction, 'Left' ) )
obj.RoadGraph = obj.invertRoadGraph( obj.RoadGraph );
end 
end 


obj.updateRoadNetworkGeometry(  );


success = obj.updatePointsLocation(  );

if ( ~success )
error( 'The input points are outside the road.' );
end 
end 


function addJunctionShifts( obj )

if ( obj.JunctionParam.Modifier ~= 0 )
pathCount = length( obj.Path );
for index = 1:pathCount
routeCount = floor( length( obj.RouteSegments( index ).Route ) / 2 );
if ( routeCount > 1 )
junctionCount = 1:routeCount;
else 
junctionCount = 0;
end 
if ( junctionCount ~= 0 )
obj.shiftJunctions( index, junctionCount, obj.JunctionParam.Modifier, obj.JunctionParam.InterpolationMethod, obj.JunctionParam.InterpolationCount, obj.JunctionParam.ShiftStraight );
end 
end 
end 

end 


function routeOut = shiftJunction( obj, route, junctionCount, distance, method, count, shiftStraight )



routeOut = route;
routeJunctionCount = 0;
for index = 1:length( route )
if ( route( index ).IsJunction )
routeJunctionCount = routeJunctionCount + 1;
end 
end 
if ( junctionCount > routeJunctionCount )
error( 'Please enter a valid route index.' );
end 

routeJunctionCount = 0;
for index = 1:length( route )
if ( route( index ).IsJunction )
routeJunctionCount = routeJunctionCount + 1;
if ( junctionCount == routeJunctionCount )
junctionRoute = obj.editJunctionRoute( route, index, distance, method, count, shiftStraight );
routeOut( index ) = junctionRoute;
end 
end 
end 
end 



function junctionRoute = editJunctionRoute( obj, route, index, distance, method, count, shiftStraight )

junctionRoute = obj.getRouteStruct(  );
junctionRoute.IsJunction = true;
startPoint = [ route( index - 1 ).CentersX, route( index - 1 ).CentersY, route( index - 1 ).CentersZ ];
endPoint = [ route( index + 1 ).CentersX, route( index + 1 ).CentersY, route( index + 1 ).CentersZ ];

startPoint0 = startPoint( end  - 1, : );
startPoint1 = startPoint( end , : );
endPoint0 = endPoint( 1, : );
endPoint1 = endPoint( 2, : );
angleEnd = atan2( endPoint1( 2 ) - endPoint0( 2 ), endPoint1( 1 ) - endPoint0( 1 ) );
angleStart = atan2( startPoint1( 2 ) - startPoint0( 2 ), startPoint1( 1 ) - startPoint0( 1 ) );
if ( abs( angleStart - angleEnd ) <= .01 && ~shiftStraight )
return ;
end 

pointsArray = obj.fitPoints( startPoint0, startPoint1, endPoint0, endPoint1, distance, method, count + 2 );
pointsArray = pointsArray( 2:end  - 1, : );
junctionRoute.CentersX = pointsArray( :, 1 );
junctionRoute.CentersY = pointsArray( :, 2 );
junctionRoute.CentersZ = pointsArray( :, 3 );
junctionRoute.RoadCentersX = pointsArray( :, 1 );
junctionRoute.RoadCentersY = pointsArray( :, 2 );
junctionRoute.RoadCentersZ = pointsArray( :, 3 );
junctionRoute.Width = 0;
end 




function pointsArray = fitPoints( ~, point0, point1, point2, point3, distance, method, count )



pointsArray = zeros( count, 3 );
pointsMiddleArray = zeros( count, 3 );
ratio = 1 / ( count + 1 );

if ( method( 1 ) == 'L' || method( 1 ) == 'l' ||  ...
strcmpi( method, 'Linear' ) )
for indexVal = 1:count
pointsMiddleArray( indexVal, : ) = ratio * point2 + ( 1 - ratio ) * point1;
ratio = ratio + 1 / ( count + 1 );
end 
pathT = [ point1;pointsMiddleArray;point2 ];
pointsArray = mathUtils.shiftPoints( pathT, distance, 1 );
elseif ( method( 1 ) == 'C' || method( 1 ) == 'c' ||  ...
strcmpi( method, 'Clothoid' ) )
pointArray = [ point0;point1;point2;point3 ];
pathT = mathUtils.clothoidInterpolation( pointArray, 4 );
totalSize = length( pathT ) - 1;
pathT = pathT( totalSize / 3:totalSize * 2 / 3, : );
pointsMiddleArray = mathUtils.shiftPoints( pathT, distance, 1 );
totalSize = length( pathT );
pointsArray = pointsMiddleArray( floor( 1:totalSize / count:totalSize ), : );
elseif ( method( 1 ) == 'P' || method( 1 ) == 'p' ||  ...
strcmpi( method, 'pchip' ) )
p = pchip( [ point1( 1 ), point2( 1 ) ], [ point1( 2 ), point2( 2 ) ] );
diff = ( point2( 1 ) - point1( 1 ) ) / count;
xq = point1( 1 ):diff:point2( 1 );
pointsMiddleArray = ppval( p, xq );
pointsArray = pointsMiddleArray;
end 
end 



function roadGraph = invertRoadGraph( ~, inputGraph )

names = inputGraph.Nodes.Name;
position = inputGraph.Nodes.Position;
endNodes = inputGraph.Edges.EndNodes;
endNodesEdited = [ endNodes( :, 2 ), endNodes( :, 1 ) ];
weight = inputGraph.Edges.Weight;

nodeProps = table( names, position,  ...
'VariableNames', { 'Name', 'Position' } );
edgeProps = table( endNodesEdited, weight,  ...
'VariableNames', { 'EndNodes', 'Weight' } );

roadGraph = digraph(  );
roadGraph = addnode( roadGraph, nodeProps );
roadGraph = addedge( roadGraph, edgeProps );

end 



function generatePaths( obj )



obj.generateRoutes(  );

obj.Path = obj.aggregateRoutes(  );
end 



function path = aggregateRoutes( obj )

if ( obj.ExitCode ==  - 1 )
path = [  ];
return 
end 
path = repmat( obj.getPathStruct(  ), 1, length( obj.RouteSegments ) );
for index = 1:length( obj.RouteSegments )
routeSegment = obj.RouteSegments( index ).Route;
[ waypoints, roadCenters ] = obj.aggregateRoute( routeSegment );
path( index ).waypoints = waypoints;
path( index ).roadCenters = roadCenters;
end 
end 



function [ path, roadCenters ] = aggregateRoute( obj, routes )

centersX = [  ];
centersZ = [  ];
centersY = [  ];
roadCentersX = [  ];
roadCentersY = [  ];
roadCentersZ = [  ];
for index = 1:length( routes )
centersX = [ centersX;routes( index ).CentersX ];%#ok<AGROW> 
centersY = [ centersY;routes( index ).CentersY ];%#ok<AGROW> 
centersZ = [ centersZ;routes( index ).CentersZ ];%#ok<AGROW>       
roadCentersX = [ roadCentersX;routes( index ).RoadCentersX ];%#ok<AGROW> 
roadCentersY = [ roadCentersY;routes( index ).RoadCentersY ];%#ok<AGROW> 
roadCentersZ = [ roadCentersZ;routes( index ).RoadCentersZ ];%#ok<AGROW>               
end 
path = [ centersX, centersY, centersZ ];
roadCenters = [ roadCentersX, roadCentersY, roadCentersZ ];

path = obj.removeDuplicatesOrNan( path );
roadCenters = obj.removeDuplicatesOrNan( roadCenters );
end 


function generateRoutes( obj )


RouteSegmentArray = repmat( obj.getRouteStruct(  ), 1, 0 );

obj.RouteSegments = repmat( struct( 'Route', RouteSegmentArray ), length( obj.StartPoints ), 1 );
for index = 1:length( obj.StartPoints )
route = obj.generateRoute( obj.StartPoints( index ),  ...
obj.EndPoints( index ), index );
obj.RouteSegments( index ).Route = route;
end 

end 

function points = removeDuplicatesOrNan( ~, pointsIn )

counter = 0;
points = zeros( size( pointsIn, 1 ), 3 );
for index = 1:size( pointsIn, 1 )
if ( index < size( pointsIn, 1 ) )


diffVal = pointsIn( index, : ) - pointsIn( index + 1, : );
if ~( norm( diffVal ) < 1e-03 )
counter = counter + 1;
points( counter, : ) = pointsIn( index, : );
end 
else 


diffVal = pointsIn( end , : ) - pointsIn( end  - 1, : );
if ~( norm( diffVal ) < 1e-03 )
counter = counter + 1;
points( counter, : ) = pointsIn( end , : );
end 
end 
end 
points = points( 1:counter, : );
end 


function route = generateRoute( obj, startPoint, endPoint, index )


if ( obj.ExitCode ==  - 1 )
route = [  ];
return 
end 

pathNodeIDs = obj.buildNodetraversalPaths( startPoint, endPoint );
if ( startPoint.Node ~= endPoint.Node && length( pathNodeIDs ) < 2 )
obj.ExitCode =  - 1;
error( [ 'Please check inputs. No path exists between the given start and end. The index of the points is ', num2str( index ) ] );
end 
if length( pathNodeIDs ) == 1


route = obj.getRouteStruct(  );
else 
routeCount = length( pathNodeIDs ) - 1;
route = repmat( obj.getRouteStruct(  ), 1, routeCount );

for index = 1:routeCount
startNode = pathNodeIDs( index );
endNode = pathNodeIDs( index + 1 );
route( index ) = obj.getRoute( startNode, endNode );
end 
end 


[ laneCountStart, widthStart ] = obj.getLane( startPoint );
[ laneCountEnd, widthEnd ] = obj.getLane( endPoint );
isCircularRoute = false;
if ( startPoint.IsOnJunction && endPoint.IsOnJunction )
if ( startPoint.RoadID ~= endPoint.RoadID )
routeStart = obj.getStartRoute( startPoint, laneCountStart, widthStart );
routeEnd = obj.getEndRoute( endPoint, laneCountEnd, widthEnd );

route = obj.setRouteWidth( route, laneCountStart, widthStart );
route = [ routeStart, route, routeEnd ];

route = obj.shiftRoute( route );
else 
route = obj.getRouteStruct(  );
route.CentersX = [ startPoint.Position( 1 ), endPoint.Position( 1 ) ];
route.CentersY = [ startPoint.Position( 2 ), endPoint.Position( 2 ) ];
route.CentersZ = [ startPoint.Position( 3 ), endPoint.Position( 3 ) ];
route.RoadCentersX = route.CentersX;
route.RoadCentersY = route.CentersY;
route.RoadCentersZ = route.CentersZ;
route.Width = 0;
end 
elseif ( startPoint.IsOnJunction == 0 && endPoint.IsOnJunction == 0 )
if ( startPoint.RoadID == endPoint.RoadID )
isCircularRoute = obj.isCircularRoute( startPoint, endPoint );
if ( isCircularRoute )
obj.ExitCode =  - 1;
route = obj.getRouteStruct(  );%#ok<NASGU> 
error( 'Circular roads are not supported.' );
end 
route = obj.getRouteSingleRoad( startPoint, endPoint, laneCountStart, widthStart, laneCountEnd, widthEnd );
else 
routeStart = obj.getStartRoute( startPoint, laneCountStart, widthStart );
routeEnd = obj.getEndRoute( endPoint, laneCountEnd, widthEnd );
if length( pathNodeIDs ) ~= 1

route = obj.setRouteWidth( route, laneCountStart, widthStart );
end 
if ( strcmpi( obj.DrivingParam.Direction, 'Left' ) )
routeStart = obj.flipRoute( routeStart );
routeEnd = obj.flipRoute( routeEnd );
routeEnd.Width =  - 1 * routeEnd.Width;
for index = 1:length( route )
route( index ).Width =  - 1 * route( index ).Width;
end 
end 
endRoad = obj.Roads( endPoint.RoadIndex ).RoadSegments( 1 );
if ( endRoad.DrivingForwardLaneCount == 0 ||  ...
endRoad.DrivingBackwardLaneCount == 0 )
pointA = [ routeEnd.CentersX( 1 ) ...
, routeEnd.CentersY( 1 ) ...
, routeEnd.CentersZ( 1 ) ];
pointB = [ routeEnd.CentersX( end  ) ...
, routeEnd.CentersY( end  ) ...
, routeEnd.CentersZ( end  ) ];
if length( pathNodeIDs ) > 1
point = [ route( end  ).CentersX( end  ) ...
, route( end  ).CentersY( end  ) ...
, route( end  ).CentersZ( end  ) ];
if ( norm( pointA - point ) > norm( pointB - point ) )
routeEnd = obj.flipRoute( routeEnd );
end 
else 
point = [  ];
end 
end 
startRoad = obj.Roads( startPoint.RoadIndex ).RoadSegments( 1 );
if ( startRoad.DrivingForwardLaneCount == 0 ||  ...
startRoad.DrivingBackwardLaneCount == 0 )
pointA = [ routeStart.CentersX( 1 ) ...
, routeStart.CentersY( 1 ) ...
, routeStart.CentersZ( 1 ) ];
pointB = [ routeStart.CentersX( end  ) ...
, routeStart.CentersY( end  ) ...
, routeStart.CentersZ( end  ) ];
if length( pathNodeIDs ) > 1
point = [ route( 1 ).CentersX( end  ) ...
, route( 1 ).CentersY( end  ) ...
, route( 1 ).CentersZ( end  ) ];
if ( norm( pointA - point ) < norm( pointB - point ) )
routeStart = obj.flipRoute( routeStart );
end 
else 
point = [  ];
end 
end 
if isempty( route )
route = [ routeStart, routeEnd ];
else 
route = [ routeStart, route, routeEnd ];
end 


route = obj.shiftRoute( route );
end 
else 
routeStart = obj.getStartRoute( startPoint, laneCountStart, widthStart );
routeEnd = obj.getEndRoute( endPoint, laneCountEnd, widthEnd );

route = obj.setRouteWidth( route, laneCountStart, widthStart );
if ( strcmpi( obj.DrivingParam.Direction, 'Left' ) )
routeStart = obj.flipRoute( routeStart );
routeEnd = obj.flipRoute( routeEnd );
for index = 1:length( route )
route( index ).Width =  - 1 * route( index ).Width;
end 
end 
route = [ routeStart, route, routeEnd ];

route = obj.shiftRoute( route );
end 
if ( ~isCircularRoute )

route( 1 ) = obj.trimPath( route( 1 ), startPoint, 'Start' );
route( end  ) = obj.trimPath( route( end  ), endPoint, 'End' );
end 
centers = [ route( 1 ).CentersX, route( 1 ).CentersY, route( 1 ).CentersZ ];
distance = norm( startPoint.Position - centers( 1, : ) );
routeTemp1 = obj.shiftRouteCenters( route( 1 ),  - distance );
routeTemp2 = obj.shiftRouteCenters( route( 1 ), distance );
routeTemp1.Width = route( 1 ).Width - distance;
routeTemp2.Width = route( 1 ).Width - distance;

norm1 = norm( startPoint.Position - [ routeTemp1( 1 ).CentersX( 1 ) ...
, routeTemp1( 1 ).CentersY( 1 ) ...
, routeTemp1( 1 ).CentersZ( 1 ) ] );
norm2 = norm( startPoint.Position - [ routeTemp2( 1 ).CentersX( 1 ) ...
, routeTemp2( 1 ).CentersY( 1 ) ...
, routeTemp2( 1 ).CentersZ( 1 ) ] );
if ( norm1 < norm2 )
route( 1 ) = routeTemp1;
else 
route( 1 ) = routeTemp2;
end 



if ( obj.DrivingParam.ParkingLane )
route = obj.addLaneShift( route, startPoint, endPoint );
end 


routeCount = length( route );
routeJunctionOut = repmat( obj.getRouteStruct(  ), 1, 2 * routeCount );
counter = 1;
for index = 1:routeCount
routeJunctionOut( counter ) = route( index );
junctionRoute = obj.getRouteStruct(  );
junctionRoute.IsJunction = true;
routeJunctionOut( counter + 1 ) = junctionRoute;
counter = counter + 2;
end 
route = routeJunctionOut( 1:end  - 1 );
end 



function route = shiftRoute( ~, route )

for index = 1:length( route )
pathX = route( index ).RoadCentersX;
pathY = route( index ).RoadCentersY;
pathZ = route( index ).RoadCentersZ;
path = [ pathX, pathY, pathZ ];
if ( ~isempty( path ) )
shiftedPath = mathUtils.shiftPoints( path, route( index ).Width, 1 );
route( index ).CentersX = shiftedPath( :, 1 );
route( index ).CentersY = shiftedPath( :, 2 );
route( index ).CentersZ = shiftedPath( :, 3 );
end 
end 
end 


function route = shiftRouteCenters( ~, route, width )

for index = 1:length( route )
pathX = route( index ).CentersX;
pathY = route( index ).CentersY;
pathZ = route( index ).CentersZ;
path = [ pathX, pathY, pathZ ];
if ( ~isempty( path ) )
shiftedPath = mathUtils.shiftPoints( path, width, 1 );
route( index ).CentersX = shiftedPath( :, 1 );
route( index ).CentersY = shiftedPath( :, 2 );
route( index ).CentersZ = shiftedPath( :, 3 );
end 
end 
end 


function route = getCircularRoute( obj, startPoint, endPoint )

route = obj.getRouteStruct(  );
route.CentersX = [ startPoint.Position( 1 ) + 1;endPoint.Position( 1 ) ];
route.CentersY = [ startPoint.Position( 2 );endPoint.Position( 2 ) ];
route.CentersZ = [ startPoint.Position( 3 );endPoint.Position( 3 ) ];
route.RoadCentersX = [ startPoint.Position( 1 ) + 1;endPoint.Position( 1 ) ];
route.RoadCentersY = [ startPoint.Position( 2 );endPoint.Position( 2 ) ];
route.RoadCentersZ = [ startPoint.Position( 3 );endPoint.Position( 3 ) ];

end 


function route = getRouteSingleRoad( obj, startPoint, endPoint, laneCountStart, widthStart, laneCountEnd, widthEnd )


routeTemp = obj.getRouteStruct(  );
roadIndex = startPoint.RoadIndex;
road = obj.Roads( roadIndex );
if ( laneCountEnd > 0 )
backwardWidth = road.RoadSegments( 1 ).DrivingBackwardLaneWidth;
widthValue = ( backwardWidth( end  ) + backwardWidth( end  - 1 ) ) / 2;
else 
forwardWidth = road.RoadSegments( 1 ).DrivingForwardLaneWidth;
widthValue = ( forwardWidth( 1 ) + forwardWidth( 2 ) ) / 2;
end 

routeTemp.CentersX = obj.Roads( roadIndex ).CentersX;
routeTemp.CentersY = obj.Roads( roadIndex ).CentersY;
routeTemp.CentersZ = obj.Roads( roadIndex ).CentersZ;
routeTemp.RoadCentersX = obj.Roads( roadIndex ).CentersX;
routeTemp.RoadCentersY = obj.Roads( roadIndex ).CentersY;
routeTemp.RoadCentersZ = obj.Roads( roadIndex ).CentersZ;

if ( laneCountStart < 0 )
routeTemp = obj.flipRoute( routeTemp );
end 
routeTemp.Index = roadIndex;
routeTemp.ID = startPoint.RoadID;

routeTempReverse = obj.flipRoute( routeTemp );

if ( sign( laneCountStart ) == sign( laneCountEnd ) )


pointPlacer = obj.getPointIndexOnRoute( routeTemp, startPoint, endPoint );
if ( strcmpi( obj.DrivingParam.Direction, 'Left' ) )
pointPlacer =  - 1 * pointPlacer;
routeTemp = obj.flipRoute( routeTemp );
routeTempReverse = obj.flipRoute( routeTempReverse );
end 
if ( pointPlacer < 0 )
route = routeTemp;
route.Width = widthStart;
route = obj.shiftRoute( route );
else 
routeStart = obj.getStartRoute( startPoint, laneCountStart, widthStart );
routeEnd = obj.getEndRoute( endPoint, laneCountEnd, widthEnd );

multiplier =  - 1;
if ( strcmpi( obj.DrivingParam.Direction, 'Left' ) )
routeStart = obj.flipRoute( routeStart );
routeEnd = obj.flipRoute( routeEnd );
routeEnd.Width =  - 1 * routeEnd.Width;
multiplier = 1;
end 
routeTempReverse.Width = multiplier * sign( laneCountStart ) * widthValue;
route = [ routeStart, routeTempReverse, routeEnd ];

route = obj.shiftRoute( route );
end 

else 
routeStart = obj.getStartRoute( startPoint, laneCountStart, widthStart );
routeEnd = obj.getEndRoute( endPoint, laneCountEnd, widthEnd );

if ( strcmpi( obj.DrivingParam.Direction, 'Left' ) )
routeStart = obj.flipRoute( routeStart );
routeEnd = obj.flipRoute( routeEnd );
routeEnd.Width =  - 1 * routeEnd.Width;
end 
route = [ routeStart, routeEnd ];

route = obj.shiftRoute( route );
end 
end 


function routeOut = flipRoute( ~, routeIn )

routeOut = routeIn;
routeOut.CentersX = flip( routeIn.CentersX );
routeOut.CentersY = flip( routeIn.CentersY );
routeOut.CentersZ = flip( routeIn.CentersZ );
routeOut.RoadCentersX = flip( routeIn.RoadCentersX );
routeOut.RoadCentersY = flip( routeIn.RoadCentersY );
routeOut.RoadCentersZ = flip( routeIn.RoadCentersZ );
end 



function circularRoute = isCircularRoute( obj, startPoint, endPoint )

if ( startPoint.IsOnJunction || endPoint.IsOnJunction )
circularRoute = false;
return ;
end 

if ( startPoint.RoadID == endPoint.RoadID )
road = obj.Roads( startPoint.RoadIndex );
if ( road.StartNode == road.EndNode )
circularRoute = true;
return ;
else 
circularRoute = false;
return ;
end 
else 
circularRoute = false;
return ;
end 
end 



function route = addLaneShift( obj, route, startPoint, endPoint )

startPath = [ route( 1 ).CentersX, route( 1 ).CentersY, route( 1 ).CentersZ ];
startPosition = startPoint.Position;
routeStartPoint = startPath( 1, : );
routeEndPoint = startPath( end , : );
parallelPathLaneLength = 9;
parallelShortPathLaneLength = 2;
if ~( norm( routeStartPoint - routeEndPoint ) < parallelPathLaneLength + mathUtils.ParLengthVal )

[ newStartPosition, angleStart ] = mathUtils.getLangeChangeStartPoint( startPath, startPosition, parallelPathLaneLength );
point = obj.getPointStruct(  );
point.Position = newStartPosition;
trimmedRoute = obj.trimPath( route( 1 ), point, 'Start' );
trimmedPoint = [ trimmedRoute.CentersX( 1 ), trimmedRoute.CentersY( 1 ), trimmedRoute.CentersZ( 1 ) ];
pointsGenerated = mathUtils.generateLaneChangePoints( startPosition, trimmedPoint, angleStart, angleStart, 10 );

trimmedRoute.CentersX = [ pointsGenerated( :, 1 );trimmedRoute.CentersX ];
trimmedRoute.CentersY = [ pointsGenerated( :, 2 );trimmedRoute.CentersY ];
trimmedRoute.CentersZ = [ pointsGenerated( :, 3 );trimmedRoute.CentersZ ];
route( 1 ) = trimmedRoute;
else 
[ newStartPosition, ~ ] = mathUtils.getLangeChangeStartPoint( startPath, startPosition, parallelShortPathLaneLength );
if ( norm( startPosition - routeEndPoint ) < parallelShortPathLaneLength )
trimmedRoute = obj.trimPath( route( 1 ), startPoint, 'Start' );
trimmedRoute.CentersX( end  ) = startPoint.Position( 1 );
trimmedRoute.CentersY( end  ) = startPoint.Position( 2 );
trimmedRoute.CentersZ( end  ) = startPoint.Position( 3 );
route( 1 ) = trimmedRoute;
else 
point = obj.getPointStruct(  );
point.Position = newStartPosition;
trimmedRoute = obj.trimPath( route( 1 ), point, 'Start' );

trimmedRoute.CentersX = [ startPoint.Position( 1 );trimmedRoute.CentersX ];
trimmedRoute.CentersY = [ startPoint.Position( 2 );trimmedRoute.CentersY ];
trimmedRoute.CentersZ = [ startPoint.Position( 3 );trimmedRoute.CentersZ ];
route( 1 ) = trimmedRoute;
end 
end 

endPath = [ route( end  ).CentersX, route( end  ).CentersY, route( end  ).CentersZ ];
endPosition = endPoint.Position;
routeStartPoint = endPath( 1, : );
routeEndPoint = endPath( end , : );
if ( norm( routeStartPoint - endPosition ) < 1 )
return ;
end 

if ~( norm( routeStartPoint - routeEndPoint ) < parallelPathLaneLength + mathUtils.ParLengthVal )
[ newEndPosition, angleEnd ] = mathUtils.getLangeChangeEndPoint( endPath, endPosition, parallelPathLaneLength );
point = obj.getPointStruct(  );
point.Position = newEndPosition;
trimmedRoute = obj.trimPath( route( end  ), point, 'End' );
trimmedPoint = [ trimmedRoute.CentersX( end  ), trimmedRoute.CentersY( end  ), trimmedRoute.CentersZ( end  ) ];
pointsGenerated = mathUtils.generateLaneChangePoints( trimmedPoint, endPosition, angleEnd, angleEnd, 10 );

trimmedRoute.CentersX = [ trimmedRoute.CentersX;pointsGenerated( :, 1 ) ];
trimmedRoute.CentersY = [ trimmedRoute.CentersY;pointsGenerated( :, 2 ) ];
trimmedRoute.CentersZ = [ trimmedRoute.CentersZ;pointsGenerated( :, 3 ) ];
route( end  ) = trimmedRoute;
else 
[ newEndPosition, ~ ] = mathUtils.getLangeChangeEndPoint( endPath, endPosition, parallelShortPathLaneLength );
if ( norm( endPosition - routeStartPoint ) < parallelShortPathLaneLength )
trimmedRoute = obj.trimPath( route( end  ), endPoint, 'End' );
trimmedRoute.CentersX( end  ) = endPoint.Position( 1 );
trimmedRoute.CentersY( end  ) = endPoint.Position( 2 );
trimmedRoute.CentersZ( end  ) = endPoint.Position( 3 );
route( end  ) = trimmedRoute;
else 
point = obj.getPointStruct(  );
point.Position = newEndPosition;
trimmedRoute = obj.trimPath( route( end  ), point, 'End' );

trimmedRoute.CentersX = [ trimmedRoute.CentersX;endPoint.Position( 1 ) ];
trimmedRoute.CentersY = [ trimmedRoute.CentersY;endPoint.Position( 2 ) ];
trimmedRoute.CentersZ = [ trimmedRoute.CentersZ;endPoint.Position( 3 ) ];
route( end  ) = trimmedRoute;
end 
end 
end 



function count = getPointIndexOnRoute( ~, route, startPoint, endPoint )


centers = [ route( 1 ).CentersX, route( 1 ).CentersY, route( 1 ).CentersZ ];
distanceStart = norm( centers( 1, : ) - startPoint.Position );
distanceEnd = norm( centers( 1, : ) - endPoint.Position );
if ( distanceStart > distanceEnd )
count = 1;
else 
count =  - 1;
end 
end 



function route = getRoute( obj, startNode, endNode )

route = obj.getRouteStruct(  );
startNodeIdx = obj.getNodeIndex( startNode );
roads = [ obj.Nodes( startNodeIdx ).OutgoingRoads; ...
obj.Nodes( startNodeIdx ).IncomingRoads ];
roadsIdx = [ obj.Nodes( startNodeIdx ).OutgoingRoadsIndex;
obj.Nodes( startNodeIdx ).IncomingRoadsIndex ];
centersX = [  ];
centersY = [  ];
centersZ = [  ];
id = 0;
idx = 0;
for index = 1:length( roads )
if ( obj.Roads( roadsIdx( index ) ).EndNode == startNode &&  ...
obj.Roads( roadsIdx( index ) ).StartNode == endNode )
centersX = flip( obj.Roads( roadsIdx( index ) ).CentersX );
centersY = flip( obj.Roads( roadsIdx( index ) ).CentersY );
centersZ = flip( obj.Roads( roadsIdx( index ) ).CentersZ );
id = obj.Roads( roadsIdx( index ) ).ID;
idx = roadsIdx( index );
break ;
end 
if ( obj.Roads( roadsIdx( index ) ).StartNode == startNode &&  ...
obj.Roads( roadsIdx( index ) ).EndNode == endNode )
centersX = obj.Roads( roadsIdx( index ) ).CentersX;
centersY = obj.Roads( roadsIdx( index ) ).CentersY;
centersZ = obj.Roads( roadsIdx( index ) ).CentersZ;
id = obj.Roads( roadsIdx( index ) ).ID;
idx = roadsIdx( index );
break ;
end 




















end 
route.CentersX = centersX;
route.CentersY = centersY;
route.CentersZ = centersZ;
route.RoadCentersX = centersX;
route.RoadCentersY = centersY;
route.RoadCentersZ = centersZ;
route.ID = id;
route.Index = idx;
route.IsJunction = false;
route.LaneCount = 0;
end 



function [ laneCount, width ] = getLane( obj, point )


laneCount = 0;
width = 0;
if ( point.IsOnJunction )
return ;
end 
index = point.RoadIndex;
road = obj.Roads( index );
centersX = road.CentersX;
centersY = road.CentersY;
centersZ = road.CentersZ;
centers = [ centersX, centersY, centersZ ];
position = point.Position;
forwardLanes = road.RoadSegments( 1 ).AllForwardLaneWidth;
for index = 1:2:length( forwardLanes )
backwardBoundaryWidth = forwardLanes( index );
forwardBoundaryWidth = forwardLanes( index + 1 );
backwardBoundary = mathUtils.shiftPoints( centers, backwardBoundaryWidth, 1 );
forwardBoundary = mathUtils.shiftPoints( centers, forwardBoundaryWidth, 1 );
polygon = [ backwardBoundary;forwardBoundary( end : - 1:1, : ) ];
checkTry = inpolygon( position( 1 ), position( 2 ),  ...
polygon( :, 1 ), polygon( :, 2 ) );
if ( checkTry )
laneCount = floor( ( index + 1 ) / 2 );
width = ( backwardBoundaryWidth + forwardBoundaryWidth ) / 2;
break ;
end 
end 
if laneCount > road.RoadSegments( 1 ).DrivingForwardLaneCount
laneCount = road.RoadSegments( 1 ).DrivingForwardLaneCount;
backwardBoundaryWidth = road.RoadSegments( 1 ).DrivingForwardLaneWidth( end  );
forwardBoundaryWidth = road.RoadSegments( 1 ).DrivingForwardLaneWidth( end  - 1 );
width = ( forwardBoundaryWidth + backwardBoundaryWidth ) / 2;
end 

if ( laneCount ~= 0 )
return ;
end 
backwardLanes = road.RoadSegments( 1 ).AllBackwardLaneWidth;
for index = 1:2:length( backwardLanes )
backwardBoundaryWidth = backwardLanes( index );
forwardBoundaryWidth = backwardLanes( index + 1 );
backwardBoundary = mathUtils.shiftPoints( centers, backwardBoundaryWidth, 1 );
forwardBoundary = mathUtils.shiftPoints( centers, forwardBoundaryWidth, 1 );
polygon = [ backwardBoundary;forwardBoundary( end : - 1:1, : ) ];
checkTry = inpolygon( position( 1 ), position( 2 ),  ...
polygon( :, 1 ), polygon( :, 2 ) );
if ( checkTry )
laneCount = length( backwardLanes ) / 2 - 1 * floor( ( index ) / 2 );
width = ( backwardBoundaryWidth + forwardBoundaryWidth ) / 2;
break ;
end 
end 

if laneCount > road.RoadSegments( 1 ).DrivingBackwardLaneCount
laneCount = road.RoadSegments( 1 ).DrivingBackwardLaneCount;
backwardBoundaryWidth = road.RoadSegments( 1 ).DrivingBackwardLaneWidth( 1 );
forwardBoundaryWidth = road.RoadSegments( 1 ).DrivingBackwardLaneWidth( 2 );
width = ( forwardBoundaryWidth + backwardBoundaryWidth ) / 2;
end 
laneCount =  - 1 * laneCount;
end 



function route = setRouteWidth( obj, route, laneCount, ~ )

for index = 1:length( route )
if ( ~route( index ).IsJunction )
roadIndex = route( index ).Index;
road = obj.Roads( roadIndex );

laneForward = road.RoadSegments( 1 ).DrivingForwardLaneWidth;
count = road.RoadSegments( 1 ).DrivingForwardLaneCount;
if ( isempty( laneForward ) )
laneForward = road.RoadSegments( 1 ).DrivingBackwardLaneWidth;
count = road.RoadSegments( 1 ).DrivingBackwardLaneCount;
end 
if ( abs( laneCount ) > count )
tempLaneCount = count;
else 
tempLaneCount = abs( laneCount );
end 
leftWidth = laneForward( tempLaneCount * 2 - 1 );
rightWidth = laneForward( tempLaneCount * 2 );
width = ( leftWidth + rightWidth ) / 2;
route( index ).LaneCount = tempLaneCount;
route( index ).Width = width;
end 
end 
end 


function route = getStartRoute( obj, point, laneCount, width )

route = obj.getRouteStruct(  );
if ( point.IsOnJunction )
route.CentersX = point.Position( 1 );
route.CentersY = point.Position( 2 );
route.CentersZ = point.Position( 3 );
route.RoadCentersX = point.Position( 1 );
route.RoadCentersY = point.Position( 2 );
route.RoadCentersZ = point.Position( 3 );
route.Width = 0;
route.IsJunction = true;
route.ID = point.RoadID;
route.Index = point.RoadIndex;
route.LaneCount = 0;
else 
roadIndex = point.RoadIndex;
centersX = obj.Roads( roadIndex ).CentersX;
centersY = obj.Roads( roadIndex ).CentersY;
centersZ = obj.Roads( roadIndex ).CentersZ;
if ( laneCount < 0 )
centersX = flip( centersX );
centersY = flip( centersY );
centersZ = flip( centersZ );
width =  - 1 * width;
end 
route.CentersX = centersX;
route.CentersY = centersY;
route.CentersZ = centersZ;
route.RoadCentersX = centersX;
route.RoadCentersY = centersY;
route.RoadCentersZ = centersZ;
route.IsJunction = false;
route.ID = point.RoadID;
route.Index = point.RoadIndex;
route.LaneCount = laneCount;
route.Width = width;
end 
end 



function route = getEndRoute( obj, point, laneCount, width )

route = obj.getRouteStruct(  );
if ( point.IsOnJunction )
route.CentersX = point.Position( 1 );
route.CentersY = point.Position( 2 );
route.CentersZ = point.Position( 3 );
route.IsJunction = true;
route.LaneCount = 0;
route.Index = point.RoadIndex;
else 
roadIndex = point.RoadIndex;
centersX = obj.Roads( roadIndex ).CentersX;
centersY = obj.Roads( roadIndex ).CentersY;
centersZ = obj.Roads( roadIndex ).CentersZ;
if ( laneCount < 0 )
centersX = flip( centersX );
centersY = flip( centersY );
centersZ = flip( centersZ );
width =  - 1 * width;
end 
route.CentersX = centersX;
route.CentersY = centersY;
route.CentersZ = centersZ;
route.RoadCentersX = centersX;
route.RoadCentersY = centersY;
route.RoadCentersZ = centersZ;
route.IsJunction = false;
route.LaneCount = laneCount;
route.Index = point.RoadIndex;
route.Width = width;
end 
end 



function updateRoadNetworkGeometry( obj )




roads = obj.RoadNetwork.Roads.toArray;
obj.Roads = repmat( obj.getRoadStruct(  ), length( roads ), 1 );
for index = 1:length( roads )
obj.Roads( index ).ID = roads( index ).ID;
obj.Roads( index ).Weight = roads( index ).Weight;
obj.Roads( index ).Direction = roads( index ).Direction;
if ( strcmpi( roads( index ).Direction, 'Backward' ) )
if ( strcmpi( obj.DrivingParam.Direction, 'Left' ) )
obj.Roads( index ).Direction = driving.roadnetwork.DirectionOfTravel( 'Forward' );
end 
end 
if ( strcmpi( roads( index ).Direction, 'Forward' ) )
if ( strcmpi( obj.DrivingParam.Direction, 'Left' ) )
obj.Roads( index ).Direction = driving.roadnetwork.DirectionOfTravel( 'Backward' );
end 
end 
if ( strcmpi( obj.DrivingParam.Direction, 'Left' ) )
obj.Roads( index ).EndNode = roads( index ).StartNode.ID;
obj.Roads( index ).StartNode = roads( index ).EndNode.ID;
else 
obj.Roads( index ).StartNode = roads( index ).StartNode.ID;
obj.Roads( index ).EndNode = roads( index ).EndNode.ID;
end 
[ obj.Roads( index ).RoadSegments, pointCount ] = obj.updateRoadSegments( roads( index ).RoadSegments.toArray );
[ obj.Roads( index ).CentersX,  ...
obj.Roads( index ).CentersY,  ...
obj.Roads( index ).CentersZ,  ...
obj.Roads( index ).IsStraight ] =  ...
obj.aggregateCenters( obj.Roads( index ).RoadSegments, pointCount );

end 


nodes = obj.RoadNetwork.Nodes.toArray;
obj.Nodes = repmat( obj.getNodeStruct(  ), length( nodes ), 1 );
for index = 1:length( nodes )
obj.Nodes( index ).ID = nodes( index ).ID;
obj.Nodes( index ).Name = nodes( index ).Name;
obj.Nodes( index ).PositionX = nodes( index ).PositionX;
obj.Nodes( index ).PositionY = nodes( index ).PositionY;
obj.Nodes( index ).PositionZ = nodes( index ).PositionZ;

if ( strcmpi( obj.DrivingParam.Direction, 'Right' ) )
[ outgoingRoads, outgoingRoadsIndex ] = obj.updateRoadsIndex( nodes( index ).OutgoingRoads.toArray );
[ incomingRoads, incomingRoadsIndex ] = obj.updateRoadsIndex( nodes( index ).IncomingRoads.toArray );
else 
[ incomingRoads, incomingRoadsIndex ] = obj.updateRoadsIndex( nodes( index ).OutgoingRoads.toArray );
[ outgoingRoads, outgoingRoadsIndex ] = obj.updateRoadsIndex( nodes( index ).IncomingRoads.toArray );
end 
obj.Nodes( index ).OutgoingRoads = outgoingRoads;
obj.Nodes( index ).OutgoingRoadsIndex = outgoingRoadsIndex;
obj.Nodes( index ).IncomingRoads = incomingRoads;
obj.Nodes( index ).IncomingRoadsIndex = incomingRoadsIndex;
obj.Nodes( index ).Polygon = obj.getJunctionPolygon( nodes( index ).RoadSegments.toArray, [ outgoingRoadsIndex;incomingRoadsIndex ] );
end 

for index = 1:length( obj.Roads )
obj.Roads( index ).StartNodeIndex = obj.getNodeIndex( obj.Roads( index ).StartNode );
obj.Roads( index ).EndNodeIndex = obj.getNodeIndex( obj.Roads( index ).EndNode );
end 
end 



function [ x, y, z, isStraight ] = aggregateCenters( obj, roadSegments, pointCount )

x = zeros( pointCount, 1 );
y = zeros( pointCount, 1 );
z = zeros( pointCount, 1 );
isStraight = zeros( pointCount, 1 );
count = 1;
for index = 1:length( roadSegments )
centerLength = length( roadSegments( index ).CentersX );
xTemp = transpose( roadSegments( index ).CentersX );
yTemp = transpose( roadSegments( index ).CentersY );
zTemp = transpose( roadSegments( index ).CentersZ );
x( count:count + centerLength - 1, 1 ) = xTemp;
y( count:count + centerLength - 1, 1 ) = yTemp;
z( count:count + centerLength - 1, 1 ) = zTemp;
if ( centerLength > 2 )
if obj.checkStraightLine( xTemp, yTemp, zTemp )
isStraight( count:count + centerLength - 1, 1 ) = 1;
else 
isStraight( count:count + centerLength - 1, 1 ) = 0;
end 
else 
isStraight( count:count + centerLength - 1, 1 ) = 1;
end 
count = count + centerLength;
end 
end 



function [ roadSegmentsOut, pointCount ] = updateRoadSegments( obj, roadSegments )


roadSegmentsOut = repmat( obj.getRoadSegmentStruct(  ), length( roadSegments ), 1 );
pointCount = 0;
for index = 1:length( roadSegments )
centersX = transpose( roadSegments( index ).CentersX.toArray );
centersY = transpose( roadSegments( index ).CentersY.toArray );
centersZ = transpose( roadSegments( index ).CentersZ.toArray );
bankingAngles = transpose( roadSegments( index ).BankingAngles.toArray );
headings = transpose( roadSegments( index ).Headings.toArray );
if ( strcmpi( obj.DrivingParam.Direction, 'Left' ) )
centersX = flip( centersX );
centersY = flip( centersY );
centersZ = flip( centersZ );
bankingAngles = flip( bankingAngles );
headings = flip( headings );
end 

roadSegmentsOut( index ).CentersX = centersX;
roadSegmentsOut( index ).CentersY = centersY;
roadSegmentsOut( index ).CentersZ = centersZ;
roadSegmentsOut( index ).BankingAngles = bankingAngles;
roadSegmentsOut( index ).Headings = headings;

pointCount = pointCount + length( roadSegments( index ).CentersX.toArray );
lanes = roadSegments( index ).Lanes.toArray;
roadSegmentsOut( index ).Lanes = obj.updateLaneGeometry( lanes );

[ forwardLaneWidth, backwardLaneWidth, bothLaneWidth ] = obj.addDrivingLaneInformation( roadSegmentsOut( index ).Lanes );
roadSegmentsOut( index ).DrivingForwardLaneWidth = forwardLaneWidth;
roadSegmentsOut( index ).DrivingBackwardLaneWidth = backwardLaneWidth;
roadSegmentsOut( index ).DrivingBothLaneWidth = bothLaneWidth;
roadSegmentsOut( index ).DrivingForwardLaneCount = length( forwardLaneWidth ) / 2;
roadSegmentsOut( index ).DrivingBackwardLaneCount = length( backwardLaneWidth ) / 2;
roadSegmentsOut( index ).DrivingBothLaneCount = length( bothLaneWidth ) / 2;

[ allForwardLaneWidth, allBackwardLaneWidth, allBothLaneWidth, allLaneWidth ] = obj.addAllLaneInformation( roadSegmentsOut( index ).Lanes, roadSegments( index ).LaneMarkings.toArray );
roadSegmentsOut( index ).AllForwardLaneWidth = allForwardLaneWidth;
roadSegmentsOut( index ).AllBackwardLaneWidth = allBackwardLaneWidth;
roadSegmentsOut( index ).AllBothLaneWidth = allBothLaneWidth;
roadSegmentsOut( index ).AllForwardLaneCount = length( allForwardLaneWidth ) / 2;
roadSegmentsOut( index ).AllBackwardLaneCount = length( allBackwardLaneWidth ) / 2;
roadSegmentsOut( index ).AllBothLaneCount = length( allBothLaneWidth ) / 2;
roadSegmentsOut( index ).AllLaneWidth = allLaneWidth;
roadSegmentsOut( index ).AllLaneCount = length( allLaneWidth ) - 1;
end 
end 


function lanesOut = updateLaneGeometry( obj, lanes )


lanesOut = repmat( obj.getLaneStruct(  ), length( lanes ), 1 );
for index = 1:length( lanes )
if ( strcmpi( obj.DrivingParam.Direction, 'Left' ) )
if ( strcmpi( lanes( index ).Direction, 'Forward' ) )
lanesOut( index ).Direction = driving.roadnetwork.DirectionOfTravel( 'Backward' );
elseif ( strcmpi( lanes( index ).Direction, 'Backward' ) )
lanesOut( index ).Direction = driving.roadnetwork.DirectionOfTravel( 'Forward' );
else 
lanesOut( index ).Direction = lanes( index ).Direction;
end 
else 
lanesOut( index ).Direction = lanes( index ).Direction;
end 
lanesOut( index ).Width = lanes( index ).Width;
lanesOut( index ).Type = lanes( index ).Type;





end 
end 



function index = getRoadIndex( obj, ID )


index =  - 1;
for idx = 1:length( obj.Roads )
if ( obj.Roads( idx ).ID == ID )
index = idx;
return ;
end 
end 
end 



function [ ID, index ] = updateRoadsIndex( obj, roads )


ID = zeros( length( roads ), 1 );
index = zeros( length( roads ), 1 );
for idx = 1:length( roads )
ID( idx ) = roads( idx ).ID;
index( idx ) = obj.getRoadIndex( ID( idx ) );
end 
end 



function index = getNodeIndex( obj, node )


index =  - 1;
for idx = 1:length( obj.Nodes )
if ( obj.Nodes( idx ).ID == node )
index = idx;
return ;
end 
end 
end 



function [ laneForward, laneBackward, laneBoth, allLaneWidth ] = addAllLaneInformation( obj, lanes, laneMarkings )


if ( strcmpi( laneMarkings( 1 ).Type, 'Unmarked' ) )
startLaneMarkingWidth = 0;
else 
if ( strcmpi( obj.DrivingParam.Direction, 'Left' ) )
endLaneMarkingWidth = laneMarkings( 1 ).Width / 2;
else 
startLaneMarkingWidth = laneMarkings( 1 ).Width / 2;
end 
end 
if ( strcmpi( laneMarkings( end  ).Type, 'Unmarked' ) )
endLaneMarkingWidth = 0;
else 
if ( strcmpi( obj.DrivingParam.Direction, 'Left' ) )
startLaneMarkingWidth = laneMarkings( end  ).Width / 2;
else 
endLaneMarkingWidth = laneMarkings( end  ).Width / 2;
end 
end 


widthRoad = 0;
backwardLaneCount = 0;
forwardLaneCount = 0;
bothLaneCount = 0;


laneWidthIgnored = 0;
laneCounter = 0;
laneWidthsArray = zeros( length( lanes ) + 1, 1 );

for index = 1:length( lanes )
widthRoad = widthRoad + lanes( index ).Width;
if ( strcmpi( lanes( index ).Direction, 'Backward' ) )
backwardLaneCount = backwardLaneCount + 1;
end 
if ( strcmpi( lanes( index ).Direction, 'Forward' ) )
forwardLaneCount = forwardLaneCount + 1;
end 
if ( strcmpi( lanes( index ).Direction, 'Both' ) )
bothLaneCount = bothLaneCount + 1;
end 

laneWidthIgnored = laneWidthIgnored + lanes( index ).Width;
laneCounter = laneCounter + 1;
laneWidthsArray( laneCounter + 1 ) = laneWidthIgnored;
end 

middleRoad = ( laneWidthsArray( end  ) - laneWidthsArray( 1 ) ) / 2;
laneWidthsArray = laneWidthsArray - middleRoad;
allLaneWidth = laneWidthsArray;
laneWidthsArray( 1 ) = laneWidthsArray( 1 ) - startLaneMarkingWidth;
laneWidthsArray( end  ) = laneWidthsArray( end  ) + endLaneMarkingWidth;

laneBackward = zeros( 1, 2 * backwardLaneCount );
laneForward = zeros( 1, 2 * forwardLaneCount );
laneBoth = zeros( 1, 2 * bothLaneCount );
backwardCounter = 0;
forwardCounter = 0;
bothCounter = 0;
for index = 1:length( lanes )
if ( strcmpi( lanes( index ).Direction, 'Backward' ) )
laneBackward( backwardCounter + 1 ) = laneWidthsArray( index );
laneBackward( backwardCounter + 2 ) = laneWidthsArray( index + 1 );
backwardCounter = backwardCounter + 2;
end 
if ( strcmpi( lanes( index ).Direction, 'Forward' ) )
laneForward( forwardCounter + 1 ) = laneWidthsArray( index );
laneForward( forwardCounter + 2 ) = laneWidthsArray( index + 1 );
forwardCounter = forwardCounter + 2;
end 
if ( strcmpi( lanes( index ).Direction, 'Both' ) )
laneBoth( bothCounter + 1 ) = laneWidthsArray( index );
laneBoth( bothCounter + 2 ) = laneWidthsArray( index + 1 );
bothCounter = bothCounter + 2;
end 
end 

if ( strcmpi( obj.DrivingParam.Direction, 'Left' ) )
laneForward = flip( laneForward );
laneBackward = flip( laneBackward );
laneBoth = flip( laneBoth );
laneForward =  - 1 * laneForward;
laneBackward =  - 1 * laneBackward;
laneBoth =  - 1 * laneBoth;
end 

end 



function [ laneForward, laneBackward, laneBoth ] = addDrivingLaneInformation( obj, lanes )



widthRoad = 0;
backwardLaneCount = 0;
forwardLaneCount = 0;
bothLaneCount = 0;


laneWidthIgnored = 0;
laneCounter = 0;
laneWidthsArray = zeros( length( lanes ) + 1, 1 );

for index = 1:length( lanes )
widthRoad = widthRoad + lanes( index ).Width;
if ( strcmpi( lanes( index ).Direction, 'Backward' ) && strcmpi( lanes( index ).Type, 'Driving' ) )
backwardLaneCount = backwardLaneCount + 1;
end 
if ( strcmpi( lanes( index ).Direction, 'Forward' ) && strcmpi( lanes( index ).Type, 'Driving' ) )
forwardLaneCount = forwardLaneCount + 1;
end 
if ( strcmpi( lanes( index ).Direction, 'Both' ) && strcmpi( lanes( index ).Type, 'Driving' ) )
bothLaneCount = bothLaneCount + 1;
end 

laneWidthIgnored = laneWidthIgnored + lanes( index ).Width;
laneCounter = laneCounter + 1;
laneWidthsArray( laneCounter + 1 ) = laneWidthIgnored;
end 

middleRoad = ( laneWidthsArray( end  ) - laneWidthsArray( 1 ) ) / 2;

laneWidthsArray = laneWidthsArray - middleRoad;

laneBackward = zeros( 1, 2 * backwardLaneCount );
laneForward = zeros( 1, 2 * forwardLaneCount );
laneBoth = zeros( 1, 2 * bothLaneCount );
backwardCounter = 0;
forwardCounter = 0;
bothCounter = 0;
for index = 1:length( lanes )
if ( strcmpi( lanes( index ).Direction, 'Backward' ) && strcmpi( lanes( index ).Type, 'Driving' ) )
laneBackward( backwardCounter + 1 ) = laneWidthsArray( index );
laneBackward( backwardCounter + 2 ) = laneWidthsArray( index + 1 );
backwardCounter = backwardCounter + 2;
end 
if ( strcmpi( lanes( index ).Direction, 'Forward' ) && strcmpi( lanes( index ).Type, 'Driving' ) )
laneForward( forwardCounter + 1 ) = laneWidthsArray( index );
laneForward( forwardCounter + 2 ) = laneWidthsArray( index + 1 );
forwardCounter = forwardCounter + 2;
end 
if ( strcmpi( lanes( index ).Direction, 'Both' ) && strcmpi( lanes( index ).Type, 'Driving' ) )
laneBoth( bothCounter + 1 ) = laneWidthsArray( index );
laneBoth( bothCounter + 2 ) = laneWidthsArray( index + 1 );
bothCounter = bothCounter + 2;
end 
end 

if ( strcmpi( obj.DrivingParam.Direction, 'Left' ) )
laneForward = flip( laneForward );
laneBackward = flip( laneBackward );
laneBoth = flip( laneBoth );
laneForward =  - 1 * laneForward;
laneBackward =  - 1 * laneBackward;
laneBoth =  - 1 * laneBoth;
end 
end 



function success = checkStraightLine( ~, x, y, z )

if ( length( x ) <= 2 )
success = true;
return ;
end 
point1 = [ x( 1 ), y( 1 ), z( 1 ) ];
point2 = [ x( 2 ), y( 2 ), z( 2 ) ];

line = mathUtils.getLineEquation( point1, point2 );
success = true;
for index = 3:length( x )
if ( abs( line( 1 ) * x( index ) + line( 2 ) * y( index ) + line( 3 ) ) > .01 )
success = false;
break ;
end 
end 
end 



function polygon = getJunctionPolygon( obj, roadSegments, connectedRoadsIndex )

edges = zeros( length( roadSegments ) * 4, 3 );
counter = 1;
for index = 1:length( roadSegments )
roadSegment = roadSegments( index );
centerX = transpose( roadSegment.CentersX.toArray );
centerY = transpose( roadSegment.CentersY.toArray );
centerZ = transpose( roadSegment.CentersZ.toArray );
path = [ centerX, centerY, centerZ ];
points = obj.findInConnectedRoads( path, connectedRoadsIndex );
edges( counter, : ) = points( 1, : );
edges( counter + 1, : ) = points( 2, : );
edges( counter + 2, : ) = points( 3, : );
edges( counter + 3, : ) = points( 4, : );
counter = counter + 4;
end 
edges = obj.removeDuplicatePoints( edges );
polygon = obj.reorderPointsInPolygon( edges );
end 



function pointsOut = findInConnectedRoads( obj, points, roadsIndex )


startPoint = points( 1, : );
endPoint = points( end , : );
pointsOut = zeros( 4, 3 );
for index = 1:length( roadsIndex )
centersX = obj.Roads( roadsIndex( index ) ).CentersX;
centersY = obj.Roads( roadsIndex( index ) ).CentersY;
centersZ = obj.Roads( roadsIndex( index ) ).CentersZ;
roadCenters = [ centersX, centersY, centersZ ];
if ( isempty( centersX ) )
return ;
end 
if ( norm( startPoint - roadCenters( 1, : ) ) <= 0.01 )
if ( isempty( obj.Roads( roadsIndex( index ) ).RoadSegments( 1 ).AllForwardLaneWidth ) )
widthF = 0;
else 
widthF = ( obj.Roads( roadsIndex( index ) ).RoadSegments( 1 ).AllForwardLaneWidth( end  ) );
end 
if ( isempty( obj.Roads( roadsIndex( index ) ).RoadSegments( 1 ).AllBackwardLaneWidth ) )
widthB = 0;
else 
widthB = ( obj.Roads( roadsIndex( index ) ).RoadSegments( 1 ).AllBackwardLaneWidth( 1 ) );
end 
FwdBoundary = mathUtils.shiftPoints( roadCenters, widthF, 1 );
BwdBoundary = mathUtils.shiftPoints( roadCenters, widthB, 1 );
pointsOut( 1, : ) = FwdBoundary( 1, : );
pointsOut( 2, : ) = BwdBoundary( 1, : );

end 
if ( norm( startPoint - roadCenters( end , : ) ) <= 0.01 )

if ( isempty( obj.Roads( roadsIndex( index ) ).RoadSegments( end  ).AllForwardLaneWidth ) )
widthF = 0;
else 
widthF = ( obj.Roads( roadsIndex( index ) ).RoadSegments( end  ).AllForwardLaneWidth( end  ) );
end 
if ( isempty( obj.Roads( roadsIndex( index ) ).RoadSegments( end  ).AllBackwardLaneWidth ) )
widthB = 0;
else 
widthB = ( obj.Roads( roadsIndex( index ) ).RoadSegments( end  ).AllBackwardLaneWidth( 1 ) );
end 
FwdBoundary = mathUtils.shiftPoints( roadCenters, widthF, 1 );
BwdBoundary = mathUtils.shiftPoints( roadCenters, widthB, 1 );
pointsOut( 1, : ) = FwdBoundary( end , : );
pointsOut( 2, : ) = BwdBoundary( end , : );
end 

if ( norm( endPoint - roadCenters( 1, : ) ) <= 0.01 )

if ( isempty( obj.Roads( roadsIndex( index ) ).RoadSegments( 1 ).AllForwardLaneWidth ) )
widthF = 0;
else 
widthF = ( obj.Roads( roadsIndex( index ) ).RoadSegments( 1 ).AllForwardLaneWidth( end  ) );
end 
if ( isempty( obj.Roads( roadsIndex( index ) ).RoadSegments( 1 ).AllBackwardLaneWidth ) )
widthB = 0;
else 
widthB = ( obj.Roads( roadsIndex( index ) ).RoadSegments( 1 ).AllBackwardLaneWidth( 1 ) );
end 

FwdBoundary = mathUtils.shiftPoints( roadCenters, widthF, 1 );
BwdBoundary = mathUtils.shiftPoints( roadCenters, widthB, 1 );
pointsOut( 3, : ) = FwdBoundary( 1, : );
pointsOut( 4, : ) = BwdBoundary( 1, : );
end 

if ( norm( endPoint - roadCenters( end , : ) ) <= 0.01 )
if ( isempty( obj.Roads( roadsIndex( index ) ).RoadSegments( end  ).AllForwardLaneWidth ) )
widthF = 0;
else 
widthF = ( obj.Roads( roadsIndex( index ) ).RoadSegments( end  ).AllForwardLaneWidth( end  ) );
end 
if ( isempty( obj.Roads( roadsIndex( index ) ).RoadSegments( end  ).AllBackwardLaneWidth ) )
widthB = 0;
else 
widthB = ( obj.Roads( roadsIndex( index ) ).RoadSegments( end  ).AllBackwardLaneWidth( 1 ) );
end 
FwdBoundary = mathUtils.shiftPoints( roadCenters, widthF, 1 );
BwdBoundary = mathUtils.shiftPoints( roadCenters, widthB, 1 );
pointsOut( 3, : ) = FwdBoundary( end , : );
pointsOut( 4, : ) = BwdBoundary( end , : );
end 
end 
end 


function edgesOut = removeDuplicatePoints( ~, edges )

edgesOut = zeros( size( edges, 1 ), 3 );
counter = 0;
for index = 1:size( edges, 1 )
point = edges( index, : );
if ( isnan( point( 1 ) ) )
continue ;
end 
for subIndex = 1:size( edges, 1 )
if ( index ~= subIndex && norm( point - edges( subIndex, : ) ) <= .1 )
edges( subIndex, : ) = nan;
end 
end 
counter = counter + 1;
edgesOut( counter, : ) = point;
end 
edgesOut = edgesOut( 1:counter, : );
end 



function polygon = reorderPointsInPolygon( ~, edges )

if size( edges, 1 ) == 0
polygon = [  ];
return ;
end 
angle = zeros( size( edges, 1 ), 1 );
polygon = zeros( size( edges, 1 ), 3 );
polygon( 1, : ) = edges( 1, : );
for index = 2:size( edges, 1 )
targetPoint = edges( index, : );
diff = edges( 1, : ) - targetPoint;
angle( index ) = atan2( diff( 2 ), diff( 1 ) );
end 
for index = 1:size( angle, 1 )
[ ~, minIndex ] = min( angle );
angle( minIndex ) = nan;
polygon( index, : ) = edges( minIndex, : );
end 
end 



function success = updatePointsLocation( obj )

pointCount = length( obj.StartPoints );
pointsAll = zeros( 2 * pointCount, 3 );
roadIdx = zeros( 2 * pointCount, 1 );
roadID = zeros( 2 * pointCount, 1 );
isOnJunction = zeros( 2 * pointCount, 1 );

for index = 1:pointCount
pointsAll( index, : ) = obj.StartPoints( index ).Position;
pointsAll( index + pointCount, : ) = obj.EndPoints( index ).Position;
end 

for index = 1:length( obj.Nodes )
polygon = obj.Nodes( index ).Polygon;
if ( size( polygon, 1 ) == 0 )
continue ;
end 

checkTry = inpolygon( pointsAll( :, 1 ), pointsAll( :, 2 ),  ...
polygon( :, 1 ), polygon( :, 2 ) );
if ( sum( checkTry ) > 0 )
roadID( checkTry ) = obj.Nodes( index ).ID;
roadIdx( checkTry ) = index;
isOnJunction( checkTry ) = 1;
end 
end 

for index = 1:length( obj.Roads )
centersX = obj.Roads( index ).CentersX;
centersY = obj.Roads( index ).CentersY;
centersZ = obj.Roads( index ).CentersZ;
centers = [ centersX, centersY, centersZ ];

LeftBoundaryWidth = obj.Roads( index ).RoadSegments( 1 ).AllLaneWidth( 1 );
RightBoundaryWidth = obj.Roads( index ).RoadSegments( 1 ).AllLaneWidth( end  );

leftShifted = mathUtils.shiftPoints( centers, 1.15 * LeftBoundaryWidth, 1 );
rightShifted = mathUtils.shiftPoints( centers, 1.15 * RightBoundaryWidth, 1 );

polygon = [ leftShifted;rightShifted( end : - 1:1, : ) ];

checkTry = inpolygon( pointsAll( :, 1 ), pointsAll( :, 2 ),  ...
polygon( :, 1 ), polygon( :, 2 ) );
if ( sum( checkTry ) > 0 )
roadID( checkTry ) = obj.Roads( index ).ID;
roadIdx( checkTry ) = index;
isOnJunction( checkTry ) = 0;
end 
end 
if ( any( roadIdx == 0 ) )
success = false;
return ;
end 

success = true;

for index = 1:pointCount
if ( roadID( index ) == 0 )
success = false;
end 
obj.StartPoints( index ).RoadID = roadID( index );
obj.StartPoints( index ).RoadIndex = roadIdx( index );
obj.StartPoints( index ).IsOnJunction = isOnJunction( index );
obj.StartPoints( index ).Node = obj.getDrivingLane( obj.StartPoints( index ), 'Start' );

obj.EndPoints( index ).RoadID = roadID( index + pointCount );
obj.EndPoints( index ).RoadIndex = roadIdx( index + pointCount );
obj.EndPoints( index ).IsOnJunction = isOnJunction( index + pointCount );
obj.EndPoints( index ).Node = obj.getDrivingLane( obj.EndPoints( index ), 'End' );
end 
end 



function [ nodeIDs ] = buildNodetraversalPaths( obj, startPoint, endPoint )









if ( length( obj.Nodes ) == 1 ||  ...
norm( startPoint.Position - endPoint.Position ) == 0 )
nodeIDs = [  ];
return ;
end 

startNodeID = startPoint.Node;
endNodeID = endPoint.Node;

if ( obj.checkCommonNode( startNodeID, endNodeID ) ~= 1 )
nodeIDs = shortestpath( obj.RoadGraph, num2str( startNodeID ), num2str( endNodeID ) );
nodes = zeros( 1, length( nodeIDs ) );
for index = 1:length( nodeIDs )
nodes( index ) = str2double( nodeIDs{ index } );
end 
nodeIDs = nodes;
else 


nodeIDs = [  ];
end 

end 



function same = checkCommonNode( obj, nodeA, nodeB )








if ( nodeA == nodeB )
same = 1;
return ;
else 
PositionArray = obj.RoadGraph.Nodes.Position;
NamesArray = obj.RoadGraph.Nodes.Name;

positionA = [  ];
positionB = [  ];
for index = 1:1:length( NamesArray )
element = NamesArray{ index };
if ( str2double( element ) == nodeA )
positionA = PositionArray( index, : );
end 
if ( str2double( element ) == nodeB )
positionB = PositionArray( index, : );
end 
end 
diff = positionA - positionB;
if ( norm( diff ) < 1e-03 )
same = 1;
else 
same = 0;
end 
end 
end 



function [ nodeID, nodeIndex, laneType ] = getDrivingLane( obj, point, mode )

nodeID = 0;


nodeIndex = 0;
if ( point.IsOnJunction )
nodeID = point.RoadID;
nodeIndex = point.RoadIndex;
else 
roadIndex = point.RoadIndex;
position = point.Position;
pointIndex = point.PointIndex;
centersX = obj.Roads( roadIndex ).CentersX;
centersY = obj.Roads( roadIndex ).CentersY;
centersZ = obj.Roads( roadIndex ).CentersZ;
centers = [ centersX, centersY, centersZ ];
if ( isempty( obj.Roads( roadIndex ).RoadSegments( 1 ).AllBackwardLaneWidth ) )
backwardLaneWidth = obj.Roads( roadIndex ).RoadSegments( 1 ).AllForwardLaneWidth( end  - 1 );
else 
backwardLaneWidth = obj.Roads( roadIndex ).RoadSegments( 1 ).AllBackwardLaneWidth( 1 );
end 
if ( isempty( obj.Roads( roadIndex ).RoadSegments( 1 ).AllForwardLaneWidth ) )
forwardLaneWidth = obj.Roads( roadIndex ).RoadSegments( 1 ).AllBackwardLaneWidth( 2 );
else 
forwardLaneWidth = obj.Roads( roadIndex ).RoadSegments( 1 ).AllForwardLaneWidth( end  );
end 
backwardLaneBoundaryRight = mathUtils.shiftPoints( centers, backwardLaneWidth, 1 );
forwardLaneBoundaryRight = mathUtils.shiftPoints( centers, forwardLaneWidth, 1 );
backwardLaneBoundaryLeft = mathUtils.shiftPoints( centers, backwardLaneWidth,  - 1 );
forwardLaneBoundaryLeft = mathUtils.shiftPoints( centers, forwardLaneWidth,  - 1 );
polygonBackwardRight = [ backwardLaneBoundaryRight;centers( end : - 1:1, : ) ];
polygonForwardRight = [ forwardLaneBoundaryRight;centers( end : - 1:1, : ) ];
polygonBackwardLeft = [ backwardLaneBoundaryLeft;centers( end : - 1:1, : ) ];
polygonForwardLeft = [ forwardLaneBoundaryLeft;centers( end : - 1:1, : ) ];
checkTryBackwardRight = inpolygon( position( 1 ), position( 2 ), polygonBackwardRight( :, 1 ), polygonBackwardRight( :, 2 ) );
checkTryForwardRight = inpolygon( position( 1 ), position( 2 ), polygonForwardRight( :, 1 ), polygonForwardRight( :, 2 ) );
checkTryBackwardLeft = inpolygon( position( 1 ), position( 2 ), polygonBackwardLeft( :, 1 ), polygonBackwardLeft( :, 2 ) );
checkTryForwardLeft = inpolygon( position( 1 ), position( 2 ), polygonForwardLeft( :, 1 ), polygonForwardLeft( :, 2 ) );
if ~( checkTryBackwardRight || checkTryForwardRight || checkTryBackwardLeft || checkTryForwardLeft )
disp( "Can't locate point on Road." )
end 
laneType = driving.roadnetwork.DirectionOfTravel( 'Unknown' );
if ( checkTryBackwardRight )
laneType = driving.roadnetwork.DirectionOfTravel( 'Backward' );
if ( strcmpi( obj.DrivingParam.Direction, 'Left' ) )
if ( strcmpi( mode, 'start' ) )
nodeID = obj.Roads( roadIndex ).EndNode;
nodeIndex = obj.Roads( roadIndex ).EndNodeIndex;
else 
nodeID = obj.Roads( roadIndex ).StartNode;
nodeIndex = obj.Roads( roadIndex ).StartNodeIndex;
end 
else 
if ( strcmpi( mode, 'start' ) )
nodeID = obj.Roads( roadIndex ).StartNode;
nodeIndex = obj.Roads( roadIndex ).StartNodeIndex;
else 
nodeID = obj.Roads( roadIndex ).EndNode;
nodeIndex = obj.Roads( roadIndex ).EndNodeIndex;
end 
end 
end 

if ( checkTryForwardRight )
laneType = driving.roadnetwork.DirectionOfTravel( 'Forward' );
if ( strcmpi( obj.DrivingParam.Direction, 'Left' ) )
if ( strcmpi( mode, 'start' ) )
nodeID = obj.Roads( roadIndex ).StartNode;
nodeIndex = obj.Roads( roadIndex ).StartNodeIndex;
else 
nodeID = obj.Roads( roadIndex ).EndNode;
nodeIndex = obj.Roads( roadIndex ).EndNodeIndex;
end 
else 
if ( strcmpi( mode, 'start' ) )
nodeID = obj.Roads( roadIndex ).EndNode;
nodeIndex = obj.Roads( roadIndex ).EndNodeIndex;
else 
nodeID = obj.Roads( roadIndex ).StartNode;
nodeIndex = obj.Roads( roadIndex ).StartNodeIndex;
end 
end 
end 
nodeStart = obj.Roads( roadIndex ).StartNode;
nodeEnd = obj.Roads( roadIndex ).EndNode;
connection1 = findedge( obj.RoadGraph, num2str( nodeStart ), num2str( nodeEnd ) );
connection2 = findedge( obj.RoadGraph, num2str( nodeEnd ), num2str( nodeStart ) );
if ( connection1( 1 ) == 0 || connection2( 1 ) == 0 )
if ( connection1( 1 ) == 0 )
if ( strcmpi( mode, 'end' ) )
nodeID = obj.Roads( roadIndex ).EndNode;
nodeIndex = obj.Roads( roadIndex ).EndNodeIndex;
else 
nodeID = obj.Roads( roadIndex ).StartNode;
nodeIndex = obj.Roads( roadIndex ).StartNodeIndex;
end 
end 
if ( connection2( 1 ) == 0 )
if ( strcmpi( mode, 'end' ) )
nodeID = obj.Roads( roadIndex ).StartNode;
nodeIndex = obj.Roads( roadIndex ).StartNodeIndex;
else 
nodeID = obj.Roads( roadIndex ).EndNode;
nodeIndex = obj.Roads( roadIndex ).EndNodeIndex;
end 
end 
end 
if ( strcmpi( mode, 'end' ) )
obj.EndPoints( pointIndex ).Direction = laneType;
else 
obj.StartPoints( pointIndex ).Direction = laneType;
end 
end 
end 



function route = trimPath( ~, route, inputPoint, mode )









path = [ route.CentersX, route.CentersY, route.CentersZ ];
if ( isempty( path ) || size( path, 1 ) < 2 )
return ;
end 
point = inputPoint.Position;
pathLen = size( path, 1 );
minDist = 65656;
index = 1;
for indx = 1:pathLen
point1 = path( indx, : );
dist = norm( point1 - point );
if ( dist < minDist )
index = indx;
minDist = dist;
end 
end 
if ( index == 1 )
pointMin1 = path( index, : );
pointMin2 = path( index + 1, : );
elseif ( index == size( path, 1 ) )
pointMin1 = path( index - 1, : );
pointMin2 = path( index, : );
index = index - 1;
else 
point1 = path( index - 1, : );
point2 = path( index, : );
point3 = path( index + 1, : );
line1 = mathUtils.getLineEquation( point1, point2 );
line2 = mathUtils.getPerpedicularLineEquation( line1, point( 1:2 ) );
projPoint1 = mathUtils.getIntersectionPointLL( line1, line2 );
if ( abs( mathUtils.norm( projPoint1, point1, 2 ) +  ...
mathUtils.norm( projPoint1, point2, 2 ) -  ...
mathUtils.norm( point1, point2, 2 ) ) <= 1e-03 )
pointMin1 = point1;
pointMin2 = point2;
index = index - 1;
else 
pointMin1 = point2;
pointMin2 = point3;
end 
end 



line1 = mathUtils.getLineEquation( pointMin1, pointMin2 );
line2 = mathUtils.getPerpedicularLineEquation( line1, point( 1:2 ) );
projPoint = mathUtils.getIntersectionPointLL( line1, line2 );
if ( norm( pointMin1( 1:2 ) - pointMin1( 1:2 ) ) == 0 )
z = 0;
else 
ratio = norm( pointMin1( 1:2 ) - projPoint ) /  ...
norm( pointMin1( 1:2 ) - pointMin1( 1:2 ) );
z = pointMin2( 3 ) * ratio + pointMin1( 3 ) * ( 1 - ratio );
end 
if ( strcmpi( mode, 'Start' ) )
pathOut = [ projPoint, z;path( index + 1:end , : ) ];
else 
pathOut = [ path( 1:index, : );projPoint, z ];
end 
route.CentersX = pathOut( :, 1 );
route.CentersY = pathOut( :, 2 );
route.CentersZ = pathOut( :, 3 );
end 



function figureH = plotGraphInternal( obj, mode )

if ( obj.ExitCode ==  - 1 )
disp( 'Please check Inputs.' );
return ;
end 

figureH = figure( 'units', 'normalized', 'outerposition', [ 0, 0, 1, 1 ] );
axesH = axes( figureH );

set( axesH, 'Units', 'Normalized' );

if ( mode == 0 )
plot( obj.RoadGraph, 'LineWidth', 2, 'Parent', axesH );
else 
positionArray = obj.RoadGraph.Nodes.Position;

xdata = positionArray( :, 1 );
ydata = positionArray( :, 2 );
zdata = positionArray( :, 3 );

plot( obj.Scenario, 'Parent', axesH );
hold on;
plot( obj.RoadGraph, 'XData', xdata, 'YData', ydata,  ...
'ZData', zdata, 'LineWidth', 2, 'Parent', axesH );
end 
end 



function figureH = plotScenarioInternal( obj )

if ( obj.ExitCode ==  - 1 )
disp( 'Please check Inputs.' );
return ;
end 

figureH = figure( 'units', 'normalized', 'outerposition', [ 0, 0, 1, 1 ] );
axesH = axes( figureH );

set( axesH, 'Units', 'Normalized' );

plot( obj.Scenario, 'Parent', axesH );
hold on;
for index = 1:length( obj.Path )
centers = obj.Path( index ).waypoints;
plot( centers( :, 1 ), centers( :, 2 ), 'LineWidth', 2, 'Color', 'Blue', 'Parent', axesH );
hold on;
plot( obj.StartPoints( index ).Position( 1 ),  ...
obj.StartPoints( index ).Position( 2 ),  ...
'o', 'Color', 'green', 'LineWidth',  ...
3, 'Parent', axesH );
plot( obj.EndPoints( index ).Position( 1 ),  ...
obj.EndPoints( index ).Position( 2 ),  ...
'o', 'Color', 'red', 'LineWidth',  ...
3, 'Parent', axesH );
hold on;
end 
end 



function figureH = plotRouteSegmentInternal( obj, pathIndex, RouteIndex, figureH )

if ( obj.ExitCode ==  - 1 )
disp( 'Please check Inputs.' );
return ;
end 

plot( obj.Scenario, 'Parent', axesH );
hold on;
route = obj.RouteSegments( pathIndex ).Route;
centersX = route( RouteIndex ).CentersX;
centersY = route( RouteIndex ).CentersY;
plot( centersX, centersY, 'LineWidth', 2, 'Color', 'Blue', 'Parent', axesH );
hold on;
plot( obj.StartPoints( pathIndex ).Position( 1 ),  ...
obj.StartPoints( pathIndex ).Position( 2 ),  ...
'o', 'Color', 'green', 'LineWidth',  ...
3, 'Parent', axesH );
plot( obj.EndPoints( pathIndex ).Position( 1 ),  ...
obj.EndPoints( pathIndex ).Position( 2 ),  ...
'o', 'Color', 'green', 'LineWidth',  ...
3, 'Parent', axesH );
hold on;
end 



function figureH = plotRoutesInternal( obj, routes )

if ( obj.ExitCode ==  - 1 )
disp( 'Please check Inputs.' );
return ;
end 

figureH = figure( 'units', 'normalized', 'outerposition', [ 0, 0, 1, 1 ] );
axesH = axes( figureH );

set( axesH, 'Units', 'Normalized' );

plot( obj.Scenario, 'Parent', axesH );
hold on;
for index = 1:length( routes )
route = routes( index ).Route;
for subIndex = 1:length( route )
centersX = route( index ).CentersX;
centersY = route( index ).CentersY;
plot( centersX, centersY, 'LineWidth', 2, 'Color', 'Blue', 'Parent', axesH );
hold on;
end 
plot( obj.StartPoints( index ).Position( 1 ),  ...
obj.StartPoints( index ).Position( 2 ),  ...
'o', 'Color', 'green', 'LineWidth',  ...
3, 'Parent', axesH );
plot( obj.EndPoints( index ).Position( 1 ),  ...
obj.EndPoints( index ).Position( 2 ),  ...
'o', 'Color', 'red', 'LineWidth',  ...
3, 'Parent', axesH );
hold on;
end 
end 



function figureH = plotRouteInternal( obj, routeIndex )

if ( obj.ExitCode ==  - 1 )
disp( 'Please check Inputs.' );
return ;
end 

figureH = figure( 'units', 'normalized', 'outerposition', [ 0, 0, 1, 1 ] );
axesH = axes( figureH );

set( axesH, 'Units', 'Normalized' );

plot( obj.Scenario, 'Parent', axesH );
hold on;
if ( routeIndex > length( obj.Path ) )
error( [ 'Index Error. Max value for index is ', num2str( length( obj.Path ) ) ] );
end 
waypoints = obj.Path( routeIndex ).waypoints;
centersX = waypoints( :, 1 );
centersY = waypoints( :, 2 );
plot( centersX, centersY, 'LineWidth', 2, 'Color', 'Blue', 'Parent', axesH );
hold on;
plot( obj.StartPoints( routeIndex ).Position( 1 ),  ...
obj.StartPoints( routeIndex ).Position( 2 ),  ...
'o', 'Color', 'green', 'LineWidth',  ...
3, 'Parent', axesH );
plot( obj.EndPoints( routeIndex ).Position( 1 ),  ...
obj.EndPoints( routeIndex ).Position( 2 ),  ...
'o', 'Color', 'green', 'LineWidth',  ...
3, 'Parent', axesH );
hold on;
end 


end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpNaHm_a.p.
% Please follow local copyright laws when handling this file.

