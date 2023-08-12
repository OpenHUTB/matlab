function encoded = compressAndEncode( input )


R36
input char
end 
compressed = coderapp.internal.util.foundation.compressString( input );
encoded = matlab.net.base64encode( compressed );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpYsjavw.p.
% Please follow local copyright laws when handling this file.

