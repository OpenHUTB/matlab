classdef CXXException < MException















properties 
Type
end 

methods 
function obj = CXXException( aTypeName, aMessageText )
R36
aTypeName( 1, : )char
aMessageText( 1, : )char
end 
obj = obj@MException( 'coderApp:util:CXXException', aMessageText );
obj.Type = aTypeName;
end 
end 

methods ( Static )
function raise( aTypeName, aMessageText )
R36
aTypeName( 1, : )char
aMessageText( 1, : )char
end 
throwAsCaller( coderapp.internal.util.foundation.CXXException( aTypeName, aMessageText ) );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpQiWTkD.p.
% Please follow local copyright laws when handling this file.

