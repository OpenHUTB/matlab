function dtcOutSignal = insertDTCCompOnInput( hN, hCInSignal, hCOutType, rndMode, satMode, compName, nfpOptions )





if nargin < 7
nfpOptions.Latency = int8( 0 );
nfpOptions.MantMul = int8( 0 );
nfpOptions.Denormals = int8( 0 );
end 

if ( nargin < 6 )
compName = 'dtc';
end 


[ dimLenIn, hCInBaseType ] = pirelab.getVectorTypeInfo( hCInSignal, true );

if hCOutType.isArrayType
hCOutBaseType = hCOutType.BaseType;
else 
hCOutBaseType = hCOutType;
end 

if ( hCInBaseType.isEqual( hCOutBaseType ) )

dtcOutSignal = hCInSignal;
return ;
end 

if ( hCInBaseType.is1BitType && hCOutBaseType.is1BitType )
dtcOutSignal = hCInSignal;
return ;
end 


if hCInSignal.Type.isArrayType
if hCOutType.isArrayType && all( hCOutType.getDimensions == dimLenIn )

dtcOutType = hCOutType;
else 


dtcOutType = pirelab.getPirVectorType( hCOutType, dimLenIn );
end 
else 
dtcOutType = hCOutType;
end 


dtcOutSignal = hN.addSignal( dtcOutType, [ compName, '_out' ] );
dtcComp = pirelab.getDTCComp( hN, hCInSignal, dtcOutSignal, rndMode, satMode, 'RWV', compName, '',  - 1, nfpOptions );

% Decoded using De-pcode utility v1.2 from file /tmp/tmp1Gr9H7.p.
% Please follow local copyright laws when handling this file.

