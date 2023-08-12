function outTypeEx = getTypeInfoAsFi( pirType, rndMode, satMode, exVal,  ...
sameDimsAsPirType )





















if ( nargin < 5 )

sameDimsAsPirType = true;
end 

if ( nargin < 4 )
exVal = 0;
end 

if ( nargin < 3 )
satMode = 'Wrap';
end 

if ( nargin < 2 )
rndMode = 'Floor';
end 


if isa( exVal, 'Simulink.Parameter' )
exVal = exVal.Value;
end 


pirLeafType = pirType.getLeafType;

if pirType.isArrayType && sameDimsAsPirType

typeDims = pirType.getDimensions;
isMatrix = ~isscalar( typeDims );
if ~isMatrix
if pirType.isRowVector
typeDims = [ 1, typeDims ];
else 
typeDims = [ typeDims, 1 ];
end 
end 


valDims = size( exVal );
if isMatrix
if all( valDims == 1 )

exVal = repmat( exVal, typeDims );
valDims = typeDims;
end 
assert( all( typeDims == valDims ) );
else 
if length( exVal ) > 1
if ( pirType.isRowVector )
if ( valDims( 1 ) ~= 1 )
exVal = exVal.';
end 
elseif ( pirType.isColumnVector )
if ( valDims( 2 ) ~= 1 )
exVal = exVal.';
end 
else 

if ( valDims( 2 ) ~= 1 )
exVal = exVal.';
end 
end 
end 
end 


if isfi( exVal )
outVal = fi( ones( typeDims ), 0, 1, 0, fimath( exVal ) ) .* exVal;
elseif pirLeafType.isEnumType
if numel( exVal ) == 1
outVal = repmat( exVal, typeDims );
else 
outVal = exVal;
end 
elseif pirLeafType.isRecordType
outVal = exVal;
else 
if ( isreal( exVal ) )
outVal = ones( typeDims, class( exVal ) ) .* exVal;
else 
outVal = complex( ones( typeDims, class( exVal ) ) .* ( real( exVal ) ), ones( typeDims, class( exVal ) ) .* ( imag( exVal ) ) );
end 
end 
else 


outVal = exVal;
end 

if pirLeafType.isDoubleType

outEx = double( outVal );
elseif pirLeafType.isSingleType
outEx = single( outVal );
elseif pirLeafType.isHalfType
outEx = half( outVal );
elseif pirLeafType.isBooleanType

nt = numerictype( 0, 1, 0 );
fm = pirelab.getFimathFromProps( satMode, rndMode );
outEx = fi( outVal, nt, fm );
elseif pirLeafType.isCharType
nt = numerictype( 0, 8, 0 );
fm = pirelab.getFimathFromProps( 'wrap', 'floor' );
outEx = fi( uint8( outVal ), nt, fm );
elseif pirLeafType.isLogicType
nt = numerictype( 0, pirLeafType.WordLength, 0 );
fm = pirelab.getFimathFromProps( satMode, rndMode );
outEx = fi( outVal, nt, fm );
elseif pirLeafType.isEnumType
if isSLEnumType( class( exVal ) )
outEx = outVal;

else 
if nargin < 4

outEx = Simulink.data.getEnumTypeInfo( pirLeafType.Name, 'DefaultValue' );
outEx = repmat( outEx, size( outVal ) );
else 

enumValues = enumeration( pirLeafType.Name )';
outEx = reshape( enumValues( outVal + 1 ), size( outVal ) );
end 
end 
elseif pirLeafType.isRecordType
outEx = outVal;
else 

nt = numerictype( pirLeafType.Signed, pirLeafType.WordLength,  ...
 - pirLeafType.FractionLength );
fm = pirelab.getFimathFromProps( satMode, rndMode );
outEx = fi( outVal, nt, fm, 'DataType', 'Fixed' );
end 

if pirelab.hasComplexType( pirType ) && isreal( outEx )



outTypeEx = complex( outEx );
else 
outTypeEx = outEx;
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpxy0MSb.p.
% Please follow local copyright laws when handling this file.

