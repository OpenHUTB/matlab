function [ value, entries ] = getTypeAndAvailableTypes( intrfOrintrfElem, typesToInclude )




R36
intrfOrintrfElem( 1, 1 )
typesToInclude{ mustBeMember( typesToInclude, [ "interface", "all" ] ) } = "all"
end 

separator = DAStudio.message( 'SystemArchitecture:PropertyInspector:Separator' );
defaultEntries = systemcomposer.internal.getBuiltInDataTypeList(  );

isPhysical = false;
if isa( intrfOrintrfElem, 'systemcomposer.architecture.model.interface.ValueTypeInterface' )
if ( intrfOrintrfElem.isAnonymous )
interfaceWrapper = systemcomposer.internal.getWrapperForImpl( intrfOrintrfElem );
if isempty( interfaceWrapper.Model )
mfModel = mf.zero.getModel( intrfOrintrfElem );
interfaceCatalog = systemcomposer.architecture.model.interface.InterfaceCatalog.getInterfaceCatalog( mfModel );
else 
interfaceCatalog = interfaceWrapper.Model.InterfaceDictionary.getImpl;
end 
else 
interfaceCatalog = intrfOrintrfElem.getCatalog(  );
end 
value = intrfOrintrfElem.p_Type;
interface = intrfOrintrfElem;
elseif isa( intrfOrintrfElem, 'systemcomposer.architecture.model.interface.AtomicPhysicalInterface' )
assert( intrfOrintrfElem.isAnonymous );
interfaceWrapper = systemcomposer.internal.getWrapperForImpl( intrfOrintrfElem );
interfaceCatalog = interfaceWrapper.Model.InterfaceDictionary.getImpl;
value = intrfOrintrfElem.p_Type;
interface = intrfOrintrfElem;
isPhysical = true;
defaultEntries = simscape.internal.availableDomains(  )';
elseif isa( intrfOrintrfElem, 'systemcomposer.architecture.model.interface.DataElement' )
interface = intrfOrintrfElem.p_ParentDataInterface;
if ( interface.isAnonymous )
interfaceWrapper = systemcomposer.internal.getWrapperForImpl( interface );
interfaceCatalog = interfaceWrapper.Model.InterfaceDictionary.getImpl;
else 
interfaceCatalog = interface.getCatalog(  );
end 
value = intrfOrintrfElem.getType(  );
elseif isa( intrfOrintrfElem, 'systemcomposer.architecture.model.interface.PhysicalElement' )
interface = intrfOrintrfElem.p_PhysicalInterface;
interfaceCatalog = interface.getCatalog(  );
defaultEntries = simscape.internal.availableDomains(  )';
value = intrfOrintrfElem.getType(  );
isPhysical = true;
elseif isa( intrfOrintrfElem, 'systemcomposer.architecture.model.swarch.FunctionArgument' )
element = intrfOrintrfElem.p_FunctionElement;
interface = element.getInterface(  );
interfaceCatalog = interface.getCatalog(  );
value = intrfOrintrfElem.getType(  );
else 
error( 'Unsupported type' );
end 



if ( interfaceCatalog.getStorageContext(  ) == systemcomposer.architecture.model.interface.Context.DICTIONARY )
ddConn = Simulink.data.dictionary.open( [ interfaceCatalog.getStorageSource(  ), '.sldd' ] );
[ isInterfaceDictInClosure, interfaceDicts ] =  ...
Simulink.interface.dictionary.internal.DictionaryClosureUtils.hasInterfaceDictInClosure( ddConn.filepath );
if isInterfaceDictInClosure
entries = {  };
for dictIdx = 1:length( interfaceDicts )
interfaceDict = interfaceDicts{ dictIdx };
dictAPI = Simulink.interface.dictionary.open( interfaceDict );
includeBusTypes = ~isa( intrfOrintrfElem, 'systemcomposer.architecture.model.interface.ValueTypeInterface' );
entries = [ entries, Simulink.interface.dictionary.internal.Utils.getDataTypeDisplayNames( dictAPI, IncludeBusTypes = includeBusTypes ) ];%#ok<AGROW> 
end 
return ;
end 
end 

if ( isa( intrfOrintrfElem, 'systemcomposer.architecture.model.interface.PhysicalInterface' ) ||  ...
isa( intrfOrintrfElem, 'systemcomposer.architecture.model.interface.PhysicalElement' ) )

intrfs = interfaceCatalog.getPortInterfacesInClosure( 'Physical' );
else 
intrfs = interfaceCatalog.getPortInterfacesInClosure( 'Data' );
end 
intrfs( arrayfun( @( x )x == interface, intrfs ) ) = [  ];

function str = loc_getStringForTypedInterface( intrf )
str = [  ];
if ~isempty( intrf )
if isa( intrf, 'systemcomposer.architecture.model.interface.CompositeDataInterface' ) ||  ...
isa( intrf, 'systemcomposer.architecture.model.interface.CompositePhysicalInterface' )
str = [ 'Bus: ', intrf.getName ];
elseif isa( intrf, 'systemcomposer.architecture.model.interface.ValueTypeInterface' )
str = [ 'ValueType: ', intrf.getName ];
else 

assert( isa( intrf, 'systemcomposer.architecture.model.swarch.ServiceInterface' ) );
end 
end 
end 

baseWSBuses = getAvailableTypesInBaseWorkspace( 'Bus' );
baseWSValueTypes = getAvailableTypesInBaseWorkspace( 'ValueType' );
if ~isempty( intrfs ) && ~isa( intrfOrintrfElem, 'systemcomposer.architecture.model.interface.ValueTypeInterface' )
buses = arrayfun( @( i )loc_getStringForTypedInterface( i ), intrfs, 'UniformOutput', false );
buses = buses( ~cellfun( 'isempty', buses ) );
buses = unique( [ buses, baseWSBuses, baseWSValueTypes ] );
else 
buses = unique( [ baseWSBuses, baseWSValueTypes ] );
end 

enums = {  };
try 
if ( ~isPhysical && interfaceCatalog.getStorageContext(  ) == systemcomposer.architecture.model.interface.Context.DICTIONARY )
enums = systemcomposer.getEnumerationsFromDictionary( ddConn );
if ( ~isempty( enums ) )
enums = [ separator, cellfun( @( c )[ 'Enum: ', c ], enums, 'UniformOutput', false ) ];
end 
ddConn.close(  );
end 
catch 

end 

if typesToInclude == "interface"
entries = buses;
else 
if ~isempty( buses )
buses = [ separator, buses ];
end 
aliasTypes = {  };
if ~isPhysical
aliasTypes = getAliasTypes( interfaceCatalog );
if ~isempty( aliasTypes )
aliasTypes = [ separator, aliasTypes ];
end 
end 
entries = [ defaultEntries, buses, enums, aliasTypes ];
end 
end 

function aliasTypeNames = getAliasTypes( interfaceCatalog )
typeCatalog = systemcomposer.property.TypeCatalog.getCatalog( mf.zero.getModel( interfaceCatalog ) );
aliasTypeNames = {  };
if ~isempty( typeCatalog )
modeledTypes = typeCatalog.p_ModeledDataTypes.toArray;
aliasTypes = modeledTypes( arrayfun( @( x )isa( x, 'systemcomposer.property.AliasType' ), modeledTypes ) );
aliasTypeNames = { aliasTypes.p_Name };
end 
end 


function types = getAvailableTypesInBaseWorkspace( kind )

R36
kind{ mustBeMember( kind, [ "Bus", "ValueType" ] ) }
end 

slDataType = [ 'Simulink.', kind ];

bws = Simulink.data.internal.BaseWorkspace;
vars = bws.identifyVisibleVariablesByClass( slDataType );
names = { vars.Name };
types = cellfun( @( n )[ kind, ': ', n ], names, 'UniformOutput', false );

end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpDTGVFJ.p.
% Please follow local copyright laws when handling this file.

