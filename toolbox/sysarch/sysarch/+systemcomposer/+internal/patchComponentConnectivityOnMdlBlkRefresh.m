function patchComponentConnectivityOnMdlBlkRefresh( comp )








ports = comp.getPorts;

mismatchConns = [  ];
linesToDelete = [  ];

try 
blkH = systemcomposer.utils.getSimulinkPeer( comp );
wasDirty = get_param( bdroot( blkH ), 'dirty' );

for port = ports
portHandle = systemcomposer.utils.getSimulinkPeer( port );
if ( portHandle ==  - 1 )
continue ;
end 

if ( port.getPortAction == systemcomposer.architecture.model.core.PortAction.REQUEST ||  ...
port.getPortAction == systemcomposer.architecture.model.core.PortAction.CLIENT )
dstPort = get_param( portHandle, 'Object' );
if ( dstPort.Line ~=  - 1 )
segment = get_param( dstPort.Line, 'Object' );
actSrcPort = systemcomposer.utils.getArchitecturePeer( segment.SrcPortHandle );

conns = getConnectorsForPort( port );
if ~isempty( conns )
assert( numel( conns ) == 1 );
expConn = conns( 1 );
expSrcPort = expConn.getSource;
if ( expSrcPort ~= actSrcPort )

linesToDelete = [ linesToDelete, segment.Handle ];%#ok<AGROW>
mismatchConns = [ mismatchConns, expConn ];%#ok<AGROW>
end 
else 



linesToDelete = [ linesToDelete, segment.Handle ];%#ok<AGROW>
end 
else 
conns = getConnectorsForPort( port );
if ~isempty( conns )


mismatchConns = [ mismatchConns, conns( 1 ) ];%#ok<AGROW>
end 
end 
elseif ( port.getPortAction == systemcomposer.architecture.model.core.PortAction.PROVIDE ||  ...
port.getPortAction == systemcomposer.architecture.model.core.PortAction.SERVER )
srcPort = get_param( portHandle, 'Object' );
if ( srcPort.Line ~=  - 1 )
segment = get_param( srcPort.Line, 'Object' );
conns = getConnectorsForPort( port );
if ~isempty( conns )
actDstPortHandles = segment.DstPortHandle;
actDstPorts = arrayfun( @( ph )systemcomposer.utils.getArchitecturePeer( ph ), actDstPortHandles, 'UniformOutput', false );
isFound = false( 1, numel( actDstPorts ) );
for conn = conns


expDstPort = conn.getDestination;
idx = find( cellfun( @( actPort )actPort == expDstPort, actDstPorts ) );
if isempty( idx )

mismatchConns = [ mismatchConns, conn ];%#ok<AGROW>
else 
isFound( idx ) = true;
end 
end 


for i = 1:numel( isFound )
if ~isFound
dstPort = get_param( actDstPortHandles( i ), 'Object' );
linesToDelete = [ linesToDelete, dstPort.Line ];%#ok<AGROW>
end 
end 
else 



linesToDelete = [ linesToDelete, segment.Handle ];%#ok<AGROW>
end 
else 
conns = getConnectorsForPort( port );
if ~isempty( conns )


mismatchConns = [ mismatchConns, conns ];%#ok<AGROW>
end 
end 
end 
end 







linesToDelete = unique( linesToDelete );
for i = 1:numel( linesToDelete )
delete_line( linesToDelete( i ) );
end 


mismatchConns = unique( mismatchConns );
for i = 1:numel( mismatchConns )
recreateLineForConnector( mismatchConns( i ) );
end 


if ( strcmpi( wasDirty, 'off' ) )
set_param( bdroot( blkH ), 'dirty', 'off' );
end 

catch 
end 

end 

function conns = getConnectorsForPort( port )

conns = port.getConnectors;
conns( arrayfun( @( c )~isempty( c.p_Redefines ), conns ) ) = [  ];

end 

function recreateLineForConnector( conn )





dstPortHandle = systemcomposer.utils.getSimulinkPeer( conn.getDestination );
dstPortObj = get_param( dstPortHandle, 'Object' );
if isa( dstPortObj, 'Simulink.Outport' )
line = dstPortObj.LineHandles;
else 
line = dstPortObj.Line;
end 
if isstruct( line )
if line.Inport ~=  - 1
delete_line( line.Inport );
end 
else 
if line ~=  - 1
delete_line( line );
end 
end 

if isvalid( conn )
srcPort = systemcomposer.internal.getWrapperForImpl( conn.getSource );
dstPort = systemcomposer.internal.getWrapperForImpl( conn.getDestination );
conn.destroy;

if ( isa( srcPort, 'systemcomposer.arch.ComponentPort' ) )
parArch = srcPort.Parent.Parent;
else 
parArch = srcPort.Parent;
end 
srcPort.connectHelper( dstPort, parArch, '', 'ShouldFlush', false );
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp2rIYTJ.p.
% Please follow local copyright laws when handling this file.

