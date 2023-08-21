classdef Tractor < sim3d.auto.WheeledVehicle

properties ( SetAccess = 'private', GetAccess = 'public' )
TractorType;

end 


methods

function self = Tractor( actorName, tractorType, varargin )
narginchk( 2, inf );
numberOfParts = uint32( 7 );

r = sim3d.auto.Tractor.parseInputs( numberOfParts, varargin{ : } );

mesh = '';

self@sim3d.auto.WheeledVehicle( actorName, r.ActorID, r.Translation,  ...
r.Rotation, r.Scale, numberOfParts, mesh );

if ( self.DebugRayTrace )
self.RayEnd( :, 2 ) = 1;
end 
self.RayStart = [ 0, 0,  - 1;0, 0,  - 1;0, 0,  - 1;0, 0,  - 1;0, 0,  - 1;0, 0,  - 1 ];
self.RayEnd = [ 1, 0, 10;1, 0, 10;1, 0, 10;1, 0, 10;1, 0, 10;1, 0, 10 ];
self.TractorType = tractorType;
self.Mesh = self.getMesh(  );
self.Animation = self.getAnimation(  );
self.Color = self.getColor( r.Color );
self.Translation = single( r.Translation );
self.Rotation = single( r.Rotation );
self.Scale = single( r.Scale );
self.ActorID = r.ActorID;


self.Config.MeshPath = self.Mesh;
self.Config.AnimationPath = self.Animation;
self.Config.ColorPath = self.Color;
self.Config.AdditionalOptions = '';
end 

function wheelHitZ = VehicleRayTraceRead( self )
[ ~, RayEnd ] = self.RaytraceReader.read(  );
if ( isempty( RayEnd ) )
error( 'sim3d:TerrainSensor:NoData', 'terrain sensor returned no data' );
end 
wheelHitZ = RayEnd( :, 3 );
if ( any( wheelHitZ > self.RayTraceMaxValueLimit ) )
error( 'sim3d:TerrainSensor:InvalidZValue', 'Check the position of vehicle to make sure vehicle did not encounter a large variation in terrain' );
end 

end 

function ret = getVehicleType( self )
switch self.TractorType
case 'ConventionalTractor'
ret = 0;
case 'CabOverTractor'
ret = 1;
otherwise 
error( 'sim3d:invalidTractorType', 'Invalid Tractor type. Please select a valid Tractor type.' );
end 
end 
function ret = getColor( ~, color )
switch color
case 'black'
ret = '/MathWorksSimulation/VehicleCommon/Materials/CarPaint/MI_CarPaint_01_Black.MI_CarPaint_01_Black';
case 'red'
ret = '/MathWorksSimulation/VehicleCommon/Materials/CarPaint/MI_CarPaint_10_Red.MI_CarPaint_10_Red';
case 'orange'
ret = '/MathWorksSimulation/VehicleCommon/Materials/CarPaint/MI_CarPaint_11_Orange.MI_CarPaint_11_Orange';
case 'yellow'
ret = '/MathWorksSimulation/VehicleCommon/Materials/CarPaint/MI_CarPaint_12_Yellow.MI_CarPaint_12_Yellow';
case 'green'
ret = '/MathWorksSimulation/VehicleCommon/Materials/CarPaint/MI_CarPaint_13_Green.MI_CarPaint_13_Green';
case 'blue'
ret = '/MathWorksSimulation/VehicleCommon/Materials/CarPaint/MI_CarPaint_14_Blue.MI_CarPaint_14_Blue';
case 'white'
ret = '/MathWorksSimulation/VehicleCommon/Materials/CarPaint/MI_CarPaint_05_White.MI_CarPaint_05_White';
case 'whitepearl'
ret = '/MathWorksSimulation/VehicleCommon/Materials/CarPaint/MI_CarPaint_06_WhitePearl.MI_CarPaint_06_WhitePearl';
case 'grey'
ret = '/MathWorksSimulation/VehicleCommon/Materials/CarPaint/MI_CarPaint_09_Grey.MI_CarPaint_09_Grey';
case 'darkgrey'
ret = '/MathWorksSimulation/VehicleCommon/Materials/CarPaint/MI_CarPaint_04_DarkGrey.MI_CarPaint_04_DarkGrey';
case 'silver'
ret = '/MathWorksSimulation/VehicleCommon/Materials/CarPaint/MI_CarPaint_07_Silver.MI_CarPaint_07_Silver';
case 'bluesilver'
ret = '/MathWorksSimulation/VehicleCommon/Materials/CarPaint/MI_CarPaint_08_BlueSilver.MI_CarPaint_08_BlueSilver';
case 'darkredblack'
ret = '/MathWorksSimulation/VehicleCommon/Materials/CarPaint/MI_CarPaint_02_DarkRedBlack.MI_CarPaint_02_DarkRedBlack';
case 'redblack'
ret = '/MathWorksSimulation/VehicleCommon/Materials/CarPaint/MI_CarPaint_03_RedBlack.MI_CarPaint_03_RedBlack';
otherwise 
error( 'sim3d:invalidVehicleColor', 'Invalid Vehicle Color. Please check help and select a valid Vehicle Color.' );
end 
end 

function ret = getMesh( self )
switch self.TractorType
case 'ConventionalTractor'
ret = '/MathWorksAutomotiveContent/Vehicles/TruckUS/Mesh/SK_USTruck.SK_USTruck';
case 'CabOverTractor'
ret = '/MathWorksAutomotiveContent/Vehicles/EUTruck/Mesh/SK_EUTruck.SK_EUTruck';
otherwise 
ret = '';
end 
end 

function ret = getAnimation( self )
switch self.TractorType
case 'ConventionalTractor'
ret = '/MathWorksAutomotiveContent/Vehicles/TruckUS/Animations/USTractorAnimBP.USTractorAnimBP_C';
case 'CabOverTractor'
ret = '/MathWorksAutomotiveContent/Vehicles/EUTruck/Animations/EUTractorAnimBP.EUTractorAnimBP_C';
otherwise 
ret = '';
end 
end 

function actorType = getActorType( ~ )
actorType = sim3d.utils.ActorTypes.Tractor;
end 

function tagName = getTagName( ~ )
tagName = 'Tractor';
end 

function copy( self, other, CopyChildren, UseSourcePosition )
R36
self( 1, 1 )sim3d.auto.Tractor
other( 1, 1 )sim3d.auto.Tractor
CopyChildren( 1, 1 )logical = true
UseSourcePosition( 1, 1 )logical = false
end 


self.TractorType = other.TractorType;


copy@sim3d.auto.WheeledVehicle( self, other, CopyChildren, UseSourcePosition );

end 

function actorS = getAttributes( self )
actorS = getAttributes@sim3d.auto.WheeledVehicle( self );
actorS.TractorType = self.TractorType;
end 

function setAttributes( self, actorS )
setAttributes@sim3d.auto.WheeledVehicle( self, actorS );
self.TractorType = actorS.TractorType;
end 

end 


methods ( Access = private, Static )
function r = parseInputs( numberOfParts, varargin )

defaultParams = struct(  ...
'Color', 'red',  ...
'Mesh', 'MeshText',  ...
'Animation', 'AnimationText',  ...
'Translation', single( zeros( numberOfParts, 3 ) ),  ...
'Rotation', single( zeros( numberOfParts, 3 ) ),  ...
'Scale', single( ones( numberOfParts, 3 ) ),  ...
'ActorID', 10,  ...
'DebugRayTrace', false );


parser = inputParser;
parser.addParameter( 'Color', defaultParams.Color );
parser.addParameter( 'Mesh', defaultParams.Mesh );
parser.addParameter( 'Animation', defaultParams.Animation );
parser.addParameter( 'Translation', defaultParams.Translation );
parser.addParameter( 'Rotation', defaultParams.Rotation );
parser.addParameter( 'Scale', defaultParams.Scale );
parser.addParameter( 'ActorID', defaultParams.ActorID );


parser.parse( varargin{ : } );
r = parser.Results;
r.Translation( 2:7, : ) = 0;
r.Rotation( 2:7, : ) = 0;
r.Scale( 2:7, : ) = 1;
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpdK11G7.p.
% Please follow local copyright laws when handling this file.

