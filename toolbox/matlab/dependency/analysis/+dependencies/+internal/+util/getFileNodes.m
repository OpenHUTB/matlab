function nodes = getFileNodes( paths, extensions )

arguments
    paths( 1, : )string;
    extensions( 1, : )string = dependencies.internal.Registry.Instance.getAnalysisExtensions(  );
end

nodes = dependencies.internal.graph.Node.createFileNode( paths );

isfile = [ nodes.Resolved ];
if any( ~isfile )
    folders = dependencies.internal.graph.Node.createFolderNode( paths );
    isfolder = [ folders.Resolved ];
    nodes = nodes( ~isfolder );

    for folder = folders( isfolder )
        files = dir( fullfile( folder.Location{ 1 }, "**" ) );
        idx = endsWith( { files.name }, extensions );

        if any( idx )
            files = arrayfun( @( f )string( fullfile( f.folder, f.name ) ), files( idx ) );
            nodes = [ nodes, dependencies.internal.graph.Node.createFileNode( files ) ];%#ok<AGROW>
        end
    end
end
end


