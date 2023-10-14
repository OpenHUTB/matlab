function graph = getDependencyDigraph( project )

arguments
    project( 1, 1 ){ mustBeA( project, [ "matlab.project.Project", "matlab.internal.project.api.Project" ] ) };
end

graph = dependencies.internal.graph.DigraphFactory.createFrom( matlab.internal.project.dependency.getDependencyGraph( project ) );
end
