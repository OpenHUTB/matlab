function info = readInfo( filePath )





R36
filePath( 1, 1 )string
end 
import matlab.io.tdms.internal.wrapper.mex.*
utility.licenseCheck(  );
info = mexTDMS( int8( OperationType.Info ), filePath );
info.Path = filePath;
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpyyjD9j.p.
% Please follow local copyright laws when handling this file.

