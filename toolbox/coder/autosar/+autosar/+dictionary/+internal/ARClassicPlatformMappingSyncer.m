classdef ARClassicPlatformMappingSyncer < Simulink.interface.dictionary.internal.PlatformMappingSyncer





properties ( Access = private )
M3IModel
SLBusInterfaceBuilder autosar.mm.sl2mm.SLBusInterfaceBuilder
InterfaceDictAPI Simulink.interface.Dictionary
end 

methods 
function this = ARClassicPlatformMappingSyncer( dictImpl )
this@Simulink.interface.dictionary.internal.PlatformMappingSyncer( dictImpl );
this.InterfaceDictAPI = Simulink.interface.dictionary.open(  ...
this.DictImpl.getDictionaryFilePath );


if isempty( this.M3IModel )
this.getOrCreateM3IModel(  );
end 

this.SLBusInterfaceBuilder = autosar.mm.sl2mm.SLBusInterfaceBuilder( this.M3IModel );
end 

function autosarClassicMapping = createPlatformMapping( this )



mdl = mf.zero.getModel( this.DictImpl );
autosarClassicMapping = sl.interface.dict.mapping.AUTOSARClassicMapping( mdl );
this.DictImpl.MappingManager.addMapping( autosarClassicMapping );

this.syncExistingSlddEntries(  );

this.DictImpl.registerObservingListener(  ...
'autosar.dictionary.internal.ARClassicPlatformSLDDListener.observeChanges' );
end 

function removePlatformMapping( this )





if ~isempty( this.M3IModel ) && this.M3IModel.isvalid(  )


autosar.dictionary.Utils.closeDictUIForModelsReferencingSharedM3IModel( this.M3IModel );


tran = autosar.utils.M3ITransaction( this.M3IModel, DisableListeners = true );
autosarcore.unregisterListenerCB( this.M3IModel );
this.M3IModel.destroy(  );
tran.commit(  );


dictFilePath = this.SLDDConn.filespec(  );
Simulink.AutosarDictionary.ModelRegistry.removeEntryFromRegistry( dictFilePath );
end 


if this.DictImpl.MappingManager.hasMappingFor( 'AUTOSARClassic' )
autosarClassicMapping = this.DictImpl.MappingManager.getMappingFor( 'AUTOSARClassic' );
this.DictImpl.MappingManager.deleteMapping( autosarClassicMapping );
end 

this.DictImpl.unregisterObservingListener(  ...
'autosar.dictionary.internal.ARClassicPlatformSLDDListener.observeChanges' );
end 

function syncInterface( this, interfaceName )
this.doSyncInterface( interfaceName, true );
end 

function syncDataType( this, dataTypeName, namedargs )
R36
this
dataTypeName
namedargs.PlatformEntryId = ''
end 
this.doSyncDataType( dataTypeName, PlatformEntryId = namedargs.PlatformEntryId );
end 

function syncConstant( this, constantName, namedargs )
R36
this
constantName
namedargs.DeploymentMethod = sl.interface.dict.mapping.ConstantDeploymentMethod.Auto;
end 
this.doSyncConstant( constantName, DeploymentMethod = namedargs.DeploymentMethod );
end 

function m3iObj = getMappedToM3IObj( this, dictElem )
R36
this
dictElem Simulink.interface.dictionary.BaseElement
end 



if isa( dictElem, 'Simulink.interface.dictionary.InterfaceElement' )
m3iObj = this.getMappedM3IInterfaceElement( dictElem );
else 
[ isEntryAlreadyMapped, entryMapping ] = this.isDDEntryMapped( dictElem.Name );
assert( isEntryAlreadyMapped, '%s is not mapped.', dictElem.Name );
m3iObj = M3I.getObjectById( entryMapping.MappedTo.EntryIdentifier, this.M3IModel );
end 
end 

function propValue = getInterfacePlatformPropValue( this, interfaceObj, propName )



R36
this
interfaceObj Simulink.interface.dictionary.PortInterface
propName
end 


m3iInterface = this.getMappedToM3IObj( interfaceObj );


switch ( propName )
case 'InterfaceKind'
propValue = m3iInterface.MetaClass.name;
case 'Package'
propValue = autosar.api.Utils.getQualifiedName( m3iInterface.containerM3I );
otherwise 
propValue = m3iInterface.( propName );
end 
end 

function setInterfacePlatformProps( this, interfaceObj, propNames, propValues )



R36
this
interfaceObj Simulink.interface.dictionary.PortInterface
propNames
propValues
end 

tran = autosar.utils.M3ITransaction( this.M3IModel, DisableListeners = false );


[ isEntryAlreadyMapped, entryMapping ] = this.isDDEntryMapped( interfaceObj.Name );
assert( isEntryAlreadyMapped, '%s is not mapped.', interfaceObj.Name );
m3iInterface = M3I.getObjectById( entryMapping.MappedTo.EntryIdentifier, this.M3IModel );


interfaceKind = propValues( strcmp( propNames, 'InterfaceKind' ) );
if ~isempty( interfaceKind )
m3iInterface = this.changeInterfaceKind( m3iInterface,  ...
interfaceKind{ : }, interfaceObj, entryMapping );
end 


dataObj = autosar.api.getAUTOSARProperties( this.DictImpl.getDictionaryFilePath );
for i = 1:length( propNames )
propName = propNames{ i };
propValue = propValues{ i };
if strcmp( propName, 'InterfaceKind' )
continue ;
elseif strcmp( propName, 'Package' )
dataObj.moveElement( autosar.api.Utils.getQualifiedName( m3iInterface ), propValue );
else 
m3iInterface.( propNames{ i } ) = propValue;
end 
end 

tran.commit(  );
end 

function [ propNames, propValues ] = getInterfaceElementPlatformProps( this, interfaceElemObj )



R36
this
interfaceElemObj Simulink.interface.dictionary.InterfaceElement
end 

propNames = {  };
propValues = {  };


m3iElement = this.getMappedToM3IObj( interfaceElemObj );
if isa( m3iElement, 'Simulink.metamodel.arplatform.interface.ModeDeclarationGroupElement' )

return ;
end 

if m3iElement.SwAddrMethod.isvalid(  )
swAddrMethod = m3iElement.SwAddrMethod.Name;
else 
swAddrMethod = '';
end 
propNames = { 'SwAddrMethod', 'SwCalibrationAccess', 'DisplayFormat' };
propValues = { swAddrMethod, m3iElement.SwCalibrationAccess.toString(  ), m3iElement.DisplayFormat };
end 

function dataType = getInterfaceElementPlatformPropertyDataType( this, interfaceElemObj, propName )

m3iElement = this.getMappedToM3IObj( interfaceElemObj );
dataType = autosar.ui.metamodel.AttributeUtils.getPropDataType(  ...
m3iElement, propName );
end 

function allowedValues = getInterfaceElementPlatformPropertyAllowedValues( this, interfaceElemObj, propName )

switch propName
case 'DisplayFormat'
allowedValues = '';
case { 'SwCalibrationAccess', 'SwAddrMethod' }

m3iElement = this.getMappedToM3IObj( interfaceElemObj );
allowedValues =  ...
autosar.ui.metamodel.AttributeUtils.getPropAllowedValues(  ...
m3iElement, propName );
otherwise 
assert( false, 'Unexpected property' )
end 
end 


function setInterfaceElementPlatformProps( this, interfaceElemObj, propNames, propValues )



R36
this
interfaceElemObj Simulink.interface.dictionary.InterfaceElement
propNames
propValues
end 


m3iElement = this.getMappedToM3IObj( interfaceElemObj );


dataObj = autosar.api.getAUTOSARProperties( this.DictImpl.getDictionaryFilePath );
elemQName = autosar.api.Utils.getQualifiedName( m3iElement );

propValues =  ...
cellfun( @( x )strrep( x, autosar.ui.metamodel.PackageString.NoneSelection, '' ),  ...
propValues, 'UniformOutput', false );


propValues = this.ensurePropValuesUseQualifiedName( propNames, propValues );

propValuePair = [ propNames, propValues ]';
propValuePair = reshape( propValuePair, 1, numel( propValuePair ) );
dataObj.set( elemQName, propValuePair{ : } );
end 

function mapping = getDictionaryMapping( this )
mapping = this.DictImpl.MappingManager.getMappingFor(  ...
sl.interface.dict.mapping.PlatformMappingKind.AUTOSARClassic );
end 
end 

methods ( Access = private )
function syncExistingSlddEntries( this )

tran = autosar.utils.M3ITransaction( this.M3IModel, DisableListeners = true );


this.syncInterfaces(  );
this.syncDataTypes(  );
this.syncConstants(  );

tran.commit(  );
end 

function getOrCreateM3IModel( this )
dictFilePath = this.SLDDConn.filespec(  );
if ~autosar.dictionary.Utils.isSharedAutosarDictionary( dictFilePath )


newM3IModel = autosar.mm.Model.newM3IModel(  );
autosar.dictionary.Utils.registerM3IModelWithDictionary( newM3IModel, dictFilePath );


tran = M3I.Transaction( newM3IModel );
autosar.mm.util.XmlOptionsDefaultPackages.setAllEmptyXmlOptionsToDefault( dictFilePath );
tran.commit(  );
end 
this.M3IModel = Simulink.AutosarDictionary.ModelRegistry.getOrLoadM3IModel( dictFilePath );


autosar.ui.utils.registerListenerCB( this.M3IModel );
end 

function [ isMapped, entryMapping, slddEntry ] = isDDEntryMapped( this, entryName )
slddEntry = this.InterfaceDictAPI.getDDEntryObject( entryName );
entryMapping = this.getDictionaryMapping(  ).findMappingEntriesByUUID( { slddEntry.UUID } );
isMapped = ~isempty( entryMapping );
end 

function m3iElement = getMappedM3IInterfaceElement( this, interfaceElemObj )



R36
this
interfaceElemObj Simulink.interface.dictionary.InterfaceElement
end 


m3iInterface = this.getMappedToM3IObj( interfaceElemObj.Owner );
if isa( m3iInterface, 'Simulink.metamodel.arplatform.interface.ModeSwitchInterface' )
m3iElement = m3iInterface.ModeGroup;
else 
m3i.mapcell( @( x )x.Name, m3iInterface.DataElements );
m3iElements = m3iInterface.DataElements;
m3iElement = [  ];
for i = 1:m3iElements.size(  )
if strcmp( m3iElements.at( i ).Name, interfaceElemObj.Name )
m3iElement = m3iElements.at( i );
break 
end 
end 
assert( ~isempty( m3iElement ), 'Could not find m3iElement for %s', interfaceElemObj.Name );
end 
end 

function m3iInterfaceOut = changeInterfaceKind( this, m3iInterfaceIn,  ...
newInterfaceKind, interfaceObj, entryMapping )

R36
this
m3iInterfaceIn
newInterfaceKind{ mustBeMember( newInterfaceKind,  ...
{ 'SenderReceiverInterface', 'NvDataInterface', 'ModeSwitchInterface' } ) }
interfaceObj Simulink.interface.dictionary.PortInterface
entryMapping sl.interface.dict.mapping.InterfaceMapping
end 

if strcmp( m3iInterfaceIn.MetaClass.name, newInterfaceKind )
m3iInterfaceOut = m3iInterfaceIn;
return ;
end 

slddBusEntry = this.InterfaceDictAPI.getDDEntryObject( interfaceObj.Name );



[ isCompatible, MException ] = this.SLBusInterfaceBuilder.checkInterfaceCompatibleWithBusObject(  ...
slddBusEntry.Name, slddBusEntry.getValue, newInterfaceKind );

if ~isCompatible
rethrow( MException );
end 






propNames = [  ];
if ~isempty( interfaceObj.Elements )
propNames = this.getInterfaceElementPlatformProps( interfaceObj.Elements( 1 ) );
end 

m3iInterfaceOut = this.SLBusInterfaceBuilder.cloneM3IInterfaceToDifferentKind(  ...
m3iInterfaceIn, newInterfaceKind, slddBusEntry.Name, slddBusEntry.getValue,  ...
propNames );


m3iInterfaceIn.destroy(  );


entryMapping.MappedTo.EntryIdentifier = M3I.SerializeId( m3iInterfaceOut );


this.applyStereotype( interfaceObj.getZCImpl(  ) );
end 

function syncInterfaces( this )
interfaces = this.InterfaceDictAPI.Interfaces;
for i = 1:length( interfaces )
this.doSyncInterface( interfaces( i ).Name, false );
end 
end 

function syncDataTypes( this )
dataTypes = this.InterfaceDictAPI.DataTypes;
for i = 1:length( dataTypes )
this.doSyncDataType( dataTypes( i ).Name );
end 
end 

function syncConstants( this )
constant = this.InterfaceDictAPI.Constants;
for i = 1:length( constant )
this.doSyncConstant( constant( i ).Name );
end 
end 

function m3iInterface = doSyncInterface( this, interfaceName, openM3ITransaction )

slddBusEntry = this.InterfaceDictAPI.getDDEntryObject( interfaceName );
entryValue = slddBusEntry.getValue(  );
if isa( entryValue, 'Simulink.ConnectionBus' )

return ;
end 


if openM3ITransaction
tran = autosar.utils.M3ITransaction( this.M3IModel, DisableListeners = false );
end 




entryMapping = this.getDictionaryMapping(  ).findMappingEntriesByUUID( { slddBusEntry.UUID } );
isEntryAlreadyMapped = ~isempty( entryMapping );

if isEntryAlreadyMapped
m3iInterface = M3I.getObjectById( entryMapping.MappedTo.EntryIdentifier, this.M3IModel );
this.SLBusInterfaceBuilder.updateM3IInterface(  ...
m3iInterface, slddBusEntry.Name, entryValue );
else 

m3iInterface = this.SLBusInterfaceBuilder.createM3IInterface(  ...
slddBusEntry.Name, entryValue );


this.getDictionaryMapping(  ).mapInterface( slddBusEntry.UUID, M3I.SerializeId( m3iInterface ) );


zcInterface = this.InterfaceDictAPI.getInterface( interfaceName ).getZCImpl(  );
this.applyStereotype( zcInterface );
end 

if openM3ITransaction
tran.commit(  );
end 
end 

function doSyncDataType( this, dataTypeName, namedargs )
R36
this
dataTypeName
namedargs.PlatformEntryId = ''
end 


[ isEntryAlreadyMapped, entryMapping, slddEntry ] = this.isDDEntryMapped( dataTypeName );

if isEntryAlreadyMapped



entryMapping.MappedTo.EntryIdentifier = namedargs.PlatformEntryId;
else 

this.getDictionaryMapping(  ).mapDataType(  ...
slddEntry.UUID, namedargs.PlatformEntryId );
end 
end 

function doSyncConstant( this, constantName, namedargs )
R36
this
constantName
namedargs.DeploymentMethod = sl.interface.dict.mapping.ConstantDeploymentMethod.Auto;
end 


[ isEntryAlreadyMapped, constantMapping, slddEntry ] = this.isDDEntryMapped( constantName );

if ~isEntryAlreadyMapped

constantMapping = this.getDictionaryMapping(  ).mapConstant(  ...
slddEntry.UUID, '' );
end 

constantMapping.DeploymentMethod = namedargs.DeploymentMethod;
end 

function propValues = ensurePropValuesUseQualifiedName( this, propNames, propValues )






propsToMetaClassMap = dictionary( 'SwAddrMethod', Simulink.metamodel.arplatform.common.SwAddrMethod.MetaClass );
propsRequireQName = propsToMetaClassMap.keys;



for propName = propsRequireQName
idx = strcmp( propNames, propName );
if ~any( idx )
continue 
end 
oldPropValue = propValues{ idx };
if ~isempty( oldPropValue ) && ~startsWith( oldPropValue, '/' )
m3iObjs = autosar.mm.Model.findObjectByMetaClass( this.M3IModel, propsToMetaClassMap( propName ) );
matchingObjs = m3i.filter( @( x )strcmp( x.Name, oldPropValue ), m3iObjs );
if numel( matchingObjs ) == 1
propValues{ idx } = autosar.api.Utils.getQualifiedName( matchingObjs{ 1 } );
end 
end 
end 
end 

function applyStereotype( this, zcInterface )%#ok<INUSL>
zcInterface.cachedWrapper.applyStereotype( 'AUTOSARClassic.PortInterface' );
end 
end 
end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmpBSTjQs.p.
% Please follow local copyright laws when handling this file.

