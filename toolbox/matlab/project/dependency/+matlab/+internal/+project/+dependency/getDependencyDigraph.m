function graph = getDependencyDigraph( project )




R36
project( 1, 1 ){ mustBeA( project, [ "matlab.project.Project", "matlab.internal.project.api.Project" ] ) };
end 

graph = dependencies.internal.graph.DigraphFactory.createFrom( matlab.internal.project.dependency.getDependencyGraph( project ) );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpjXNkzP.p.
% Please follow local copyright laws when handling this file.

