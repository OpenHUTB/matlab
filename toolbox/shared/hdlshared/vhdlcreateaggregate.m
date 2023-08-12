function result = vhdlcreateaggregate( value, outsize, outbp, outsigned )






result = '(';

if outsize == 0
result = sprintf( '%E', value );
elseif outsize == 1
result = sprintf( '''%d''', value ~= 0 );
else 
temp = floor( ( double( value ) * ( 2 ^ outbp ) ) + 0.5 );
if temp < 0 && outsigned == 0
error( message( 'HDLShared:directemit:negunsignedaggregate', temp ) );
end 

binform = mydec2bin( temp, outsize, outsigned, temp < 0 );
binform( binform == '/' ) = '1';
lenbin = length( binform );

if ( temp >= 0 ) && lenbin >= outsize && outsigned && binform( 1 ) == '1'
binform = char( [ '0', '1' * ones( 1, lenbin - 1 ) ] );
end 

if lenbin > outsize
error( message( 'HDLShared:directemit:invalidlengths', lenbin, outsize ) );




elseif lenbin < outsize
if temp >= 0
binform = [ ones( 1, outsize - lenbin ) .* '0', binform ];
lenbin = outsize;
else 
binform = [ ones( 1, outsize - lenbin ) .* '1', binform ];
lenbin = outsize;
end 
end 
onescount = sum( binform == '1' );
zeroscount = lenbin - onescount;
if onescount == lenbin
result = '(OTHERS => ''1'')';
elseif zeroscount == lenbin
result = '(OTHERS => ''0'')';
elseif onescount < zeroscount
result = [ result, parsebinform( binform, '1', '0' ) ];
else 
result = [ result, parsebinform( binform, '0', '1' ) ];
end 
end 

function result = parsebinform( binform, val1, val2 );
result = '';
list = ( length( binform ) - find( binform == val1 ) );
lastn = list( 1 );
in_run = 0;
for n = list( 2:end  )
if n == lastn - 1;
if in_run == 0
result = [ result, num2str( lastn ), ' DOWNTO ' ];
in_run = 1;
end 
else 
result = [ result, num2str( lastn ), ' => ''', val1, ''', ' ];
in_run = 0;
end 
lastn = n;
end 

result = [ result, num2str( list( end  ) ), ' => ''', val1, ''', ' ];

result = [ result, ' OTHERS => ''', val2, ''')' ];


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




% Decoded using De-pcode utility v1.2 from file /tmp/tmpdh3Xme.p.
% Please follow local copyright laws when handling this file.

