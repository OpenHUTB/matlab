classdef SLBusInterfaceBuilder < handle




properties ( Access = private )
M3IModel;
M3IInterfacePkg;
MaxShortNameLength;
end 

methods 
function this = SLBusInterfaceBuilder( m3iModel )
import autosar.mm.util.XmlOptionsAdapter;

this.M3IModel = m3iModel;
this.ensureInterfacePackageCreated( openTransaction = true );
this.MaxShortNameLength = autosar.ui.utils.getAutosarMaxShortNameLength( this.M3IModel );
end 

function m3iInterface = createM3IInterface( this, busName, busObj )


this.ensureInterfacePackageCreated( openTransaction = false );
if isa( busObj, 'Simulink.Bus' )

interfaceMetaClass = Simulink.metamodel.arplatform.interface.SenderReceiverInterface.MetaClass;
m3iInterface = this.createDataInterface( this.M3IInterfacePkg, interfaceMetaClass,  ...
busName, busObj );
else 

assert( isa( busObj, 'Simulink.ServiceBus' ), 'Unexpected bus type: ', class( busObj ) );
m3iInterface = this.createClientServerInterface( busName, busObj );
end 
end 

function updateM3IInterface( this, m3iInterface, busName, busObj )


import autosar.mm.sl2mm.SLBusInterfaceBuilder


busElemNames = { busObj.Elements.Name };
m3iElems = SLBusInterfaceBuilder.getM3IInterfaceElements( m3iInterface );


isMultiElementInterface = isa( m3iElems, 'M3I.SequenceOfClassObject' );
interfaceElemNames = {  };
if isMultiElementInterface
interfaceElemNames = m3i.mapcell( @( x )x.Name, m3iElems );
else 

if m3iElems.isvalid(  )
interfaceElemNames = { m3iElems.Name };
end 
end 

if numel( busElemNames ) > numel( interfaceElemNames )

if isMultiElementInterface
[ newElemName, idx ] = setdiff( busElemNames, interfaceElemNames );
assert( length( newElemName ) == 1, 'can only add one element per transaction!' );
m3iNewElem = this.createM3IInterfaceElement( m3iInterface, newElemName{ 1 } );
m3iElems.insert( idx, m3iNewElem );
else 

if ( numel( busElemNames ) == 1 ) && ( numel( interfaceElemNames ) == 0 )
m3iNewElem = this.createM3IInterfaceElement( m3iInterface, busElemNames{ 1 } );
m3iInterface.( autosar.mm.ModelMetaData.InterfaceToElementsPropName( class( m3iInterface ) ) ) = m3iNewElem;
end 
end 
elseif numel( busElemNames ) < numel( interfaceElemNames )

[ deletedElemName, idx ] = setdiff( interfaceElemNames, busElemNames );
assert( length( deletedElemName ) == 1, 'can only delete one element per transaction!' );
if isMultiElementInterface
m3iElems.at( idx ).destroy;
else 
if m3iElems.isvalid(  ) && strcmp( m3iElems.Name, deletedElemName )
m3iElems.destroy(  );
end 
end 
else 

if isMultiElementInterface
for elemIdx = 1:length( busObj.Elements )
m3iElems.at( elemIdx ).Name = busObj.Elements( elemIdx ).Name;
end 
else 
if m3iElems.isvalid(  )
m3iElems.Name = busObj.Elements( 1 ).Name;
end 
end 
end 


m3iInterface.Name = busName;
end 

function m3iInterfaceOut = cloneM3IInterfaceToDifferentKind( this, m3iInterfaceIn,  ...
newInterfaceKind, busName, busObj, interfaceElemPropNames )



interfaceMetaClass = Simulink.metamodel.arplatform.interface.( newInterfaceKind ).MetaClass;
m3iInterfaceOut = this.createDataInterface( m3iInterfaceIn.containerM3I, interfaceMetaClass,  ...
busName, busObj );
m3iInterfaceOut.IsService = m3iInterfaceIn.IsService;




if ~isempty( interfaceElemPropNames ) &&  ...
~strcmp( newInterfaceKind, 'ModeSwitchInterface' )
m3iElemsIn = m3iInterfaceIn.DataElements;
m3iElemsOut = m3iInterfaceOut.DataElements;
for elemIdx = 1:m3iElemsIn.size(  )
for propIdx = 1:length( interfaceElemPropNames )
prop = interfaceElemPropNames{ propIdx };
propVal = m3iElemsIn.at( elemIdx ).( prop );
if isa( propVal, 'M3I.Object' ) && ~propVal.isvalid(  )
continue ;
end 
m3iElemsOut.at( elemIdx ).( prop ) = m3iElemsIn.at( elemIdx ).( prop );
end 
end 
end 
end 
end 

methods ( Static )
function [ isCompatible, MException ] = checkInterfaceCompatibleWithBusObject( busName, busValue, interfaceKind )
R36
busName
busValue

interfaceKind{ mustBeMember( interfaceKind,  ...
{ 'SenderReceiverInterface', 'NvDataInterface', 'ModeSwitchInterface' } ) }
end 

isCompatible = true;
MException = [  ];

try 
switch ( interfaceKind )
case 'ModeSwitchInterface'
if ( length( busValue.Elements ) ~= 1 ) ||  ...
~Simulink.data.isSupportedEnumClass( strrep( busValue.Elements( 1 ).DataType, 'Enum: ', '' ) ) ||  ...
~( busValue.Elements( 1 ).Dimensions == 1 )
DAStudio.error( 'autosarstandard:dictionary:BusObjectNotCompatibleWithMSInterface',  ...
busName );
end 
otherwise 


end 
catch ME
isCompatible = false;
MException = ME;
end 
end 
end 

methods ( Access = private )
function m3iInterface = createDataInterface( this, m3iPkg, interfaceMetaClass, name, busObj )
import autosar.mm.sl2mm.SLBusInterfaceBuilder

interfaceQName = interfaceMetaClass.qualifiedName;
interfaceFcn = str2func( interfaceQName );
m3iInterface = interfaceFcn( this.M3IModel );
m3iInterface.Name = name;
m3iPkg.packagedElement.append( m3iInterface );

elemPropName = autosar.mm.ModelMetaData.InterfaceToElementsPropName( class( m3iInterface ) );
elemMetaClassName = autosar.mm.ModelMetaData.InterfaceToElementsMetaClass( class( m3iInterface ) );

if strcmp( interfaceQName, 'Simulink.metamodel.arplatform.interface.ModeSwitchInterface' )
assert( length( busObj.Elements ) == 1, 'ModeSwitchInterface can only have 1 element.' )
elementFcn = str2func( elemMetaClassName );
m3iInterface.( elemPropName ) = elementFcn( this.M3IModel );
m3iInterface.( elemPropName ).Name = busObj.Elements( 1 ).Name;
else 
for i = 1:length( busObj.Elements )
autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(  ...
m3iInterface, m3iInterface.( elemPropName ),  ...
busObj.Elements( i ).Name, elemMetaClassName );
end 
end 
end 

function m3iInterface = createClientServerInterface( this, name, busObj )


m3iInterface = Simulink.metamodel.arplatform.interface.ClientServerInterface( this.M3IModel );
m3iInterface.Name = name;
this.M3IInterfacePkg.packagedElement.append( m3iInterface );

for elemIdx = 1:length( busObj.Elements )
fcnObj = busObj.Elements( elemIdx );
m3iOperation = autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(  ...
m3iInterface, m3iInterface.Operations,  ...
fcnObj.Name,  ...
'Simulink.metamodel.arplatform.interface.Operation' );

for argIdx = 1:length( fcnObj.Arguments )
argument = fcnObj.Arguments( argIdx );
m3iArg = autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(  ...
m3iOperation, m3iOperation.Arguments,  ...
argument.Name,  ...
'Simulink.metamodel.arplatform.interface.ArgumentData' );
if any( strcmp( argument.Name, fcnObj.getOutputArgumentNames(  ) ) )
m3iArg.Direction = Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.Out;
end 
end 
end 
end 

function ensureInterfacePackageCreated( this, namedargs )
R36
this
namedargs.openTransaction = true;
end 

m3iRoot = this.M3IModel.RootPackage.front(  );
interfacePackage = m3iRoot.InterfacePackage;
if isempty( interfacePackage )
interfacePackage = autosar.mm.util.XmlOptionsDefaultPackages.InterfacesPackage;
m3iRoot.InterfacePackage = interfacePackage;
end 
m3iPkg = autosar.mm.Model.getArPackage( this.M3IModel, interfacePackage );
if isempty( m3iPkg )
if namedargs.openTransaction
tran = autosar.utils.M3ITransaction( this.M3IModel, DisableListeners = true );
end 
m3iPkg = autosar.mm.Model.getOrAddARPackage( this.M3IModel,  ...
interfacePackage );

if namedargs.openTransaction
tran.commit(  );
end 
end 
this.M3IInterfacePkg = m3iPkg;
end 
end 

methods ( Static, Access = private )
function m3iElements = getM3IInterfaceElements( m3iInterface )
import autosar.mm.sl2mm.SLBusInterfaceBuilder
m3iElements = m3iInterface.( autosar.mm.ModelMetaData.InterfaceToElementsPropName( class( m3iInterface ) ) );
end 

function m3iElement = createM3IInterfaceElement( m3iInterface, elementName )
import autosar.mm.sl2mm.SLBusInterfaceBuilder
elementClass = autosar.mm.ModelMetaData.InterfaceToElementsMetaClass( class( m3iInterface ) );
elementFcn = str2func( elementClass );
m3iElement = elementFcn( m3iInterface.rootModel );
m3iElement.Name = elementName;
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpFXcsci.p.
% Please follow local copyright laws when handling this file.

