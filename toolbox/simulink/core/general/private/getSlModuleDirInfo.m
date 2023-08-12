






function dirInfo = getSlModuleDirInfo( module )

module = rtwprivate( 'Add_C_ExtToNames', { module } );
fmodule = which( module{ : } );
dirInfo = dir( fmodule );

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpC0N1W4.p.
% Please follow local copyright laws when handling this file.

