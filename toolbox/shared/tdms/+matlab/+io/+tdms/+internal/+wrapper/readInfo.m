function info = readInfo( filePath )





R36
filePath{ mustBeFile }
end 
import matlab.io.tdms.internal.wrapper.*

filePath = matlab.io.datastore.FileSet( filePath ).nextfile(  ).Filename;
info = utility.formatMexInfo( mex.readInfo( filePath ) );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpxY6C8O.p.
% Please follow local copyright laws when handling this file.

