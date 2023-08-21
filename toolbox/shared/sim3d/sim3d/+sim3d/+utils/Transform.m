classdef Transform < handle

properties ( SetAccess = 'protected', GetAccess = 'protected' )

Translation( :, 3 )single = [ 0, 0, 0 ];


Rotation( :, 3 )single = [ 0, 0, 0 ];


Scale( :, 3 )single = [ 1, 1, 1 ];


Units( :, 3 ) = { sim3d.units.si.M(  ), sim3d.units.si.Rad(  ), sim3d.units.One(  ) };
end 


methods

function self = Transform( translation, rotation, scale, units )

R36
translation( :, 3 )single = zeros( 1, 3 )
rotation( :, 3 )single = zeros( size( translation ) )
scale( :, 3 )single = ones( size( translation ) )
units( :, 3 ) = { sim3d.units.si.M(), sim3d.units.si.Rad(), sim3d.units.One() };
end 
self.Translation = translation;
self.Rotation = rotation;
self.Scale = scale;
self.Units = units;
end 


function set( self, translation, rotation, scale )

R36
self sim3d.utils.Transform
translation( :, 3 )single
rotation( :, 3 )single
scale( :, 3 )single
end 
self.Translation = self.Units{ 1 }.set( translation );
self.Rotation = self.Units{ 2 }.set( rotation );
self.Scale = self.Units{ 3 }.set( scale );
end 


function [ translation, rotation, scale ] = get( self )

translation = self.Units{ 1 }.get( self.Translation );
rotation = self.Units{ 2 }.get( self.Rotation );
scale = self.Units{ 3 }.get( self.Scale );
end


function translation = getTranslation( self )

translation = self.Translation;
end


function rotation = getRotation( self )

rotation = self.Rotation;
end


function scale = getScale( self )
scale = self.Scale;
end


function setTranslation( self, translation )

R36
self sim3d.utils.Transform
translation( :, 3 )single
end 
self.Translation = translation;
end


function setRotation( self, rotation )

R36
self sim3d.utils.Transform
rotation( :, 3 )single
end 
self.Rotation = rotation;
end


function setScale( self, scale )

R36
self sim3d.utils.Transform

scale( :, 3 )single
end 
self.Scale = scale;
end 


function add( self, transform )

R36
self sim3d.utils.Transform
transform sim3d.utils.Transform
end 
self.Translation = self.Translation + transform.Translation;
self.Rotation = self.Rotation + transform.Rotation;
end 


function copy( self, transform )

R36
self sim3d.utils.Transform
transform sim3d.utils.Transform
end 
self.Translation = transform.Translation;
self.Rotation = transform.Rotation;
self.Scale = transform.Scale;
end 
end 
end 



