classdef DataTypesTabAdapter < sl.interface.dictionaryApp.tab.AbstractArchTabAdapter




properties ( Constant, Access = protected )
TabId = 'DataTypesTab';
end 

properties ( Access = protected )
DefaultEntryName;
end 

methods ( Static, Access = public )
function cols = getColumnNames(  )

cols =  ...
sl.interface.dictionaryApp.node.StructElementNode. ...
getGenericPropertyNames(  );
end 
end 

methods ( Access = public )
function addEntry( this, entryType, parentNode, position )
R36
this
entryType
parentNode sl.interface.dictionaryApp.node.StructTypeNode ...
 = sl.interface.dictionaryApp.node.StructTypeNode.empty(  );
position{ mustBeNumeric } = 0;
end 
this.DefaultEntryName = entryType;
switch entryType
case 'ValueType'
this.DictObj.addValueType( this.getDefaultEntryName(  ) );
case 'AliasType'
this.DictObj.addAliasType( this.getDefaultEntryName(  ) );
case 'Structure'
busObj = this.createDefaultBus(  );
this.DictObj.addStructType( this.getDefaultEntryName(  ),  ...
SimulinkBus = busObj );
case 'StructureElement'
updateStructBusObj = this.addStructureElement(  ...
parentNode.getDataObject(  ), position );

parentNode.replaceDataObject( updateStructBusObj );
case 'Enumeration'
this.DictObj.addEnumType( this.getDefaultEntryName(  ) );
otherwise 
assert( false, 'Unexpected entry type in DataTypesTabAdapter' );
end 
end 

function deleteEntry( this, selectedNode )
if isa( selectedNode, 'sl.interface.dictionaryApp.node.StructElementNode' )
structElementName = selectedNode.getPropValue( 'Name' );
parentStructNode = selectedNode.getParentNode(  );
parentStructName = parentStructNode.getPropValue( 'Name' );
parentStructObj = this.DictObj.getDataType( parentStructName );
parentStructObj.removeElement( structElementName );
else 
datatypeName = selectedNode.getPropValue( 'Name' );
this.DictObj.removeDataType( datatypeName );
end 
end 

function canPaste = canPaste( ~, node )




canPaste =  ...
isa( node, 'sl.interface.dictionaryApp.node.InterfaceNode' ) ||  ...
isa( node, 'sl.interface.dictionaryApp.node.DataTypeNode' );
end 
end 

methods ( Access = protected )
function entryNames = getEntryNames( this )
entryNames = this.DictObj.getDataTypeNames(  );
end 

function entry = getEntry( this, name )
entry = this.DictObj.getDataType( name );
end 

function addedEntry = addEntryForSourceObj( this, entryName, sourceObj )
R36
this
entryName{ mustBeNonzeroLengthText };
sourceObj( 1, 1 );
end 
addedEntry = this.DictObj.addDataTypeUsingSLObj( entryName, sourceObj );
end 
end 

methods ( Access = private )
function structBusObj = addStructureElement( this, structBusObj, position )
elementName = this.getDefaultElementName( structBusObj );
structBusObj = sl.interface.dictionaryApp.utils.addElementToBusObject(  ...
structBusObj, elementName, position );
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpfrCXEG.p.
% Please follow local copyright laws when handling this file.

