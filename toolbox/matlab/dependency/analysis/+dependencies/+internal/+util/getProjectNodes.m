function nodes = getProjectNodes( project, extensions )




R36
project
extensions( 1, : )string = dependencies.internal.Registry.Instance.getAnalysisExtensions(  );
end 

files = string( { project.Files.Path } );
nodes = dependencies.internal.graph.Node.createFileNode( files );

filter = dependencies.internal.graph.NodeFilter.fileExtension( extensions );
idx = filter.apply( nodes );

nodes = nodes( idx );
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpuQZq6j.p.
% Please follow local copyright laws when handling this file.

