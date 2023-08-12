classdef InterfaceTree < handle




properties ( Access = public )
Parent;
TreeType;
end 

properties ( Access = private )
Adapter;
TreeElems = {  };
RootNodes;
filterPattern = wildcardPattern;
end 

properties ( Access = ?systemcomposer.internal.adapter.PortNode )
TreeNodeIDService;
end 

methods 
function this = InterfaceTree( dlg, adapter, type )

R36
dlg( 1, 1 )systemcomposer.internal.adapter.Dialog;
adapter( 1, 1 )double;
type( 1, : )char;
end 
this.Parent = dlg;
this.Adapter = adapter;
this.TreeType = type;
this.TreeNodeIDService = systemcomposer.internal.profile.internal.TreeNodeIDMap(  );
this.RootNodes = this.getRootNodes(  );
this.TreeElems = this.getTreeElements(  );
end 

function filteredRootNodes = getTreeModel( this, filterText )






R36
this
filterText( 1, : )char;
end 
if isempty( filterText )
this.filterPattern = wildcardPattern;
else 
this.filterPattern = filterText;
end 
allRootNodes = this.getRootNodes(  );
filteredRootNodes = [  ];
treeElems = {  };
for idx = 1:length( allRootNodes )
elems = this.visitNode( allRootNodes{ idx }, {  } );
treeElems = [ treeElems;elems ];%#ok<*AGROW> 
canIncludeNode = any( contains( elems, this.filterPattern ) );
if canIncludeNode
filteredRootNodes = [ filteredRootNodes;allRootNodes( idx ) ];
end 
end 
this.RootNodes = allRootNodes;
this.TreeElems = treeElems;
end 

function update( this )

this.RootNodes = this.getRootNodes(  );
this.TreeElems = this.getTreeElements(  );
end 

function matchFound = includeNode( this, node )



matchFound = false;
if ~isequal( this.filterPattern, wildcardPattern ) && contains( this.filterPattern, '/' )

nodePath = node.getFullPath(  );
else 
nodePath = node.getDisplayLabel(  );
end 
if contains( nodePath, this.filterPattern )

matchFound = true;
return ;
end 

if node.hasChildren(  )
children = node.getAllChildren(  );
for idx = 1:length( children )
child = children{ idx };
matchFound = this.includeNode( child );
if matchFound

break ;
end 
end 
end 
end 

function tf = hasElement( this, elem )

R36
this
elem( 1, : )char;
end 
tf = any( strcmp( elem, this.TreeElems ) );
end 

function tf = nodeIsEditable( this, elemPath )

R36
this %#ok<INUSA> 
elemPath( 1, : )char;
end 
tf = ~contains( elemPath, "/" );
end 

function pruneUnconnectedOutputBEPs( this )



if strcmp( this.TreeType, 'output' )
beps = find_system( this.Adapter, 'BlockType', 'Outport' );
conns = find_system( this.Adapter, 'FindAll', 'on', 'Type', 'Line' );
bepsToDelete = [  ];
if length( beps ) ~= length( conns )



pcData = get_param( beps, 'PortConnectivity' );
if isa( pcData, 'struct' )
pcData = { pcData };
end 
for i = 1:length( pcData )
if pcData{ i }.SrcBlock ==  - 1
bepsToDelete = [ bepsToDelete;beps( i ) ];
end 
end 
end 





if ~isempty( conns )
for k = 1:length( conns )
if get_param( conns( k ), 'SrcBlockHandle' ) ==  - 1
bep = get_param( conns( k ), 'DstBlockHandle' );
if bep ~=  - 1 && ~any( ismember( bepsToDelete, bep ) )
bepsToDelete = [ bepsToDelete;bep ];
end 
end 
end 
end 

if ~isempty( bepsToDelete )
if length( bepsToDelete ) == length( beps )


for j = 2:length( bepsToDelete )
blockPath = Simulink.ID.getFullName( bepsToDelete( j ) );
delete_block( blockPath );
end 
set_param( bepsToDelete( 1 ), 'Element', '' );
else 

for j = 1:length( bepsToDelete )
blockPath = Simulink.ID.getFullName( bepsToDelete( j ) );
delete_block( blockPath );
end 
end 
end 
end 
end 
end 
methods ( Access = private )
function nodes = getRootNodes( this )



portConn = get_param( this.Adapter, 'PortHandles' );
if strcmp( this.TreeType, 'input' )
numPorts = length( portConn.Inport );
else 
numPorts = length( portConn.Outport );
end 
nodes = cell( 1, numPorts );
for idx = 1:numPorts
nodes{ idx } = this.createPortNode( this.TreeType, idx );
end 
this.RootNodes = nodes;
end 
function elems = getTreeElements( this )



elems = {  };
for idx = 1:length( this.RootNodes )
elems = this.visitNode( this.RootNodes{ idx }, elems );
end 
end 
function elemList = visitNode( this, node, elemList )


elemList = [ elemList;{ node.getFullPath(  ) } ];

if node.hasChildren(  )
children = node.getHierarchicalChildren(  );
for c = 1:length( children )
child = children{ c };
elemList = this.visitNode( child, elemList );
end 
end 
end 
function node = createPortNode( this, type, index )


if strcmpi( type, 'input' )
portBlk = find_system( this.Adapter,  ...
'SearchDepth', 1, 'BlockType', 'Inport', 'Port', num2str( index ) );
else 
portBlk = find_system( this.Adapter,  ...
'SearchDepth', 1, 'BlockType', 'Outport', 'Port', num2str( index ) );
end 

portBlk = portBlk( 1 );

name = get_param( portBlk, 'PortName' );
nodeID = this.TreeNodeIDService.get( name );
node = systemcomposer.internal.adapter.PortNode(  ...
nodeID, this.Adapter, portBlk, this );
end 
end 
methods ( Access = { ?systemcomposer.internal.adapter.PortNode,  ...
?systemcomposer.internal.adapter.ElementNode } )
function node = createElementNode( this, name, portInterface, parentName )

nodeID = this.TreeNodeIDService.get( [ parentName, '/', name ] );
node = systemcomposer.internal.adapter.ElementNode(  ...
nodeID, name, portInterface, parentName, this );
end 

function isMapped = isTreeNodeMapped( this, node )

nodePath = node.getFullPath(  );
nodePath = this.Parent.tree2ElemPath( nodePath );
isMapped = this.Parent.isTreeNodeMapped( nodePath );
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpuRUihu.p.
% Please follow local copyright laws when handling this file.

