function [ x_min, x_max, y_min, y_max, to_do, n_be, n_en ] = linemima( layout, blklocs )





[ n_l, m_l ] = size( layout );

block_n = [  ];
to_do = [  ];
for i = n_l - 1: - 1:1
[ tmpx, tmpy ] = blkxchk( layout( i:i + 1, : ), blklocs );
if ~isempty( tmpx )
to_do = [ i, to_do ];
cros_inf = tmpx;
block_n = tmpy;
end ;
end ;
n_be = min( to_do );
n_en = max( to_do );



if isempty( block_n )
x_min = max( blklocs( :, 3 ) );
x_max = min( blklocs( :, 1 ) );
y_min = max( blklocs( :, 4 ) );
y_max = min( blklocs( :, 2 ) );
else 
x_min = min( find( blklocs( block_n, 1 ) == min( blklocs( block_n, 1 ) ) ) );
x_max = max( find( blklocs( block_n, 3 ) == max( blklocs( block_n, 3 ) ) ) );
y_min = min( find( blklocs( block_n, 2 ) == min( blklocs( block_n, 2 ) ) ) );
y_max = max( find( blklocs( block_n, 4 ) == max( blklocs( block_n, 4 ) ) ) );
x_min = blklocs( block_n( x_min ), 1 );
x_max = blklocs( block_n( x_max ), 3 );
y_min = blklocs( block_n( y_min ), 2 );
y_max = blklocs( block_n( y_max ), 4 );
end ;



% Decoded using De-pcode utility v1.2 from file /tmp/tmpbhZNjX.p.
% Please follow local copyright laws when handling this file.

