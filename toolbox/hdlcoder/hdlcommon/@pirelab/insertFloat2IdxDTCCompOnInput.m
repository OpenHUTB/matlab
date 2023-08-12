



function outSig = insertFloat2IdxDTCCompOnInput( hN, inSig, width,  ...
oneBasedIdx, compName, nfpOptions )


narginchk( 5, 6 );

if nargin < 6
nfpOptions.Latency = int8( 0 );
nfpOptions.MantMul = int8( 0 );
nfpOptions.Denormals = int8( 0 );
end 

uintT = getSmallestUintType( width, oneBasedIdx );
if ~oneBasedIdx
roundingMode = 'Zero';
else 
roundingMode = 'Floor';
end 
dtcOut = pirelab.insertDTCCompOnInput( hN, inSig, uintT,  ...
roundingMode, 'Wrap', [ compName, '_dtc_comp' ], nfpOptions );
outSig = dtcOut;
end 




function uintT = getSmallestUintType( width, oneBasedIdx )

minBitsNeeded = ceil( log2( double( width + oneBasedIdx ) ) );

smallestByteAddressableDT = min( max( 2 ^ ceil( log2( minBitsNeeded ) ), 8 ), 32 );
uintT = pir_unsigned_t( smallestByteAddressableDT );
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpWFigSd.p.
% Please follow local copyright laws when handling this file.

