function nodes = getDispatchableNodes( files )

R36
files( 1, : )string{ mustBeNonempty, mustBeNonzeroLengthText };
end 

nodes = dependencies.internal.graph.Node.empty( 1, 0 );

for file = files
i_errorForNewModel( file );

node = dependencies.internal.analysis.findSymbol( file );
if ~node.isFile || ~node.Resolved
node = dependencies.internal.analysis.findFile( file );
end 
if ~node.Resolved
warning( message( "SimulinkDependencyAnalysis:Engine:CannotFindFile", file ) );
end 

nodes( end  + 1 ) = node;%#ok<AGROW>
end 

end 


function i_errorForNewModel( file )
try 
fullpath = which( file );
catch 
return ;
end 

if "new Simulink model" == fullpath
if "on" == get_param( file, "ModelTemplatePlugin" )
error( message( "SimulinkDependencyAnalysis:Engine:EditedTemplate", file ) );
else 
error( message( "SimulinkDependencyAnalysis:Engine:NewSimulinkModel", file ) );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpOstoj2.p.
% Please follow local copyright laws when handling this file.

