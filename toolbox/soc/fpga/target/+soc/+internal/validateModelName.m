function validateModelName( sys )

if ~isstring( sys ) && ~ischar( sys )
error( message( 'soc:msgs:checkModelName' ) );
end 
if ~eq( exist( sys, 'file' ), 4 )
error( message( 'soc:msgs:checkModelExist', sys ) );
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmp497UdW.p.
% Please follow local copyright laws when handling this file.

