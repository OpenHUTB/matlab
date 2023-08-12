




function result = ismethod( classOrObj, methodNames, passthroughArgs )
R36
classOrObj
methodNames string
end 
R36( Repeating )
passthroughArgs
end 

if ischar( classOrObj ) || isstring( classOrObj )
className = classOrObj;
else 
className = class( classOrObj );
end 
realMethodNames = coderapp.internal.util.methods( className, passthroughArgs{ : } );
result = ismember( methodNames, realMethodNames );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp3Hv6SJ.p.
% Please follow local copyright laws when handling this file.

