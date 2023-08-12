classdef slHitCrossingType < Simulink.IntEnumType
emumeration 
None( 0 )
NegativeToPositive( 1 )
NegativeToZero( 2 )
ZeroToPositive( 4 )
PositiveToNegative( 8 )
PositiveToZero( 16 )
ZeroToNegative( 32 )
end 
methods ( Static )
function dScope = getDataScope(  )
dScope = 'Exported';
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpJatFyx.p.
% Please follow local copyright laws when handling this file.

