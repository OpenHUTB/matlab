function nodes = getFunctionHandleNodes( fh )






R36
fh( 1, 1 )function_handle;
end 

info = functions( fh );

if isempty( info.file )
nodes = analyzeAnonymous( info );
else 
nodes = i_filter( dependencies.internal.graph.Node.createFileNode( info.file ) );
end 

end 


function nodes = analyzeAnonymous( info )
workspace = dependencies.internal.analysis.matlab.Workspace;
if isfield( info, "workspace" )
vars = cellfun( @( w )string( fields( w ) ), info.workspace, "UniformOutput", false );
workspace.addVariables( [ vars{ : } ] );
end 

handler = dependencies.internal.analysis.Handler;
node = dependencies.internal.graph.Node( info.function, "FunctionHandle", true );
root = dependencies.internal.graph.Component.createRoot( node );
factory = dependencies.internal.analysis.DependencyFactory( handler, root, "" );

deps = [ 
handler.Analyzers.MATLAB.analyze( info.function, factory, workspace, [  ] ),  ...
handler.Analyzers.MATLAB.finalize
 ];

nodes = i_filter( [ deps.DownstreamNode ] );
end 

function nodes = i_filter( nodes )
filter = dependencies.internal.graph.NodeFilter.fileWithin( { matlabroot } );
nodes( filter.apply( nodes ) ) = [  ];
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpNu_I6W.p.
% Please follow local copyright laws when handling this file.

