classdef PortNode < handle




properties 
ID;
Adapter;
PortBlk;
ArchPort;
NodeFactory;
end 

methods 
function this = PortNode( id, adapter, portBlk, factory )


this.ID = id;
this.Adapter = adapter;
this.PortBlk = portBlk;
this.NodeFactory = factory;
this.ArchPort = systemcomposer.utils.getArchitecturePeer(  ...
get_param( portBlk, 'handle' ) );
end 

function id = getID( this )
id = this.ID;
end 

function label = getDisplayLabel( this )
label = get_param( this.PortBlk, 'PortName' );
end 

function iconPath = getDisplayIcon( this )


iconPath = '';
if this.NodeFactory.isTreeNodeMapped( this )
iconPath = fullfile( matlabroot, 'toolbox', 'sysarch', 'sysarch',  ...
'+systemcomposer', '+internal', '+adapter', 'resources', 'ElementAdapted.png' );
end 
end 

function has = hasChildren( this )



has = false;
pi = this.ArchPort.getPortInterface(  );
if ~isempty( pi )
has = ~isempty( pi.getElementNames(  ) );
end 
end 

function children = getAllChildren( this )


pi = this.ArchPort.getPortInterface(  );
names = pi.getElementNames(  );
children = cell( 1, length( names ) );
for idx = 1:length( names )
name = names{ idx };
children{ idx } = this.NodeFactory.createElementNode(  ...
name, pi, this.getDisplayLabel(  ) );
end 
end 

function filteredChildren = getHierarchicalChildren( this )

filteredChildren = {  };
allChildren = this.getAllChildren(  );
for idx = 1:numel( allChildren )
child = allChildren{ idx };
if this.NodeFactory.includeNode( child )
filteredChildren = [ filteredChildren;{ child } ];%#ok<AGROW> 
end 
end 
end 

function p = getFullPath( this )

p = this.getDisplayLabel(  );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpbAYo6V.p.
% Please follow local copyright laws when handling this file.

