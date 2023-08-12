function pList = addPort( this, portNames, portTypes, stereotype )










R36
this
portNames
portTypes{ mustBeMember( portTypes, { 'in', 'out', 'physical', 'client', 'server' } ) }
stereotype = string.empty( 1, 0 );
end 

this.validateAPISupportForAUTOSAR( 'addPort' );

pImplList = systemcomposer.architecture.model.design.ArchitecturePort.empty(  );
pList = systemcomposer.arch.ArchitecturePort.empty(  );

portNames = string( portNames );
portTypes = string( portTypes );
stereotype = string( stereotype );

if ~isempty( stereotype ) && length( stereotype ) > 1
if ~isequal( length( stereotype ), length( portNames ) )
error( 'systemcomposer:API:AddPortStereotypeMismatch', message(  ...
'SystemArchitecture:API:AddPortStereotypeMismatch' ).getString );
end 
end 

if ~isequal( length( portNames ), length( portTypes ) )
error( 'systemcomposer:API:AddPortArgsMismatch', message(  ...
'SystemArchitecture:API:AddPortArgsMismatch' ).getString );
end 



if length( stereotype ) == 1
stereotype = repmat( stereotype, 1, length( portNames ) );
end 


numInPorts = this.getImpl.getNumberOfInPorts;

bhs = cell( 1, length( portNames ) );
runningIdxInPort = 1;
try 
t = this.MFModel.beginTransaction;
for i = 1:numel( portNames )
pName = portNames( i );
pType = portTypes( i );
switch pType
case "in"
inPort = pName;

inPort = this.getImpl.getUniquePortName( inPort );
if ~isempty( inPort )
if isa( this.Parent, 'systemcomposer.arch.VariantComponent' )
fullPortName = [ this.Parent.getQualifiedName, '/', inPort ];
bh = add_block( 'built-in/Inport', fullPortName,  ...
'MakeNameUnique', 'on', 'Port', num2str( numInPorts + runningIdxInPort ) );
elseif strcmp( this.Definition, 'StateflowBehavior' )
stateflowRoot = sfroot;
chartId = sfprivate( 'block2chart', this.Parent.SimulinkHandle );
chartObj = stateflowRoot.find( '-isa', 'Stateflow.Chart', 'Id', chartId );
sfData = Stateflow.Data( chartObj );
sfData.Name = inPort;
sfData.Scope = 'Input';
bh = get_param( sfData.getFullName, 'Handle' );
else 
if isempty( this.Parent )
fullPortName = [ this.Name, '/Bus Element In1' ];
else 
fullPortName = [ this.Parent.getQualifiedName, '/Bus Element In1' ];
end 
bh = add_block( 'simulink/Ports & Subsystems/In Bus Element',  ...
fullPortName, 'MakeNameUnique', 'on',  ...
'CreateNewPort', 'on',  ...
'PortName', inPort, 'Element', '', 'Port', num2str( numInPorts + runningIdxInPort ) );
end 
runningIdxInPort = runningIdxInPort + 1;
bhs( i ) = { bh };
end 
case "out"
outPort = pName;

outPort = this.getImpl.getUniquePortName( outPort );
if ~isempty( outPort )
if isa( this.Parent, 'systemcomposer.arch.VariantComponent' )
fullPortName = [ this.Parent.getQualifiedName, '/', outPort ];
bh = add_block( 'built-in/Outport', fullPortName, 'MakeNameUnique', 'on' );
elseif strcmp( this.Definition, 'StateflowBehavior' )
stateflowRoot = sfroot;
chartId = sfprivate( 'block2chart', this.Parent.SimulinkHandle );
chartObj = stateflowRoot.find( '-isa', 'Stateflow.Chart', 'Id', chartId );
sfData = Stateflow.Data( chartObj );
sfData.Name = outPort;
sfData.Scope = 'Output';
bh = get_param( sfData.getFullName, 'Handle' );
else 
if isempty( this.Parent )
fullPortName = [ this.Name, '/Bus Element Out1' ];
else 
fullPortName = [ this.Parent.getQualifiedName, '/Bus Element Out1' ];
end 
bh = add_block( 'simulink/Ports & Subsystems/Out Bus Element',  ...
fullPortName, 'MakeNameUnique', 'on',  ...
'CreateNewPort', 'on',  ...
'PortName', outPort, 'Element', '' );
end 
bhs( i ) = { bh };
end 
case "physical"
physicalPort = pName;

physicalPort = this.getImpl.getUniquePortName( physicalPort );
if ~isempty( physicalPort )
if isempty( this.Parent ) && strcmp( get_param( this.SimulinkHandle, 'Type' ), 'block_diagram' ) &&  ...
strcmp( get_param( this.SimulinkHandle, 'BlockDiagramType' ), 'model' )
error( message( 'SystemArchitecture:API:PhysicalPortNotAllowedAtModelRoot' ) );
elseif isa( this.Parent, 'systemcomposer.arch.VariantComponent' )
fullPortName = [ this.Parent.getQualifiedName, '/', physicalPort ];
bh = add_block( 'built-in/PMIOPort', fullPortName, 'MakeNameUnique', 'on' );
elseif strcmp( this.Definition, 'StateflowBehavior' )
error( message( 'SystemArchitecture:API:PhysicalPortNotAllowedOnStateflowChart' ) );
else 
if isempty( this.Parent )
fullPortName = [ this.Name, '/', physicalPort ];
else 
fullPortName = [ this.Parent.getQualifiedName, '/', physicalPort ];
end 
bh = add_block( 'built-in/PMIOPort',  ...
fullPortName, 'MakeNameUnique', 'on', 'Name', physicalPort );
end 
bhs( i ) = { bh };
end 
case "client"
clientPort = pName;
clientPort = this.getImpl.getUniquePortName( clientPort );
if ~isempty( clientPort )
if isa( this.Parent, 'systemcomposer.arch.VariantComponent' )
error( message( 'SystemArchitecture:API:ClientServerPortNotAllowedForVariantComponent' ) );
elseif strcmp( this.Definition, 'StateflowBehavior' )
error( message( 'SystemArchitecture:API:ClientServerPortNotAllowedOnStateflowChart' ) );
elseif ~isempty( this.Parent ) && systemcomposer.internal.isSubsystemReferenceComponent( this.Parent.SimulinkHandle )
error( message( 'SystemArchitecture:API:ClientServerPortNotAllowedForSubsystemReference' ) );
elseif ~strcmp( get_param( this.SimulinkHandle, 'SimulinkSubdomain' ), 'SoftwareArchitecture' )
error( message( 'SystemArchitecture:API:ClientServerPortNotAllowedForNonSoftwareArchitecture' ) );
else 
if isempty( this.Parent )
fullPortName = [ this.Name, '/', '  Bus Element In1' ];
else 
fullPortName = [ this.Parent.getQualifiedName, '/', '  Bus Element In1' ];
end 
bh = add_block( 'simulink/Ports & Subsystems/In Bus Element',  ...
fullPortName, 'MakeNameUnique', 'on',  ...
'CreateNewPort', 'on',  ...
'PortName', clientPort, 'Element', '' );
set_param( bh, 'AllowServiceAccess', 'on' );
set_param( bh, 'isClientServer', 'on' );
end 
runningIdxInPort = runningIdxInPort + 1;
bhs( i ) = { bh };
end 
case "server"
serverPort = pName;
serverPort = this.getImpl.getUniquePortName( serverPort );
if ~isempty( serverPort )
if isa( this.Parent, 'systemcomposer.arch.VariantComponent' )
error( message( 'SystemArchitecture:API:ClientServerPortNotAllowedForVariantComponent' ) );
elseif strcmp( this.Definition, 'StateflowBehavior' )
error( message( 'SystemArchitecture:API:ClientServerPortNotAllowedOnStateflowChart' ) );
elseif ~isempty( this.Parent ) && systemcomposer.internal.isSubsystemReferenceComponent( this.Parent.SimulinkHandle )
error( message( 'SystemArchitecture:API:ClientServerPortNotAllowedForSubsystemReference' ) );
elseif ~strcmp( get_param( this.SimulinkHandle, 'SimulinkSubdomain' ), 'SoftwareArchitecture' )
error( message( 'SystemArchitecture:API:ClientServerPortNotAllowedForNonSoftwareArchitecture' ) );
else 
if isempty( this.Parent )
fullPortName = [ this.Name, '/', '  Bus Element Out1' ];
else 
fullPortName = [ this.Parent.getQualifiedName, '/', '  Bus Element Out1' ];
end 
bh = add_block( 'simulink/Ports & Subsystems/Out Bus Element',  ...
fullPortName, 'MakeNameUnique', 'on',  ...
'CreateNewPort', 'on',  ...
'PortName', serverPort, 'Element', '' );
set_param( bh, 'AllowServiceAccess', 'on' );
set_param( bh, 'isClientServer', 'on' );
end 
bhs( i ) = { bh };
end 
end 
end 
systemcomposer.internal.arch.internal.processBatchedPluginEvents( this.SimulinkModelHandle );
t.commit;

stereotypeList = string.empty( 0, length( portNames ) );
for i = 1:numel( bhs )
bh = bhs( i );
archP = systemcomposer.utils.getArchitecturePeer( bh{ : } );
if ~isempty( archP )
pImplList( i ) = archP;
if ~isempty( stereotype )
stereotypeList( i ) = stereotype( i );
else 
stereotypeList( i ) = "";
end 
end 
end 

for i = 1:numel( pImplList )
pList( i ) = systemcomposer.internal.getWrapperForImpl( pImplList( i ), 'systemcomposer.arch.ArchitecturePort' );
end 


if ~( isempty( stereotypeList ) || all( stereotypeList.matches( "" ) ) )
t = this.MFModel.beginTransaction;
for i = 1:length( pImplList )
if ~isequal( stereotypeList( i ), "" )
systemcomposer.internal.arch.applyPrototype( pImplList( i ), stereotypeList( i ) );
end 
end 
t.commit;
end 

catch ME
rethrow( ME );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpEIZV5G.p.
% Please follow local copyright laws when handling this file.

