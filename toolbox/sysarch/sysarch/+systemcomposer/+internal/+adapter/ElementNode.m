classdef ElementNode < handle




properties 
ID;
Name;
PortInterface;
ParentName;
NodeFactory;
end 

methods 
function this = ElementNode( id, name, portInterface, parentName, factory )


this.ID = id;
this.Name = name;
this.PortInterface = portInterface;
this.ParentName = parentName;
this.NodeFactory = factory;
end 

function id = getID( this )
id = this.ID;
end 

function label = getDisplayLabel( this )
label = this.Name;
end 

function has = hasChildren( this )



elem = this.PortInterface.getElement( this.Name );
has = ~isempty( this.getSubInterface( elem ) );
end 

function children = getAllChildren( this )


elem = this.PortInterface.getElement( this.Name );
subType = this.getSubInterface( elem );

names = subType.getElementNames(  );
children = cell( 1, length( names ) );
for idx = 1:length( names )
name = names{ idx };
children{ idx } = this.NodeFactory.createElementNode(  ...
name, subType, [ this.ParentName, '/', this.Name ] );
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

function iconPath = getDisplayIcon( this )


iconPath = '';
if this.NodeFactory.isTreeNodeMapped( this )
iconPath = fullfile( matlabroot, 'toolbox', 'sysarch', 'sysarch',  ...
'+systemcomposer', '+internal', '+adapter', 'resources', 'ElementAdapted.png' );
end 
end 

function p = getFullPath( this )

p = [ this.ParentName, '/', this.Name ];
end 
end 

methods ( Access = private )
function subInterface = getSubInterface( this, elem )


subInterface = mf.zero.ModelElement.empty;
if elem.hasReferencedType
subInterface = elem.getTypeAsInterface(  );
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpKXVNDs.p.
% Please follow local copyright laws when handling this file.

