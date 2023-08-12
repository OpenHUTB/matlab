classdef StateOutput




emumeration 
CD
CX
CY
CL
CZ
Cl
Cm
Cn
end 

methods ( Hidden, Static )
function vec = getStateOutputVector( frame )
R36
frame( 1, 1 )Aero.Aircraft.internal.datatype.ReferenceFrame
end 





if ( frame == "Body" )

vec = [ "CX";"CY";"CZ";"Cl";"Cm";"Cn" ];
elseif ( frame == "Wind" ) || ( frame == "Stability" )

vec = [ "CD";"CY";"CL";"Cl";"Cm";"Cn" ];
end 
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpvZR5M0.p.
% Please follow local copyright laws when handling this file.

