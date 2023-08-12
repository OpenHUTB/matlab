function result = vhdlconstantvalue( cval, outsize, outbp, outsigned, format )














if nargin == 4
format = '';
end 

if length( cval ) ~= 1
warning( message( 'HDLShared:directemit:nonscalar' ) );
cval = cval( 1 );
end 

if outsize == 0
gp = pir;
isnfp = isNativeFloatingPointMode(  );
if gp.getTargetCodeGenSuccess || isnfp

result = sprintf( 'X"%s"', num2hex( cval ) );
else 
result = sprintf( '%21.16E', double( cval ) );
end 
elseif outsize == 1
result = sprintf( '''%d''', cval ~= 0 );
else 
if isinf( cval ) && cval > 0
result = handleplusinf( cval, outsize, outbp, outsigned, format );
elseif isinf( cval ) && cval < 0
result = handleminusinf( cval, outsize, outbp, outsigned, format );
elseif isa( cval, 'double' ) || isa( cval, 'single' ) || isinteger( cval ) || islogical( cval )
result = handlenonfi( cval, outsize, outbp, outsigned, format );
elseif isa( cval, 'embedded.fi' )
result = handlefi( cval, outsize, outbp, outsigned, format );
else 
error( message( 'HDLShared:directemit:UnknownType', class( cval ) ) );
end 
end 


function result = hexconst( val, outsize, outbp, outsigned )
hexsize = ceil( outsize / 4 );

hexval = mydec2hex( val, hexsize, outsigned, ( val < 0 ) );
result = hexformat( hexval, outsize, outsigned );


function result = hexformat( hexval, outsize, outsigned )
bitsize = sprintf( '%d', outsize - 1 );
result = [ 'signed(to_stdlogicvector(bit_vector''(X"', hexval,  ...
'"))(', bitsize, ' DOWNTO 0))' ];
if ~outsigned
result = [ 'un', result ];
end 

function str = mydec2bin( d, n, issigned, isneg )

if nargin < 2
n = ceil( log2( max( d ) ) );
isneg = false;
end 

d = double( d );

[ f, e ] = log2( max( d ) );
n = max( n, ceil( e ) );
binstr = rem( floor( d * pow2( ( 1 - n ):0 ) ), 2 );
if issigned && ~isneg && binstr( 1 ) == 1
binstr = [ 0, ones( 1, length( binstr ) - 1 ) ];
end 

binvalues = '01';
str = binvalues( abs( binstr ).' + 1 );


function str = mydec2hex( d, n, issigned, isneg )

if nargin < 2
n = ceil( log2( max( d ) ) / 4 );
isneg = false;
end 

d = double( d );

[ f, e ] = log2( max( d ) );
n = max( n, ceil( e / 4 ) );
binstr = rem( floor( d * pow2( 1 - ( 4 * n ):0 ) ), 2 );
if issigned && ~isneg && binstr( 1 ) == 1
binstr = [ 0, ones( 1, length( binstr ) - 1 ) ];
end 


binstr = reshape( binstr, 4, n ).';
binstr = binstr * 2 .^ [ 3, 2, 1, 0 ].';

hexstr = '0123456789ABCDEF';

str = hexstr( abs( binstr ).' + 1 );


function result = binformat( binstr, outsize, outsigned )
result = [ 'signed''("', binstr, '")' ];
if ~outsigned
result = [ 'un', result ];
end 


function result = handleplusinf( cval, outsize, outbp, outsigned, format )
if outsigned
if isempty( format ) || isempty( strmatch( lower( format ), 'noaggregate' ) )
result = sprintf( '(%d => ''0'', OTHERS => ''1'')', outsize - 1 );
else 
hexsize = ceil( outsize / 4 );
hexmod = mod( outsize - 1, 4 );
hexstr = '0137';
result = char( 'F' * ones( 1, hexsize ) );
result( 1 ) = hexstr( hexmod + 1 );
result = hexformat( result, outsize, outsigned );
end 
else 
if isempty( format ) || isempty( strmatch( lower( format ), 'noaggregate' ) )
result = '(OTHERS => ''1'')';
else 
hexsize = ceil( outsize / 4 );
hexmod = mod( outsize - 1, 4 );
hexstr = '137F';
result = char( 'F' * ones( 1, hexsize ) );
result( 1 ) = hexstr( hexmod + 1 );
result = hexformat( result, outsize, outsigned );
end 
end 



function result = handleminusinf( cval, outsize, outbp, outsigned, format )
if outsigned
if isempty( format ) || isempty( strmatch( lower( format ), 'noaggregate' ) )
result = sprintf( '(%d => ''1'', OTHERS => ''0'')', outsize - 1 );
else 
hexsize = ceil( outsize / 4 );
hexmod = mod( outsize - 1, 4 );
hexstr = '1248';
result = char( '0' * ones( 1, hexsize ) );
result( 1 ) = hexstr( hexmod + 1 );
result = hexformat( result, outsize, outsigned );
end 
else 
error( message( 'HDLShared:directemit:negunsignedconst' ) );
end 



function result = handlenonfi( cval, outsize, outbp, outsigned, format )

temp = floor( ( double( cval ) * ( 2 ^ outbp ) ) + 0.5 );

if temp < 0 && outsigned == 0
error( message( 'HDLShared:directemit:negunsignedconst' ) );
end 

if ~isempty( format ) && ~isempty( strmatch( lower( format ), 'bin' ) )
result = sprintf( '"%s"', mydec2bin( temp, outsize, outsigned, temp < 0 ) );
elseif temp > 2 ^ 31 - 1 || temp <  - 2 ^ 31 || hdlgetparameter( 'use_aggregates_for_const' ) == 1
if isempty( format ) || ~isempty( strmatch( lower( format ), 'aggregate' ) )
result = vhdlcreateaggregate( cval, outsize, outbp, outsigned );
else 
result = hexconst( temp, outsize, outbp, outsigned );
end 
else 
if ~isempty( format ) && ~isempty( strmatch( lower( format ), 'hex' ) )
result = hexconst( temp, outsize, outbp, outsigned );
else 
if outsigned
result = sprintf( 'to_signed(%d, %d)', temp, outsize );
else 
result = sprintf( 'to_unsigned(%d, %d)', temp, outsize );
end 
end 
end 




function result = handlefi( cval, outsize, outbp, outsigned, format )





if ~( ( cval.WordLength == outsize ) && ( cval.FractionLength == outbp ) &&  ...
( cval.Signed == outsigned ) )
warning( message( 'HDLShared:directemit:nonmatchingfi' ) );
end 

if ~isempty( format ) && ~isempty( strmatch( lower( format ), 'hex' ) )
result = hexformat( hex( cval ), outsize, outsigned );
elseif ~isempty( format ) && ~isempty( strmatch( lower( format ), 'bin' ) )
result = sprintf( '"%s"', bin( cval ) );
elseif outsize >= 32
result = binformat( bin( cval ), outsize, outsigned );
elseif ~isempty( format ) && ~isempty( strmatch( lower( format ), 'decimal' ) )
if outsigned
result = sprintf( 'to_signed(%d, %d)', int( cval ), outsize );
else 
result = sprintf( 'to_unsigned(%d, %d)', int( cval ), outsize );
end 
else 
result = binformat( bin( cval ), outsize, outsigned );
end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmpuhMSEF.p.
% Please follow local copyright laws when handling this file.

