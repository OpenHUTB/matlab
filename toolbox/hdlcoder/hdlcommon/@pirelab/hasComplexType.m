






function isc = hasComplexType( pirType )
T = pirelab.getComplexType( pirType );
isc = ~isfloat( T ) || isa( T, 'hdlcoder.tp_complex' );
return 
end 














% Decoded using De-pcode utility v1.2 from file /tmp/tmpgEP5Mp.p.
% Please follow local copyright laws when handling this file.

