function enc_path = encpath( blk, submodel, rest, sepChar )





if ~ischar( blk ) || ~ischar( submodel ) || ~ischar( rest ) || ~ischar( sepChar )
DAStudio.error( 'Simulink:tools:encPathArgsMustBeStrings' );
end 

enc_path = slInternal( 'encpath', blk, submodel, rest, sepChar );

% Decoded using De-pcode utility v1.2 from file /tmp/tmpjq6yaw.p.
% Please follow local copyright laws when handling this file.

