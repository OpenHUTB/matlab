function pirType = getPirVectorType( basetp, portDims, allowSingleElementVector )






if nargin < 3
allowSingleElementVector = false;
end 

if ( length( portDims ) == 1 ) && portDims == 1 && ~allowSingleElementVector

pirType = basetp;
else 
arrtypef = pir_arr_factory_tc;

if ( length( portDims ) == 1 )

vecLen = portDims( 1 );
vecLen = double( vecLen );
arrtypef.addDimension( vecLen );

elseif ( length( portDims ) == 2 )

[ vectorLength, vectorOrientation ] = getVectorLengthAndOrientation( portDims );
arrtypef.addDimension( vectorLength );
arrtypef.VectorOrientation = vectorOrientation;

else 





parsedDims = hdlparseportdims( portDims, 1 );
vector = [ parsedDims( 2, 1 ), parsedDims( 3, 1 ) ];

if ~any( vector == 0 ) && max( vector ) ~= prod( vector )
error( message( 'hdlcommon:hdlcommon:matrixnotsupported' ) );
end 

[ vectorLen, vectorOrientation ] = getVectorLengthAndOrientation( vector );
arrtypef.addDimension( vectorLen );
arrtypef.VectorOrientation = vectorOrientation;








end 

arrtypef.addBaseType( basetp );
pirType = pir_array_t( arrtypef );
end 

end 

function [ vectorLen, vectorOrientation ] = getVectorLengthAndOrientation( portDims )





if portDims( 1 ) == 0
error( message( 'hdlcommon:hdlcommon:internalinvalidvectordimension' ) );
elseif portDims( 2 ) == 0
vectorLen = portDims( 1 );
vectorOrientation = 'unoriented';
elseif portDims( 1 ) == 1
vectorLen = portDims( 2 );
vectorOrientation = 'row';
elseif portDims( 2 ) == 1
vectorLen = portDims( 1 );
vectorOrientation = 'column';
else 
error( message( 'hdlcommon:hdlcommon:internalinvalidvectordimension' ) );
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpL8d0HV.p.
% Please follow local copyright laws when handling this file.

