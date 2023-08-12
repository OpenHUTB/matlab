function layout = lineext( layout, blklocs, port_fm, port_to )























if nargin ~= 4
DAStudio.error( 'Simulink:utility:invNumArgsWithAbsValue', mfilename, 4 );
end ;

[ n_l, m_l ] = size( layout );
if n_l < 2
disp( getString( message( 'Simulink:utility:NoLineSegment' ) ) )
disp( getString( message( 'Simulink:utility:ErrorCallingLineext' ) ) )
return ;
end ;
[ n_b, m_b ] = size( blklocs );
if n_b < 1

return ;
end ;
if ( ( m_l ~= 2 ) | ( m_b ~= 4 ) | ( length( port_fm ) ~= 3 ) | ( length( port_to ) ~= 3 ) )
disp( getString( message( 'Simulink:utility:IllegalLengthOfInputVariable' ) ) )
end ;


[ x_min, x_max, y_min, y_max, to_do, n_be, n_en ] = linemima( layout, blklocs );





flag = zeros( n_l, 1 );

while ( ~isempty( to_do ) & n_l < 10 )



if n_be == 1
[ tmp1, tmp2, tmp3, tmp4, tmp5 ] = linemima( layout( 1:2, : ), blklocs );
if ~isempty( tmp5 )
if ( ( ( port_fm( 1 ) == 0 ) & ( tmp1 < layout( 1, 1 ) ) & ( tmp2 > layout( 1, 1 ) ) ) ...
 | ( ( port_fm( 1 ) == 1 ) & ( tmp3 < layout( 1, 2 ) ) & ( tmp4 > layout( 1, 2 ) ) ) ...
 | ( ( port_fm( 1 ) == 2 ) & ( tmp2 > layout( 1, 1 ) ) & ( tmp1 < layout( 1, 1 ) ) ) ...
 | ( ( port_fm( 1 ) == 3 ) & ( tmp4 > layout( 1, 2 ) ) & ( tmp3 < layout( 1, 2 ) ) ) )
disp( getString( message( 'Simulink:utility:DispBlockOverlap' ) ) );
return ;
end ;
end ;
end ;
if n_en == n_l - 1
[ tmp1, tmp2, tmp3, tmp4, tmp5 ] = linemima( layout( n_en:n_l, : ), blklocs );
if ~isempty( tmp5 )
if ( ( ( port_to( 1 ) == 0 ) & ( tmp1 < layout( n_l, 1 ) ) & ( tmp2 > layout( n_l, 1 ) ) ) ...
 | ( ( port_to( 1 ) == 1 ) & ( tmp3 < layout( n_l, 2 ) ) & ( tmp4 > layout( n_l, 2 ) ) ) ...
 | ( ( port_to( 1 ) == 2 ) & ( tmp2 > layout( n_l, 1 ) ) & ( tmp1 < layout( n_l, 1 ) ) ) ...
 | ( ( port_to( 1 ) == 3 ) & ( tmp4 > layout( n_l, 2 ) ) & ( tmp3 < layout( n_l, 2 ) ) ) )
disp( getString( message( 'Simulink:utility:DispBlockOverlap' ) ) );
return ;
end ;
end ;
end ;




straight = 0;
if ( n_be + 1 == n_l ) & ( n_be == 1 )
straight = 1;
elseif ( n_be + 1 == n_l )
if ( max( abs( layout( n_be, : ) - layout( n_be + 1, : ) ) ) >  ...
4 * max( abs( layout( n_be, : ) - layout( n_be - 1, : ) ) ) )
straight = 1;
end ;
elseif ( n_be == 1 ) & ( n_be + 2 >= n_l )
if ( max( abs( layout( n_be, : ) - layout( n_be + 1, : ) ) ) >  ...
4 * max( abs( layout( n_be + 1, : ) - layout( n_be + 2, : ) ) ) )
straight = 1;
end ;
end ;
if straight








direct = linedir( layout( n_be:n_be + 1, : ) );
if direct < 0

return ;
end ;
if ( direct == 1 ) | ( direct == 3 )

layout = fliplr( layout );
layout( :, 1 ) =  - layout( :, 1 );
blklocs( :, 1:2 ) = fliplr( blklocs( :, 1:2 ) );
blklocs( :, 3:4 ) = fliplr( blklocs( :, 3:4 ) );
blklocs( :, [ 1, 3 ] ) = fliplr(  - blklocs( :, [ 1, 3 ] ) );
end ;

if ( direct == 2 ) | ( direct == 1 )

layout =  - layout;
blklocs( :, [ 1, 3 ] ) = fliplr(  - blklocs( :, [ 1, 3 ] ) );
blklocs( :, [ 2, 4 ] ) = fliplr(  - blklocs( :, [ 2, 4 ] ) );
end ;
















[ x_min, x_max, y_min, y_max ] = linemima( layout( n_be:n_be + 1, : ), blklocs );


layout( n_be + 5:n_l + 4, : ) = layout( n_be + 1:n_l, : );
flag( n_be + 5:n_l + 4 ) = flag( n_be + 1:n_l );
flag( n_be:n_be + 4 ) = flag( n_be:n_be + 4 ) * 0;
n_l = n_l + 4;


layout( n_be + 1, 1 ) = min( ( layout( n_be, 1 ) + x_min ) / 2, x_min - 10 );
layout( n_be + 4, 1 ) = max( ( layout( n_be + 5, 1 ) + x_max ) / 2, x_max + 10 );
layout( n_be + 1, 2 ) = layout( n_be, 2 );
layout( n_be + 4, 2 ) = layout( n_be + 5, 2 );
layout( n_be + 2, 1 ) = layout( n_be + 1, 1 );
layout( n_be + 3, 1 ) = layout( n_be + 4, 1 );
layout( n_be + 2, 2 ) = y_max + 10;
layout( n_be + 3, 2 ) = y_max + 10;
again = 1;
odir = 0;
addir = 0;
sudir = 0;

again = 0;
while again <= 10
again = again + 1;



if isempty( blkxchk( layout( n_be + 1:n_be + 2, : ), blklocs ) )
addir = 1;
if isempty( blkxchk( layout( n_be + 3:n_be + 4, : ), blklocs ) )
[ cros_inf, block_n ] = blkxchk( layout( n_be + 2:n_be + 3, : ), blklocs );
if isempty( cros_inf )

again = 11;odir = 0;
else 

tmp_max = max( find( blklocs( block_n, 4 ) == max( blklocs( block_n, 4 ) ) ) );
tmp_max = blklocs( tmp_max, 4 );
layout( n_be + 2, 2 ) = tmp_max + 10 + abs( layout( n_be + 2, 1 ) - layout( n_be + 3, 1 ) ) / 40;
layout( n_be + 3, 2 ) = layout( n_be + 2, 2 );
end ;
end ;
else 
again = 11;
odir = 1;
end ;
end ;
again = 1;
if odir



odir = 0;
layout( n_be + 2, 2 ) = y_min - 10 - abs( layout( n_be + 2, 1 ) - layout( n_be + 3, 1 ) ) / 40;;
layout( n_be + 3, 2 ) = layout( n_be + 2, 2 );
again = 0;
while again <= 10
again = again + 1;
if isempty( blkxchk( layout( n_be + 1:n_be + 2, : ), blklocs ) )
sudir = 1;
if isempty( blkxchk( layout( n_be + 3:n_be + 4, : ), blklocs ) )
[ cros_inf, block_n ] = blkxchk( layout( n_be + 2:n_be + 3, : ), blklocs );
if isempty( cros_inf )

again = 11;odir = 0;
else 

tmp_min = min( find( blklocs( block_n, 2 ) == min( blklocs( block_n, 2 ) ) ) );
tmp_min = blklocs( tmp_min, 2 );
layout( n_be + 2, 2 ) = tmp_min - 10 - abs( layout( n_be + 2, 1 ) - layout( n_be + 3, 1 ) ) / 40;
layout( n_be + 3, 2 ) = layout( n_be + 2, 2 );
end ;
end ;
else 
again = 11;
odir = 1;
end ;
end ;
end ;
if odir == 1
if addir == 1
layout( n_be + 2, 2 ) = y_max + 10 + abs( layout( n_be + 2, 1 ) - layout( n_be + 3, 1 ) ) / 40;
layout( n_be + 3, 2 ) = layout( n_be + 2, 2 );
elseif sudir == 1
layout( n_be + 2, 2 ) = y_min - 10 - abs( layout( n_be + 2, 1 ) - layout( n_be + 3, 1 ) ) / 40;
layout( n_be + 3, 2 ) = layout( n_be + 2, 2 );
else 

layout( n_be + 1:n_l - 4, : ) = layout( n_be + 5:n_l, : );
layout( n_l - 3:n_l, : ) = [  ];
flag( n_l - 3:n_l ) = [  ];
n_l = 11;
end ;
end ;


if ( direct == 2 ) | ( direct == 1 )
layout =  - layout;
blklocs( :, [ 1, 3 ] ) = fliplr(  - blklocs( :, [ 1, 3 ] ) );
blklocs( :, [ 2, 4 ] ) = fliplr(  - blklocs( :, [ 2, 4 ] ) );
end ;

if ( direct == 1 ) | ( direct == 3 )

layout( :, 1 ) =  - layout( :, 1 );
layout = fliplr( layout );
blklocs( :, [ 1, 3 ] ) = fliplr(  - blklocs( :, [ 1, 3 ] ) );
blklocs( :, 1:2 ) = fliplr( blklocs( :, 1:2 ) );
blklocs( :, 3:4 ) = fliplr( blklocs( :, 3:4 ) );
end ;













elseif ( n_be > 1 ) & ( n_be + 1 < n_l ) & ( flag( n_be ) < 1 )









up = 1;dn = 1;


direct = linedir( layout( n_be - 1:n_be, : ) );
if direct < 0

return ;
end ;
if ( direct == 1 ) | ( direct == 3 )

layout = fliplr( layout );
layout( :, 1 ) =  - layout( :, 1 );
blklocs( :, 1:2 ) = fliplr( blklocs( :, 1:2 ) );
blklocs( :, 3:4 ) = fliplr( blklocs( :, 3:4 ) );
blklocs( :, [ 1, 3 ] ) = fliplr(  - blklocs( :, [ 1, 3 ] ) );
end ;

if ( direct == 2 ) | ( direct == 1 )

layout =  - layout;
blklocs( :, [ 1, 3 ] ) = fliplr(  - blklocs( :, [ 1, 3 ] ) );
blklocs( :, [ 2, 4 ] ) = fliplr(  - blklocs( :, [ 2, 4 ] ) );
end ;














while up

[ x_min, x_max, y_min, y_max, test ] =  ...
linemima( layout( n_be:n_be + 1, : ), blklocs );
if isempty( test )
dn = 0;
up = 0;
else 

if isempty( blkxchk( [ layout( n_be - 1, : );x_max + 10, layout( n_be, 2 ) ], blklocs ) )
if x_max < layout( n_be + 1, 1 )
layout( n_be, 1 ) = x_max + 10 + abs( layout( n_be, 2 ) - layout( n_be + 1, 2 ) ) / 40;
layout( n_be + 1, 1 ) = layout( n_be, 1 );
elseif n_be + 1 ~= n_l
layout( n_be, 1 ) = x_max + 10 + abs( layout( n_be, 2 ) - layout( n_be + 1, 2 ) ) / 40;
layout( n_be + 1, 1 ) = layout( n_be, 1 );
else 
up = 0;
end ;
else 
up = 0;
end ;
end ;
end ;
while dn

[ x_min, x_max, y_min, y_max, test ] =  ...
linemima( layout( n_be:n_be + 1, : ), blklocs );
if isempty( test )
dn = 0;
up = 0;
else 

if isempty( blkxchk( [ layout( n_be - 1, : );x_min - 10, layout( n_be, 2 ) ], blklocs ) )
if x_max < layout( n_be + 1, 1 )
layout( n_be, 1 ) = x_min - 10 - abs( layout( n_be, 2 ) - layout( n_be + 1, 2 ) ) / 40;
layout( n_be + 1, 1 ) = layout( n_be, 1 );
elseif n_be + 1 ~= n_l
layout( n_be, 1 ) = x_min - 10 - abs( layout( n_be, 2 ) - layout( n_be + 1, 2 ) ) / 40;
layout( n_be + 1, 1 ) = layout( n_be, 1 );
else 
dn = 0;
end ;
else 
dn = 0;
flag( n_be ) = 1 + flag( n_be );
end ;
end ;
end ;


if ( direct == 2 ) | ( direct == 1 )
layout =  - layout;
blklocs( :, [ 1, 3 ] ) = fliplr(  - blklocs( :, [ 1, 3 ] ) );
blklocs( :, [ 2, 4 ] ) = fliplr(  - blklocs( :, [ 2, 4 ] ) );
end ;

if ( direct == 1 ) | ( direct == 3 )

layout( :, 1 ) =  - layout( :, 1 );
layout = fliplr( layout );
blklocs( :, [ 1, 3 ] ) = fliplr(  - blklocs( :, [ 1, 3 ] ) );
blklocs( :, 1:2 ) = fliplr( blklocs( :, 1:2 ) );
blklocs( :, 3:4 ) = fliplr( blklocs( :, 3:4 ) );
end ;












elseif flag( n_be ) < 10








revers = 0;
if n_be + 1 == n_l
revers = 1;
layout = flipud( layout );
n_be = 1;n_en = 2;
end ;


direct = linedir( layout( n_be:n_be + 1, : ) );
if direct < 0

return ;
end ;

if ( direct == 1 ) | ( direct == 3 )

layout = fliplr( layout );
layout( :, 1 ) =  - layout( :, 1 );
blklocs( :, 1:2 ) = fliplr( blklocs( :, 1:2 ) );
blklocs( :, 3:4 ) = fliplr( blklocs( :, 3:4 ) );
blklocs( :, [ 1, 3 ] ) = fliplr(  - blklocs( :, [ 1, 3 ] ) );
end ;

if ( direct == 2 ) | ( direct == 1 )

layout =  - layout;
blklocs( :, [ 1, 3 ] ) = fliplr(  - blklocs( :, [ 1, 3 ] ) );
blklocs( :, [ 2, 4 ] ) = fliplr(  - blklocs( :, [ 2, 4 ] ) );
end ;
















[ x_min, x_max, y_min, y_max ] = linemima( layout( n_be:n_be + 1, : ), blklocs );


direct2 = linedir( layout( n_be + 1:n_be + 2, : ) );



layout( n_be + 3:n_l + 2, : ) = layout( n_be + 1:n_l, : );
flag( n_be + 3:n_l + 2 ) = flag( n_be + 1:n_l );
flag( n_be + 1:n_be + 2 ) = flag( n_be + 1:n_be + 2 ) * 0;
n_l = n_l + 2;


layout( n_be + 1, 1 ) = min( ( layout( n_be, 1 ) + x_min ) / 2, x_min - 10 );
layout( n_be + 2, 1 ) = layout( n_be, 1 );
if direct2 == 1
layout( n_be + 3, 2 ) = max( ( layout( n_be + 3, 2 ) + y_max ) / 2, y_max + 10 );
else 
layout( n_be + 3, 2 ) = min( ( layout( n_be + 3, 2 ) + y_min ) / 2, y_min - 10 );
end ;
layout( n_be + 2, 1 ) = layout( n_be + 1, 1 );
layout( n_be + 2, 2 ) = layout( n_be + 3, 2 );

odir = 0;
addir = 0;
sudir = 0;
thdir = 0;
frdir = 0;
again = 1;test = 0;
while again & ( test < 10 )
test = test + 1;
if addir == 0

[ tmp_x_min, tmp_x_max, tmp_y_min, tmp_y_max, tmp_x ] =  ...
linemima( layout( n_be:n_be + 1, : ), blklocs );
addir = 1;
if ~isempty( tmp_x )
if tmp_x_max < x_min
layout( n_be + 1, 1 ) = ( x_min + tmp_x_max ) / 2;
sudir = 0;
elseif tmp_x_min > layout( n_be, 1 )
layout( n_be + 1, 1 ) = min( ( layout( n_be, 1 ) + tmp_x_min ) / 2, tmp_x_min - 10 );
thdir = 0;sudir = 0;
else 

odir = 1;addir = 0;sudir = 0;again = 0;
end ;
layout( n_be + 2, 1 ) = layout( n_be + 1, 1 );
end ;
end ;

if sudir == 0

[ tmp_x_min, tmp_x_max, tmp_y_min, tmp_y_max, tmp_x ] =  ...
linemima( layout( n_be + 1:n_be + 2, : ), blklocs );
sudir = 1;
if ~isempty( tmp_x )
if ( tmp_x_max < x_min )
layout( n_be + 2, 1 ) = ( tmp_x_max + x_min ) / 2;
elseif ( tmp_y_min > y_max ) & ( direct2 == 1 )
layout( n_be + 2, 2 ) = ( tmp_y_min + y_max ) / 2;
thdir = 0;
frdir = 0;
elseif ( tmp_y_max < y_min ) & ( direct2 == 3 )
layout( n_be + 2, 2 ) = ( tmp_y_max + y_min ) / 2;
thdir = 0;
frdir = 0;
elseif ( tmp_x_min > layout( n_be, 1 ) )
layout( n_be + 2, 1 ) = min( ( tmp_x_min + layout( n_be, 1 ) ) / 2, tmp_x_min - 10 );
sudir = 0;
thdir = 0;
else 

sudir = 0;
odir = 1;
again = 0;
end ;
end ;

layout( n_be + 3, 2 ) = layout( n_be + 2, 2 );
layout( n_be + 1, 1 ) = layout( n_be + 2, 1 );
end ;
if thdir == 0

[ tmp_x_min, tmp_x_max, tmp_y_min, tmp_y_max, tmp_x ] =  ...
linemima( layout( n_be + 2:n_be + 3, : ), blklocs );
thdir = 1;
if ~isempty( tmp_x )
if ( tmp_x_max < x_min )
layout( n_be + 2, 1 ) = ( tmp_x_max + x_min ) / 2;
sudir = 0;
elseif ( tmp_y_max > y_max ) & ( tmp_y_max < layout( n_be + 4, 2 ) ) & ( direct2 == 1 )

layout( n_be + 3, 2 ) = max( ( tmp_x_max + layout( n_be + 4, 2 ) ) / 2, tmp_x_max );
sudir = 0;
thdir = 0;
elseif ( tmp_y_min < y_min ) & ( tmp_y_min > layout( n_be + 4, 2 ) ) & ( direct2 == 3 )

layout( n_be + 3, 2 ) = min( ( tmp_x_min + layout( n_be + 4, 2 ) ) / 2, tmp_x_min - 10 );
sudir = 0;
thdir = 0;
elseif ( tmp_y_min > layout( n_be + 4, 2 ) ) & ( direct2 == 3 )
layout( n_be + 3, 2 ) = ( tmp_y_min > layout( n_be + 4, 2 ) ) / 2;
elseif ( tmp_y_max < layout( n_be + 4, 2 ) ) & ( direct2 == 13 )
layout( n_be + 3, 2 ) = ( tmp_y_max > layout( n_be + 4, 2 ) ) / 2;
else 

sudir = 0;
odir = 1;
again = 0;
end ;
layout( n_be + 2, 2 ) = layout( n_be + 3, 2 );
layout( n_be + 1, 1 ) = layout( n_be + 2, 1 );
end ;
end ;
if frdir == 0;

[ tmp_x_min, tmp_x_max, tmp_y_min, tmp_y_max, tmp_x ] =  ...
linemima( layout( n_be + 3:n_be + 4, : ), blklocs );
thdir = 1;
if ~isempty( tmp_x )
if ( tmp_y_max < layout( n_be + 4, 2 ) ) & ( direct2 == 1 )
layout( n_be + 3, 2 ) = max( ( layout( n_be + 4, 2 ) + tmp_y_max ) / 2, tmp_y_max + 10 );
thdir = 0;
elseif ( tmp_y_min > layout( n_be + 4, 2 ) ) & ( direct2 == 3 )
layout( n_be + 3, 2 ) = min( ( layout( n_be + 4, 2 ) + tmp_y_min ) / 2, tmp_y_min - 10 );
thdir = 0;
else 
thdir = 0;odir = 0;
again = 0;
end ;
layout( n_be + 2, 2 ) = layout( n_be + 3, 2 );
end ;
end ;
end ;


if ( direct == 2 ) | ( direct == 1 )
layout =  - layout;
blklocs( :, [ 1, 3 ] ) = fliplr(  - blklocs( :, [ 1, 3 ] ) );
blklocs( :, [ 2, 4 ] ) = fliplr(  - blklocs( :, [ 2, 4 ] ) );
end ;

if ( direct == 1 ) | ( direct == 3 )

layout( :, 1 ) =  - layout( :, 1 );
layout = fliplr( layout );
blklocs( :, [ 1, 3 ] ) = fliplr(  - blklocs( :, [ 1, 3 ] ) );
blklocs( :, 1:2 ) = fliplr( blklocs( :, 1:2 ) );
blklocs( :, 3:4 ) = fliplr( blklocs( :, 3:4 ) );
end ;














if revers
layout = flipud( layout );
revers = 0;
end ;
else 
n_l = 11;
end ;


[ x_min, x_max, y_min, y_max, to_do, n_be, n_en ] =  ...
linemima( layout, blklocs );
end ;


for j = 1:3
[ n_l, m_l ] = size( layout );
if n_l > 5
tmp = [  ];
i = 1;
while i < n_l - 3
i = i + 1;
tmp( 1, : ) = layout( i - 1, : );
tmp( 3, : ) = layout( i + 2, : );
if rem( i, 2 ) == 0
tmp( 2, 2 ) = layout( i - 1, 2 );
tmp( 2, 1 ) = layout( i + 2, 1 );
else 
tmp( 2, 1 ) = layout( i - 1, 1 );
tmp( 2, 2 ) = layout( i + 2, 2 );
end ;
if isempty( blkxchk( tmp( 1:2, : ), blklocs ) )
if isempty( blkxchk( tmp( 2:3, : ), blklocs ) )
layout( i, : ) = tmp( 2, : );
layout( i + 1:i + 2, : ) = [  ];
n_l = n_l - 2;
end ;
end ;
end ;
end ;
end ;


% Decoded using De-pcode utility v1.2 from file /tmp/tmpUGPrMz.p.
% Please follow local copyright laws when handling this file.

