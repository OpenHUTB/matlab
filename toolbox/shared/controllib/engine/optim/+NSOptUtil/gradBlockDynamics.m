function J = gradBlockDynamics( tInfo, iblk, p, U, V, tau )






ZEROTOL = 100 * eps;
nB = size( U, 2 );
if nargin < 6
tau = ones( nB, 1 );
end 



J = NaN( numel( p ), nB );
for k = 1:nB

u = U( :, k );
v = V( :, k );
vu = v' * u;
if abs( vu ) > ZEROTOL
J( :, k ) = localGradBlock( tInfo, iblk, p, ( tau( k ) / vu ) * u, v );
end 
end 




function g = localGradBlock( tInfo, iB, x, u, v )







g = zeros( numel( x ), 1 );
n = size( u, 2 );

p = tInfo.p0;
p( tInfo.iFree ) = x;

blk = tInfo.TunedBlocks( iB );
npf = blk.npf;
ip = sum( [ tInfo.TunedBlocks( 1:iB - 1 ).np ] );
ipf = sum( [ tInfo.TunedBlocks( 1:iB - 1 ).npf ] );
jx = tInfo.iFree( ipf + 1:ipf + npf ) - ip;

u = [ u;zeros( blk.ny, n ) ];
v = [ v;zeros( blk.nu, n ) ];
g( ipf + 1:ipf + npf ) = gradUV( blk.Data, p( ip + 1:ip + blk.np ), u, v, jx );

% Decoded using De-pcode utility v1.2 from file /tmp/tmpPJ8Dar.p.
% Please follow local copyright laws when handling this file.

