function [ abcd, ir, jc ] = padess( T, N, needs_scalar_expansion )















A = [  ];B = [  ];C = [  ];D = [  ];
mA = [  ];mB = [  ];mC = [  ];mD = [  ];

len = length( T );
if length( N ) ~= len
DAStudio.error( 'Simulink:util:DelayAndOrderEqualLength' );
end 

for i = 1:len
n = N( i );
[ Ai, Bi, Ci, Di ] = local_pade( T( i ), n );
A = blkdiag( A, Ai );
B = blkdiag( B, Bi );
C = blkdiag( C, Ci );
D = blkdiag( D, Di );
mA = blkdiag( mA, [ ones( 1, n );[ eye( n - 1 ), zeros( n - 1, 1 ) ] ] );
mB = blkdiag( mB, [ ones( n > 0, 1 );zeros( n - 1, 1 ) ] );
mc = zeros( 1, n );mc( 1:2:n ) = 1;
mC = blkdiag( mC, mc );
mD = blkdiag( mD, 1 );
end 

if needs_scalar_expansion

B = B * ones( size( B, 2 ), 1 );
mB = mB * ones( size( mB, 2 ), 1 );

D = D * ones( size( D, 2 ), 1 );
mD = mD * ones( size( mD, 2 ), 1 );
end 

mask = logical( [ mA, mB;mC, mD ] );
ABCD = [ A, B;C, D ];
abcd = ABCD( mask );
[ ix, jx ] = find( mask );

ir = ix - 1;
jc = 0:length( ir );
jc = jc( find( diff( [  - 1;jx;max( jx ) + 1 ] ) ) )';




ABCD( mask ) = 0;
if any( ABCD( : ) )
DAStudio.error( 'Simulink:util:NonZeroOtherEntries' );
end 

if sum( mask( : ) ) ~= max( jc )
DAStudio.error( 'Simulink:util:WrongElementCount' );
end 



function [ A, B, C, D ] = local_pade( T, n )

if T == 0 || n == 0
A = zeros( n );
B = zeros( n, 1 );
C = zeros( 1, n );
D = 1;

else 
a = zeros( 1, n + 1 );a( 1 ) = 1;
b = zeros( 1, n + 1 );b( 1 ) = 1;
for k = 1:n, 
fact = T * ( n - k + 1 ) / ( 2 * n - k + 1 ) / k;
a( k + 1 ) = (  - fact ) * a( k );
b( k + 1 ) = fact * b( k );
end 
a = fliplr( a / b( n + 1 ) );
b = fliplr( b / b( n + 1 ) );


[ A, B, C, D ] = tf2ss( a, b );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp8kfpBq.p.
% Please follow local copyright laws when handling this file.

