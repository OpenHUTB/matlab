function removeAllSimulinkConnectors( comp )



linesToDelete = [  ];

try 
blkH = systemcomposer.utils.getSimulinkPeer( comp );
bdHandle = bdroot( blkH );
archPluginTxn = systemcomposer.internal.arch.internal.ArchitecturePluginTransaction(  ...
get_param( bdHandle, 'Name' ) );
wasDirty = get_param( bdHandle, 'dirty' );
portHandleStruct = get_param( blkH, 'PortHandles' );

for inport = portHandleStruct.Inport
dstPort = get_param( inport, 'Object' );
if ( dstPort.Line ~=  - 1 )
linesToDelete = [ linesToDelete, dstPort.Line ];%#ok<AGROW>
end 
end 

for outport = portHandleStruct.Outport
srcPort = get_param( outport, 'Object' );
if ( srcPort.Line ~=  - 1 )
segment = get_param( srcPort.Line, 'Object' );
actDstPortHandles = segment.DstPortHandle;
for i = 1:numel( actDstPortHandles )
dstPort = get_param( actDstPortHandles( i ), 'Object' );
linesToDelete = [ linesToDelete, dstPort.Line ];%#ok<AGROW>
end 
end 
end 

for physicalL = portHandleStruct.LConn
connPort = get_param( physicalL, 'Object' );
if ( connPort.Line ~=  - 1 )
linesToDelete = [ linesToDelete, connPort.Line ];%#ok<AGROW>
end 
end 

for physicalR = portHandleStruct.RConn
connPort = get_param( physicalR, 'Object' );
if ( connPort.Line ~=  - 1 )
linesToDelete = [ linesToDelete, connPort.Line ];%#ok<AGROW>
end 
end 


linesToDelete = unique( linesToDelete );
for i = 1:numel( linesToDelete )
delete_line( linesToDelete( i ) );
end 


if ( strcmpi( wasDirty, 'off' ) )
set_param( bdroot( blkH ), 'dirty', 'off' );
end 
delete( archPluginTxn );
catch 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpPvqp6Q.p.
% Please follow local copyright laws when handling this file.

