classdef Vehicle < sim3d.AbstractActor



properties ( SetAccess = protected )

Config


ConfigWriter
end 

properties 

Color


Animation


ActorID
end 

properties ( Access = protected, Constant )

Suffix = '/VehicleConfiguration_OUT'
end 

methods 

function self = Vehicle( actorName, actorID, translation, rotation, scale, numberOfParts, mesh )
self@sim3d.AbstractActor( actorName, 'Scene Origin', translation, rotation, scale,  ...
'ActorClassId', actorID, 'NumberOfParts', numberOfParts, 'Mesh', mesh );
end 

function setup( self )
setup@sim3d.AbstractActor( self );

self.ConfigWriter = sim3d.io.Publisher( [ self.ActorName, self.Suffix ] );
end 
function reset( self )
reset@sim3d.AbstractActor( self );
self.ConfigWriter.send( self.Config );
end 

function writeTransform( self, translation, rotation, scale )

if ~isempty( self.TransformWriter )
self.TransformWriter.write( single( translation ), single( rotation ), single( scale ) );
end 
self.ConfigWriter.send( self.Config );
end 

function [ translation, rotation, scale ] = readTransform( self )

if ~isempty( self.TransformReader )
sim3d.engine.EngineReturnCode.assertObject( self.TransformReader );
[ translation, rotation, scale ] = self.TransformReader.read(  );
else 
translation = [  ];
rotation = [  ];
scale = [  ];
end 
end 

function copy( self, other, CopyChildren, UseSourcePosition )
R36
self( 1, 1 )sim3d.vehicle.Vehicle
other( 1, 1 )sim3d.vehicle.Vehicle
CopyChildren( 1, 1 )logical = true
UseSourcePosition( 1, 1 )logical = false
end 


self.Color = other.Color;
self.Animation = other.Animation;
self.ActorID = other.ActorID;


copy@sim3d.AbstractActor( self, other, CopyChildren, UseSourcePosition );

end 

function actorS = getAttributes( self )
actorS.Base = getAttributes@sim3d.AbstractActor( self );
actorS.Color = self.Color;
actorS.Animation = self.Animation;
actorS.ActorID = self.ActorID;
end 

function setAttributes( self, actorS )
setAttributes@sim3d.AbstractActor( self, actorS.Base );
self.Color = actorS.Color;
self.Animation = actorS.Animation;
self.ActorID = actorS.ActorID;
end 

function delete( self )
if ~isempty( self.ConfigWriter )
self.ConfigWriter.delete(  );
self.ConfigWriter = [  ];
end 

delete@sim3d.AbstractActor( self );
end 

end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpHnY5cS.p.
% Please follow local copyright laws when handling this file.

