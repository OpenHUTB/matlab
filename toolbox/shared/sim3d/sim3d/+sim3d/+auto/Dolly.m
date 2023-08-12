classdef Dolly < sim3d.auto.WheeledVehicle

properties ( SetAccess = 'private', GetAccess = 'public' )
DollyType;
end 

methods 
function self = Dolly( actorName, DollyType, varargin )
narginchk( 2, inf );
numberOfParts = sim3d.auto.Dolly.getNumberOfPartsFromDollyType( DollyType );
r = sim3d.auto.Dolly.parseInputs( varargin{ : } );
sim3d.auto.Dolly.VerifyInitialTransformSize( r.Translation, r.Rotation, r.Scale, numberOfParts );


mesh = '';


self@sim3d.auto.WheeledVehicle( actorName, r.ActorID, r.Translation,  ...
r.Rotation, r.Scale, numberOfParts, mesh );
if ( self.DebugRayTrace )
self.RayEnd( :, 2 ) = 1;
end 

self.DollyType = DollyType;
self.setRaytraceConfig(  );
self.Mesh = self.getMesh(  );
self.Animation = self.getAnimation(  );
self.ActorID = r.ActorID;
self.RayStart = [ 0, 0,  - 1;0, 0,  - 1 ];
self.RayEnd = [ 1, 0, 10;1, 0, 10 ];


self.Config.MeshPath = self.Mesh;
self.Config.AnimationPath = self.Animation;
self.Config.ColorPath = '';
self.Config.AdditionalOptions = '';
end 

function ret = getMesh( self )
switch self.DollyType
case 'OneAxleDolly'
ret = '/MathWorksAutomotiveContent/Vehicles/DollyTrailers/Meshes/OneAxleDolly';
case 'TwoAxleDolly'
ret = '/MathWorksAutomotiveContent/Vehicles/DollyTrailers/Meshes/TwoAxleDolly';
case 'ThreeAxleDolly'
ret = '/MathWorksAutomotiveContent/Vehicles/DollyTrailers/Meshes/ThreeAxleDolly';
otherwise 
ret = '';
end 
end 

function ret = getAnimation( ~ )
ret = '/MathWorksAutomotiveContent/Vehicles/DollyTrailers/Animation/DollyAnimBP.DollyAnimBP_C';
end 

function setRaytraceConfig( self )
switch self.DollyType
case 'TwoAxleDolly'
self.RayStart = [ 0, 0,  - 1;0, 0,  - 1;0, 0,  - 1;0, 0,  - 1 ];
self.RayEnd = [ 1, 0, 10;1, 0, 10;1, 0, 10;1, 0, 10 ];
case 'ThreeAxleDolly'
self.RayStart = [ 0, 0,  - 1;0, 0,  - 1;0, 0,  - 1;0, 0,  - 1;0, 0,  - 1;0, 0,  - 1 ];
self.RayEnd = [ 1, 0, 10;1, 0, 10;1, 0, 10;1, 0, 10;1, 0, 10;1, 0, 10 ];
end 
if ( self.DebugRayTrace )
self.RayEnd( :, 2 ) = 1;
end 
end 

function copy( self, other, CopyChildren, UseSourcePosition )
R36
self( 1, 1 )sim3d.auto.Dolly
other( 1, 1 )sim3d.auto.Dolly
CopyChildren( 1, 1 )logical = true
UseSourcePosition( 1, 1 )logical = false
end 


self.DollyType = other.DollyType;


copy@sim3d.auto.WheeledVehicle( self, other, CopyChildren, UseSourcePosition );

end 

function actorS = getAttributes( self )
actorS = getAttributes@sim3d.auto.WheeledVehicle( self );
actorS.DollyType = self.DollyType;
end 

function setAttributes( self, actorS )
setAttributes@sim3d.auto.WheeledVehicle( self, actorS );
self.DollyType = actorS.DollyType;
end 
end 

methods ( Access = public, Hidden = true )
function actorType = getActorType( ~ )
actorType = sim3d.utils.ActorTypes.Dolly;
end 
function numberOfParts = getNumberOfParts( self )
numberOfParts = self.NumberOfParts;
end 
function tagName = getTagName( ~ )
tagName = 'Dolly';
end 
end 
methods ( Access = private, Static )

function r = parseInputs( varargin )

defaultParams = struct(  ...
'Color', 'red',  ...
'Mesh', 'MeshText',  ...
'Animation', 'AnimationText',  ...
'Translation', single( zeros( 5, 3 ) ),  ...
'Rotation', single( zeros( 5, 3 ) ),  ...
'Scale', single( ones( 5, 3 ) ),  ...
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


parser.parse( varargin{ : } );
r = parser.Results;
end 

function numberOfParts = getNumberOfPartsFromDollyType( dollyType )
switch dollyType
case 'TwoAxleDolly'
numberOfParts = uint32( 8 );
case 'ThreeAxleDolly'
numberOfParts = uint32( 11 );
otherwise 
numberOfParts = uint32( 5 );
end 
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpeA2ZNL.p.
% Please follow local copyright laws when handling this file.

