function [ names, folders ] = toolboxDependencyAnalysis( files_in )
























R36
files_in( 1, : )string{ mustBeNonempty, mustBeNonzeroLengthText };
end 

nodes = dependencies.internal.util.getDispatchableNodes( files_in );
results = i_analyze( nodes );
[ names, folders ] = i_findToolboxes( results );

end 


function results = i_analyze( nodes )
import dependencies.internal.engine.filters.analyzeNodes;
import dependencies.internal.engine.filters.analyzeWithin;
import dependencies.internal.analysis.toolbox.ToolboxAnalyzer.analyzeToolboxes;

analyzer = dependencies.internal.engine.BasicAnalyzer;

dependencies.internal.analysis.simulink.setupParameterAnalysis( analyzer );

testroot = fullfile( matlabroot, "test" );
analyzer.Filters = analyzeNodes( nodes ) | analyzeWithin( testroot ) | analyzeToolboxes( false );

unfilteredGraph = analyzer.analyze( nodes );

results = dependencies.internal.analysis.toolbox.reduceOptionalProducts( unfilteredGraph );
end 


function [ names, folders ] = i_findToolboxes( results )
import dependencies.internal.graph.Type;
isProdOrTbx = ismember( [ results.Nodes.Type ], [ Type.PRODUCT, Type.TOOLBOX ] );
[ names, folders ] = arrayfun( @i_findInfo, results.Nodes( isProdOrTbx ), 'UniformOutput', false );

[ names, idx ] = sort( names );
folders = folders( idx );
end 


function [ name, folder ] = i_findInfo( node )
if node.Type == dependencies.internal.graph.Type.TOOLBOX
folder = node.Location{ 1 };
try 
info = ver( folder );
name = info.Name;
catch 
installedAddons = matlab.internal.addons.getAddonInstallations;
addon = installedAddons( folder == [ installedAddons.InstallationFolder ] );
name = char( addon.Name );
end 
else 
baseCode = i_pickBaseCodeByPriority( node );
finder = dependencies.internal.analysis.toolbox.ToolboxFinder;
info = finder.fromBaseCode( baseCode );
name = info.Name;
folder = info.DirectoryName;
end 
end 

function baseCode = i_pickBaseCodeByPriority( node )
baseCodes = node.Location;

if length( baseCodes ) == 1
baseCode = baseCodes{ 1 };
return ;
end 

[ found, idx ] = ismember( "ML", baseCodes );
if ~found
[ found, idx ] = ismember( "SL", baseCodes );
end 
if ~found
[ found, idx ] = ismember( "SS", baseCodes );
end 
if ~found
idx = 1;
end 

baseCode = baseCodes{ idx };
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpmYPuzd.p.
% Please follow local copyright laws when handling this file.

