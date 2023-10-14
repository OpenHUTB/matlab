function decompressed = decodeAndDecompress( input )

arguments
    input char
end

decoded = typecast( matlab.net.base64decode( input ), 'int8' );
decompressed = coderapp.internal.util.foundation.decompressString( decoded );
end


