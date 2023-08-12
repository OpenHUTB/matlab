function out = insertAdapterForConnector( mdlName, connUUID )








mdl = systemcomposer.arch.Model( mdlName );
conn = mdl.lookup( 'UUID', connUUID );
assert( ~isempty( conn ) );
assert( isa( conn, 'systemcomposer.arch.Connector' ) );


parentSys = getConnParentName( conn );


prev = systemcomposer.sync.transaction.model.TransactionFeature.toggle( true );
featCleaner = onCleanup( @(  )systemcomposer.sync.transaction.model.TransactionFeature.toggle( prev ) );

txn = systemcomposer.internal.SLPluginTransaction( mdlName,  ...
systemcomposer.sync.transaction.model.InsertAdapterAtPortEvent.StaticMetaClass );
txn.addEventData( 'p_ConnectorUUID', connUUID );


disconnectInSimulink( parentSys, conn );


adH = createAdapterAtPortInSL( parentSys, conn.DestinationPort );
adapterName = get_param( adH, 'Name' );
txn.addEventData( 'p_AdapterBlockHdl', adH );


reconnectWithAdapterInSL( parentSys, conn, adapterName );


txn.commitTransaction(  );

adapterPath = [ get_param( adH, 'Parent' ), '/', adapterName ];
out = message( 'SystemComposerChecks:Checks:SuccessfullyInsertedNextSteps', adapterPath ).getString(  );

end 


function parentSys = getConnParentName( conn )
if conn.Parent == conn.Model.Architecture
parentSys = conn.Parent.Name;
else 
parentHdl = conn.Parent.SimulinkHandle;
parentSys = [ get_param( parentHdl, 'Parent' ), '/', get_param( parentHdl, 'Name' ) ];
end 
end 


function pos = getPotentialAdapterPosition( targetPort )
portPos = get_param( targetPort.SimulinkHandle, 'position' );
pos = [ portPos( 1 ) - 45, portPos( 2 ) - 10, portPos( 1 ) - 20, portPos( 2 ) + 10 ];
end 


function disconnectInSimulink( parentSys, conn )
oport = [ conn.SourcePort.Parent.Name, '/', num2str( get_param( conn.SourcePort.SimulinkHandle, 'PortNumber' ) ) ];
iport = [ conn.DestinationPort.Parent.Name, '/', num2str( get_param( conn.DestinationPort.SimulinkHandle, 'PortNumber' ) ) ];
delete_line( parentSys, oport, iport );
end 


function adH = createAdapterAtPortInSL( parentSys, port )
adapterName = 'Adapter';
adapterPos = getPotentialAdapterPosition( port );
adH = add_block( 'built-in/Subsystem', [ parentSys, '/', adapterName ], 'MakeNameUnique', 'on' );
SimulinkSubDomainMI.SimulinkSubDomain.setSimulinkSubDomain( adH, SimulinkSubDomainMI.SimulinkSubDomainEnum.ArchitectureAdapter );
systemcomposer.internal.adapter.resetPorts( adH );
set_param( adH, 'position', adapterPos );
end 


function reconnectWithAdapterInSL( parentSys, conn, adapterName )
oport = [ conn.SourcePort.Parent.Name, '/', num2str( get_param( conn.SourcePort.SimulinkHandle, 'PortNumber' ) ) ];
iport = [ conn.DestinationPort.Parent.Name, '/', num2str( get_param( conn.DestinationPort.SimulinkHandle, 'PortNumber' ) ) ];
lh1 = add_line( parentSys, oport, [ adapterName, '/1' ] );
lh2 = add_line( parentSys, [ adapterName, '/1' ], iport );
Simulink.BlockDiagram.routeLine( [ lh1, lh2 ] );
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpw1cDjx.p.
% Please follow local copyright laws when handling this file.

