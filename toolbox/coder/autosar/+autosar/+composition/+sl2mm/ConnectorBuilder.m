classdef ConnectorBuilder < handle





properties ( SetAccess = immutable, GetAccess = private )
TopModelName;
CompositionSys;
M3IModel;
M3IComposition;
AllDictsInterfaceNames;
end 

properties ( Access = private )
AssemblyConnectors;
DelegationConnectors;
end 


properties ( Dependent )
MaxShortNameLength;
end 

properties ( Constant, Access = private )

CompPrototypeMetaClass = 'Simulink.metamodel.arplatform.composition.ComponentPrototype';
AssemblyMetaClass = 'Simulink.metamodel.arplatform.composition.AssemblyConnector';
AssemblyProviderMetaClass = 'Simulink.metamodel.arplatform.instance.CompositionPPortInstanceRef';
AssemblyRequesterMetaClass = 'Simulink.metamodel.arplatform.instance.CompositionRPortInstanceRef';
DelegationMetaClass = 'Simulink.metamodel.arplatform.composition.DelegationConnector';
DelegationInnerRPortMetaClass = 'Simulink.metamodel.arplatform.instance.CompositionRPortInstanceRef';
DelegationInnerPPortMetaClass = 'Simulink.metamodel.arplatform.instance.CompositionPPortInstanceRef';
end 


methods 
function maxShortNameLength = get.MaxShortNameLength( this )
maxShortNameLength = get_param( this.TopModelName, 'AutosarMaxShortNameLength' );
end 
end 

methods 


function this = ConnectorBuilder( compositionSys, AllDictsInterfaceNames )



this.TopModelName = bdroot( compositionSys );
this.CompositionSys = compositionSys;
this.AllDictsInterfaceNames = AllDictsInterfaceNames;
this.M3IModel = autosar.api.Utils.m3iModel( this.TopModelName );

isTopComposition = strcmp( this.TopModelName, compositionSys );
if isTopComposition
this.M3IComposition = autosar.api.Utils.m3iMappedComponent( this.TopModelName );
else 
this.M3IComposition = autosar.composition.studio.CompBlockUtils.getM3IComp( compositionSys );
end 
end 


function build( this )




autosarcore.unregisterListenerCB( this.M3IModel );
rlCleanup = onCleanup( @(  )autosar.ui.utils.registerListenerCB( this.M3IModel ) );


trans = M3I.Transaction( this.M3IModel );


this.syncComponentQualifiedNames(  );


this.collectConnectorsInfo(  );


this.buildMetaModel(  );


trans.commit(  );
end 
end 

methods ( Access = private )


function buildMetaModel( this )


for idx = 1:length( this.AssemblyConnectors )
this.findOrCreateAssemblyConnector( this.AssemblyConnectors( idx ) );
end 


for idx = 1:length( this.DelegationConnectors )
this.findOrCreateDelegationConnector( this.DelegationConnectors( idx ) );
end 




this.assignCompositionPortInterfaces(  );
end 

function syncComponentQualifiedNames( this )







compBlocks = autosar.composition.Utils.findCompBlocks( this.CompositionSys );
for blkIdx = 1:length( compBlocks )
compBlock = compBlocks{ blkIdx };
[ isLinked, compMdl ] = autosar.composition.Utils.isCompBlockLinked( compBlock );
if isLinked
if ~bdIsLoaded( compMdl )
load_system( compMdl );
end 


m3iCompTypeSrc = autosar.api.Utils.m3iMappedComponent( compMdl );
assert( m3iCompTypeSrc.isvalid(  ), 'invalid m3iCompType for %s', compMdl );
m3iCompProto = autosar.composition.Utils.findM3ICompPrototypeForCompBlock( compBlock );
assert( m3iCompProto.isvalid(  ), 'invalid m3iCompProto for %s', compBlock );
m3iCompTypeDst = m3iCompProto.Type;
assert( m3iCompTypeDst.isvalid(  ), 'invalid m3iCompType for %s', compBlock );


compQNameSrc = autosar.api.Utils.getQualifiedName( m3iCompTypeSrc );
compQNameDst = autosar.api.Utils.getQualifiedName( m3iCompTypeDst );
if ~strcmp( compQNameSrc, compQNameDst )
autosar.api.Utils.syncComponentQualifiedName( m3iCompTypeDst,  ...
compQNameDst, compQNameSrc );
end 
end 
end 
end 

function m3iConnector = findOrCreateDelegationConnector( this, connectorSpec )



m3iDelegationConnectors = m3i.filter( @( x ) ...
isa( x, 'Simulink.metamodel.arplatform.composition.DelegationConnector' ),  ...
this.M3IComposition.Connectors );

matchedExistingConnector = false;
for k = 1:length( m3iDelegationConnectors )
m3iDelegationConnector = m3iDelegationConnectors{ k };
if connectorSpec.IsInbound
if strcmp( connectorSpec.InnerCompPrototypeName, m3iDelegationConnector.InnerPort.ComponentPrototype.Name ) &&  ...
isa( m3iDelegationConnector.InnerPort, this.DelegationInnerRPortMetaClass ) &&  ...
strcmp( connectorSpec.InnerPortPrototypeQName, autosar.api.Utils.getQualifiedName( m3iDelegationConnector.InnerPort.RequiredPort ) ) &&  ...
strcmp( connectorSpec.OuterPortPrototypeName, m3iDelegationConnector.OuterPort.Name )
matchedExistingConnector = true;
break ;
end 
else 
if strcmp( connectorSpec.InnerCompPrototypeName, m3iDelegationConnector.InnerPort.ComponentPrototype.Name ) &&  ...
isa( m3iDelegationConnector.InnerPort, this.DelegationInnerPPortMetaClass ) &&  ...
strcmp( connectorSpec.InnerPortPrototypeQName, autosar.api.Utils.getQualifiedName( m3iDelegationConnector.InnerPort.ProvidedPort ) ) &&  ...
strcmp( connectorSpec.OuterPortPrototypeName, m3iDelegationConnector.OuterPort.Name )
matchedExistingConnector = true;
break ;
end 
end 
end 

if matchedExistingConnector
m3iConnector = m3iDelegationConnector;
return 
end 

connectorName = connectorSpec.calculateConnectorName( this.MaxShortNameLength );
m3iConnector =  ...
autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(  ...
this.M3IComposition, this.M3IComposition.Connectors, connectorName, this.DelegationMetaClass );


portMetaClass = connectorSpec.InnerCompM3IPort.MetaClass.qualifiedName;
portPropName = autosar.composition.sl2mm.ConnectorBuilder.getPortPropertyNameFromMetaClass( portMetaClass );
[ componentQName, innerPortName ] = autosar.utils.splitQualifiedName( connectorSpec.InnerPortPrototypeQName );
m3iComponent = autosar.mm.Model.findChildByName( this.M3IModel, componentQName );
if connectorSpec.IsInbound

m3iConnector.InnerPort = eval( sprintf( '%s(this.M3IModel)', this.DelegationInnerRPortMetaClass ) );
m3iConnector.InnerPort.RequiredPort = autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(  ...
m3iComponent, m3iComponent.( portPropName ), innerPortName, portMetaClass );
else 

m3iConnector.InnerPort = eval( sprintf( '%s(this.M3IModel)', this.DelegationInnerPPortMetaClass ) );
m3iConnector.InnerPort.ProvidedPort = autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(  ...
m3iComponent, m3iComponent.( portPropName ), innerPortName, portMetaClass );
end 

m3iCompProto =  ...
autosar.mm.sl2mm.ModelBuilder.findInSequenceNamedItem(  ...
this.M3IComposition, this.M3IComposition.Components,  ...
connectorSpec.InnerCompPrototypeName, this.CompPrototypeMetaClass );
m3iConnector.InnerPort.ComponentPrototype = m3iCompProto;



m3iConnector.OuterPort = autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(  ...
this.M3IComposition, this.M3IComposition.( portPropName ), connectorSpec.OuterPortPrototypeName, portMetaClass );




if connectorSpec.InnerCompM3IPort.Interface.isvalid(  )
innerPortInterfaceQName = autosar.api.Utils.getQualifiedName( connectorSpec.InnerCompM3IPort.Interface );
m3iConnector.OuterPort.Interface = autosar.mm.Model.findChildByName( this.M3IModel, innerPortInterfaceQName );
elseif ~m3iConnector.OuterPort.Interface.isvalid(  )



DAStudio.warning( 'autosarstandard:validation:Composition_CannotInferInterface',  ...
[ this.CompositionSys, '/', m3iConnector.OuterPort.Name ] );
end 






autosar.composition.sl2mm.ConnectorBuilder.removeDuplicatePortsNotOfType(  ...
this.M3IComposition, connectorSpec.OuterPortPrototypeName, portMetaClass );


m3iDesc = autosar.mm.util.DescriptionHelper.createOrUpdateM3IDescription(  ...
this.M3IModel, m3iConnector.desc, connectorSpec.SLLineDescription );
if ~isempty( m3iDesc )
m3iConnector.desc = m3iDesc;
end 
end 

function m3iConnector = findOrCreateAssemblyConnector( this, connectorSpec )

import autosar.composition.sl2mm.ConnectorBuilder;



m3iAssemblyConnectors = m3i.filter( @( x ) ...
isa( x, 'Simulink.metamodel.arplatform.composition.AssemblyConnector' ),  ...
this.M3IComposition.Connectors );
for k = 1:length( m3iAssemblyConnectors )
m3iAssemblyConnector = m3iAssemblyConnectors{ k };
if strcmp( connectorSpec.ProviderCompPrototypeName, m3iAssemblyConnector.Provider.ComponentPrototype.Name ) &&  ...
strcmp( connectorSpec.ProviderPortPrototypeQName, autosar.api.Utils.getQualifiedName( m3iAssemblyConnector.Provider.ProvidedPort ) ) &&  ...
strcmp( connectorSpec.RequesterCompPrototypeName, m3iAssemblyConnector.Requester.ComponentPrototype.Name ) &&  ...
strcmp( connectorSpec.RequesterPortPrototypeQName, autosar.api.Utils.getQualifiedName( m3iAssemblyConnector.Requester.RequiredPort ) )
m3iConnector = m3iAssemblyConnector;
return ;
end 
end 



connectorName = connectorSpec.calculateConnectorName( this.MaxShortNameLength );
m3iConnector =  ...
autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(  ...
this.M3IComposition, this.M3IComposition.Connectors, connectorName, this.AssemblyMetaClass );


m3iConnector.Provider = eval( sprintf( '%s(this.M3IModel)', this.AssemblyProviderMetaClass ) );
[ componentQName, providerPortName ] = autosar.utils.splitQualifiedName( connectorSpec.ProviderPortPrototypeQName );
m3iComponent = autosar.mm.Model.findChildByName( this.M3IModel, componentQName );



m3iProviderPort = ConnectorBuilder.findM3IProviderPort(  ...
m3iComponent, providerPortName );
m3iConnector.Provider.ProvidedPort = m3iProviderPort;
m3iCompProto =  ...
autosar.mm.sl2mm.ModelBuilder.findInSequenceNamedItem(  ...
this.M3IComposition, this.M3IComposition.Components,  ...
connectorSpec.ProviderCompPrototypeName, this.CompPrototypeMetaClass );
m3iConnector.Provider.ComponentPrototype = m3iCompProto;


m3iConnector.Requester = eval( sprintf( '%s(this.M3IModel)', this.AssemblyRequesterMetaClass ) );
[ componentQName, requesterPortName ] = autosar.utils.splitQualifiedName( connectorSpec.RequesterPortPrototypeQName );
m3iComponent = autosar.mm.Model.findChildByName( this.M3IModel, componentQName );



m3iRequesterPort = ConnectorBuilder.findM3IRequesterPort(  ...
m3iComponent, requesterPortName );
m3iConnector.Requester.RequiredPort = m3iRequesterPort;
m3iCompProto =  ...
autosar.mm.sl2mm.ModelBuilder.findInSequenceNamedItem(  ...
this.M3IComposition, this.M3IComposition.Components,  ...
connectorSpec.RequesterCompPrototypeName, this.CompPrototypeMetaClass );
m3iConnector.Requester.ComponentPrototype = m3iCompProto;


m3iDesc = autosar.mm.util.DescriptionHelper.createOrUpdateM3IDescription(  ...
this.M3IModel, m3iConnector.desc, connectorSpec.SLLineDescription );
if ~isempty( m3iDesc )
m3iConnector.desc = m3iDesc;
end 
end 

function collectConnectorsInfo( this )


compBlocks = autosar.composition.Utils.findCompBlocks( this.CompositionSys );
compositeInports = autosar.composition.Utils.findCompositeInports( this.CompositionSys );

slSignalLines = [  ];
for blkIdx = 1:length( compBlocks )
slSignalLines = [ slSignalLines
autosar.composition.sl2mm.ConnectorBuilder ...
.findCompositionSignalLinesFromSrcBlock( compBlocks{ blkIdx } ) ];%#ok<AGROW>
end 


for blkIdx = 1:length( compositeInports )
slSignalLines = [ slSignalLines
autosar.composition.sl2mm.ConnectorBuilder ...
.findCompositionSignalLinesFromSrcBlock( compositeInports{ blkIdx } ) ];%#ok<AGROW>
end 


for lineIdx = 1:length( slSignalLines )
slSignalLine = slSignalLines( lineIdx );
srcBlkH = get_param( slSignalLine.getSrcPortHandle(  ), 'SrcBlockHandle' );
dstBlkH = get_param( slSignalLine.getDstPortHandle(  ), 'DstBlockHandle' );
srcBlkType = get_param( srcBlkH, 'BlockType' );
dstBlkType = get_param( dstBlkH, 'BlockType' );
isAssembly = any( strcmp( srcBlkType, { 'SubSystem', 'ModelReference' } ) ) &&  ...
any( strcmp( dstBlkType, { 'SubSystem', 'ModelReference' } ) );
if isAssembly
srcPortH = get( slSignalLine.getSrcPortHandle(  ), 'SrcPortHandle' );
portNum = get_param( srcPortH, 'PortNumber' );
portType = get_param( srcPortH, 'PortType' );
parentBlock = get_param( srcPortH, 'Parent' );

portType( 1 ) = upper( portType( 1 ) );
slPort = autosar.composition.sl2mm.ConnectorBuilder.findSLPortBlockFromPortNum(  ...
parentBlock, portType, portNum );
slPort = slPort{ 1 };
m3iProviderPort = autosar.composition.sl2mm.ConnectorBuilder.findARPortMappedToSLPort(  ...
parentBlock, slPort );
providerPortQName = autosar.api.Utils.getQualifiedName( m3iProviderPort );
providerCompProtoName = get_param( srcBlkH, 'Name' );

dstPortH = get( slSignalLine.getDstPortHandle(  ), 'DstPortHandle' );
portNum = get_param( dstPortH, 'PortNumber' );
portType = get_param( dstPortH, 'PortType' );


parentBlock = get_param( dstPortH, 'Parent' );
portType( 1 ) = upper( portType( 1 ) );
slPort = autosar.composition.sl2mm.ConnectorBuilder.findSLPortBlockFromPortNum(  ...
parentBlock, portType, portNum );
slPort = slPort{ 1 };

m3iRequesterPort = autosar.composition.sl2mm.ConnectorBuilder.findARPortMappedToSLPort(  ...
parentBlock, slPort );
requesterPortQName = autosar.api.Utils.getQualifiedName( m3iRequesterPort );
requesterCompProtoName = get_param( dstBlkH, 'Name' );
slLineDescription = get_param( slSignalLine.getLineHandle, 'Description' );
assemblyConnector = autosar.composition.sl2mm.private.AssemblyConnector(  ...
providerCompProtoName, providerPortQName,  ...
requesterCompProtoName, requesterPortQName, slLineDescription );
this.AssemblyConnectors = [ this.AssemblyConnectors, assemblyConnector ];
else 
isOutBound = any( strcmp( srcBlkType, { 'SubSystem', 'ModelReference' } ) ) &&  ...
strcmp( dstBlkType, 'Outport' );
isInBound = strcmp( srcBlkType, 'Inport' ) &&  ...
any( strcmp( dstBlkType, { 'SubSystem', 'ModelReference' } ) );
isDelegation = isOutBound || isInBound;

if isDelegation
if isOutBound
srcPortH = get( slSignalLine.getSrcPortHandle(  ), 'SrcPortHandle' );
portNum = get_param( srcPortH, 'PortNumber' );


parentBlock = get_param( srcPortH, 'Parent' );
innerSlPort = autosar.composition.sl2mm.ConnectorBuilder.findSLPortBlockFromPortNum(  ...
parentBlock, 'Outport', portNum );
innerSlPort = innerSlPort{ 1 };
innerM3IPort = autosar.composition.sl2mm.ConnectorBuilder.findARPortMappedToSLPort(  ...
parentBlock, innerSlPort );
innerCompProtoName = get_param( srcBlkH, 'Name' );


outerPortName = get_param( dstBlkH, 'PortName' );

else 
dstPortH = get( slSignalLine.getDstPortHandle(  ), 'DstPortHandle' );
portNum = get_param( dstPortH, 'PortNumber' );


parentBlock = get_param( dstPortH, 'Parent' );
innerSlPort = autosar.composition.sl2mm.ConnectorBuilder.findSLPortBlockFromPortNum(  ...
parentBlock, 'Inport', portNum );
innerSlPort = innerSlPort{ 1 };

innerM3IPort = autosar.composition.sl2mm.ConnectorBuilder.findARPortMappedToSLPort(  ...
parentBlock, innerSlPort );
innerCompProtoName = get_param( dstBlkH, 'Name' );


outerPortName = get_param( srcBlkH, 'PortName' );
end 

innerPortQName = autosar.api.Utils.getQualifiedName( innerM3IPort );
slLineDescription = get_param( slSignalLine.getLineHandle, 'Description' );
delegationConnector = autosar.composition.sl2mm.private.DelegationConnector(  ...
innerCompProtoName, innerPortQName,  ...
outerPortName, isInBound, innerM3IPort, slLineDescription );
this.DelegationConnectors = [ this.DelegationConnectors, delegationConnector ];
end 
end 
end 
end 

function assignCompositionPortInterfaces( this )



if isempty( this.AllDictsInterfaceNames )



return ;
end 

compositionH = get_param( this.CompositionSys, 'Handle' );
compositePortBlks = [ autosar.composition.Utils.findCompositeInports( compositionH ); ...
autosar.composition.Utils.findCompositeOutports( compositionH ) ];



datadict = get_param( this.TopModelName, 'DataDictionary' );
ddConn = Simulink.data.dictionary.open( datadict );
designDataSection = ddConn.getSection( 'Design Data' );

for portIdx = 1:length( compositePortBlks )
slPortName = getfullname( compositePortBlks( portIdx ) );
m3iPort = autosar.composition.Utils.findM3IPortForCompositePort( slPortName );



[ isUsingBusObj, busObjName ] = autosar.simulink.bep.Utils.isBEPUsingBusObject( slPortName );
if isUsingBusObj
interfaceName = autosar.utils.StripPrefix( busObjName );
if any( strcmp( interfaceName, this.AllDictsInterfaceNames ) )


ddEntry = designDataSection.getEntry( interfaceName );
idict = Simulink.interface.dictionary.open( ddEntry.DataSource );
mapppingSyncer = idict.getPlatformMappingSyncer( 'AUTOSARClassic' );
interfaceObj = idict.getInterface( interfaceName );
m3iInterface = mapppingSyncer.getMappedToM3IObj( interfaceObj );
m3iPort.Interface = m3iInterface;
end 
end 
end 
end 
end 

methods ( Static )
function destroyM3IConnectors( m3iModel )







m3iConnectors = autosar.mm.Model.findObjectByMetaClass( m3iModel,  ...
Simulink.metamodel.arplatform.composition.Connector.MetaClass,  ...
true, true );
for i = 1:m3iConnectors.size(  )
m3iConnector = m3iConnectors.at( i );
if m3iConnector.isvalid(  )
m3iConnector.destroy(  );
end 
end 
end 
end 

methods ( Static, Access = public )
function slPortBlocks = findSLPortBlockFromPortNum( parentSys, portType, portNum )






parentSysFullName = getfullname( parentSys );
assert( isnumeric( portNum ), 'expect integer value for portNum' );
assert( any( strcmp( portType, { 'Inport', 'Outport' } ) ), 'unexpected portType %s.', portType );



fcnCallInportsHidden = isequal( slfeature( 'SoftwareModelingAutosar' ), 0 ) &&  ...
strcmp( get_param( parentSysFullName, 'Type' ), 'block' ) &&  ...
strcmp( get_param( parentSysFullName, 'BlockType' ), 'ModelReference' ) &&  ...
autosar.composition.Utils.isModelInCompositionDomain( bdroot( parentSysFullName ) );


if strcmp( get_param( parentSysFullName, 'Type' ), 'block' ) &&  ...
strcmp( get_param( parentSysFullName, 'BlockType' ), 'ModelReference' )
parentSysFullName = get_param( parentSysFullName, 'ModelName' );
if ~bdIsLoaded( parentSysFullName )
load_system( parentSysFullName );
end 
end 

if strcmp( portType, 'Inport' ) && fcnCallInportsHidden




slDataPorts = find_system( parentSysFullName, 'SearchDepth', 1,  ...
'BlockType', portType, 'OutputFunctionCall', 'off' );
[ ~, sortAccordingToPortNum ] = sort( str2double( get_param( slDataPorts, 'Port' ) ) );
slDataPortsSorted = slDataPorts( sortAccordingToPortNum );



portNames = get_param( slDataPortsSorted, 'PortName' );
[ ~, idx ] = unique( portNames, 'stable' );
slDataPortsFiltered = slDataPortsSorted( idx );
slPortBlocksFiltered = slDataPortsFiltered{ portNum };



slPortBlockPortName = get_param( slPortBlocksFiltered, 'PortName' );
slPortBlocks = slDataPorts( strcmp( slPortBlockPortName,  ...
get_param( slDataPorts, 'PortName' ) ) );
else 

slPortBlocks = find_system( parentSysFullName, 'SearchDepth', 1,  ...
'BlockType', portType, 'Port', num2str( portNum ) );

assert( length( unique( get_param( slPortBlocks, 'PortName' ) ) ) == 1,  ...
'found multiple sl ports that have same port num but different portName!' );
end 

assert( ~isempty( slPortBlocks ), 'could not find Simulink %s block with portNum "%d" in "%s".',  ...
portType, portNum, parentSysFullName );
end 

function slSignalLines = findCompositionSignalLinesFromSrcBlock( srcBlockH, namedargs )




R36
srcBlockH
namedargs.TraverseThroughAdapterBlocks = true;
end 

import autosar.composition.sl2mm.ConnectorBuilder

blockType = get_param( srcBlockH, 'BlockType' );
assert( any( strcmp( blockType, { 'ModelReference', 'SubSystem', 'Inport' } ) ),  ...
'Cannot mark connections for unsupported block Type %s.', blockType );

slSignalLines = [  ];
parentName = get_param( srcBlockH, 'Parent' );

blockPC = get_param( srcBlockH, 'PortConnectivity' );
for pcIdx = 1:length( blockPC )
if isempty( blockPC( pcIdx ).DstBlock )
continue ;
end 



[ dstBlkHandles, dstPortNums ] =  ...
ConnectorBuilder.findDestinationPorts( blockPC( pcIdx ), namedargs.TraverseThroughAdapterBlocks );

sourcePort = [ get_param( srcBlockH, 'Name' ), '/', blockPC( pcIdx ).Type ];
for dstBlkIdx = 1:length( dstBlkHandles )
dstBlkHandle = dstBlkHandles( dstBlkIdx );
dstPortNum = dstPortNums( dstBlkIdx );

dstBlkType = get_param( dstBlkHandle, 'BlockType' );
switch ( dstBlkType )
case { 'ModelReference', 'SubSystem' }

dstPort = [ get_param( dstBlkHandle, 'Name' ), '/', num2str( dstPortNum + 1 ) ];
slSignalLines = [ slSignalLines
autosar.composition.mm2sl.SLSignalLine( parentName, sourcePort, dstPort ) ];%#ok<AGROW>
case 'Outport'

dstPort = [ get_param( dstBlkHandle, 'Name' ), '/1' ];
slSignalLines = [ slSignalLines
autosar.composition.mm2sl.SLSignalLine( parentName, sourcePort, dstPort ) ];%#ok<AGROW>
otherwise 

end 
end 
end 
end 
end 

methods ( Static, Access = private )

function [ dstBlkHandles, dstPortNums ] = findDestinationPorts( portConnectivity, traverseThroughAdapterBlocks )




import autosar.composition.sl2mm.ConnectorBuilder

dstBlkHandles = [  ];
dstPortNums = [  ];

blkHandles = portConnectivity.DstBlock;
if isempty( blkHandles )
return ;
end 

portNums = portConnectivity.DstPort;

for dstBlkIdx = 1:length( blkHandles )
dstBlkHandle = blkHandles( dstBlkIdx );
dstPortNum = portNums( dstBlkIdx );

if traverseThroughAdapterBlocks && autosar.composition.Utils.isAdapterBlock( dstBlkHandle )


ph = get_param( dstBlkHandle, 'PortHandles' );
assert( length( ph.Outport ) == 1, 'Adapter block should only have 1 output port!' );
adapterBlockPC = get_param( dstBlkHandle, 'PortConnectivity' );
for pcIdx = 1:length( adapterBlockPC )

[ dstBlkHandle, dstPortNum ] = ConnectorBuilder.findDestinationPorts(  ...
adapterBlockPC( pcIdx ), traverseThroughAdapterBlocks );
dstBlkHandles = [ dstBlkHandles, dstBlkHandle ];%#ok<AGROW>
dstPortNums = [ dstPortNums, dstPortNum ];%#ok<AGROW>
end 
else 
dstBlkHandles = [ dstBlkHandles, dstBlkHandle ];%#ok<AGROW>
dstPortNums = [ dstPortNums, dstPortNum ];%#ok<AGROW>
end 
end 
end 

function propName = getPortPropertyNameFromMetaClass( portMetaClass )
if strcmp( portMetaClass, 'Simulink.metamodel.arplatform.port.DataReceiverPort' )
propName = 'ReceiverPorts';
elseif strcmp( portMetaClass, 'Simulink.metamodel.arplatform.port.DataSenderPort' )
propName = 'SenderPorts';
elseif strcmp( portMetaClass, 'Simulink.metamodel.arplatform.port.DataSenderReceiverPort' )
propName = 'SenderReceiverPorts';
elseif strcmp( portMetaClass, 'Simulink.metamodel.arplatform.port.ModeReceiverPort' )
propName = 'ModeReceiverPorts';
elseif strcmp( portMetaClass, 'Simulink.metamodel.arplatform.port.ModeSenderPort' )
propName = 'ModeSenderPorts';
elseif strcmp( portMetaClass, 'Simulink.metamodel.arplatform.port.ClientPort' )
propName = 'ClientPorts';
elseif strcmp( portMetaClass, 'Simulink.metamodel.arplatform.port.ServerPort' )
propName = 'ServerPorts';
elseif strcmp( portMetaClass, 'Simulink.metamodel.arplatform.port.NvDataReceiverPort' )
propName = 'NvReceiverPorts';
elseif strcmp( portMetaClass, 'Simulink.metamodel.arplatform.port.NvDataSenderPort' )
propName = 'NvSenderPorts';
elseif strcmp( portMetaClass, 'Simulink.metamodel.arplatform.port.NvDataSenderReceiverPort' )
propName = 'NvSenderReceiverPorts';
elseif strcmp( portMetaClass, 'Simulink.metamodel.arplatform.port.ParameterReceiverPort' )
propName = 'ParameterReceiverPorts';
elseif strcmp( portMetaClass, 'Simulink.metamodel.arplatform.port.TriggerReceiverPort' )
propName = 'TriggerReceiverPorts';
else 
assert( false, 'Unexpected port meta class: %s', portMetaClass );
end 
end 



function m3iPort = findARPortMappedToSLPort( parentBlock, slPortName )
if strcmp( get_param( parentBlock, 'BlockType' ), 'ModelReference' )
modelName = get_param( parentBlock, 'ModelName' );
mapping = autosar.api.Utils.modelMapping( modelName );
slPortType = get_param( slPortName, 'BlockType' );
if strcmp( slPortType, 'Inport' )
blockMappings = mapping.Inports;
else 
blockMappings = mapping.Outports;
end 
blockMapping = blockMappings.findobj( 'Block', slPortName );
assert( ~isempty( blockMapping ),  ...
'Simulink port %s is not mapped! Map the Simulink port first.', slPortName );
ARPortName = blockMapping.MappedTo.Port;
m3iComp = autosar.api.Utils.m3iMappedComponent( modelName );
m3iPortSeq = autosar.mm.Model.findObjectByName( m3iComp, ARPortName );
assert( m3iPortSeq.size(  ) == 1, 'Could not find ARPortName %s in model %s!',  ...
ARPortName, modelName );
m3iPort = m3iPortSeq.at( 1 );
else 
m3iPort = autosar.composition.Utils.findM3IPortForCompositePort( slPortName );
end 
end 

function m3iProviderPort = findM3IProviderPort( m3iComponent, providerPortName )
if isa( m3iComponent, 'Simulink.metamodel.arplatform.component.AdaptiveApplication' )
pPortMetaClass = 'Simulink.metamodel.arplatform.port.ServiceProvidedPort';
pPortMemberName = 'ProvidedPorts';
else 
pPortMetaClass = 'Simulink.metamodel.arplatform.port.DataSenderPort';
pPortMemberName = 'SenderPorts';
end 
m3iProviderPort = autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(  ...
m3iComponent, m3iComponent.( pPortMemberName ), providerPortName, pPortMetaClass );
end 

function m3iRequiredPort = findM3IRequesterPort( m3iComponent, requesterPortName )
if isa( m3iComponent, 'Simulink.metamodel.arplatform.component.AdaptiveApplication' )
rPortMetaClass = 'Simulink.metamodel.arplatform.port.ServiceRequiredPort';
rPortMemberName = 'RequiredPorts';
else 
rPortMetaClass = 'Simulink.metamodel.arplatform.port.DataReceiverPort';
rPortMemberName = 'ReceiverPorts';
end 
m3iRequiredPort = autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(  ...
m3iComponent, m3iComponent.( rPortMemberName ), requesterPortName, rPortMetaClass );
end 

function removeDuplicatePortsNotOfType( m3iComponent, portName, portMetaClass )


m3iPortSeq = autosar.mm.Model.findObjectByName( m3iComponent, portName );
for i = 1:m3iPortSeq.size(  )
if ~isa( m3iPortSeq.at( i ), portMetaClass )
m3iPortSeq.at( i ).destroy(  );
end 
end 
end 
end 
end 






% Decoded using De-pcode utility v1.2 from file /tmp/tmpLSna__.p.
% Please follow local copyright laws when handling this file.

