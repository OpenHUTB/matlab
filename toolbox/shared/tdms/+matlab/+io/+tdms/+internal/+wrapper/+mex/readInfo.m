function info = readInfo( filePath )

arguments
    filePath( 1, 1 )string
end
import matlab.io.tdms.internal.wrapper.mex.*
utility.licenseCheck(  );
info = mexTDMS( int8( OperationType.Info ), filePath );
info.Path = filePath;
end
