function write( graph, file, root )




R36
graph( 1, 1 ){ mustBeA( graph, [ "dependencies.internal.graph.Graph", "dependencies.internal.graph.ImmutableGraph" ] ) };
file( 1, 1 )string{ mustBeNonzeroLengthText };
root( 1, 1 )string = "";
end 

writers = dependencies.internal.Registry.Instance.GraphWriters';
for writer = writers
if endsWith( file, writer.Extensions )
writer.write( graph, file, root );
return ;
end 
end 

dependencies.internal.util.throwException( "MATLAB:dependency:readwrite:UnknownFileFormat", file );

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpdE3W01.p.
% Please follow local copyright laws when handling this file.

