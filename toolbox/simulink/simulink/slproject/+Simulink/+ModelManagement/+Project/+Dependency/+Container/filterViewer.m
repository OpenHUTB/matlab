function filterViewer( viewer, paths, filterType )



R36
viewer( 1, 1 )dependencies.internal.viewer.DependencyViewer;
paths( 1, : )string;
filterType( 1, 1 )string{ mustBeMember( filterType, [ "upstream", "downstream", "all" ] ) } = "all";
end 

nodes = dependencies.internal.graph.Node.createFileNode( paths );

filterType = string( filterType );
switch filterType
case "upstream"
viewer.filter( nodes, dependencies.internal.viewer.ImpactType.IMPACTED );
case "downstream"
viewer.filter( nodes, dependencies.internal.viewer.ImpactType.REQUIRED );
case "all"
viewer.filter( nodes, dependencies.internal.viewer.ImpactType.ALL_DEPENDENCIES );
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp_ixpsA.p.
% Please follow local copyright laws when handling this file.

