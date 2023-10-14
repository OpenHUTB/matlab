function nodes = getProjectNodes( project, extensions )

arguments
    project
    extensions( 1, : )string = dependencies.internal.Registry.Instance.getAnalysisExtensions(  );
end

files = string( { project.Files.Path } );
nodes = dependencies.internal.graph.Node.createFileNode( files );

filter = dependencies.internal.graph.NodeFilter.fileExtension( extensions );
idx = filter.apply( nodes );

nodes = nodes( idx );
end


