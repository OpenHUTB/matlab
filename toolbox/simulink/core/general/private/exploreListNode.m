function exploreListNode( file, treeNode, listNode, varargin )




cmdDaexplr = 'view';
if nargin > 3 && islogical( varargin{ 1 } ) && varargin{ 1 }
cmdDaexplr = 'view_and_expand';
end 

me = daexplr;
[ hTreeNode, treeNode ] = findTreeNode( me, treeNode, file, listNode );
if ~isempty( hTreeNode )
if isempty( listNode ) || strcmpi( treeNode, 'modelnode' )
daexplr( cmdDaexplr, hTreeNode );
elseif strcmpi( treeNode, 'dictionary' )
if ischar( listNode )
[ listUdi, nIdx ] = hTreeNode.getIndexForNamedItem( me, listNode );
else 
assert( isnumeric( listNode ) );
[ listUdi, nIdx ] = hTreeNode.getIndexForIdItem( listNode );
end 
me.view( listUdi, nIdx );
else 
listnodes = hTreeNode.getChildren;

if strcmpi( treeNode, 'mask' )
listNodeName = file;
else 
listNodeName = listNode;
end 

for i = 1:length( listnodes )
if strcmpi( treeNode, 'mask' )
label = listnodes( i ).getFullName;
label = strrep( label, sprintf( '\n' ), ' ' );
else 
label = listnodes( i ).getDisplayLabel;
end 
if isequal( label, listNodeName )
daexplr( cmdDaexplr, listnodes( i ) );
break ;
end 
end 
end 
end 
end 

function [ hNode, nodeType ] = findTreeNode( me, nodeType, file, nodeName )
hNode = '';
if strcmpi( nodeType, 'base' )
dispName = 'Base Workspace';
root = me.getRoot;
if isa( root, "Simulink.Object" ) && ismethod( root, 'getMixedHierarchicalChildren' )
subnodes = root.getMixedHierarchicalChildren;
else 
subnodes = num2cell( root.getHierarchicalChildren );
end 
hNode = findNamedTreeNode( subnodes, dispName, '' );
elseif strcmpi( nodeType, 'model' )
if slfeature( 'SLModelOwnedDataDictionary' ) > 0
dispName = DAStudio.message( 'Simulink:dialog:WorkspaceLocation_ModelDict' );
else 
dispName = 'Model Workspace';
end 
hBlock = get_param( file, 'Object' );

if isa( hBlock, "Simulink.Object" ) && ismethod( hBlock, 'getMixedHierarchicalChildren' )
subnodes = hBlock.getMixedHierarchicalChildren;
else 
subnodes = num2cell( hBlock.getHierarchicalChildren );
end 

hNode = findNamedTreeNode( subnodes, dispName, '' );

if isa( hNode, "Simulink.Object" ) && ismethod( hNode, 'getMixedHierarchicalChildren' )
subnodes = hNode.getMixedHierarchicalChildren;
else 
subnodes = num2cell( hNode.getHierarchicalChildren );
end 

if length( subnodes ) > 0
hNode = subnodes{ 1 };
nodeType = 'dictionary';
end 
elseif strcmpi( nodeType, 'dictionary' )
dd = Simulink.dd.open( file );
dd.show;
root = me.getRoot;
if isa( root, "Simulink.Object" ) && ismethod( root, 'getMixedHierarchicalChildren' )
subnodes = root.getMixedHierarchicalChildren;
else 
subnodes = num2cell( root.getHierarchicalChildren );
end 

dispName = [ 'Data Dictionary', ' ''', dd.filespec, '''' ];
hNode = findNamedTreeNode( subnodes, '', dispName );
subnodes = num2cell( hNode.getHierarchicalChildren );
hNode = subnodes{ 1 };
elseif strcmpi( nodeType, 'mask' )
hBlock = get_param( file, 'Object' );
hNode = hBlock.getParent;
elseif strcmpi( nodeType, 'modelnode' )
hBlock = get_param( file, 'Object' );

if isa( hBlock, "Simulink.Object" ) && ismethod( hBlock, 'getMixedHierarchicalChildren' )
subnodes = hBlock.getMixedHierarchicalChildren;
else 
subnodes = num2cell( hBlock.getHierarchicalChildren );
end 

hNode = findNamedTreeNode( subnodes, nodeName, '' );
else 
nodeType = '';
end 

end 

function hNode = findNamedTreeNode( subnodes, dispName, fullName )
hNode = '';
for i = 1:length( subnodes )
if ~isempty( fullName ) && strcmpi( subnodes{ i }.getFullName, fullName )
hNode = subnodes{ i };
break ;
elseif ~isempty( dispName ) && strncmpi( subnodes{ i }.getDisplayLabel, dispName, length( dispName ) )
hNode = subnodes{ i };
break ;
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpi9AwU_.p.
% Please follow local copyright laws when handling this file.

