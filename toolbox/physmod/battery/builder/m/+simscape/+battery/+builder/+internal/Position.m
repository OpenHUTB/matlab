classdef Position







properties 
X( 1, 1 )double
Y( 1, 1 )double
Z( 1, 1 )double
end 

methods 
function obj = Position( namedArgs )

R36
namedArgs.X( 1, 1 )double = 0
namedArgs.Y( 1, 1 )double = 0
namedArgs.Z( 1, 1 )double = 0
end 
obj.X = namedArgs.X;
obj.Y = namedArgs.Y;
obj.Z = namedArgs.Z;
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmp0nbx3t.p.
% Please follow local copyright laws when handling this file.

