function reshapeComp = getReshapeComp( hN, hInSignals, hOutSignals, compName )


narginchk( 3, 4 );
if nargin < 4
compName = 'Reshape';
end 

inType = hInSignals.Type;
outType = hOutSignals.Type;
assert( ~xor( inType.isArrayType, outType.isArrayType ),  ...
'Inputs and outputs must both either be scalar or non-scalar' );

if ~outType.isArrayType ||  ...
( numel( outType.Dimensions ) == numel( inType.Dimensions ) &&  ...
all( outType.Dimensions == inType.Dimensions ) )



reshapeComp = pircore.getWireComp( hN, hInSignals, hOutSignals, compName );
reshapeComp.setSourceBlock( 'reshape' );
else 
assert( prod( outType.Dimensions ) == prod( inType.Dimensions ),  ...
'Inputs and outputs to a reshape comp must have the same number of elements' );

if outType.isMatrix
outDimType = 'Customize';
elseif outType.isRowVector
outDimType = 'Row vector (2-D)';
elseif outType.isColumnVector
outDimType = 'Column vector (2-D)';
else 
outDimType = '1-D array';
end 
outDims = num2cell( outType.Dimensions );

reshapeComp = pircore.getReshapeComp( hN, hInSignals, hOutSignals, outDimType, outDims, compName );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpI1Qw_3.p.
% Please follow local copyright laws when handling this file.

