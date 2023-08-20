classdef Motorcycle < sim3d.auto.WheeledVehicle

properties ( SetAccess = 'private', GetAccess = 'public' )

LightModule = {};
MotorcycleType;
end


properties ( Access = private )
WheelBase = 1.72;
WheelRadius = 0.35;
end


methods 
function self = Motorcycle( actorName, motorcycleType, varargin )
numberOfParts = uint32( 4 );
r = sim3d.auto.Motorcycle.parseInputs( numberOfParts, varargin{ : } );

self@sim3d.auto.WheeledVehicle( actorName, r.ActorID, r.Translation,  ...
r.Rotation, r.Scale, numberOfParts, sim3d.auto.Motorcycle.getBlueprintPath( motorcycleType ) );
if ( self.DebugRayTrace )
self.RayEnd( :, 2 ) = 1;
end 
self.MotorcycleType = motorcycleType;
self.Mesh = sim3d.auto.Motorcycle.getBlueprintPath( motorcycleType );
self.Animation = '';
self.Color = self.getColor( r.Color );
self.ActorID = r.ActorID;
self.RayStart = [ 0, 0,  - 0.35;0, 0,  - 0.35 ];
self.RayEnd = [ 1, 0, 5;1, 0, 5 ];

self.Config.MeshPath = self.Mesh;
self.Config.AnimationPath = self.Animation;
self.Config.ColorPath = self.Color;
self.Config.AdditionalOptions = '';

self.LightModule = sim3d.vehicle.VehicleLightingModule( r.LightConfiguration );

self.Config.AdditionalOptions = self.LightModule.generateInitMessageString(  );
end


function step( self, X, Y, Yaw )
translation = zeros( self.NumberOfParts, 3, 'single' );
rotation = zeros( self.NumberOfParts, 3, 'single' );
scale = ones( self.NumberOfParts, 3, 'single' );
[ ~, RayEnd ] = self.TerrainSensorSubscriber.read(  );
[ previousTranslation, previousRotation, ~ ] = self.readTransform(  );
if ( any( RayEnd( :, 3 ) > self.RayTraceMaxValueLimit ) )
error( 'sim3d:TerrainSensor:InvalidZValue', 'Check the position of bicycle to make sure it did not encounter a large variation in terrain' );
end 
HitZ = median( RayEnd( :, 3 ) ) + sign( RayEnd( 1, 3 ) - RayEnd( 2, 3 ) ) * 0.01;
pitch = real( asin( ( RayEnd( 1, 3 ) - RayEnd( 2, 3 ) ) / self.WheelBase ) );
translation( 1, : ) = [ X, Y, HitZ ];
rotation( 1, : ) = [  - pitch, 0, Yaw ];

pX = previousTranslation( 1, 1 );
pY = previousTranslation( 1, 2 );
pYaw = previousRotation( 1, 3 );
pWheelRotation = previousRotation( 2, 2 );
currentWheelRotation = self.EstimateWheelRotationAndSteerAngle( pX, pY, pYaw, pWheelRotation, X, Y, Yaw, self.WheelBase, self.WheelRadius );

rotation( 2:3, 2 ) = single( currentWheelRotation );
self.writeTransform( translation, rotation, scale );
self.writeConfig(  );
end 


function writeConfig( self )

self.Config.AdditionalOptions = self.LightModule.generateStepMessageString(  );

self.ConfigWriter.send( self.Config );

end


function wheelRotation = EstimateWheelRotationAndSteerAngle( ~, pX, pY, pYaw, pWheelRotation, X, Y, Yaw, WheelBase, WheelRadius )

dX = X - pX;
dY = Y - pY;
dPsi = sign( Yaw - pYaw ) * mod( Yaw - pYaw, 2 * pi );
dx = dX * cos( Yaw ) + dY * sin( Yaw );
dy = dX * sin( Yaw ) + dY * cos( Yaw );
CGdisp = sqrt( dy ^ 2 + dx ^ 2 );
if dPsi == 0
dPsi = .001;
end 

beta = atan2( dy, dx );
Rest = CGdisp / 2 / sin( dPsi / 2 );
deltaL = atan( WheelBase / ( Rest - 1.9 / 2 ) );
deltaR = atan( WheelBase / ( Rest + 1.9 / 2 ) );

wheelRotation = cos( median( [ deltaL, deltaR ] ) ) * CGdisp / WheelRadius * cos( beta );
wheelRotation = pWheelRotation + wheelRotation;
end


function ret = getMesh( self )
ret = self.Mesh;
end 


function ret = getColor( ~, color )
switch color
case 'black'
ret = '(R=0.000000,G=0.000000,B=0.000000,A=1.000000)';
case 'red'
ret = '(R=1.000000,G=0.000000,B=0.000000,A=1.000000)';
case 'orange'
ret = '(R=0.896269,G=0.332452,B=0.006049,A=1.000000)';
case 'yellow'
ret = '(R=1.000000,G=1.000000,B=0.000000,A=1.000000)';
case 'green'
ret = '(R=0.000000,G=1.000000,B=0.000000,A=1.000000)';
case 'blue'
ret = '(R=0.000000,G=0.000000,B=1.000000,A=1.000000)';
case 'white'
ret = '(R=1.000000,G=1.000000,B=1.000000,A=1.000000)';
case 'silver'
ret = '(R=0.508881,G=0.545724,B=0.571125,A=1.000000)';
otherwise 
error( 'sim3d:invalidVehicleColor', 'Invalid Vehicle Color. Please check help and select a valid Vehicle Color.' );
end 
end 


function copy( self, other, CopyChildren, UseSourcePosition )
R36
self( 1, 1 )sim3d.auto.PassengerVehicle
other( 1, 1 )sim3d.auto.PassengerVehicle
CopyChildren( 1, 1 )logical = true
UseSourcePosition( 1, 1 )logical = false
end 

self.LightModule = other.LightModule;

copy@sim3d.auto.WheeledVehicle( self, other, CopyChildren, UseSourcePosition );

end 

end


methods ( Access = public, Hidden = true )
function actorType = getActorType( ~ )
actorType = sim3d.utils.ActorTypes.Motorcycle;
end 
function numberOfParts = getNumberOfParts( self )
numberOfParts = self.NumberOfParts;
end 
function tagName = getTagName( ~ )
tagName = 'Motorcycle';
end 
end 
methods ( Access = private, Static )

function ret = getBlueprintPath( motorcycleType )
switch motorcycleType
case 'SportsBike'
ret = 'Blueprint''/MathWorksAutomotiveContent/Vehicles/Motorcycle/Blueprints/BP_1000cc.BP_1000cc_C''';
case 'MotorBike'
ret = 'Blueprint''/MathWorksAutomotiveContent/Vehicles/Motorcycle/Blueprints/BP_150cc.BP_150cc_C''';
case 'Scooter'
ret = 'Blueprint''/MathWorksAutomotiveContent/Vehicles/Motorcycle/Blueprints/BP_Scooter.BP_Scooter_C''';
otherwise 
ret = 'Blueprint''/MathWorksAutomotiveContent/Vehicles/Motorcycle/Blueprints/BP_1000cc.BP_1000cc_C''';
end 
end 

function r = parseInputs( numberOfParts, varargin )

defaultParams = struct(  ...
'Color', 'red',  ...
'Mesh', 'MeshText',  ...
'Animation', 'AnimationText',  ...
'Translation', single( zeros( numberOfParts, 3 ) ),  ...
'Rotation', single( zeros( numberOfParts, 3 ) ),  ...
'Scale', single( ones( numberOfParts, 3 ) ),  ...
'ActorID', sim3d.utils.SemanticType.Vehicle,  ...
'DebugRayTrace', false );


parser = inputParser;
parser.addParameter( 'Color', defaultParams.Color );
parser.addParameter( 'Mesh', defaultParams.Mesh );
parser.addParameter( 'Animation', defaultParams.Animation );
parser.addParameter( 'Translation', defaultParams.Translation );
parser.addParameter( 'Rotation', defaultParams.Rotation );
parser.addParameter( 'Scale', defaultParams.Scale );
parser.addParameter( 'ActorID', defaultParams.ActorID );
parser.addParameter( 'LightConfiguration', {  } );


parser.parse( varargin{ : } );
r = parser.Results;
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp2ijfue.p.
% Please follow local copyright laws when handling this file.

