function nodes = addRequiredFiles( graph, nodes, within )

arguments
    graph
    nodes
    within( 1, : )string = string.empty;
end

nodes = arrayfun( @i_dropAdditionalLocations, nodes );
nodes = [ nodes, i_getOutstandingNodes( graph, nodes, within ) ];

end



function outstanding = i_getOutstandingNodes( graph, nodes, within )
import dependencies.internal.graph.NodeFilter
graph = dependencies.internal.graph.Graph( graph.Nodes, graph.Dependencies );

if isempty( within )
    fileFilter = NodeFilter.nodeType( "File" );
else
    fileFilter = NodeFilter.fileWithin( within );
end

filter = NodeFilter.requiredBy( graph, nodes ) &  ...
    fileFilter &  ...
    NodeFilter.isResolved;
required = graph.Nodes( filter.apply( graph.Nodes ) );

outstanding = setdiff( required, nodes );

if ~isempty( outstanding )
    outstanding = [ outstanding, i_getOutstandingNodes( graph, outstanding, within ) ];
end
end

function node = i_dropAdditionalLocations( node )
node = dependencies.internal.graph.Node.createFileNode(  ...
    node.Location{ 1 } );
end

