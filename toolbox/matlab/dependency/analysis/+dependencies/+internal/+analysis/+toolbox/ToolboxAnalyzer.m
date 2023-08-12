classdef ToolboxAnalyzer < dependencies.internal.engine.AnalysisFilter




properties ( Constant, Access = private )
ExtensionMap = i_createExtensionMap;
TypeMap = i_createTypeMap;
end 

properties 
AnalyzeToolboxes( 1, 1 )logical = false;
end 

properties ( GetAccess = private, SetAccess = immutable )
ToolboxMap containers.Map;
NodeIsResolvedFile dependencies.internal.graph.NodeFilter;
NodeIsSharedProduct dependencies.internal.graph.NodeFilter;
DownstreamIsResolvedFile dependencies.internal.graph.DependencyFilter;
end 

methods ( Static )

function analyzer = analyzeToolboxes( analyzeToolboxes )
R36
analyzeToolboxes( 1, 1 )logical = false;
end 

toolboxAnalyzer = dependencies.internal.analysis.toolbox.ToolboxAnalyzer;
toolboxAnalyzer.AnalyzeToolboxes = analyzeToolboxes;

analyzer = dependencies.internal.engine.filters.MatlabFilter( toolboxAnalyzer );
end 

end 

methods 

function this = ToolboxAnalyzer(  )
import dependencies.internal.graph.DependencyFilter.downstream;
import dependencies.internal.graph.NodeFilter.isResolved;
import dependencies.internal.graph.NodeFilter.nodeType;
import dependencies.internal.graph.NodeFilter.wrapNode;
import dependencies.internal.graph.Type;

this.ToolboxMap = containers.Map;

this.NodeIsResolvedFile = all( isResolved, nodeType( Type.FILE ) );
this.NodeIsSharedProduct = all( nodeType( Type.PRODUCT ), wrapNode( @i_areSharedProductNodes ) );
this.DownstreamIsResolvedFile = downstream( this.NodeIsResolvedFile );

finder = dependencies.internal.analysis.toolbox.ToolboxFinder;
finder.validate(  );
end 

function [ accept, tbx ] = analyzeNodes( this, nodes )
import dependencies.internal.graph.Component;
import dependencies.internal.graph.Dependency.createToolbox
import dependencies.internal.graph.Type;


accept = true( size( nodes ) );
tbx = dependencies.internal.graph.Dependency.empty( 1, 0 );

idx = apply( this.NodeIsResolvedFile, nodes );
for n = find( idx )
node = nodes( n );

toolboxAtNodeFolder = this.findToolbox( node );
accept( n ) = this.allowAnalysisOfFilesIn( toolboxAtNodeFolder );
fileTypeProduct = this.findProductFromFileType( node );

for toolbox = this.createReducedSetOfProducts( toolboxAtNodeFolder, fileTypeProduct )
tbx( end  + 1 ) = createToolbox( node, toolbox, Type.TOOLBOX );%#ok<AGROW>
end 
end 
end 


function [ accept, tbx ] = analyzeDependencies( this, deps )
import dependencies.internal.graph.Dependency.createToolbox

accept = true( size( deps ) );

tbx = dependencies.internal.graph.Dependency.empty( 1, 0 );


idx = apply( this.DownstreamIsResolvedFile, deps );
for n = find( idx )
dep = deps( n );

toolboxes = this.findToolbox( dep.DownstreamNode );




accept( n ) = this.allowAnalysisOfFilesIn( toolboxes );




toolboxes = this.filterOutProductsRequiredByFileExtension(  ...
toolboxes, dep.UpstreamNode );

for toolbox = toolboxes
tbx( end  + 1 ) = createToolbox(  ...
dep.UpstreamComponent,  ...
toolbox, dep.Type );%#ok<AGROW>
end 
end 


for n = 1:length( deps )
dep = deps( n );
type = dep.Type;
baseType = type.Base.ID;
if ~this.TypeMap.isKey( baseType )
continue ;
end 

product = this.TypeMap( baseType );

if ~this.nodeDependsOnProduct( dep.UpstreamNode, product )
tbx( end  + 1 ) = createToolbox(  ...
dep.UpstreamComponent,  ...
product,  ...
type );%#ok<AGROW>
end 
if accept( n ) && ~this.nodeDependsOnProduct( dep.DownstreamNode, product )
tbx( end  + 1 ) = createToolbox(  ...
dep.DownstreamComponent,  ...
product,  ...
type );%#ok<AGROW>
end 
end 
end 

end 

methods ( Access = private )

function toolbox = findToolbox( this, node )
import dependencies.internal.graph.Node;
if isKey( this.ToolboxMap, node.ID )
toolbox = this.ToolboxMap( node.ID );
else 
toolbox = Node.createProductOrToolboxFromPath( node.Location{ 1 } );
this.ToolboxMap( node.ID ) = toolbox;
end 
end 

function accept = allowAnalysisOfFilesIn( this, toolbox )



import dependencies.internal.graph.Type;
accept = isempty( toolbox ) || ( this.AnalyzeToolboxes && toolbox.Type == Type.TOOLBOX );
end 

function product = findProductFromFileType( this, node )
product = dependencies.internal.graph.Node.empty( 1, 0 );
if ~node.isFile(  )
return ;
end 
[ ~, ~, ext ] = fileparts( node.Location{ 1 } );
if this.ExtensionMap.isKey( ext )
func = this.ExtensionMap( ext );
product = func( node.Location{ 1 } );
end 
end 

function productNodes = filterOutProductsRequiredByFileExtension(  ...
this, productNodes, fileNode )
if isempty( productNodes )
return ;
end 
productsRequiredByFileExtension = this.findProductFromFileType( fileNode );
if ~isempty( productsRequiredByFileExtension )
productNodes = i_filterOutProductNodesThatContainAny(  ...
productNodes, productsRequiredByFileExtension );
end 
end 

function result = nodeDependsOnProduct( this, node, product )
nodeProduct = this.findProductFromFileType( node );
result = ~isempty( nodeProduct ) && nodeProduct == product;
end 

function filteredNodes = createReducedSetOfProducts( this, toolboxAtNodeFolder, fileTypeProduct )
if isempty( fileTypeProduct )
filteredNodes = toolboxAtNodeFolder;
return ;
end 

filteredNodes = fileTypeProduct;

if isempty( toolboxAtNodeFolder )
return ;
end 

if ~this.NodeIsSharedProduct.apply( toolboxAtNodeFolder )
filteredNodes( end  + 1 ) = toolboxAtNodeFolder;
return ;
end 

basecodes = string( toolboxAtNodeFolder.Location );
if any( basecodes == fileTypeProduct.Location{ 1 } )
return ;
end 

if any( basecodes == "ML" )
filteredNodes( end  + 1 ) = dependencies.internal.graph.Node.createProductNode( "ML" );
return ;
end 

filteredNodes( end  + 1 ) = toolboxAtNodeFolder;
end 
end 

end 


function productsFromDep = i_filterOutProductNodesThatContainAny(  ...
productsFromDep, productsFromExt )
shouldBeKept = arrayfun(  ...
@( prod )~all( ismember( productsFromExt.Location, prod.Location ) ),  ...
productsFromDep );
productsFromDep = productsFromDep( shouldBeKept );
end 

function map = i_createExtensionMap(  )
map = containers.Map;
i_addFactory( map, "ML", [ ".m", ".p", ".mlx", ".mat", ".fig", ".mltbx", ".mlapp" ] );
i_addFactory( map, "SL", [ ".slx", ".mdl", ".slxp", ".mdlp", ".sldd", ".slxc" ] );
i_addFactory( map, "SS", [ ".ssc", ".sscp" ] );
i_addFactory( map, "RQ", [ ".slreqx", ".slmx" ] );
i_addFactory( map, "SB", ".sbproj" );
i_addFunction( map, @i_createNodeIfTestManagerFile, ".mldatx" );
i_addFunction( map, @i_createNodeIfSystemComposerProfile, ".xml" );
end 

function i_addFactory( map, baseCode, extensions )
import dependencies.internal.graph.Nodes;
product = Nodes.createProductNode( baseCode );
i_addFunction( map, @( ~ )product, extensions );
end 

function i_addFunction( map, func, extensions )
for extension = extensions
map( extension ) = func;
end 
end 

function map = i_createTypeMap(  )
import dependencies.internal.graph.Nodes;

map = containers.Map;

i_addProductNodes( map, "DV", "SimulinkDesignVerifier" );

i_addProductNodes( map, "SZ", [ "TestHarness", "ExternalTestHarness" ] );

i_addProductNodes( map, "RQ", "RequirementInfo" );
end 

function i_addProductNodes( map, baseCode, types )
import dependencies.internal.graph.Nodes;
product = Nodes.createProductNode( baseCode );
for type = types
map( type ) = product;
end 
end 

function node = i_createNodeIfTestManagerFile( file )
node = dependencies.internal.graph.Node.empty( 1, 0 );
try %#ok<TRYNC>
app = matlabshared.mldatx.internal.getApplication( file );
if strcmp( app, 'SimulinkTest' )
node = dependencies.internal.graph.Nodes.createProductNode( "SZ" );
end 
end 
end 

function node = i_createNodeIfSystemComposerProfile( file )
node = dependencies.internal.graph.Node.empty( 1, 0 );
try %#ok<TRYNC>
if Simulink.loadsave.find( file, '/MF0/systemcomposer.profile.Profile' )
node = dependencies.internal.graph.Nodes.createProductNode( "ZC" );
end 
end 
end 

function isShared = i_isSharedProductNode( productNode )
isShared = length( productNode.Location ) ~= 1;
end 

function areShared = i_areSharedProductNodes( productNodes )
areShared = arrayfun( @i_isSharedProductNode, productNodes );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp3b0rRV.p.
% Please follow local copyright laws when handling this file.

