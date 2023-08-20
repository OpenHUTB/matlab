classdef Trailer < sim3d.auto.WheeledVehicle

properties ( SetAccess = 'private', GetAccess = 'public' )
TrailerType;
end 


methods

function self = Trailer( actorName, trailerType, varargin )
narginchk( 2, inf );
[ numberOfParts ] = sim3d.auto.Trailer.getNumberOfPartsFromTrailerType( trailerType );
r = sim3d.auto.Trailer.parseInputs( numberOfParts, varargin{ : } );

mesh = '';

self@sim3d.auto.WheeledVehicle( actorName, r.ActorID, r.Translation,  ...
r.Rotation, r.Scale, numberOfParts, mesh );
self.TrailerType = trailerType;
self.setRaytraceConfig(  );
self.Mesh = self.getMesh(  );
self.Animation = self.getAnimation(  );
self.Translation = single( r.Translation );
self.Rotation = single( r.Rotation );
self.Scale = single( r.Scale );
self.ActorID = r.ActorID;

self.Config.MeshPath = self.Mesh;
self.Config.AnimationPath = self.Animation;
self.Config.ColorPath = '';
self.Config.AdditionalOptions = '';
end


function ret = getVehicleType( self )
switch self.TrailerType
case 'TwoAxleTrailer'
ret = 0;
case 'ThreeAxleTrailer'
ret = 1;
otherwise 
error( 'sim3d:invalidVehicleType', 'Invalid Vehicle Type. Please check help and select a valid Vehicle Type' );
end 
end


function ret = getMesh(self)
switch self.TrailerType
case 'TwoAxleTrailer'
ret = '/MathWorksAutomotiveContent/Vehicles/USBoxTrailer/Mesh/SK_USBoxTrailer.SK_USBoxTrailer';
case 'ThreeAxleTrailer'
ret = '/MathWorksAutomotiveContent/Vehicles/EUBoxTrailer/Mesh/SK_EUBoxTrailer.SK_EUBoxTrailer';
otherwise 
ret = '';
end 
end


function ret = getAnimation(self)
switch self.TrailerType
case 'TwoAxleTrailer'
ret = '/MathWorksAutomotiveContent/Vehicles/USBoxTrailer/Animations/USTrailerAnimBP.USTrailerAnimBP_C';
case 'ThreeAxleTrailer'
ret = '/MathWorksAutomotiveContent/Vehicles/EUBoxTrailer/Animations/EUTrailerAnimBP.EUTrailerAnimBP_C';
otherwise 
ret = '';
end 
end


function actorType = getActorType(~)
actorType = sim3d.utils.ActorTypes.Trailer;
end


function tagName = getTagName(~)
tagName = 'Trailer';
end 


function setRaytraceConfig(self)
switch self.TrailerType
case 'TwoAxleTrailer'
self.RayStart = [ 0, 0,  - 1;0, 0,  - 1;0, 0,  - 1;0, 0,  - 1 ];
self.RayEnd = [ 1, 0, 10;1, 0, 10;1, 0, 10;1, 0, 10 ];
case 'ThreeAxleTrailer'
self.RayStart = [ 0, 0,  - 1;0, 0,  - 1;0, 0,  - 1;0, 0,  - 1;0, 0,  - 1;0, 0,  - 1 ];
self.RayEnd = [ 1, 0, 10;1, 0, 10;1, 0, 10;1, 0, 10;1, 0, 10;1, 0, 10 ];
end 

if ( self.DebugRayTrace )
self.RayEnd( :, 2 ) = 1;
end 
end


function copy( self, other, CopyChildren, UseSourcePosition )
R36
self( 1, 1 )sim3d.auto.Trailer
other( 1, 1 )sim3d.auto.Trailer
CopyChildren( 1, 1 )logical = true
UseSourcePosition( 1, 1 )logical = false
end 

self.TrailerType = other.TrailerType;

copy@sim3d.auto.WheeledVehicle( self, other, CopyChildren, UseSourcePosition );

end 


function actorS = getAttributes( self )
actorS = getAttributes@sim3d.auto.WheeledVehicle( self );
actorS.TrailerType = self.TrailerType;
end 


function setAttributes( self, actorS )
setAttributes@sim3d.auto.WheeledVehicle( self, actorS );
self.TrailerType = actorS.TrailerType;
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
parser.addParameter( 'DebugRayTrace', defaultParams.DebugRayTrace );

parser.parse( varargin{ : } );
r = parser.Results;
r.Translation( 2:end , : ) = 0;
r.Rotation( 2:end , : ) = 0;
r.Scale( 2:end , : ) = 1;
end


function [ numberOfParts ] = getNumberOfPartsFromTrailerType( trailerType )
switch trailerType
case 'TwoAxleTrailer'
numberOfParts = uint32( 5 );

case 'ThreeAxleTrailer'
numberOfParts = uint32( 7 );

end 
end 
end 

end 




