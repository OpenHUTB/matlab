function internal = isInternal( exception )





R36
exception( 1, 1 )MException
end 

if isa( exception, 'coderapp.internal.error.DecoratedException' )
internal = exception.IsInternal;
elseif isempty( exception.identifier )

internal = true;
else 
try 
message( exception.identfier );
internal = false;
catch 
internal = true;
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp6xvcg5.p.
% Please follow local copyright laws when handling this file.

