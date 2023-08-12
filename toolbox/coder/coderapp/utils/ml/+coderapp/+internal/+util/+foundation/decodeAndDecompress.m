function decompressed = decodeAndDecompress( input )


R36
input char
end 

decoded = typecast( matlab.net.base64decode( input ), 'int8' );
decompressed = coderapp.internal.util.foundation.decompressString( decoded );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpzj1RQk.p.
% Please follow local copyright laws when handling this file.

