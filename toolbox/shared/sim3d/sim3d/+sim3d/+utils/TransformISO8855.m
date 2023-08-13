classdef TransformISO8855 < sim3d.utils.Transform


methods 
function self = TransformISO8855( translation, rotation, scale, units )


R36
translation( :, 3 )single = zeros( 1, 3 )
rotation( :, 3 )single = zeros( size( translation ) )
scale( :, 3 )single = ones( size( translation ) )
units( :, 3 ) = { sim3d.units.si.M(  ), sim3d.units.Deg(  ), sim3d.units.One(  ) };
end 
self@sim3d.utils.Transform( translation, rotation, scale, units );
self.set( translation, rotation, scale );
end 

function set( self, translation, rotation, scale )


R36
self sim3d.utils.TransformISO8855
translation( :, 3 )single
rotation( :, 3 )single
scale( :, 3 )single
end 

translation( :, 2 ) =  - translation( :, 2 );

rotation( :, 2 ) =  - ( rotation( :, 2 ) );
rotation( :, 3 ) =  - ( rotation( :, 3 ) );

set@sim3d.utils.Transform( self, translation, rotation, scale );
end 

function [ translation, rotation, scale ] = get( self )

[ translation, rotation, scale ] = get@sim3d.utils.Transform( self );

translation( :, 2 ) =  - translation( :, 2 );

rotation( 1, 2 ) =  - ( rotation( 1, 2 ) );
rotation( 1, 3 ) =  - ( rotation( 1, 3 ) );
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpUl1uzW.p.
% Please follow local copyright laws when handling this file.

