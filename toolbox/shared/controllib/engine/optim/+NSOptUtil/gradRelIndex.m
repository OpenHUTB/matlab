function [ J, f ] = gradRelIndex( SPECDATA, SYSDATA, tInfo, RMAX, x, wB, fB, UB, VB )








np = numel( x );


nx0 = size( SYSDATA.Acl, 1 );
[ nzL, nwL ] = size( SYSDATA.Dcl );
iu = SPECDATA.Input;
iy = SPECDATA.Output;
SuppliedH = ( nargin > 6 );
Ts = tInfo.Ts;
FID = SYSDATA.FixedInteg;
W1 = SPECDATA.Sector.W1;
W2 = SPECDATA.Sector.W2;


xPerf = SPECDATA.xPerf;
nxr = numel( xPerf );
sxr = SYSDATA.Scaling.sx( xPerf, : );


Acl = SPECDATA.Acl;Bcl = SPECDATA.Bcl;Ccl = SPECDATA.Ccl;Dcl = SPECDATA.Dcl;
Ucl = SPECDATA.Ucl;
nx = size( Acl, 1 );
[ ny, nu ] = size( Dcl );


noWT = true;
WL = SPECDATA.WL;
if isempty( WL )
bL = zeros( 0, ny );dL = eye( ny );
else 
bL = WL.b;dL = WL.d;noWT = false;
end 
WR = SPECDATA.WR;
if isempty( WR )
cR = zeros( nu, 0 );dR = eye( nu );
else 
cR = WR.c;dR = WR.d;noWT = false;
end 
T = SPECDATA.Transform;
if isempty( T )
nxE = 0;
else 
nxE = size( T.E.a, 1 );
bL = bL * T.F;dL = dL * T.F;
cR = T.G * cR;dR = T.G * dR;
noWT = false;
end 
nxWL = size( bL, 1 );
nxWR = size( cR, 2 );


nB = numel( wB );
f = zeros( nB, 1 );
J = zeros( np, nB );
uk = zeros( nx0, 1 );
vk = zeros( nx0, 1 );
zk = zeros( nzL, 1 );
wk = zeros( nwL, 1 );
if Ts > 0
szB = complex( cos( Ts * wB ), sin( Ts * wB ) );
else 
szB = complex( 0, wB );
end 
for k = 1:nB
sz = szB( k );
if isinf( sz )

if SuppliedH

fObj = fB( k );u = UB( :, k );v = VB( :, k );
else 
[ ~, u1, v1, w1, c1, s1 ] = ltipack.util.gsvmax( W1' * Dcl, W2' * Dcl, 0 );
if isempty( u1 )
u = zeros( ny, 1 );v = zeros( nu, 1 );
else 
u = ( s1 * W1 * u1 - c1 * W2 * v1 ) / ( s1 + c1 / RMAX ) ^ 2;v = w1;
end 
fObj = c1 / ( s1 + c1 / RMAX );
end 
beta = zeros( nx, 1 );
gamma = zeros( nx, 1 );
else 

if SuppliedH

fObj = fB( k );u = UB( :, k );v = VB( :, k );


[ ~, beta, gamma ] = frkernel( Acl,  - Bcl * v,  - u' * Ccl, 0, [  ], sz );
beta = Ucl * beta;
gamma = Ucl * gamma';
else 

[ hB, beta, gamma ] = frkernel( Acl,  - Bcl,  - Ccl, Dcl, [  ], sz );
[ ~, u1, v1, w1, c1, s1 ] = ltipack.util.gsvmax( W1' * hB, W2' * hB, 0 );
if isempty( u1 )
u = zeros( ny, 1 );v = zeros( nu, 1 );
else 
u = ( s1 * W1 * u1 - c1 * W2 * v1 ) / ( s1 + c1 / RMAX ) ^ 2;v = w1;
end 
fObj = c1 / ( s1 + c1 / RMAX );
beta = Ucl * ( beta * v );
gamma = Ucl * ( gamma' * u );
end 
end 
f( k ) = fObj;

uk( xPerf ) = gamma( nxWL + nxE + 1:nxWL + nxE + nxr, : ) ./ sxr;
vk( xPerf ) = beta( nxWL + nxE + 1:nxWL + nxE + nxr, : ) .* sxr;
if noWT
zk( iy ) = u;
wk( iu ) = v;
else 
zk( iy ) = bL' * gamma( 1:nxWL, : ) + dL' * u;
wk( iu ) = cR * beta( nx - nxWR + 1:nx, : ) + dR * v;
end 
J( :, k ) = NSOptUtil.gradLFT( SYSDATA, tInfo, x, [ uk;zk ], [ vk;wk ] );

if FID.Active && wB( k ) < 1e3 * FID.Shift
try %#ok<TRYNC>
thetaU = sylvester(  - FID.A22, FID.A11, real( ( FID.U2' * vk ) * ( uk' * FID.V1 ) ) );
thetaV = sylvester( FID.A11,  - FID.A22, real( ( FID.U1' * vk ) * ( uk' * FID.V2 ) ) );
nxF = size( thetaU, 2 );
JU = [ FID.U2 * thetaV', FID.U1;zeros( nzL, 2 * nxF ) ];
JV = [ FID.V1, FID.V2 * thetaU;zeros( nwL, 2 * nxF ) ];
J( :, k ) = J( :, k ) - FID.Shift * NSOptUtil.gradLFT( SYSDATA, tInfo, x, JU, JV );
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpjgB8wQ.p.
% Please follow local copyright laws when handling this file.

