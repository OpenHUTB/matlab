classdef Tree < handle









events 
SelectionChanged
end 


properties 
NodeProvider( 1, 1 )simscape.ui.internal.NodeProvider =  ...
simscape.ui.internal.DefaultNodeProvider
end 

properties 
Incremental( 1, 1 )logical = false
SelectionStyle( 1, 1 )simscape.ui.internal.TreeSelectionStyle =  ...
simscape.ui.internal.TreeSelectionStyle.Leafselect
end 


properties ( Dependent )
Parent
SelectedPaths( :, 1 )cell
end 


properties ( Access = private )
UITree
end 

methods 

function obj = Tree( args )
R36
args.NodeProvider( 1, 1 )simscape.ui.internal.NodeProvider = simscape.ui.internal.DefaultNodeProvider
args.Parent = uigridlayout( uifigure, RowHeight = "1x", ColumnWidth = "1x" );
args.Incremental( 1, 1 )logical = true;
end 
obj.Incremental = args.Incremental;
obj.makeTree( args.Parent, args.NodeProvider );
end 

function set.Incremental( obj, state )
obj.Incremental = state;
if ~state && ~isempty( obj.UITree )
obj.addChildren( obj.UITree );
end 
end 


function set.NodeProvider( obj, nodeProvider )
R36
obj( 1, 1 )
nodeProvider( 1, 1 )simscape.ui.internal.NodeProvider
end 
obj.NodeProvider = nodeProvider;
obj.updateTree(  )
end 


function out = get.Parent( obj )
out = obj.UITree.Parent;
end 


function set.Parent( obj, p )
R36
obj( 1, 1 )
p( 1, 1 )
end 
obj.UITree.Parent = p;
end 





function set.SelectionStyle( obj, s )
R36
obj( 1, 1 )
s( 1, 1 )simscape.ui.internal.TreeSelectionStyle
end 
import simscape.ui.internal.TreeSelectionStyle


obj.SelectionStyle = s;


previous = obj.UITree.SelectedNodes;%#ok<MCSUP> 


obj.UITree.Multiselect =  ...
~isequal( s, TreeSelectionStyle.Singleselect );%#ok<MCSUP>


selected = obj.UITree.SelectedNodes;%#ok<MCSUP> 
obj.setSelectedNodes( selected, previous );

end 


function expand( obj, p )
R36
obj( 1, 1 )
p( 1, : )cell = {  };
end 
if isempty( p )
p = arrayfun( @obj.path, obj.UITree.Children, 'UniformOutput', false );
nodes = cellfun( @obj.find, p, 'UniformOutput', false );
cellfun( @( n, p )obj.addNodeChildren( n.Children, p ), nodes, p );
cellfun( @obj.expandNode, nodes );
else 
node = obj.find( p );
obj.addNodeChildren( node.Children, p );
obj.expandNode( node );
end 
end 


function out = get.SelectedPaths( obj )
out = arrayfun( @obj.path, obj.UITree.SelectedNodes,  ...
'UniformOutput', false );
end 

function set.SelectedPaths( obj, p )
R36
obj( 1, 1 )
p( 1, : )cell
end 
nodes = cellfun( @( p )obj.find( p ), p, 'UniformOutput', false );
nodes = [ nodes{ : } ];
arrayfun( @( n )obj.expandParent( n ), nodes );
obj.setSelectedNodes( nodes, obj.UITree.SelectedNodes );
end 
end 

methods ( Access = private )
function broadCastSelectionChanged( obj, ~, ed )


if ~isequal( obj.UITree.SelectedNodes, ed.SelectedNodes )
return 
end 
obj.setSelectedNodes( ed.SelectedNodes,  ...
ed.PreviousSelectedNodes );
end 


function expandNode( obj, node )
R36
obj( 1, 1 )
node( 1, 1 )matlab.ui.container.TreeNode
end 
node.expand(  );
obj.expandParent( node );
end 

function expandParent( obj, node )
R36
obj( 1, 1 )
node( 1, 1 )matlab.ui.container.TreeNode
end 
node = node.Parent;
while isa( node, 'matlab.ui.container.TreeNode' )
node.expand(  );
node = node.Parent;
end 
end 

function setSelectedNodes( obj, selected, previouslySelected )
import simscape.ui.internal.TreeSelectionStyle

switch obj.SelectionStyle
case TreeSelectionStyle.Leafselect
selected = lFilterLeaf( selected );
case TreeSelectionStyle.Singleselect

if ~isempty( selected )
selected = selected( 1 );
end 
end 






obj.UITree.SelectedNodes = selected;


if isequal( selected, previouslySelected )
return 
end 
notify( obj, 'SelectionChanged' );
end 

function makeTree( obj, parent, nodeProvider )
R36
obj( 1, 1 )
parent
nodeProvider( 1, 1 )simscape.ui.internal.NodeProvider
end 
obj.UITree = uitree( 'Parent', parent, 'Multiselect', 'on', 'Interruptible', 'off', 'BusyAction', 'queue' );
obj.UITree.SelectionChangedFcn = @( varargin )obj.broadCastSelectionChanged( varargin{ : } );
obj.NodeProvider = nodeProvider;
end 

function updateTree( obj )





delete( obj.UITree.Children );
ch = obj.addChildren( obj.UITree );


if obj.Incremental
obj.UITree.NodeExpandedFcn = @( ~, n )expandCallback( obj, n );
obj.addNodeChildren( ch, [  ] );
end 

end 

function uinodes = addChildren( obj, parent, pth )
R36
obj( 1, 1 )
parent( 1, 1 )
pth( 1, : )cell = cell( 1, 0 );
end 
if isempty( parent.Children )
ch = obj.NodeProvider.children( pth );
uinodes = lTreeNodes( parent, numel( ch ) );
for idx = 1:numel( ch )
n = ch( idx );
defaultNodeData = struct( "Index", { n.ID }, "Populated", { false }, "Terminal", n.Terminal );
set( uinodes( idx ), 'Text', n.Data.Text, 'Icon', n.Data.Icon, 'NodeData', defaultNodeData );
end 
else 
uinodes = parent.Children;
end 

if ~obj.Incremental
obj.addNodeChildren( uinodes, pth );
end 

function uinodes = lTreeNodes( parent, n )
uinodes = [  ];
if n > 0
node = uitreenode( parent );
copiedNodes = copyobj( node, repmat( parent, 1, n - 1 ) );
uinodes = [ node;copiedNodes( : ) ];
end 
end 

end 

function expandCallback( obj, n )
if obj.Incremental
n = n.Node;
obj.addNodeChildren( n.Children, obj.path( n ) );
end 
end 

function addNodeChildren( obj, nodes, parentPath )
R36
obj( 1, 1 )
nodes
parentPath( 1, : )cell
end 
for idx = 1:numel( nodes )
n = nodes( idx );
nd = n.NodeData;
if ~nd.Terminal && ( ~obj.Incremental || ~nd.Populated )
obj.addChildren( n, [ parentPath, nd.Index ] );
nd.Populated = true;
set( n, 'NodeData', nd );
end 
end 
end 

function p = path( ~, node )
p = cell( 1, 0 );
while isa( node, 'matlab.ui.container.TreeNode' )
p = [ node.NodeData.Index, p ];%#ok<AGROW> 
node = node.Parent;
end 
end 

function n = find( obj, path )
R36
obj( 1, 1 )
path( 1, : )
end 
n = obj.UITree;
for iPath = 1:numel( path )
children = n.Children;
ch = [  ];
for iCh = 1:numel( children )
lExpand( children( iCh ) );
if lIsNode( children( iCh ), path( iPath ) )
ch = children( iCh );
end 
end 
if isempty( ch )
if n == obj.UITree
n = [  ];
end 
return 
else 
n = ch;
end 
end 

function res = lIsNode( node, idx )
res = isequal( node.NodeData.Index, idx );
end 

function lExpand( node )
nd = node.NodeData;
if ~nd.Terminal && ~nd.Populated
obj.addNodeChildren( node, obj.path( node.Parent ) );
end 
end 
end 

end 
end 

function selected = lFilterLeaf( nodes )
selected = nodes;
if ~isempty( selected )
isLeaf = arrayfun( @( n )isempty( n.Children ), selected );
if any( isLeaf )
selected = selected( isLeaf );
else 
selected = selected( end  );
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp2z3XPf.p.
% Please follow local copyright laws when handling this file.

