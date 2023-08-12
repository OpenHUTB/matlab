function SYSDATA = evalLFT( SYSDATA, tInfo, x )
















if isempty( tInfo.UncertainBlocks )

Blocks = tInfo.TunedBlocks;
BlockInfo = SYSDATA.TunedBlocks;

p = tInfo.p0;
p( tInfo.iFree ) = x;
nxB = SYSDATA.nxB;
nwB = SYSDATA.nwB;
nzB = SYSDATA.nzB;
else 

Blocks = tInfo.UncertainBlocks;
BlockInfo = SYSDATA.UncertainBlocks;
p = x;
nxB = SYSDATA.nxU;
nwB = SYSDATA.nwU;
nzB = SYSDATA.nzU;
end 


Ac = zeros( nxB );
Bc = zeros( nxB, nzB );
Cc = zeros( nwB, nxB );
Dc = zeros( nwB, nzB );
ix = 0;iu = 0;iy = 0;ip = 0;
for j = 1:numel( Blocks )
blk = Blocks( j );
npj = blk.np;
nr = BlockInfo( j ).NRepeat;
if nr > 0

[ acj, bcj, ccj, dcj ] = p2ss( blk.Data, p( ip + 1:ip + npj ) );
nxj = size( acj, 1 );
[ nyj, nuj ] = size( dcj );
Offsets = BlockInfo( j ).Offset;
for ct = 1:nr
Ac( ix + 1:ix + nxj, ix + 1:ix + nxj ) = acj;
Bc( ix + 1:ix + nxj, iu + 1:iu + nuj ) = bcj;
Cc( iy + 1:iy + nyj, ix + 1:ix + nxj ) = ccj;
Dc( iy + 1:iy + nyj, iu + 1:iu + nuj ) = dcj - Offsets( :, :, ct );
ix = ix + nxj;iu = iu + nuj;iy = iy + nyj;
end 
end 
ip = ip + npj;
end 


A = SYSDATA.A;
B = SYSDATA.B;
C = SYSDATA.C;
D = SYSDATA.D;
nx = size( A, 1 );
ny = size( D, 1 ) - nzB;
nu = size( D, 2 ) - nwB;
Acl = [ A, zeros( nx, nxB );zeros( nxB, nx ), Ac ];
Bcl = [ B( :, 1:nu );zeros( nxB, nu ) ];
Ccl = [ C( 1:ny, : ), zeros( ny, nxB ) ];
Dcl = D( 1:ny, 1:nu );
auxB = [ zeros( nx, nzB ), B( :, nu + 1:nu + nwB );Bc, zeros( nxB, nwB ); ...
zeros( ny, nzB ), D( 1:ny, nu + 1:nu + nwB ) ];
auxC = [ C( ny + 1:ny + nzB, : ), zeros( nzB, nxB ), D( ny + 1:ny + nzB, 1:nu ); ...
zeros( nwB, nx ), Cc, zeros( nwB, nu ) ];


D22 = D( ny + 1:ny + nzB, nu + 1:nu + nwB );
if norm( D22, 1 ) + norm( Dc, 1 ) > 0



auxD = [ eye( nzB ),  - D22; - Dc, eye( nwB ) ];
auxDC = auxD\auxC;
auxBD = auxB / auxD;
else 
auxDC = auxC;auxBD = auxB;
end 
S = auxB * auxDC;
nxcl = nx + nxB;
SYSDATA.Acl = Acl + S( 1:nxcl, 1:nxcl );
SYSDATA.Bcl = Bcl + S( 1:nxcl, nxcl + 1:nxcl + nu );
SYSDATA.Ccl = Ccl + S( nxcl + 1:nxcl + ny, 1:nxcl );
SYSDATA.Dcl = Dcl + S( nxcl + 1:nxcl + ny, nxcl + 1:nxcl + nu );


SYSDATA.LFTData = struct( 'nxP', nx, 'nxC', nxB,  ...
'beta', auxBD( :, nzB + 1:nzB + nwB ), 'gamma', auxDC( 1:nzB, : ),  ...
'SingularFlag', ~isfinite( norm( S, 1 ) ) );

% Decoded using De-pcode utility v1.2 from file /tmp/tmpjTH1Zb.p.
% Please follow local copyright laws when handling this file.

