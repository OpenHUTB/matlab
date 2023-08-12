classdef ( Abstract )DataTypeNode < sl.interface.dictionaryApp.node.DesignNode & matlab.mixin.Heterogeneous




methods ( Static, Access = public )
function node = getDataTypeNode( interfaceDictObj, dictObj, platformKind, studio )
R36
interfaceDictObj( 1, 1 )Simulink.interface.dictionary.DataType;
dictObj( 1, 1 )Simulink.interface.Dictionary;
platformKind sl.interface.dict.mapping.PlatformMappingKind
studio sl.interface.dictionaryApp.StudioApp;
end 

if isa( interfaceDictObj, 'Simulink.interface.dictionary.StructType' )
node = sl.interface.dictionaryApp.node.StructTypeNode(  ...
interfaceDictObj, dictObj, platformKind, studio );
elseif isa( interfaceDictObj, 'Simulink.interface.dictionary.ValueType' )
node = sl.interface.dictionaryApp.node.ValueTypeNode(  ...
interfaceDictObj, dictObj, platformKind, studio );
elseif isa( interfaceDictObj, 'Simulink.interface.dictionary.AliasType' )
node = sl.interface.dictionaryApp.node.AliasTypeNode(  ...
interfaceDictObj, dictObj, platformKind, studio );
elseif isa( interfaceDictObj, 'Simulink.interface.dictionary.EnumType' )
node = sl.interface.dictionaryApp.node.EnumTypeNode(  ...
interfaceDictObj, dictObj, platformKind, studio );
else 
assert( false, 'Unexpected data type object' )
end 
end 
end 

methods ( Access = protected )

function propertyNames = getPlatformProperties( ~ )

propertyNames = containers.Map(  );
end 
end 

methods ( Access = public )
function propVal = getPropValue( this, propName )
propName = this.getRealPropName( propName );
if strcmp( propName,  ...
sl.interface.dictionaryApp.node.PackageString.NameProp )
propVal = this.InterfaceDictElement.Name;
else 
assert( this.isGenericProperty( propName ), 'No platform properties on data types yet' );
ddContents = this.DictObj.getDesignDataContents(  );
entryName = this.InterfaceDictElement.Name;
realPropName = this.getRealPropName( propName );
propVal = ddContents.getDDEntryPropertyValue( entryName, realPropName );
end 
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpd93p4y.p.
% Please follow local copyright laws when handling this file.

