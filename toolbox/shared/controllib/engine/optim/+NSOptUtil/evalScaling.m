function tInfo = evalScaling( tInfo, p )









nL = tInfo.nL;
LS = tInfo.LoopScalings;
npS = sum( [ LS.np ] );
if nL > 0 && npS > 0
np = numel( p );
p = p( np - npS + 1:np );
nxS = sum( [ LS.nx ] );
nw = tInfo.nw;
nz = tInfo.nz;
AL = zeros( nxS );BL = zeros( nxS, nz + nL );CL = zeros( nz + nL, nxS );DL = eye( nz + nL );
AR = zeros( nxS );BR = zeros( nxS, nw + nL );CR = zeros( nw + nL, nxS );DR = eye( nw + nL );
pL = zeros( nxS, 1 );pR = zeros( nxS, 1 );
ix = 0;iL = nz;iR = nw;ip = 0;
for ct = 1:nL
np = LS( ct ).np;
nc = LS( ct ).nc;
if np > 0
ns = LS( ct ).ns;
nx = LS( ct ).nx;
if ns > 0
lambda = p( ip + 1 );
else 
lambda = 0;
end 
if nx > 0
ipx = ip + ns;
a = p( ipx + 1:ipx + nx );
b = p( ipx + nx + 1:ipx + 2 * nx );

[ AL( ix + 1:ix + nx, ix + 1:ix + nx ), BL( ix + 1:ix + nx, iL + 1:iL + nc ),  ...
CL( iL + 1:iL + nc, ix + 1:ix + nx ), DL( iL + 1:iL + nc, iL + 1:iL + nc ),  ...
pL( ix + 1:ix + nx, 1 ) ] = localRealizeScaling(  - lambda, b, a );

[ AR( ix + 1:ix + nx, ix + 1:ix + nx ), BR( ix + 1:ix + nx, iR + 1:iR + nc ),  ...
CR( iR + 1:iR + nc, ix + 1:ix + nx ), DR( iR + 1:iR + nc, iR + 1:iR + nc ),  ...
pR( ix + 1:ix + nx, 1 ) ] = localRealizeScaling( lambda, a, b );
else 
DL( iL + 1:iL + nc, iL + 1:iL + nc ) = exp(  - lambda );
DR( iR + 1:iR + nc, iR + 1:iR + nc ) = exp( lambda );
end 
ip = ip + np;
ix = ix + nx;
end 
iL = iL + nc;
iR = iR + nc;
end 
tInfo.DL.a = AL;tInfo.DL.b = BL;tInfo.DL.c = CL;tInfo.DL.d = DL;tInfo.DL.Poles = pL;
tInfo.DR.a = AR;tInfo.DR.b = BR;tInfo.DR.c = CR;tInfo.DR.d = DR;tInfo.DR.Poles = pR;
end 


function [ a, b, c, d, p ] = localRealizeScaling( lambda, alpha, beta )




N = numel( alpha );
a = zeros( N );
b = zeros( N, 1 );
aux = exp( lambda / 2 );
if N > 0
a( 1, : ) =  - beta;a( 2:N + 1:end  ) = 1;b( 1 ) = aux;
end 
d = aux ^ 2;
c = aux * ( alpha - beta );
p = eig( a );

% Decoded using De-pcode utility v1.2 from file /tmp/tmpcXHd7s.p.
% Please follow local copyright laws when handling this file.

