classdef InterfacesTabAdapter < sl.interface.dictionaryApp.tab.AbstractArchTabAdapter




properties ( Constant, Access = protected )
TabId = 'InterfacesTab';
end 

properties ( Access = protected )
DefaultEntryName = 'DataInterface';
end 

methods ( Static, Access = public )
function cols = getColumnNames(  )

cols =  ...
sl.interface.dictionaryApp.node.InterfaceElementNode. ...
getGenericPropertyNames(  );
end 
end 

methods ( Access = public )
function addEntry( this, entryInfo, itfNode, position )
R36
this
entryInfo{ mustBeNonzeroLengthText };
itfNode sl.interface.dictionaryApp.node.InterfaceNode ...
 = sl.interface.dictionaryApp.node.InterfaceNode.empty(  );
position{ mustBeNumeric } = 1;
end 
if strcmp( entryInfo, 'Interface' )
busObj = this.createDefaultBus(  );
this.DictObj.addDataInterface( this.getDefaultEntryName(  ),  ...
SimulinkBus = busObj );
elseif strcmp( entryInfo, 'InterfaceElement' )

updatedItfBusObj = this.addDataElement( itfNode.getDataObject(  ), position );

itfNode.replaceDataObject( updatedItfBusObj );
else 
assert( false, 'Unexpected entry type for interface tab adapter' );
end 
end 

function deleteEntry( this, selectedNode )
if isa( selectedNode, 'sl.interface.dictionaryApp.node.InterfaceNode' )

parentInterfaceName = selectedNode.getPropValue( 'Name' );
this.DictObj.removeInterface( parentInterfaceName );
elseif isa( selectedNode, 'sl.interface.dictionaryApp.node.InterfaceElementNode' )

interfaceElementName = selectedNode.getPropValue( 'Name' );
parentInterfaceNode = selectedNode.getParentNode(  );
parentInterfaceName = parentInterfaceNode.getPropValue( 'Name' );
parentInterfaceObj = this.DictObj.getInterface( parentInterfaceName );
parentInterfaceObj.removeElement( interfaceElementName );
else 
assert( false, 'Unexpected entry type for interface tab adapter' );
end 
end 

function canPaste = canPaste( ~, node )




canPaste =  ...
isa( node, 'sl.interface.dictionaryApp.node.InterfaceNode' ) ||  ...
isa( node, 'sl.interface.dictionaryApp.node.StructTypeNode' );
end 
end 

methods ( Access = protected )
function entryNames = getEntryNames( this )
entryNames = this.DictObj.getInterfaceNames(  );
end 

function entry = getEntry( this, name )
entry = this.DictObj.getInterface( name );
end 

function addedEntry = addEntryForSourceObj( this, entryName, sourceObj )
R36
this
entryName{ mustBeNonzeroLengthText };
sourceObj( 1, 1 )Simulink.Bus;
end 
addedEntry = this.DictObj.addDataInterface( entryName, 'SimulinkBus', sourceObj );
end 

end 

methods ( Access = private )

function itfBusObj = addDataElement( this, itfBusObj, position )

elementName =  ...
this.getDefaultElementName( itfBusObj );
itfBusObj = sl.interface.dictionaryApp.utils.addElementToBusObject(  ...
itfBusObj, elementName, position );
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpYw3y7b.p.
% Please follow local copyright laws when handling this file.

