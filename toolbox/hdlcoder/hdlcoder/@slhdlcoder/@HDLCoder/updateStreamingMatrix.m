function updateStreamingMatrix( this, p )




for i = 1:length( p.Networks )
n = p.Networks( i );


if isempty( strfind( n.Name, 'streaming_matrix_partition' ) )
continue ;
end 


extractElements( n );
end 

end 


function extractElements( n )

assert( numel( n.PirInputSignals ) == 2 );
inSig1 = n.PirInputSignals( 1 );
inSig2 = n.PirInputSignals( 2 );
assert( inSig1.Type.is2DMatrix(  ) && inSig2.Type.is2DMatrix(  ) );
baseRate = inSig1.SimulinkRate;
dim1 = inSig1.Type.Dimensions( 1 );
dim2 = inSig1.Type.Dimensions( 2 );
dim = dim1 * dim2;
baseType = inSig1.Type.BaseType;



assert( numel( n.PirOutputSignals ) == 1 );
outSig = n.PirOutputSignals( 1 );
assert( outSig.Type.is2DMatrix(  ) );


coreComp = getCoreComp( inSig1 );
disconnectReceivers( inSig1 );
disconnectReceivers( inSig2 );

vectorSig1 = n.addSignal( pirelab.createPirArrayType( baseType, [ dim, 0 ] ), 'vector_sig1' );
vectorSig2 = n.addSignal( pirelab.createPirArrayType( baseType, [ dim, 0 ] ), 'vector_sig2' );




reshape1 = pircore.getWireComp( n, inSig1, vectorSig1, 'wire1', '',  - 1 );
reshape2 = pircore.getWireComp( n, inSig2, vectorSig2, 'wire2', '',  - 1 );

reshape1.setSourceBlock( 'reshape' );
reshape2.setSourceBlock( 'reshape' );


count = dim + 5;
numbits = ceil( log2( double( count ) ) );

counterSig = n.addSignal( pir_ufixpt_t( 5, 0 ), 'counter_sig' );
counterSig.SimulinkRate = baseRate;
pirelab.getCounterComp( n, [  ], counterSig, 'Count limited', 0, 1, count - 1,  ...
0, 0, 0, 0, 'counter', 0 );





demuxOutSignals1 = hdlhandles( dim, 1 );
demuxOutSignals2 = hdlhandles( dim, 1 );
for ii = 1:dim
demuxOutName1 = sprintf( 'demux_out1%_%d', ii );
demuxOutSignals1( ii ) = n.addSignal( baseType, demuxOutName1 );
demuxOutName2 = sprintf( 'demux_out2%_%d', ii );
demuxOutSignals2( ii ) = n.addSignal( baseType, demuxOutName2 );
end 

pirelab.getDemuxComp( n, vectorSig1, demuxOutSignals1 );
pirelab.getDemuxComp( n, vectorSig2, demuxOutSignals2 );

multiportOutSig1 = n.addSignal( baseType, 'multiport_sig' );
pirelab.getMultiPortSwitchComp( n, [ counterSig;demuxOutSignals1 ], multiportOutSig1,  ...
1, 'Zero-based contiguous', 'Floor', 'Wrap' );

multiportOutSig2 = n.addSignal( baseType, 'multiport_sig' );
pirelab.getMultiPortSwitchComp( n, [ counterSig;demuxOutSignals2 ], multiportOutSig2,  ...
1, 'Zero-based contiguous', 'Floor', 'Wrap' );

multiportOutSig1.addReceiver( coreComp, 0 );
multiportOutSig2.addReceiver( coreComp, 1 );


n.renderCodegenPir;

end 

function comp = getCoreComp( inSig )
recs = inSig.getReceivers;
for ii = 1:numel( recs )
comp = recs( ii ).Owner;
if ~comp.isBlackBox
return ;
end 
end 
end 

function disconnectReceivers( sig )
recs = sig.getReceivers;
for ii = 1:numel( recs )
rec = recs( ii );
sig.disconnectReceiver( rec );
end 
end 







% Decoded using De-pcode utility v1.2 from file /tmp/tmpHdpZ2R.p.
% Please follow local copyright laws when handling this file.

