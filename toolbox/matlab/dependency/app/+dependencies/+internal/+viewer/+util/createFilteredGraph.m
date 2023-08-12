function outGraph = createFilteredGraph( inGraph, nodeFilter, types, options )





R36
inGraph( 1, 1 )
nodeFilter( 1, 1 )dependencies.internal.graph.NodeFilter;
types( 1, : )string = [  ];
options.IncludeUnresolvedDownstreamFiles( 1, 1 )logical = true;
end 

import dependencies.internal.graph.NodeFilter;
import dependencies.internal.graph.DependencyFilter.*;

outNodes = inGraph.Nodes( apply( nodeFilter, inGraph.Nodes ) );
isFilteredNode = NodeFilter.isMember( outNodes );

downstreamFilter = downstream( isFilteredNode );
if options.IncludeUnresolvedDownstreamFiles
downstreamFilter = downstreamFilter | downstream( ~NodeFilter.isResolved );
end 

if ~isempty( types )
downstreamFilter = downstreamFilter & dependencyType( types );
end 
depFilter = upstream( isFilteredNode ) & ( downstreamFilter | hasRelationship( "Toolbox" ) );

outDeps = inGraph.Dependencies( apply( depFilter, inGraph.Dependencies ) );
outNodes = unique( [ outNodes, outDeps.DownstreamNode ] );

outGraph = dependencies.internal.graph.Graph( outNodes, outDeps, inGraph.Properties );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpzCM_ke.p.
% Please follow local copyright laws when handling this file.

