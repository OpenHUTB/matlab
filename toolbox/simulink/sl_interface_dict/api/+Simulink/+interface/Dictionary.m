classdef Dictionary < handle




properties ( Access = private )

DesignDataContents Simulink.interface.dictionary.internal.DesignDataContents
ProfilesManagerMap containers.Map
PlatformMappingSyncerMap containers.Map
end 

properties ( Hidden, SetAccess = private )
SLDDConn Simulink.dd.Connection
ZCMFModel


DictImpl sl.interface.dict.InterfaceDictionary
end 

properties ( Dependent, SetAccess = private )
DictionaryFileName
Interfaces( 0, : )Simulink.interface.dictionary.PortInterface
DataTypes( 0, : )Simulink.interface.dictionary.DataType
end 

properties ( Hidden, Dependent, SetAccess = private )
Constants( 0, : )Simulink.interface.dictionary.Constant
end 

methods ( Hidden )
function this = Dictionary( namedargs )



R36
namedargs.DictFileName{ mustBeTextScalar }
end 
dictFileName = namedargs.DictFileName;
this.DictImpl = sl.interface.dict.api.openInterfaceDictionary( dictFileName );
this.SLDDConn = Simulink.dd.open( dictFileName );
this.DesignDataContents = Simulink.interface.dictionary.internal.DesignDataContents( dictFileName );
this.ProfilesManagerMap = containers.Map(  );
this.PlatformMappingSyncerMap = containers.Map(  );


this.ZCMFModel = systemcomposer.openDictionary( this.filepath(  ) );
end 
end 

methods ( Hidden, Static, Access = public )
function platformNames = getBuiltInPlatformNames(  )

platformNames = {  };
if autosarinstalled
platformNames{ end  + 1 } = 'AUTOSARClassic';
end 
end 
end 

methods 
function interface = addDataInterface( this, interfaceName, namedargs )









R36
this Simulink.interface.Dictionary
interfaceName{ mustBeTextScalar, mustBeNonzeroLengthText }
namedargs.SimulinkBus{ mustBeA( namedargs.SimulinkBus, 'Simulink.Bus' ) } = Simulink.Bus
end 



removeHint = this.addInterfaceHint( interfaceName );%#ok<NASGU>

isModelContext = false;
[ ~, sourceName ] = fileparts( this.DictionaryFileName );
systemcomposer.BusObjectManager.AddInterface( sourceName, isModelContext,  ...
convertStringsToChars( interfaceName ), namedargs.SimulinkBus );

interface = this.getInterface( interfaceName );
end 

function removeInterface( this, interfaceName )



R36
this Simulink.interface.Dictionary
interfaceName{ mustBeTextScalar, mustBeNonzeroLengthText }
end 


this.checkIsInterface( interfaceName );

this.ZCMFModel.removeInterface( interfaceName );
end 

function interface = getInterface( this, interfaceName )



R36
this Simulink.interface.Dictionary
interfaceName{ mustBeTextScalar, mustBeNonzeroLengthText }
end 


this.checkIsInterface( interfaceName );

interface = this.getInterfaceWrapper( interfaceName );
end 

function interfaceNames = getInterfaceNames( this )





interfaceCatalog = this.getZCInterfaceCatalog(  );
interfaceNames = interfaceCatalog.getPortInterfaceNamesInClosure( 'CompositeDataInterface' );
if slfeature( 'AllowServiceBusInInterfaceDictionary' )
interfaceNames = [ interfaceNames, interfaceCatalog.getPortInterfaceNamesInClosure( 'Service' ) ];
end 
if slfeature( 'AllowConnectionBusInInterfaceDictionary' )
interfaceNames = [ interfaceNames, interfaceCatalog.getPortInterfaceNamesInClosure( 'Physical' ) ];
end 
interfaceNames = sort( interfaceNames );
end 

function dataType = addAliasType( this, dtName, namedargs )









R36
this Simulink.interface.Dictionary
dtName{ mustBeTextScalar, mustBeNonzeroLengthText }
namedargs.BaseType{ mustBeA( namedargs.BaseType, { 'char', 'string',  ...
'Simulink.interface.dictionary.DataType' } ) } = 'double'
end 

if isa( namedargs.BaseType, 'Simulink.interface.dictionary.DataType' )
baseTypeStr = namedargs.BaseType.getTypeString(  );
else 
baseTypeStr = namedargs.BaseType;
end 

aliasType = Simulink.AliasType( baseTypeStr );
this.DesignDataContents.addDataType( dtName, aliasType );
dataType = this.getDataType( dtName );
end 

function dataType = addEnumType( this, dtName )



R36
this Simulink.interface.Dictionary
dtName{ mustBeTextScalar, mustBeNonzeroLengthText }
end 

enumDef = Simulink.data.dictionary.EnumTypeDefinition;
this.DesignDataContents.addDataType( dtName, enumDef );
dataType = this.getDataType( dtName );
end 

function dataType = addValueType( this, dtName, namedargs )



R36
this Simulink.interface.Dictionary
dtName{ mustBeTextScalar, mustBeNonzeroLengthText }
namedargs.SimulinkValueType{ mustBeA( namedargs.SimulinkValueType, 'Simulink.ValueType' ) } = Simulink.ValueType
end 

this.DesignDataContents.addDataType( dtName, namedargs.SimulinkValueType );
dataType = this.getDataType( dtName );
end 

function dataType = addStructType( this, dtName, namedargs )



R36
this Simulink.interface.Dictionary
dtName{ mustBeTextScalar, mustBeNonzeroLengthText }
namedargs.SimulinkBus{ mustBeA( namedargs.SimulinkBus, 'Simulink.Bus' ) } = Simulink.Bus
end 

this.DesignDataContents.addDataType( dtName, namedargs.SimulinkBus );
dataType = this.getDataType( dtName );
end 

function removeDataType( this, dtName )



R36
this Simulink.interface.Dictionary
dtName{ mustBeTextScalar, mustBeNonzeroLengthText }
end 
this.DesignDataContents.removeDataType( dtName );
end 

function dataType = getDataType( this, dtName )



R36
this Simulink.interface.Dictionary
dtName{ mustBeTextScalar, mustBeNonzeroLengthText }
end 
dataType = this.getDataTypeWrapper( dtName );
end 

function dataTypeNames = getDataTypeNames( this )





dataTypeNames = this.getZCTypesCatalog.p_ModeledDataTypes.keys;
valueTypeNames = this.getZCInterfaceCatalog(  ).getPortInterfaceNamesInClosure( 'ValueTypeInterface' );

dataTypeNames = sort( [ dataTypeNames, valueTypeNames ] );
end 

function platformMapping = getPlatformMapping( this, platformName )







platformMapping = [  ];
if this.hasPlatformMapping( platformName )
platformMapping =  ...
Simulink.interface.dictionary.internal.PlatformMapping.getPlatformMapping(  ...
platformName, this );
end 
end 

function save( this )


this.SLDDConn.saveChanges(  );
end 

function value = isDirty( this )


value = this.SLDDConn.hasUnsavedChanges;
end 

function show( this )


pb = Simulink.internal.ScopedProgressBar(  ...
DAStudio.message( 'autosarstandard:editor:LoadInterfaceDictProgressUI' ) );
c = onCleanup( @(  )delete( pb ) );
sl.interface.dictionaryApp.StudioApp.open( this );
end 

function showChanges( this )







dd = Simulink.data.dictionary.open( this.DictionaryFileName );
dd.showChanges(  );
end 

function close( this, namedargs )








R36
this
namedargs.DiscardChanges = false
end 

if ~this.DictImpl.isvalid(  )

return 
end 

ddFilePath = this.filepath(  );
if namedargs.DiscardChanges
Simulink.data.dictionary.closeAll( this.DictionaryFileName, '-discard' );
else 
Simulink.data.dictionary.closeAll( this.DictionaryFileName );
end 
sl.interface.dict.api.closeInterfaceDictionary( ddFilePath );
end 

function importFromBaseWorkspace( this )










importHelper = Simulink.interface.dictionary.internal.ImportToDictionaryHelper( this.DictionaryFileName );
importHelper.importFromBaseWks( 'KeepDictionary' );
end 

function importFromFile( this, fileName )










R36
this Simulink.interface.Dictionary
fileName{ mustBeTextScalar, mustBeNonzeroLengthText }
end 

if ~endsWith( fileName, '.mat' )

error( message( 'interface_dictionary:api:InvalidMATFileExtension', fileName ) );
end 

importHelper = Simulink.interface.dictionary.internal.ImportToDictionaryHelper( this.DictionaryFileName );
importHelper.importFromMATFile( fileName, 'KeepDictionary' );
end 

end 

methods 

function interfaces = get.Interfaces( this )
interfaceNames = this.getInterfaceNames(  );
interfaces = Simulink.interface.dictionary.DataInterface.empty( numel( interfaceNames ), 0 );
for i = 1:numel( interfaceNames )
interfaces( i ) = this.getInterface( interfaceNames{ i } );
end 
end 

function datatypes = get.DataTypes( this )
dataTypeNames = this.getDataTypeNames(  );
datatypes = Simulink.interface.dictionary.DataType.empty( numel( dataTypeNames ), 0 );
for i = 1:numel( dataTypeNames )
datatypes( i ) = this.getDataType( dataTypeNames{ i } );
end 
end 

function constants = get.Constants( this )
constantNames = this.DesignDataContents.getConstantNames(  );
constants = Simulink.interface.dictionary.Constant.empty( numel( constantNames ), 0 );
for i = 1:numel( constantNames )
constants( i ) = this.getConstant( constantNames{ i } );
end 
end 

function value = get.DictionaryFileName( this )
[ ~, f, e ] = fileparts( this.filepath );
value = [ f, e ];
end 
end 

methods ( Hidden )


function ddEntry = getDDEntryObject( this, entryName )
ddEntry = this.DesignDataContents.getEntryObject( entryName );
end 

function setDDEntryValue( this, entryName, value )
this.DesignDataContents.setEntryValue( entryName, value );
end 

function dataType = addDataTypeUsingSLObj( this, dtName, slObj )










this.DesignDataContents.addDataType( dtName, slObj );
dataType = this.getDataType( dtName );
end 

function ddContents = getDesignDataContents( this )
ddContents = this.DesignDataContents;
end 

function slddConn = getSLDDConn( this )
slddConn = this.SLDDConn;
end 

function value = filepath( this )
assert( this.DictImpl.isvalid, 'Expected Interface Dictionary implementation to be valid.' );
value = this.DictImpl.getDictionaryFilePath(  );
end 

function value = isOpen( this )
value = this.SLDDConn.isOpen(  );
end 

function isempty = isEmpty( this )
isempty = all( size( this.Interfaces ) == 0 ) && all( size( this.DataTypes ) == 0 );
end 

function platformMapping = addPlatformMapping( this, platformName, namedargs )








R36
this
platformName
namedargs.PlatformSource = '';
end 

if strcmp( platformName, 'AUTOSARClassic' )

assert( isempty( namedargs.PlatformSource ),  ...
'For AUTOSARClassic PlatformSource should not be specified.' );
else 
assert( ~isempty( namedargs.PlatformSource ),  ...
'PlatformSource must be specified for platforms other than AUTOSARClassic' );

this.addPlatformSource( namedargs.PlatformSource );
end 

this.ensurePlatformMappingCreatedFor( platformName );
platformMapping = this.getPlatformMapping( platformName );
end 

function hasMapping = hasPlatformMapping( this, platformName )





if strcmp( platformName, 'AUTOSARClassic' )
platformKind = sl.interface.dict.mapping.PlatformMappingKind( platformName );
mappingManager = this.DictImpl.MappingManager;
hasMapping = mappingManager.hasMappingFor( platformKind );
else 


hasMapping = any( strcmp( this.getPlatformNames(  ), platformName ) );
end 
end 

function removePlatformMapping( this, platformName )
if ~this.hasPlatformMapping( platformName )
return ;
end 

if any( strcmp( platformName, Simulink.interface.Dictionary.getBuiltInPlatformNames(  ) ) )


syncer = this.getPlatformMappingSyncer( platformName );
syncer.removePlatformMapping(  );


this.PlatformMappingSyncerMap.remove( platformName );
else 


platformSources = this.DictImpl.PlatformSources;
for pIdx = 1:platformSources.Size
sdpSlddFile = platformSources.at( pIdx ).DefinitionFile;
mf0SDP = this.getMF0SoftwarePlatform( sdpSlddFile );
if strcmp( platformName, mf0SDP.Name )
this.removePlatformSource( sdpSlddFile );
break 
end 
end 
end 
end 

function constant = addConstant( this, name )
this.checkConstantSupport(  );
ddEntry = this.DesignDataContents.addConstant( name );
constant = Simulink.interface.dictionary.Constant( this, ddEntry.UUID );
end 

function removeConstant( this, name )
this.checkConstantSupport(  );
this.DesignDataContents.removeConstant( name );
end 

function constant = getConstant( this, name )
this.checkConstantSupport(  );
ddEntry = this.DesignDataContents.getConstant( name );
constant = Simulink.interface.dictionary.Constant( this, ddEntry.UUID );
end 

function constantNames = getConstantNames( this )
this.checkConstantSupport(  );
constantNames = this.DesignDataContents.getConstantNames(  );
end 

function platformNames = getPlatformNames( this )

platformNames = {  };
platformNames = [ platformNames, this.getPlatformsNamesMappedToDict(  ) ];



platformNames = [ platformNames, this.getFunctionPlatformNames(  ) ];
end 

function platformNames = getPlatformsNamesMappedToDict( this )


platformNames = keys( this.PlatformMappingSyncerMap );
end 

function platformNames = getFunctionPlatformNames( this )


platformNames = {  };
platformSources = this.DictImpl.PlatformSources;
for pIdx = 1:platformSources.Size
platformDefFile = platformSources.at( pIdx ).DefinitionFile;
mf0SDP = Simulink.interface.Dictionary.getMF0SoftwarePlatform( platformDefFile );
platformNames{ end  + 1 } = mf0SDP.Name;%#ok<AGROW>
end 
end 

function syncer = getPlatformMappingSyncer( this, platformKind )
platformName = char( platformKind );
if ~this.PlatformMappingSyncerMap.isKey( platformName )

this.ensurePlatformMappingCreatedFor( platformName );
end 
syncer = this.PlatformMappingSyncerMap( platformName );
end 

function interface = addServiceInterface( this, interfaceName )
R36
this Simulink.interface.Dictionary
interfaceName{ mustBeTextScalar, mustBeNonzeroLengthText }
end 



removeHint = this.addInterfaceHint( interfaceName );%#ok<NASGU>

this.ZCMFModel.addServiceInterface( interfaceName );
interface = this.getInterface( interfaceName );
end 

function interface = addPhysicalInterface( this, interfaceName, namedargs )
R36
this Simulink.interface.Dictionary
interfaceName{ mustBeTextScalar, mustBeNonzeroLengthText }
namedargs.SimulinkConnBus{ mustBeA( namedargs.SimulinkConnBus, 'Simulink.ConnectionBus' ) } = Simulink.ConnectionBus
end 



removeHint = this.addInterfaceHint( interfaceName );%#ok<NASGU>

this.ZCMFModel.addPhysicalInterface( interfaceName, namedargs.SimulinkConnBus );
interface = this.getInterface( interfaceName );
end 
end 

methods ( Access = private )
function ensurePlatformMappingCreatedFor( this, platformName )





if ~strcmp( platformName, 'AUTOSARClassic' )
return 
end 

platformKind = sl.interface.dict.mapping.PlatformMappingKind( platformName );

if this.hasPlatformMapping( platformName )
if ~this.PlatformMappingSyncerMap.isKey( platformName )

this.PlatformMappingSyncerMap( platformName ) =  ...
Simulink.interface.dictionary.internal.PlatformMappingSyncer.createSyncer(  ...
this.DictImpl, platformKind );
end 
return ;
end 


if isempty( this.ZCMFModel.getImpl.getProfile( platformName ) )
profileManager = this.getProfileManager( platformKind );
this.ZCMFModel.applyProfile( profileManager.getProfileFilePath(  ) );
end 


platformMappingSyncer =  ...
Simulink.interface.dictionary.internal.PlatformMappingSyncer.createSyncer(  ...
this.DictImpl, platformKind );
this.PlatformMappingSyncerMap( platformName ) = platformMappingSyncer;


platformMappingSyncer.createPlatformMapping(  );
end 

function addPlatformSource( this, sdpSlddFile )



R36
this
sdpSlddFile{ mustBeFile }
end 


Simulink.interface.Dictionary.getMF0SoftwarePlatform( sdpSlddFile );

if this.hasPlatformSource( sdpSlddFile )
return ;
end 

platformSource = this.DictImpl.createIntoPlatformSources(  );
platformSource.DefinitionFile = sdpSlddFile;
end 

function removePlatformSource( this, sdpSlddFile )
[ hasPlatform, platformSource ] = this.hasPlatformSource( sdpSlddFile );
if ~hasPlatform
return ;
end 
platformSource.destroy(  );
end 

function [ hasPlatform, platformSource ] = hasPlatformSource( this, sdpSlddFile )
hasPlatform = false;
platformSource = [  ];
platformSources = this.DictImpl.PlatformSources;
for pIdx = 1:platformSources.Size
if strcmp( sdpSlddFile, platformSources.at( pIdx ).DefinitionFile )
hasPlatform = true;
platformSource = platformSources.at( pIdx );
return ;
end 
end 
end 

function profileManager = getProfileManager( this, platformKind )
platformName = char( platformKind );
if ~this.ProfilesManagerMap.isKey( platformName )
this.ProfilesManagerMap( platformName ) =  ...
Simulink.interface.dictionary.internal.ProfileManager.getManager( platformName );
end 
profileManager = this.ProfilesManagerMap( platformName );
end 

function removeHint = addInterfaceHint( this, interfaceName )





interfaceTracker = this.DictImpl.SLInterfaceTracker;
interfaceTracker.InterfaceNameHints.add( interfaceName );
removeHint = onCleanup( @(  ) ...
interfaceTracker.InterfaceNameHints.remove( interfaceName ) );
end 

function checkIsInterface( this, entryName )



interfaceCatalog = this.getZCInterfaceCatalog(  );
if isempty( interfaceCatalog.getPortInterface( entryName ) )
DAStudio.error( 'interface_dictionary:api:InterfaceDoesNotExist',  ...
this.DictionaryFileName, entryName );
end 
end 

function interface = getInterfaceWrapper( this, interfaceName )
zcInterface = this.ZCMFModel.getInterface( interfaceName );
zcImpl = zcInterface.getImpl(  );
if isa( zcInterface, 'systemcomposer.interface.DataInterface' )
interface = Simulink.interface.dictionary.DataInterface( zcImpl, this.DictImpl );
elseif isa( zcInterface, 'systemcomposer.interface.PhysicalInterface' )
interface = Simulink.interface.dictionary.PhysicalInterface( zcImpl, this.DictImpl );
elseif isa( zcInterface, 'systemcomposer.interface.ServiceInterface' )
interface = Simulink.interface.dictionary.ServiceInterface( zcImpl, this.DictImpl );
else 
assert( false, 'Unexpected interface: %s', class( zcInterface ) );
end 
end 

function dataType = getDataTypeWrapper( this, dtName )
zcImpl = this.getZCTypesCatalog(  ).getModeledDataType( dtName );
if isa( zcImpl, 'systemcomposer.property.AliasType' )
dataType = Simulink.interface.dictionary.AliasType( this, zcImpl );
elseif isa( zcImpl, 'systemcomposer.property.StructDataType' )
dataType = Simulink.interface.dictionary.StructType( this, zcImpl );
elseif isa( zcImpl, 'systemcomposer.property.EnumDataType' )
dataType = Simulink.interface.dictionary.EnumType( this, zcImpl );
else 


valueTypeNames = this.getZCInterfaceCatalog(  ).getPortInterfaceNamesInClosure( 'ValueTypeInterface' );
if any( strcmp( dtName, valueTypeNames ) )
zcImpl = this.ZCMFModel.getInterface( dtName ).getImpl;
dataType = Simulink.interface.dictionary.ValueType( this, zcImpl );
else 
DAStudio.error( 'interface_dictionary:api:DataTypeDoesNotExist',  ...
this.DictionaryFileName, dtName );
end 
end 
end 

function zcImpl = getZCTypeFromCatalog( this, dtName )
zcImpl = this.getZCTypesCatalog(  ).getModeledDataType( dtName );
if isempty( zcImpl )
DAStudio.error( 'interface_dictionary:api:DataTypeDoesNotExist',  ...
this.DictionaryFileName, dtName );
end 
end 

function typesCatalog = getZCTypesCatalog( this )
typesCatalog = this.ZCMFModel.getImpl.getTypeCatalog(  );
end 

function interfaceCatalog = getZCInterfaceCatalog( this )
interfaceCatalog = this.ZCMFModel.getImpl;
end 
end 

methods ( Static, Access = private )
function sdpObj = getMF0SoftwarePlatform( fileName )
hlp = coder.internal.CoderDataStaticAPI.getHelper;
dd = hlp.openDD( fileName );
assert( dd.owner.SoftwarePlatforms.Size == 1,  ...
'%s must contain a valid SDP definition', fileName );
sdpObj = dd.owner.SoftwarePlatforms.at( 1 );
end 

function checkConstantSupport(  )
if ~slfeature( 'InterfaceDictConstants' )
assert( false, 'Constants are not supported.' );
end 
end 
end 
end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmpAWiP6e.p.
% Please follow local copyright laws when handling this file.

