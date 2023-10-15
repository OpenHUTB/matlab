function info = readInfo( filePath )

arguments
    filePath{ mustBeFile }
end
import matlab.io.tdms.internal.wrapper.*

filePath = matlab.io.datastore.FileSet( filePath ).nextfile(  ).Filename;
info = utility.formatMexInfo( mex.readInfo( filePath ) );
end
