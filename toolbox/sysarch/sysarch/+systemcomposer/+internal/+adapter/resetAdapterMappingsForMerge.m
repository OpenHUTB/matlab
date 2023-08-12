function resetAdapterMappings( blkHdl )





adapterComp = systemcomposer.utils.getArchitecturePeer( blkHdl );
if isempty( adapterComp )
return ;
end 

assert( adapterComp.isAdapterComponent );

modeEnum = systemcomposer.internal.adapter.ModeEnums;
if ~strcmpi( systemcomposer.internal.adapter.getAdapterMode( blkHdl ), modeEnum.Merge )
return ;
end 


outBlk = find_system( blkHdl, 'BlockType', 'Outport' );
outputPortName = get_param( outBlk( 1 ), 'PortName' );
compPort = adapterComp.getPort( outputPortName );
archPort = compPort.getArchitecturePort(  );
portInterf = archPort.getPortInterface(  );
portInterfWrapper = systemcomposer.internal.getWrapperForImpl( portInterf );
if ~isempty( portInterfWrapper )
archPortWrapper = systemcomposer.internal.getWrapperForImpl( archPort );
if isequal( portInterfWrapper.Owner, archPortWrapper )
portInterfWrapper.destroy(  );
end 
end 


inBlk = find_system( blkHdl, 'BlockType', 'Inport' );
inputs = { get_param( inBlk( 1 ), 'PortName' ) };
outputs = { get_param( outBlk( 1 ), 'PortName' ) };
systemcomposer.internal.adapter.setMappings( blkHdl, inputs, outputs );

end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmpoO96eK.p.
% Please follow local copyright laws when handling this file.

