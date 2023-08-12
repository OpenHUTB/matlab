function graph = read( file, root )




R36
file( 1, 1 )string;
root( 1, 1 )string = "";
end 

i_checkFile( file );

readers = dependencies.internal.Registry.Instance.GraphReaders';
for reader = readers
if endsWith( file, reader.Extensions )
try 
graph = reader.read( file, root );
catch exception
throw( dependencies.internal.util.wrapException(  ...
exception,  ...
"MATLAB:dependency:readwrite:InvalidFileFormat",  ...
file ) );
end 
return ;
end 
end 

dependencies.internal.util.throwException( "MATLAB:dependency:readwrite:UnknownFileFormat", file );

end 


function i_checkFile( file )
if ~dependencies.internal.graph.Node.createFileNode( file ).Resolved
dependencies.internal.util.throwException( "MATLAB:dependency:readwrite:FileNotFound", file );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpRyDSVv.p.
% Please follow local copyright laws when handling this file.

