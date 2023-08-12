function result = verilogconstantvalue( cval, outsize, outbp, outsigned, format )








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

result = sprintf( '''h%s', num2hex( cval ) );
else 
result = sprintf( '%21.16E', double( cval ) );
end 
elseif outsize == 1
result = sprintf( '1''b%d', cval ~= 0 );
else 
if isinf( cval ) && cval > 0
if outsigned
result = sprintf( '%d''b0%s', outsize, char( '1' * ones( 1, outsize - 1 ) ) );
else 
result = sprintf( '%d''b%s', outsize, char( '1' * ones( 1, outsize ) ) );
end 
elseif isinf( cval ) && cval < 0
if outsigned
result = sprintf( '%d''b1%s', outsize, char( '0' * ones( 1, outsize - 1 ) ) );
else 
error( message( 'HDLShared:directemit:negvalue' ) );
end 
else 

if isa( cval, 'double' ) || isa( cval, 'single' ) || isinteger( cval ) || islogical( cval )
temp = floor( ( double( cval ) * ( 2 ^ outbp ) ) + 0.5 );

if temp < 0 && outsigned == 0
error( message( 'HDLShared:directemit:negvalue' ) );
end 

hexsize = ceil( outsize / 4 );

if ( ~isempty( format ) && ~isempty( strmatch( lower( format ), 'hex' ) ) ) || outsize >= 32
hexstr = mydec2hex( temp, hexsize, outsigned, ( temp < 0 ) );
result = sprintf( '%d''h%s', outsize, hexstr );
elseif ~isempty( format ) && ~isempty( strmatch( lower( format ), 'decimal' ) )
if temp < 0
result = sprintf( '-%d''d%d', outsize,  - temp );
else 
result = sprintf( '%d''d%d', outsize, temp );
end 
else 
if temp < 0
temp = 2 ^ outsize + temp;
end 
result = sprintf( '%d''b%s', outsize, dec2bin( temp, outsize ) );
end 
elseif isa( cval, 'embedded.fi' )




if ~( ( cval.WordLength == outsize ) && ( cval.FractionLength == outbp ) &&  ...
( cval.Signed == outsigned ) )
warning( message( 'HDLShared:directemit:nonmatchingfi' ) );
end 

if ( ~isempty( format ) && ~isempty( strmatch( lower( format ), 'hex' ) ) ) || outsize >= 32
result = sprintf( '%d''h%s', outsize, hex( cval ) );
elseif ~isempty( format ) && ~isempty( strmatch( lower( format ), 'decimal' ) )
if cval < 0
result = sprintf( '-%d''d%d', outsize, int(  - cval ) );
else 
result = sprintf( '%d''d%d', outsize, int( cval ) );
end 
else 
result = sprintf( '%d''b%s', outsize, bin( cval ) );
end 
else 
error( message( 'HDLShared:directemit:UnknownType', class( cval ) ) );
end 

end 
end 


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






% Decoded using De-pcode utility v1.2 from file /tmp/tmpUHWR6m.p.
% Please follow local copyright laws when handling this file.

