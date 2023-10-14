function [ files, missing ] = functionDependencyAnalysis( fh, analysisFcn )

arguments
    fh( 1, 1 )function_handle
    analysisFcn( 1, 1 )function_handle = @dependencies.internal.analyze
end

depGraph = analysisFcn( fh );
assert( isa( depGraph.Nodes, "table" ),  ...
    'MultiSim.internal.functionDependencyAnalysis: expected a table' );

files = depGraph.Nodes.Name( depGraph.Nodes.Resolved );
missing = depGraph.Nodes.Name( ~depGraph.Nodes.Resolved );
end

