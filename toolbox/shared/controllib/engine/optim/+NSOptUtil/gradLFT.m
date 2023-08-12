function g = gradLFT( SYSDATA, tInfo, x, u, v )




















TuneFlag = isempty( tInfo.UncertainBlocks );
if TuneFlag

Blocks = tInfo.TunedBlocks;
BlockInfo = SYSDATA.TunedBlocks;

p = tInfo.p0;
p( tInfo.iFree ) = x;
else 
Blocks = tInfo.UncertainBlocks;
BlockInfo = SYSDATA.UncertainBlocks;
p = x;
end 



LFTData = SYSDATA.LFTData;
zu = LFTData.beta( 1:size( u, 1 ), : )' * u;
zv = LFTData.gamma( :, 1:size( v, 1 ) ) * v;


g = zeros( numel( x ), 1 );
ix = LFTData.nxP;iu = 0;iy = 0;ip = 0;ipf = 0;
for j = 1:numel( Blocks )
blk = Blocks( j );
npj = blk.np;npfj = blk.npf;
nr = BlockInfo( j ).NRepeat;
if nr > 0
blkData = blk.Data;
nxj = blk.nx;nyj = blk.ny;nuj = blk.nu;

if TuneFlag
jx = tInfo.iFree( ipf + 1:ipf + npfj ) - ip;
else 
jx = 1:npfj;
end 
if nr == 1

uj = [ u( ix + 1:ix + nxj, : );zu( iy + 1:iy + nyj, : ) ];
vj = [ v( ix + 1:ix + nxj, : );zv( iu + 1:iu + nuj, : ) ];
g( ipf + 1:ipf + npfj ) = gradUV( blkData, p( ip + 1:ip + npj ), uj, vj, jx );
ix = ix + nxj;iu = iu + nuj;iy = iy + nyj;
else 
gj = zeros( npfj, 1 );
pj = p( ip + 1:ip + npj );
for ct = 1:nr
uj = [ u( ix + 1:ix + nxj, : );zu( iy + 1:iy + nyj, : ) ];
vj = [ v( ix + 1:ix + nxj, : );zv( iu + 1:iu + nuj, : ) ];
gj = gj + gradUV( blkData, pj, uj, vj, jx );
ix = ix + nxj;iu = iu + nuj;iy = iy + nyj;
end 
g( ipf + 1:ipf + npfj ) = gj;
end 
end 
ip = ip + npj;ipf = ipf + npfj;
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp9lZC7z.p.
% Please follow local copyright laws when handling this file.

