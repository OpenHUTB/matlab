classdef ( Sealed )NodeType



emumeration 
Param( true )
Category( true )
Production( true )
Service( true )
Tag
Perspective
end 

properties 
IsPrimary( 1, 1 )logical
end 

methods 
function this = NodeType( primary )
R36
primary = false
end 
this.IsPrimary = primary;
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpwRPTbF.p.
% Please follow local copyright laws when handling this file.

