function sharedLists = gatherSharedDT( h, blkObj )




sharedLists = {  };
hPorts = blkObj.PortHandles;

inport1Obj = get_param( hPorts.Inport( 1 ), 'Object' );
[ srcBlkAtInport1, srcSigAtInport1 ] = h.getSourceSignal( inport1Obj );

if ~( isempty( srcBlkAtInport1 ) || isempty( srcSigAtInport1 ) )

numInputPorts = length( hPorts.Inport );
sharedLists = cell( 1, numInputPorts + 1 );

recordForOutport.blkObj = blkObj;
recordForOutport.pathItem = 'Output';

for idx = 1:numInputPorts
inportObj = get_param( hPorts.Inport( idx ), 'Object' );
[ srcBlkAtInport, srcSigAtInport, srcInfo ] = h.getSourceSignal( inportObj );

recordForInport.blkObj = srcBlkAtInport;
recordForInport.pathItem = srcSigAtInport;
recordForInport.srcInfo = srcInfo;

sharedLists{ idx } = recordForInport;
end 

sharedLists{ numInputPorts + 1 } = recordForOutport;
sharedLists = { sharedLists };
end 
if strcmp( blkObj.MaskType, 'Toeplitz' )
samePortShare = hShareSrcAtSamePort( h, blkObj );
sharedLists = h.hAppendToSharedLists( sharedLists, samePortShare );
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpDm2F6G.p.
% Please follow local copyright laws when handling this file.

