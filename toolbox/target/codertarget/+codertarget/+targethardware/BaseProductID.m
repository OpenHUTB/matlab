classdef BaseProductID < uint64












emumeration 
SL( 1 )
SLC( 2 )
EC( 4 )
ROS( 8 )
SOC( 16 )
EC_SOC( 20 )
UNSPECIFIED( 0 )
end 

methods 
function out = toNum( obj )
out = double( obj );
end 
end 

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpVX9NX4.p.
% Please follow local copyright laws when handling this file.

