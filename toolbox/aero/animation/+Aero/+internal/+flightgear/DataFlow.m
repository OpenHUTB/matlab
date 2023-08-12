classdef DataFlow




emumeration 
Send
Receive
SendReceive
end 

methods ( Static )
function obj = createDataFlow( str )
R36
str( 1, 1 )string
end 


str = erase( str, "-" );
obj = Aero.internal.flightgear.DataFlow( str );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmphTlmg_.p.
% Please follow local copyright laws when handling this file.

