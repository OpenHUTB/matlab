function [ files, missing ] = functionDependencyAnalysis( fh, analysisFcn )





R36
fh( 1, 1 )function_handle
analysisFcn( 1, 1 )function_handle = @dependencies.internal.analyze
end 

depGraph = analysisFcn( fh );
assert( isa( depGraph.Nodes, "table" ),  ...
'MultiSim.internal.functionDependencyAnalysis: expected a table' );

files = depGraph.Nodes.Name( depGraph.Nodes.Resolved );
missing = depGraph.Nodes.Name( ~depGraph.Nodes.Resolved );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpQnJLWR.p.
% Please follow local copyright laws when handling this file.

