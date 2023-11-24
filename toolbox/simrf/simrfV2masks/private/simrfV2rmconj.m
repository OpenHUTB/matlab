function xrmconj = simrfV2rmconj( x, tol )

if isempty( x )
xrmconj = x;
return 
end 

validateattributes( x, { 'numeric' }, { 'ncols', 2, 'finite' }, mfilename, 'x' );

if nargin < 2 || isempty( tol )
tol = 100 * eps( class( x ) );
else 
validateattributes( tol, { 'numeric' }, { 'scalar', 'positive' },  ...
mfilename, 'tol', 2 );
end 

xtemp = x;
x_len = size( xtemp, 1 );

xtemp_idx = 1:x_len;

real_idx = xtemp_idx( all( abs( imag( xtemp ) ) <= tol * abs( xtemp ), 2 ) );
num_reals = numel( real_idx );
num_cplx = x_len - num_reals;
if num_cplx > 0

validateattributes( num_cplx, { 'numeric' }, { 'even', 'integer' },  ...
mfilename, 'number of complex poles of the rational function' )
end 


xidx = NaN( ( x_len + num_reals ) / 2, 1 );
xrmconj = NaN( ( x_len + num_reals ) / 2, 2 );
if ~isempty( real_idx )


tmp_idx = num_cplx / 2 + 1;
[ ~, realSorted_idx ] = sort( real( xtemp( real_idx, 1 ) ) );
xidx( tmp_idx:end  ) = real_idx( realSorted_idx );
xrmconj( tmp_idx:end , : ) = xtemp( real_idx, : );

xtemp( real_idx, : ) = [  ];
xtemp_idx( real_idx ) = [  ];
end 


[ ~, cpxre_idx ] = sort( real( xtemp( :, 1 ) ) );
xtemp = xtemp( cpxre_idx, : );
xtemp_idx = xtemp_idx( cpxre_idx );

maxRealVals = max( abs( real( xtemp( 1:2:num_cplx, : ) ) ),  ...
abs( real( xtemp( 2:2:num_cplx, : ) ) ) );

validateattributes(  ...
abs( real( xtemp( 1:2:num_cplx, : ) ) - real( xtemp( 2:2:num_cplx, : ) ) ) >  ...
eps( maxRealVals ) .* [ 1e4, 1e9 ], { 'logical' },  ...
{ 'ncols', 2, 'even' }, mfilename,  ...
'number of complex poles of the rational function' )

nxt_row = 1;

while nxt_row < num_cplx

realTol = eps( real( xtemp( nxt_row, 1 ) ) ) * 1e4;
equal_re_idx =  ...
find( abs( real( xtemp( :, 1 ) - real( xtemp( nxt_row, 1 ) ) ) ) <= realTol );

re_len = length( equal_re_idx );

validateattributes( re_len, { 'numeric' }, { 'integer', 'even' },  ...
mfilename, 'number of complex poles of the rational function' )

[ ~, cplxpair_idx ] = sort( imag( xtemp( equal_re_idx, 1 ) ), 'descend' );
ximag = imag( xtemp( cplxpair_idx, : ) );
xq = xtemp( equal_re_idx( cplxpair_idx ), : );

validateattributes(  ...
abs( ximag + ximag( re_len: - 1:1, : ) ) > eps( abs( imag( xq ) ) ) .* [ 1e4, 1e9 ],  ...
{ 'logical' }, { 'ncols', 2, 'even' }, mfilename,  ...
'complex conjugate poles of the rational function' )
out_row = ( ( nxt_row - 1 ) / 2 ) + 1;

xrmconj( out_row:out_row + re_len / 2 - 1, : ) =  ...
[ xq( 1:re_len / 2, 1 ), xq( 1:re_len / 2, 2 ) * 2 ];
xidx( out_row:out_row + re_len / 2 - 1 ) =  ...
xtemp_idx( equal_re_idx( cplxpair_idx( 1:re_len / 2 ) ) );


nxt_row = nxt_row + re_len;
end 




