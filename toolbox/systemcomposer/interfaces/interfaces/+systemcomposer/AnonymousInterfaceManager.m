classdef AnonymousInterfaceManager < handle




methods ( Static )

function SetSLPortProperty( aPort, prop, propval )

if ( ishandle( aPort ) )
slPortBlock = aPort;
aPort = systemcomposer.utils.getArchitecturePeer( aPort );
else 
slPortBlock = systemcomposer.utils.getSimulinkPeer( aPort );
if isempty( slPortBlock )
return ;
end 
slPortBlock = slPortBlock( 1 );
end 

blkType = get_param( slPortBlock, 'BlockType' );
if strcmp( blkType, 'PMIOPort' )
assert( strcmp( prop, 'Type' ) );
set_param( slPortBlock, 'ConnectionType', [ 'Connection: ', propval ] );
elseif ( strcmpi( get_param( slPortBlock, 'isBusElementPort' ), 'on' ) )
bepTree = systemcomposer.BusObjectManager.fetchTreeNodeObjectForBusElementPort( slPortBlock );
bepTreeRootNode = Simulink.internal.CompositePorts.TreeNode.findNode( bepTree, '' );
bepTreeNode = Simulink.internal.CompositePorts.TreeNode.findNode( bepTree, get_param( slPortBlock, 'Element' ) );

definedByBusOject = ~isempty( bepTreeRootNode.busTypeRootAttrs ) || ~isempty( bepTreeRootNode.busTypeElementAttrs );
if definedByBusOject && ~strcmp( prop, 'Type' )
return ;
end 
switch ( prop )
case 'Type'
if contains( propval, 'Bus: ' )







if isempty( aPort.getPortInterface ) || strcmp( aPort.getPortInterface.p_Dimensions, '1' )
Simulink.internal.CompositePorts.TreeNode.setDimsCL( bepTreeNode, '[1 1]' );
end 
end 
Simulink.internal.CompositePorts.TreeNode.setDataTypeCL( bepTreeNode, propval );
case 'Dimensions'
Simulink.internal.CompositePorts.TreeNode.setDimsCL( bepTreeNode, propval );
case 'Units'
Simulink.internal.CompositePorts.TreeNode.setUnitCL( bepTreeNode, propval );
case 'Complexity'
Simulink.internal.CompositePorts.TreeNode.setComplexityCL( bepTreeNode, upper( propval ) );
case 'Minimum'
Simulink.internal.CompositePorts.TreeNode.setMinCL( bepTreeNode, propval );
case 'Maximum'
Simulink.internal.CompositePorts.TreeNode.setMaxCL( bepTreeNode, propval );
case 'Description'
Simulink.internal.CompositePorts.TreeNode.setDescCL( bepTreeNode, propval );
end 
else 
if ~isempty( aPort.getArchitecture ) && isa( aPort.getArchitecture, 'systemcomposer.architecture.model.sldomain.StateflowArchitecture' )
stateflowRoot = sfroot;
chartId = sfprivate( 'block2chart', get_param( get_param( slPortBlock, 'Parent' ), 'Handle' ) );
chartObj = stateflowRoot.find( '-isa', 'Stateflow.Chart', 'Id', chartId );
dataObj = chartObj.find( { '-isa', 'Stateflow.Data', '-OR', '-isa', 'Stateflow.Message' }, 'Name', get_param( slPortBlock, 'Name' ) );
dataObjProps = dataObj.Props;
switch ( prop )
case 'Type'
dataObj.DataType = propval;
case 'Dimensions'
dataObjProps.Array.Size = propval;
case 'Units'
dataObjProps.Unit.Name = propval;
case 'Complexity'
switch ( propval )
case 'complex'
propval = 'On';
case 'real'
propval = 'Off';
case 'auto'
propval = 'Inherited';
end 
dataObjProps.Complexity = propval;
case 'Minimum'
dataObjProps.Range.Minimum = propval;
case 'Maximum'
dataObjProps.Range.Maximum = propval;
case 'Description'
dataObj.Description = propval;
end 
else 
switch ( prop )
case 'Type'
propname = 'OutDataTypeStr';
case 'Dimensions'
propname = 'PortDimensions';
case 'Units'
propname = 'Unit';
case 'Complexity'
propname = 'SignalType';
case 'Minimum'
propname = 'OutMin';
case 'Maximum'
propname = 'OutMax';
case 'Description'
propname = 'Description';
end 
set_param( slPortBlock, propname, propval );
end 
end 
end 

function ResetInterfaceElementProperties( aPort, varargin )




slPortBlocks = systemcomposer.utils.getSimulinkPeer( aPort );
if isempty( slPortBlocks )
return ;
end 
slPortBlock = slPortBlocks( 1 );

blkType = get_param( slPortBlock, 'BlockType' );

if ( ( nargin == 2 ) && varargin{ 1 } )
if strcmp( blkType, 'PMIOPort' )

allDomains = simscape.internal.availableDomains(  );
set_param( slPortBlock, 'ConnectionType', [ 'Connection: ', allDomains{ 1 } ] );
systemcomposer.internal.arch.internal.processBatchedPluginEvents( bdroot( slPortBlock ) );
elseif ( strcmpi( get_param( slPortBlock, 'isBusElementPort' ), 'on' ) )
if ( numel( slPortBlocks ) > 1 )
for i = 2:numel( slPortBlocks )
delete_block( slPortBlocks( i ) );
end 
systemcomposer.internal.arch.internal.processBatchedPluginEvents( bdroot( slPortBlock ) );
end 
bepTree = systemcomposer.BusObjectManager.fetchTreeNodeObjectForBusElementPort( slPortBlock );
bepTreeRootNode = Simulink.internal.CompositePorts.TreeNode.findNode( bepTree, '' );
Simulink.internal.CompositePorts.TreeNode.setDataTypeCL( bepTreeRootNode, 'double' );
Simulink.internal.CompositePorts.TreeNode.setDimsCL( bepTreeRootNode, '1' );
Simulink.internal.CompositePorts.TreeNode.setUnitCL( bepTreeRootNode, '' );
Simulink.internal.CompositePorts.TreeNode.setComplexityCL( bepTreeRootNode, 'REAL' );
Simulink.internal.CompositePorts.TreeNode.setMinCL( bepTreeRootNode, '[]' );
Simulink.internal.CompositePorts.TreeNode.setMaxCL( bepTreeRootNode, '[]' );
else 
if ~isempty( aPort.getArchitecture ) && isa( aPort.getArchitecture, 'systemcomposer.architecture.model.sldomain.StateflowArchitecture' )
stateflowRoot = sfroot;
chartId = sfprivate( 'block2chart', get_param( get_param( slPortBlock, 'Parent' ), 'Handle' ) );
chartObj = stateflowRoot.find( '-isa', 'Stateflow.Chart', 'Id', chartId );
dataObj = chartObj.find( { '-isa', 'Stateflow.Data', '-OR', '-isa', 'Stateflow.Message' }, 'Name', get_param( slPortBlock, 'Name' ) );
dataObj.DataType = 'double';
else 
set_param( slPortBlock,  ...
'OutDataTypeStr', 'double',  ...
'PortDimensions', '1',  ...
'Unit', '',  ...
'SignalType', 'real',  ...
'OutMin', '[]',  ...
'OutMax', '[]',  ...
'Description', '' );
systemcomposer.internal.arch.internal.processBatchedPluginEvents( bdroot( slPortBlock ) );
end 
end 
else 
if strcmp( blkType, 'PMIOPort' )
set_param( slPortBlock, 'ConnectionType', 'Inherit: auto' );
elseif ( strcmpi( get_param( slPortBlock, 'isBusElementPort' ), 'on' ) )
if ( numel( slPortBlocks ) > 1 )
for i = 2:numel( slPortBlocks )
delete_block( slPortBlocks( i ) );
end 
systemcomposer.internal.arch.internal.processBatchedPluginEvents( bdroot( slPortBlock ) );
end 
set_param( slPortBlock, 'Element', '' );
bepTree = systemcomposer.BusObjectManager.fetchTreeNodeObjectForBusElementPort( slPortBlock );
bepTreeRootNode = Simulink.internal.CompositePorts.TreeNode.findNode( bepTree, '' );
Simulink.internal.CompositePorts.TreeNode.setDataTypeCL( bepTreeRootNode, 'Inherit: auto' );
Simulink.internal.CompositePorts.TreeNode.setDimsCL( bepTreeRootNode, '-1' );
Simulink.internal.CompositePorts.TreeNode.setUnitCL( bepTreeRootNode, 'inherit' );
Simulink.internal.CompositePorts.TreeNode.setComplexityCL( bepTreeRootNode, 'AUTO' );
Simulink.internal.CompositePorts.TreeNode.setMinCL( bepTreeRootNode, '[]' );
Simulink.internal.CompositePorts.TreeNode.setMaxCL( bepTreeRootNode, '[]' );
else 
if ~isempty( aPort.getArchitecture ) && isa( aPort.getArchitecture, 'systemcomposer.architecture.model.sldomain.StateflowArchitecture' )
stateflowRoot = sfroot;
chartId = sfprivate( 'block2chart', get_param( get_param( slPortBlock, 'Parent' ), 'Handle' ) );
chartObj = stateflowRoot.find( '-isa', 'Stateflow.Chart', 'Id', chartId );
dataObj = chartObj.find( { '-isa', 'Stateflow.Data', '-OR', '-isa', 'Stateflow.Message' }, 'Name', get_param( slPortBlock, 'Name' ) );
dataObj.DataType = 'Inherit: Same as Simulink';
dataObj.Props.Array.Size = '-1';
dataObj.Props.Unit.Name = '';
dataObj.Props.Complexity = 'Off';
dataObj.Props.Range.Minimum = '[]';
dataObj.Props.Range.Maximum = '[]';
dataObj.Description = '';
else 
set_param( slPortBlock,  ...
'OutDataTypeStr', 'Inherit: auto',  ...
'PortDimensions', '-1',  ...
'Unit', 'inherit',  ...
'SignalType', 'auto',  ...
'OutMin', '[]',  ...
'OutMax', '[]',  ...
'Description', '' );
end 
end 
end 
end 

function SetupPortInterfaceFromSLPort( mf0Model, archPort, slPortBlock )







if isempty( slPortBlock )
return ;
end 
slPortBlock = slPortBlock( 1 );

if ( strcmpi( get_param( slPortBlock, 'isBusElementPort' ), 'on' ) )
bepTree = systemcomposer.BusObjectManager.fetchTreeNodeObjectForBusElementPort( slPortBlock );
bepTreeRootNode = Simulink.internal.CompositePorts.TreeNode.findNode( bepTree, '' );
type = Simulink.internal.CompositePorts.TreeNode.getDataType( bepTreeRootNode );
units = Simulink.internal.CompositePorts.TreeNode.getUnit( bepTreeRootNode );
dims = Simulink.internal.CompositePorts.TreeNode.getDims( bepTreeRootNode );
complexityEnum = Simulink.internal.CompositePorts.TreeNode.getComplexity( bepTreeRootNode );
if complexityEnum == sl.mfzero.treeNode.Complexity.COMPLEX
complexity = 'complex';
elseif complexityEnum == sl.mfzero.treeNode.Complexity.REAL
complexity = 'real';
else 
complexity = 'auto';
end 
min = Simulink.internal.CompositePorts.TreeNode.getMin( bepTreeRootNode );
max = Simulink.internal.CompositePorts.TreeNode.getMax( bepTreeRootNode );
description = '';
else 
type = get_param( slPortBlock, 'OutDataTypeStr' );
dims = get_param( slPortBlock, 'PortDimensions' );
units = get_param( slPortBlock, 'Unit' );
complexity = get_param( slPortBlock, 'SignalType' );
min = get_param( slPortBlock, 'OutMin' );
max = get_param( slPortBlock, 'OutMax' );
description = get_param( slPortBlock, 'Description' );
end 

txn = mf0Model.beginTransaction(  );
pi = archPort.createAnonymousInterface(  );
pie = pi.getElement( '' );
pie.setType( type );
if pie.hasOwnedType
pie.setDimensions( dims );
pie.setUnits( units );
pie.setComplexity( complexity );
pie.setMinimum( min );
pie.setMaximum( max );
pie.setDescription( description );
end 
txn.commit(  );
end 

function AddInlinedInterfaceElement( aPort, elementName, elemParams )
slPortBlock = systemcomposer.utils.getSimulinkPeer( aPort );
if isempty( slPortBlock )
return ;
end 
slPortBlock = slPortBlock( 1 );

bepTree = systemcomposer.BusObjectManager.fetchTreeNodeObjectForBusElementPort( slPortBlock );
bepTreeRootNode = Simulink.internal.CompositePorts.TreeNode.findNode( bepTree, '' );

hasExistingInlineComposite = false;
intrfUsage = aPort.p_InterfaceUsage;
if ~isempty( intrfUsage )
intrf = intrfUsage.p_AnonymousInterface;
if ~isempty( intrf ) && isa( intrf, 'systemcomposer.architecture.model.interface.CompositeDataInterface' )
hasExistingInlineComposite = true;
if ~isempty( intrf.getElement( elementName ) )
error( message( 'SystemArchitecture:Interfaces:PortInterfaceElementAlreadyExists', elementName, aPort.getName ) );
end 
end 
end 

if ~hasExistingInlineComposite && ~isempty( bepTreeRootNode.signalAttrs )

Simulink.internal.CompositePorts.TreeNode.setDataTypeCL( bepTreeRootNode, 'Inherit: auto' );
end 

if isempty( get_param( slPortBlock, 'Element' ) )
set_param( slPortBlock, 'Element', elementName );
bh = slPortBlock;
else 
aPortWrappper = systemcomposer.internal.getWrapperForImpl( aPort );
if ( aPortWrappper.Direction == systemcomposer.arch.PortDirection.Input )
fullPortName = [ aPortWrappper.Parent.getQualifiedName, '/In1' ];
else 
assert( aPortWrappper.Direction == systemcomposer.arch.PortDirection.Output );
fullPortName = [ aPortWrappper.Parent.getQualifiedName, '/Out1' ];
end 
bh = add_block( slPortBlock, fullPortName, 'MakeNameUnique', 'on', 'Element', elementName );
end 

systemcomposer.internal.arch.internal.processBatchedPluginEvents( bdroot( bh ) );

if ( nargin > 2 )

systemcomposer.AnonymousInterfaceManager.SetSLPortProperty( bh, 'Type', elemParams.Type );
systemcomposer.AnonymousInterfaceManager.SetSLPortProperty( bh, 'Dimensions', elemParams.Dimensions );
systemcomposer.AnonymousInterfaceManager.SetSLPortProperty( bh, 'Units', elemParams.Units );
systemcomposer.AnonymousInterfaceManager.SetSLPortProperty( bh, 'Complexity', elemParams.Complexity );
systemcomposer.AnonymousInterfaceManager.SetSLPortProperty( bh, 'Minimum', elemParams.Minimum );
systemcomposer.AnonymousInterfaceManager.SetSLPortProperty( bh, 'Maximum', elemParams.Maximum );
systemcomposer.AnonymousInterfaceManager.SetSLPortProperty( bh, 'Description', elemParams.Description );
end 
end 

function DeleteInlinedInterfaceElement( aPort, elementName )
slPortBlock = systemcomposer.utils.getSimulinkPeer( aPort );
if isempty( slPortBlock )
return ;
end 
numBusElementPorts = numel( slPortBlock );

if numBusElementPorts == 1
set_param( slPortBlock( 1 ), 'Element', '' );
bh = slPortBlock( 1 );
systemcomposer.internal.arch.internal.processBatchedPluginEvents( bdroot( bh ) );
else 
slPortBlock = slPortBlock( strcmp( get_param( slPortBlock, 'Element' ), elementName ) );
mdlName = bdroot( slPortBlock );

delete_block( slPortBlock );

systemcomposer.internal.arch.internal.processBatchedPluginEvents( mdlName );
end 
end 

function RenameInlinedInterfaceElement( aPort, oldElementName, newElementName )
slPortBlock = systemcomposer.utils.getSimulinkPeer( aPort );
if isempty( slPortBlock )
return ;
end 
slPortBlock = slPortBlock( strcmp( get_param( slPortBlock, 'Element' ), oldElementName ) );
if ~isempty( slPortBlock )
set_param( slPortBlock, 'Element', newElementName );
systemcomposer.internal.arch.internal.processBatchedPluginEvents( bdroot( slPortBlock ) );
end 
end 

function SetInlinedInterfaceElementProperty( aPort, elementName, propName, propVal )
slPortBlock = systemcomposer.utils.getSimulinkPeer( aPort );
if isempty( slPortBlock )
return ;
end 
slPortBlock = slPortBlock( 1 );

bepTree = systemcomposer.BusObjectManager.fetchTreeNodeObjectForBusElementPort( slPortBlock );
bepTreeRootNode = Simulink.internal.CompositePorts.TreeNode.findNode( bepTree, elementName );
switch ( propName )
case 'Type'
Simulink.internal.CompositePorts.TreeNode.setDataTypeCL( bepTreeRootNode, propVal );
case 'Dimensions'
Simulink.internal.CompositePorts.TreeNode.setDimsCL( bepTreeRootNode, propVal );
case 'Units'
Simulink.internal.CompositePorts.TreeNode.setUnitCL( bepTreeRootNode, propVal );
case 'Complexity'
Simulink.internal.CompositePorts.TreeNode.setComplexityCL( bepTreeRootNode, upper( propVal ) );
case 'Minimum'
Simulink.internal.CompositePorts.TreeNode.setMinCL( bepTreeRootNode, propVal );
case 'Maximum'
Simulink.internal.CompositePorts.TreeNode.setMaxCL( bepTreeRootNode, propVal );
case 'Description'
Simulink.internal.CompositePorts.TreeNode.setDescCL( bepTreeRootNode, propVal );
end 
end 

function portInfo = GetSLPortInfo( portHandle )


portInfo = systemcomposer.internal.PortInformation;
if systemcomposer.internal.isStateflowBehaviorComponent( get_param( portHandle, 'Parent' ) )
stateflowRoot = sfroot;
chartId = sfprivate( 'block2chart', get_param( get_param( portHandle, 'Parent' ), 'Handle' ) );
chartObj = stateflowRoot.find( '-isa', 'Stateflow.Chart', 'Id', chartId );
dataObj = chartObj.find( { '-isa', 'Stateflow.Data', '-OR', '-isa', 'Stateflow.Message' }, 'Name', get_param( portHandle, 'Name' ) );

portInfo.Type = dataObj.DataType;

elseif get_param( portHandle, 'BlockType' ) == "PMIOPort"

portInfo.Type = get_param( portHandle, 'ConnectionType' );

elseif ( strcmpi( get_param( portHandle, 'isBusElementPort' ), 'on' ) )

elemName = get_param( portHandle, 'Element' );
bepTree = systemcomposer.BusObjectManager.fetchTreeNodeObjectForBusElementPort( portHandle );
bepTreeRootNode = Simulink.internal.CompositePorts.TreeNode.findNode( bepTree, elemName );

portInfo.Name = elemName;
portInfo.Type = Simulink.internal.CompositePorts.TreeNode.getDataType( bepTreeRootNode );
portInfo.Dimensions = Simulink.internal.CompositePorts.TreeNode.getDims( bepTreeRootNode );
portInfo.Unit = Simulink.internal.CompositePorts.TreeNode.getUnit( bepTreeRootNode );
portInfo.Complexity = char( Simulink.internal.CompositePorts.TreeNode.getComplexity( bepTreeRootNode ) );
portInfo.Minimum = Simulink.internal.CompositePorts.TreeNode.getMin( bepTreeRootNode );
portInfo.Maximum = Simulink.internal.CompositePorts.TreeNode.getMax( bepTreeRootNode );
portInfo.Description = Simulink.internal.CompositePorts.TreeNode.getDesc( bepTreeRootNode );

else 

assert( get_param( portHandle, 'isBusElementPort' ) == "off", "Only port blocks are supported!" );

portInfo.Type = get_param( portHandle, 'OutDataTypeStr' );
portInfo.Dimensions = get_param( portHandle, 'PortDimensions' );
portInfo.Unit = get_param( portHandle, 'Unit' );
portInfo.Complexity = get_param( portHandle, 'SignalType' );
portInfo.Minimum = get_param( portHandle, 'OutMin' );
portInfo.Maximum = get_param( portHandle, 'OutMax' );
portInfo.Description = get_param( portHandle, 'Description' );
end 
end 

function SetBusPortInfo( blockH, portInfo )



systemcomposer.AnonymousInterfaceManager.SetSLPortProperty( blockH, 'Type', portInfo.Type );
systemcomposer.AnonymousInterfaceManager.SetSLPortProperty( blockH, 'Dimensions', portInfo.Dimensions );
systemcomposer.AnonymousInterfaceManager.SetSLPortProperty( blockH, 'Units', portInfo.Unit );
systemcomposer.AnonymousInterfaceManager.SetSLPortProperty( blockH, 'Complexity', portInfo.Complexity );
systemcomposer.AnonymousInterfaceManager.SetSLPortProperty( blockH, 'Minimum', portInfo.Minimum );
systemcomposer.AnonymousInterfaceManager.SetSLPortProperty( blockH, 'Maximum', portInfo.Maximum );
systemcomposer.AnonymousInterfaceManager.SetSLPortProperty( blockH, 'Description', portInfo.Description );
end 

function portInfo = GetZCPortInfo( aPort )
R36
aPort{ mustBeA( aPort, 'systemcomposer.arch.ArchitecturePort' ) }
end 

portInfo = systemcomposer.internal.PortInformation;
interface = aPort.Interface;

if isempty( interface )
return ;
elseif isa( interface, 'systemcomposer.interface.DataInterface' )

for idx = 1:length( interface.Elements )
thisPortInfo = systemcomposer.internal.PortInformation;
element = interface.Elements( idx );

thisPortInfo.Name = element.Name;
thisPortInfo.Type = element.Type.DataType;
thisPortInfo.Dimensions = element.Type.Dimensions;
thisPortInfo.Unit = element.Type.Units;
thisPortInfo.Complexity = element.Type.Complexity;
thisPortInfo.Minimum = element.Type.Minimum;
thisPortInfo.Maximum = element.Type.Maximum;
thisPortInfo.Description = element.Type.Description;
thisPortInfo.Owner = class( interface.Owner );

portInfo( idx ) = thisPortInfo;
end 
else 

portInfo = systemcomposer.internal.PortInformation;
portInfo.Name = interface.Name;
portInfo.Type = interface.DataType;
portInfo.Dimensions = interface.Dimensions;
portInfo.Unit = interface.Units;
portInfo.Complexity = interface.Complexity;
portInfo.Minimum = interface.Minimum;
portInfo.Maximum = interface.Maximum;
portInfo.Description = interface.Description;
portInfo.Owner = class( interface.Owner );
end 
end 

end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpynfUHJ.p.
% Please follow local copyright laws when handling this file.

