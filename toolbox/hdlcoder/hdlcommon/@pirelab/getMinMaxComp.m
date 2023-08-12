function minmaxComp = getMinMaxComp( hN, hInSignals, hOutSignals,  ...
compName, opName, isDSPBlk, outputMode, isOneBased, desc, slbh, nfpOptions )











if nargin < 11
nfpOptions.Latency = int8( 0 );
nfpOptions.MantMul = int8( 0 );
nfpOptions.Denormals = int8( 0 );
end 

if nargin < 10
slbh =  - 1;
end 

if nargin < 9
desc = '';
end 

if ( nargin < 8 )
isOneBased = true;
end 

if ( nargin < 7 )
outputMode = 'Value';
end 

if ( nargin < 6 )
isDSPBlk = false;
end 

if ( nargin < 5 )
opName = 'min';
end 

if ( nargin < 4 )
compName = 'minmax';
end 

sizeOfInput = pirelab.getVectorTypeInfo( hOutSignals( 1 ) );
arrayType = pirelab.createPirArrayType( hdlcoder.tp_boolean, sizeOfInput );
if numel( hInSignals ) > 1 && sizeOfInput( 1 ) > 1
rel_out = hN.addSignal( arrayType, [ compName, '' ] );
if ( contains( opName, 'min', 'IgnoreCase', true ) )
pirelab.getRelOpComp( hN, [ hInSignals( 1 ), hInSignals( 2 ) ], rel_out, '<' );
else 
pirelab.getRelOpComp( hN, [ hInSignals( 1 ), hInSignals( 2 ) ], rel_out, '>' );
end 
minmaxComp = pirelab.getSwitchComp( hN, [ hInSignals( 1 ), hInSignals( 2 ) ], hOutSignals, rel_out, 'switch', '~=', 0 );
else 
minmaxComp = pircore.getMinMaxComp( hN, hInSignals, hOutSignals,  ...
compName, opName, isDSPBlk, outputMode, isOneBased, desc, slbh, nfpOptions );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp1O2utz.p.
% Please follow local copyright laws when handling this file.

