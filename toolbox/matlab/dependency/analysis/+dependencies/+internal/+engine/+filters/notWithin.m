function filter = notWithin( roots )




arguments
    roots( 1, : )string;
end

import dependencies.internal.graph.NodeFilter.*
import dependencies.internal.graph.DependencyFilter.downstream
import dependencies.internal.engine.filters.DelegateFilter

nodeFilter = ~nodeType( "File" ) | ~fileWithin( roots );
depFilter = downstream( nodeFilter );
filter = DelegateFilter( nodeFilter, depFilter );

end

