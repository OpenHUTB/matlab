classdef SimlogNodeProvider < simscape.ui.internal.NodeProvider







properties ( SetAccess = immutable, GetAccess = private )
Simlog
end 

methods 
function obj = SimlogNodeProvider( simlog )
R36
simlog simscape.logging.Node
end 
obj.Simlog = simlog;
end 
function out = children( obj, nodePath )
R36
obj( 1, 1 )
nodePath( 1, : )cell
end 
p = obj.fetch( nodePath );
if isempty( nodePath ) || ~isscalar( p )
ni = num2cell( uint32( 1:numel( p ) ) );
else 
ni = childIds( p );
end 

out = [  ];
for idx = 1:numel( ni )
[ nd, isTerminal ] = lNodeData( ni{ idx }, p );
out = [ out, struct( "ID", { ni( idx ) }, "Data", { nd }, "Terminal", { isTerminal } ) ];%#ok<AGROW> 
end 
end 
end 
methods ( Access = private )
function out = fetch( obj, nodePath )
R36
obj( 1, 1 )
nodePath( 1, : )cell
end 
out = obj.Simlog;
for idx = 1:numel( nodePath )
v = nodePath{ idx };
out = getChild( out, v );
end 
end 
end 
end 

function [ nd, isTerminal ] = lNodeData( nameOrIndex, parent )
import simscape.logging.internal.getNodeDisplayOptions

obj = getChild( parent, nameOrIndex );
isTerminal = isscalar( obj ) && isempty( obj.childIds(  ) );
res = getNodeDisplayOptions( obj,  ...
[ "TreeNodeIcon", "TreeNodeLabelFcn" ],  ...
{ lGetTreeNodeIcon( obj ), @lDefaultLabel } );
label = res{ 2 }( obj );
nd = struct( "Text", { string( label ) }, "Icon", string( res( 1 ) ) );
end 

function str = lDefaultLabel( n )
if isscalar( n )
str = getName( n );
else 
str = n( 1 ).id;
end 
end 

function icon = lGetTreeNodeIcon( nodes )
persistent Terminal NonTerminal
if isempty( Terminal )
Terminal = fullfile( matlabroot, 'toolbox', 'physmod', 'common',  ...
'logging', 'sli', 'm', 'resources', 'icons', 'signal.png' );
NonTerminal = fullfile( matlabroot, 'toolbox', 'physmod', 'common',  ...
'logging', 'sli', 'm', 'resources', 'icons',  ...
'nonterminal_node.png' );
end 

if numel( nodes ) > 1
node = nodes( 1 );
else 
node = nodes;
end 

if numChildren( node ) == 0
icon = Terminal;
else 
icon = NonTerminal;
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpgbYXub.p.
% Please follow local copyright laws when handling this file.

