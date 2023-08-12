function graph = getDependencyGraph( project )




R36
project( 1, 1 ){ mustBeA( project, [ "matlab.project.Project", "matlab.internal.project.api.Project" ] ) };
end 

if matlab.internal.project.util.useWebFrontEnd
graph = dependencies.internal.project.getDependencyGraph( project );
elseif usejava( 'jvm' )
graph = matlab.internal.project.util.processJavaCall( @(  )i_getJavaDependencyGraph( project ) );
else 
graph = dependencies.internal.graph.ImmutableGraph( dependencies.internal.graph.Graph );
end 
end 

function graph = i_getJavaDependencyGraph( project )
facade = com.mathworks.toolbox.slproject.project.matlab.api.MatlabAPIFacadeFactory.getReferencedControlSet( java.io.File( project.RootFolder ) );
controlset = facade.getProjectControlSet(  );
class = java.lang.Class.forName( "com.mathworks.toolbox.slproject.extensions.dependency.DependencyExtension", true, controlset.getClass.getClassLoader );
extension = controlset.getExtension( class );
graph = extension.getNativeContainer(  ).getGraph(  );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpgLWv6p.p.
% Please follow local copyright laws when handling this file.

