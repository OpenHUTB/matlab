function graph = analyze( input, options )

R36
input;
options.Include( 1, : )string = string.empty;
options.Exclude( 1, : )string = string.empty;
options.Traverse( 1, 1 )string{ mustBeMember( options.Traverse, [ "None", "User", "Test", "All" ] ) } = "User";
options.AnalyzeUnsavedChanges( 1, 1 )logical = false;
options.ResultType( 1, 1 )string{ mustBeMember( options.ResultType, [ "digraph", "dependencies.internal.graph.Graph", "dependencies.internal.graph.MutableGraph" ] ) } = "digraph";
options.NodeFilter( 1, 1 )dependencies.internal.graph.NodeFilter;
options.DependencyFilter( 1, 1 )dependencies.internal.graph.DependencyFilter;
end 

nodes = dependencies.internal.util.getNodes( input );

analysis = i_getDefaultAnalysisOptions(  );
analysis = i_setAnalyzeUnsavedChanges( analysis, options.AnalyzeUnsavedChanges );
analysis.Filters = [ 
i_createTraverseFilter( options.Traverse, nodes ) ...
, i_createTypeFilter( options.Include, options.Exclude ) ...
, i_createCustomFilter( options )
 ];


graph = dependencies.internal.engine.analyze( nodes, analysis );

if options.ResultType == "dependencies.internal.graph.Graph"
graph = dependencies.internal.graph.Graph( graph );
end 

if options.ResultType == "digraph"
graph = dependencies.internal.graph.DigraphFactory.createFrom( graph );
end 

end 


function options = i_getDefaultAnalysisOptions(  )
persistent analysis;

if isempty( analysis )
analysis = dependencies.internal.engine.AnalysisOptions;
if dependencies.internal.util.isProductInstalled( "SL" )
analysis = dependencies.internal.analysis.simulink.setupParameterAnalysis( analysis );
end 
end 

options = analysis;


if dependencies.internal.util.isProductInstalled( "SL" )
options = i_resetBaseWorkspaceAnalyzer( options );
end 
end 


function filter = i_createTraverseFilter( traverse, nodes )
import dependencies.internal.graph.NodeFilter.*;
import dependencies.internal.graph.DependencyFilter.downstream;
import dependencies.internal.engine.filters.DelegateFilter;

switch traverse
case "None"
toAnalyze = ~fileWithin( { matlabroot } );
filter = DelegateFilter( isMember( nodes ), downstream( toAnalyze ) );
case "Test"
testroot = fullfile( matlabroot, "test" );
toAnalyze = ~nodeType( "File" ) | ~fileWithin( { matlabroot } ) | fileWithin( testroot );
filter = DelegateFilter( isMember( nodes ) | toAnalyze, downstream( toAnalyze ) );
case "All"
filter = dependencies.internal.engine.AnalysisFilter.empty( 1, 0 );
otherwise 
toAnalyze = ~nodeType( "File" ) | ~fileWithin( { matlabroot } );
filter = DelegateFilter( isMember( nodes ) | toAnalyze, downstream( toAnalyze ) );
end 
end 


function filter = i_createTypeFilter( include, exclude )
import dependencies.internal.graph.DependencyFilter.*;
import dependencies.internal.engine.filters.DelegateFilter;

depFilter = acceptDependency( true );
if ~isempty( include )
depFilter = depFilter & dependencyType( include, true );
end 
if ~isempty( exclude )
depFilter = depFilter & ~dependencyType( exclude, true );
end 
filter = DelegateFilter( depFilter );
end 


function filter = i_createCustomFilter( options )
import dependencies.internal.engine.filters.DelegateFilter;

hasNodeFilter = isfield( options, "NodeFilter" );
hasDependencyFilter = isfield( options, "DependencyFilter" );

if hasNodeFilter && hasDependencyFilter
filter = DelegateFilter( options.NodeFilter, options.DependencyFilter );
elseif hasNodeFilter
filter = DelegateFilter( options.NodeFilter );
elseif hasDependencyFilter
filter = DelegateFilter( options.DependencyFilter );
else 
filter = dependencies.internal.engine.AnalysisFilter.empty( 1, 0 );
end 
end 


function options = i_setAnalyzeUnsavedChanges( options, analyze )
idx = find( arrayfun( @( a )isa( a, "dependencies.internal.analysis.simulink.SimulinkModelAnalyzer" ), options.NodeAnalyzers ) );
for n = idx
options.NodeAnalyzers( n ).AnalyzeUnsavedChanges = analyze;
end 
end 


function options = i_resetBaseWorkspaceAnalyzer( options )
idx = find( arrayfun( @( a )isa( a, "dependencies.internal.analysis.matlab.BaseWorkspaceAnalyzer" ), options.NodeAnalyzers ) );
if ~isempty( idx )
options.NodeAnalyzers( idx ) = dependencies.internal.analysis.matlab.BaseWorkspaceAnalyzer;
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp2Z4Gw5.p.
% Please follow local copyright laws when handling this file.

