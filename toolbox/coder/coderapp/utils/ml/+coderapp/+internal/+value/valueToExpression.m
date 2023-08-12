function expr = valueToExpression( value, maxChars, restrictXmlChars, preserveClass )
R36
value
maxChars{ mustBeGreaterThan( maxChars, 0 ) } = Inf
restrictXmlChars{ mustBeNumericOrLogical( restrictXmlChars ) } = false
preserveClass{ mustBeNumericOrLogical( preserveClass ) } = true
end 


if preserveClass
msArgs = { 'class' };
else 
msArgs = {  };
end 

[ expr, value ] = doValueToExpression( value );
if numel( expr ) > maxChars
expr = '';
elseif ~isempty( expr ) && isfloat( value )
try 
if any( typecast( value( value == 0 ), 'uint64' ) )

expr = '';
end 
catch 
end 
end 


function [ expr, value ] = doValueToExpression( value )
expr = '';
if ndims( value ) > 2 %#ok<ISMAT>
return 
end 
if ischar( value ) || isstring( value )

uniques = unique( char( value ) );
if ~restrictXmlChars || ( isempty( intersect( uniques, [ 1:8, 11:12, 15:19, 55296:57343 ] ) ) && all( uniques <= 65533 ) )
expr = mat2str( value, msArgs{ : } );
else 
return 
end 
elseif ~isenum( value ) && ~isfi( value )
if isfloat( value )
if isa( value, 'double' )
argOverride = {  };
else 
argOverride = msArgs;
end 
if all( floor( value ) == value & abs( value ) <= getflintmax( value ) )



expr = mat2str( value, int32( ceil( log10( getflintmax( value ) ) ) ), argOverride{ : } );
else 
expr = mat2str( value, argOverride{ : } );
if ~all( eval( expr ) == value )

expr = mat2str( value, 38, argOverride{ : } );
end 
end 
elseif isinteger( value )
expr = mat2str( value, ceil( log10( double( intmax( class( value ) ) ) ) ), msArgs{ : } );
elseif islogical( value )
expr = mat2str( value );
end 
end 
if isempty( expr )
if iscell( value )
expr = cell2str( value );
else 
try 
expr = mat2str( value, msArgs{ : } );
catch 
end 
end 
end 
end 


function expr = cell2str( value )
sz = size( value );
if isempty( value )
if any( sz > 0 )
expr = sprintf( 'cell(%d,%d)', sz( 1 ), sz( 2 ) );
else 
expr = '{}';
end 
return 
end 

subExprs = cell( 1, numel( value ) );
sIdx = 0;
for i = 1:sz( 1 )
for j = 1:sz( 2 )
sIdx = sIdx + 1;
subExprs{ sIdx } = coderapp.internal.value.valueToExpression(  ...
value{ i, j }, maxChars, restrictXmlChars );
if isempty( subExprs{ sIdx } )
expr = '';
return 
end 
end 
end 

delims = repmat( { ' ' }, 1, numel( subExprs ) - 1 );
semiIdx = 1:numel( delims );
semiIdx( mod( semiIdx, sz( 2 ) ) > 0 ) = [  ];
delims( semiIdx ) = { ';' };
expr = [ '{', strjoin( subExprs, delims ), '}' ];
end 
end 


function maxVal = getflintmax( input )

if isa( input, 'half' )
maxVal = half.flintmax(  );
else 

maxVal = flintmax( class( input ) );
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpIqSPi9.p.
% Please follow local copyright laws when handling this file.

