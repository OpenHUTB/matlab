classdef ( Hidden )Aircraft < sim3d.vehicle.Vehicle


properties ( SetAccess = protected )

LightModule = [  ]
end 

properties 


RayStart


RayEnd
end 


properties ( Access = protected )

TerrainSensorPublisher = [  ];
TerrainSensorSubscriber = [  ];
TerrainSensorConfig;
RayTraceMaxValueLimit = 1.0e+10
end 

properties ( Access = protected, Constant )
ContentRoot = '/MathWorksAerospaceContent'
TerrainSensorSuffixOut = '/TerrainSensorConfiguration_OUT';
TerrainSensorSuffixIn = '/TerrainSensorDetection_IN';
Colors = { 'red', 'orange', 'yellow', 'green', 'cyan', 'blue',  ...
'black', 'white', 'silver', 'metal' };
end 

methods 
function self = Aircraft( actorName, actorID, translation, rotation, scale, numberOfParts )



mesh = '';


self@sim3d.vehicle.Vehicle( actorName, actorID, translation, rotation, scale, numberOfParts, mesh );



end 

function setup( self )

setup@sim3d.vehicle.Vehicle( self );
self.TerrainSensorPublisher = sim3d.io.Publisher( [ self.ActorName, self.TerrainSensorSuffixOut ] );
self.TerrainSensorSubscriber = sim3d.io.Subscriber( [ self.ActorName, self.TerrainSensorSuffixIn ] );
end 

function writeTransform( self, translation, rotation, scale )

self.Config.AdditionalOptions = self.LightModule.generateStepMessageString(  );
writeTransform@sim3d.vehicle.Vehicle( self, translation, rotation, scale );
end 

function [ translation, rotation, scale ] = readTransform( self )
[ translation, rotation, scale ] = readTransform@sim3d.vehicle.Vehicle( self );
end 

function AircraftRayTraceSetup( self, rayStart, rayEnd )

self.TerrainSensorConfig.RayStart = rayStart;
self.TerrainSensorConfig.RayEnd = rayEnd;
self.TerrainSensorPublisher.publish( self.TerrainSensorConfig );
end 

function [ traceStart, traceEnd, status ] = AircraftRayTraceRead( self )


status = 0;
if self.TerrainSensorSubscriber.has_message(  )
terrainSensorDetections = self.TerrainSensorSubscriber.take(  );
traceStart = terrainSensorDetections.TraceStart;
traceEnd = terrainSensorDetections.TraceEnd;
end 
if ( isempty( traceStart ) || isempty( traceEnd ) )
status = sim3d.engine.EngineReturnCode.No_Data;
end 
end 

function copy( self, other, CopyChildren, UseSourcePosition )
R36
self( 1, 1 )sim3d.aircraft.Aircraft
other( 1, 1 )sim3d.aircraft.Aircraft
CopyChildren( 1, 1 )logical = true
UseSourcePosition( 1, 1 )logical = false
end 


self.LightModule = other.LightModule;


copy@sim3d.vehicle.Vehicle( self, other, CopyChildren, UseSourcePosition );
end 

function delete( self )

delete@sim3d.vehicle.Vehicle( self );
if ~isempty( self.TerrainSensorPublisher )
self.TerrainSensorPublisher = [  ];
end 
if ~isempty( self.TerrainSensorSubscriber )
self.TerrainSensorSubscriber = [  ];
end 

end 

end 


methods ( Access = protected, Static )
function VerifyInitialTransformSize( translation, rotation, scale, numberOfParts )


if ( ~( all( size( translation ) == [ numberOfParts, 3 ] ) && all( size( rotation ) == [ numberOfParts, 3 ] ) && all( size( scale ) == [ numberOfParts, 3 ] ) ) )
error( message( 'aeroblks_sim3d:aerolibsim3d:sim3dInvalidInitialTransform' ) );
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp3BzYbb.p.
% Please follow local copyright laws when handling this file.

