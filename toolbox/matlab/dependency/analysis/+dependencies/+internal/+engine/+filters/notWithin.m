function filter = notWithin( roots )




R36
roots( 1, : )string;
end 

import dependencies.internal.graph.NodeFilter.*
import dependencies.internal.graph.DependencyFilter.downstream
import dependencies.internal.engine.filters.DelegateFilter

nodeFilter = ~nodeType( "File" ) | ~fileWithin( roots );
depFilter = downstream( nodeFilter );
filter = DelegateFilter( nodeFilter, depFilter );

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmp4ZPJ9a.p.
% Please follow local copyright laws when handling this file.

