classdef TransformX3D < sim3d.utils.Transform





methods 
function self = TransformX3D( translation, rotation, scale, units )


R36
translation( :, 3 )single = zeros( 1, 3 )
rotation( :, 3 )single = zeros( size( translation ) )
scale( :, 3 )single = ones( size( translation ) )
units( :, 3 ) = { sim3d.units.si.M(  ), sim3d.units.si.Rad(  ), sim3d.units.One(  ) };
end 
self@sim3d.utils.Transform( translation, rotation, scale, units );
self.set( translation, rotation, scale );
end 

function set( self, translation, rotation, scale )

R36
self sim3d.utils.TransformX3D
translation( :, 3 )single
rotation( :, 3 )single
scale( :, 3 )single
end 


set@sim3d.utils.Transform( self,  ...
translation * [ 1, 0, 0;0, 0, 1;0, 1, 0 ],  ...
[ rotation( :, 1 ), rotation( :, 3 ),  - rotation( :, 2 ) ],  ...
scale );
end 

function [ translation, rotation, scale ] = get( self )

[ sim3dTranslation, sim3dRotation, sim3dScale ] = get@sim3d.utils.Transform( self );
translation = sim3dTranslation * [ 1, 0, 0;0, 0, 1;0, 1, 0 ]';
rotation = [ sim3dRotation( :, 1 ),  - sim3dRotation( :, 3 ), sim3dRotation( :, 2 ) ];
scale = sim3dScale;
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpKatTI6.p.
% Please follow local copyright laws when handling this file.

