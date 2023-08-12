classdef AbstractArchTabAdapter < sl.interface.dictionaryApp.tab.AbstractTabAdapter




properties ( SetAccess = immutable, GetAccess = protected )
DictObj Simulink.interface.Dictionary;
PlatformKind sl.interface.dict.mapping.PlatformMappingKind;
Studio sl.interface.dictionaryApp.StudioApp;
ListObj sl.interface.dictionaryApp.list.List;
end 

methods ( Access = public )
function node = getNode( this, entryName )
entry = this.getEntry( entryName );
node = sl.interface.dictionaryApp.node.DesignNode.getDesignNode(  ...
entry, this.DictObj, this.PlatformKind, this.Studio, this.ListObj );
end 

function copy( this, nodesToCopy )



for nodeIdx = 1:length( nodesToCopy )
curNode = nodesToCopy{ nodeIdx };
assert( this.canPaste( curNode ), 'Unexpected node type' );

protectedNames = [ this.DictObj.getInterfaceNames(  ),  ...
this.DictObj.getDataTypeNames(  ) ];
newName = sl.interface.dictionaryApp.utils.getUniqueName(  ...
curNode.Name, protectedNames );
srcObj = curNode.getDataObject(  );
copiedObj = this.addEntryForSourceObj( newName, srcObj );
if curNode.hasPlatformProperties(  ) &&  ...
isa( copiedObj, class( curNode.getInterfaceDictElement(  ) ) )

sl.interface.dictionaryApp.utils.copyPlatformProperties( this.DictObj,  ...
curNode.getInterfaceDictElement(  ), copiedObj );
end 
end 
end 
end 

methods ( Access = protected )
function this = AbstractArchTabAdapter( dictObj, platformKind, studio, listObj )
R36
dictObj( 1, 1 )Simulink.interface.Dictionary;
platformKind
studio sl.interface.dictionaryApp.StudioApp;
listObj sl.interface.dictionaryApp.list.List;
end 
this.DictObj = dictObj;
this.PlatformKind = platformKind;
this.Studio = studio;
this.ListObj = listObj;
end 

function elementName = getDefaultElementName( ~, parentBus )
startName = 'Element';
protectedNames = { parentBus.Elements.Name };
elementName = sl.interface.dictionaryApp.tab.AbstractTabAdapter. ...
calcUniqueName( startName, protectedNames );
end 

function busObj = createDefaultBus( this )


busObj = Simulink.Bus;
busElement = Simulink.BusElement;
busElement.Name = this.getDefaultElementName( busObj );
busObj.Elements = busElement;
end 
end 

methods ( Abstract, Access = protected )
entry = getEntry( this, entryName );
end 

methods ( Static, Access = public )
function tabAdapter = getTabAdapter( dictObj, platformKind, tabId, studio, listObj )
R36
dictObj( 1, 1 )Simulink.interface.Dictionary;
platformKind;
tabId( 1, : )char;
studio sl.interface.dictionaryApp.StudioApp;
listObj sl.interface.dictionaryApp.list.List;
end 
switch tabId
case 'InterfacesTab'
tabAdapter =  ...
sl.interface.dictionaryApp.tab.InterfacesTabAdapter(  ...
dictObj, platformKind, studio, listObj );
case 'DataTypesTab'
tabAdapter =  ...
sl.interface.dictionaryApp.tab.DataTypesTabAdapter(  ...
dictObj, platformKind, studio, listObj );
case 'ConstantsTab'
tabAdapter =  ...
sl.interface.dictionaryApp.tab.ConstantsTabAdapter(  ...
dictObj, platformKind, studio, listObj );
otherwise 
assert( false, 'Unexpected tab id when retrieving tab adapter' );
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpNPV2A9.p.
% Please follow local copyright laws when handling this file.

