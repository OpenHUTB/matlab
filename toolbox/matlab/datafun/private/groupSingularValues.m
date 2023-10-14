function T = groupSingularValues( X, k )

arguments
    X{ mustBeVector }
    k
end

X = X( : );
Z = completeLinkage( X );
T = distanceCluster( Z, k );

end

function Z = completeLinkage( Y )
n = size( Y, 1 );
m = ceil( sqrt( 2 * n ) );
Z = zeros( m - 1, 3, 'like', Y );

N = zeros( 1, 2 * m - 1 );
N( 1:m ) = 1;
n = m;
R = 1:n;

for s = 1:( n - 1 )
    [ v, k ] = min( Y );

    i = floor( m + 1 / 2 - sqrt( m ^ 2 - m + 1 / 4 - 2 * ( k - 1 ) ) );
    j = k - ( i - 1 ) * ( m - i / 2 ) + i;

    Z( s, : ) = [ R( i ), R( j ), v ];

    I1 = 1:( i - 1 );I2 = ( i + 1 ):( j - 1 );I3 = ( j + 1 ):m;
    I = [ I1 .* ( m - ( I1 + 1 ) / 2 ) - m + i, i * ( m - ( i + 1 ) / 2 ) - m + I2, i * ( m - ( i + 1 ) / 2 ) - m + I3 ];
    J = [ I1 .* ( m - ( I1 + 1 ) / 2 ) - m + j, I2 .* ( m - ( I2 + 1 ) / 2 ) - m + j, j * ( m - ( j + 1 ) / 2 ) - m + I3 ];

    Y( I ) = max( Y( I ), Y( J ) );

    J = [ J, i * ( m - ( i + 1 ) / 2 ) - m + j ];%#ok<AGROW>
    Y( J ) = [  ];

    m = m - 1;
    N( n + s ) = N( R( i ) ) + N( R( j ) );
    R( i ) = n + s;
    R( j:( n - 1 ) ) = R( ( j + 1 ):n );
end

Z( :, [ 1, 2 ] ) = sort( Z( :, [ 1, 2 ] ), 2 );
end


function T = distanceCluster( Z, k )

crit = Z( :, 3 );
conn = checkcut( Z, k, crit );
T = labeltree( Z, conn );

end


function conn = checkcut( X, cutoff, crit )

n = size( X, 1 ) + 1;
conn = ( crit <= cutoff );

todo = conn & ( X( :, 1 ) > n | X( :, 2 ) > n );
while ( any( todo ) )
    rows = find( todo );

    cdone = true( length( rows ), 2 );
    for j = 1:2
        crows = X( rows, j );
        t = ( crows > n );
        if any( t )
            child = crows( t ) - n;
            cdone( t, j ) = ~todo( child );
            conn( rows( t ) ) = conn( rows( t ) ) & conn( child );
        end
    end

    todo( rows( cdone( :, 1 ) & cdone( :, 2 ) ) ) = 0;
end
end


function T = labeltree( X, conn )

n = size( X, 1 );
nleaves = n + 1;
T = ones( n + 1, 1 );

todo = true( n, 1 );

clustlist = reshape( 1:2 * n, n, 2 );

while ( any( todo ) )

    rows = find( todo & ~conn );
    if isempty( rows ), break ;end

    for j = 1:2
        children = X( rows, j );

        leaf = ( children <= nleaves );
        if any( leaf )
            T( children( leaf ) ) = clustlist( rows( leaf ), j );
        end

        joint = ~leaf;
        joint( joint ) = conn( children( joint ) - nleaves );
        if any( joint )
            clustnum = clustlist( rows( joint ), j );
            childnum = children( joint ) - nleaves;
            clustlist( childnum, 1 ) = clustnum;
            clustlist( childnum, 2 ) = clustnum;
            conn( childnum ) = 0;
        end
    end

    todo( rows ) = 0;
end

[ ~, ~, T ] = unique( T );
end


