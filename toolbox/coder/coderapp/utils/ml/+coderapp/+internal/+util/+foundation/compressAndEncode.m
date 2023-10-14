function encoded = compressAndEncode( input )

arguments
    input char
end
compressed = coderapp.internal.util.foundation.compressString( input );
encoded = matlab.net.base64encode( compressed );
end



