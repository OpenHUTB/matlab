function [ J, f ] = gradHinfPerf( SPECDATA, SYSDATA, tInfo, x, wB, hB, iwB )






np = numel( x );


nx0 = size( SYSDATA.Acl, 1 );
[ nzL, nwL ] = size( SYSDATA.Dcl );
iu = SPECDATA.Input;
iy = SPECDATA.Output;
SuppliedH = ( nargin > 5 );
Ts = tInfo.Ts;
if isempty( tInfo.UncertainBlocks )
StaticScaling = SPECDATA.DScaling.Static;
DynamicScaling = ( SPECDATA.DScaling.Dynamic > 0 );
else 
StaticScaling = false;
DynamicScaling = false;
end 
FID = SYSDATA.FixedInteg;


xPerf = SPECDATA.xPerf;
nxr = numel( xPerf );
sxr = SYSDATA.Scaling.sx( xPerf, : );


Bcl0 = SYSDATA.Bcl( xPerf, iu );
Ccl0 = SYSDATA.Ccl( iy, xPerf );
Dcl0 = SYSDATA.Dcl( iy, iu );


Acl = SPECDATA.Acl;Bcl = SPECDATA.Bcl;Ccl = SPECDATA.Ccl;Dcl = SPECDATA.Dcl;
Ucl = SPECDATA.Ucl;
nx = size( Acl, 1 );
[ ny, nu ] = size( Dcl );


nxD = 0;
if StaticScaling || DynamicScaling

DL = tInfo.DL;
DR = tInfo.DR;
if DynamicScaling
nxD = size( DL.a, 1 );
end 
zkD = zeros( nzL, 1 );
wkD = zeros( nwL, 1 );
zkL = zeros( nzL, 1 );
wkR = zeros( nwL, 1 );
end 


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
nxWDL = nxWL + nxD;
nxWDR = nxWR + nxD;


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

[ U, S, V ] = svd( hB( :, :, iwB( k ) ) );
else 
[ U, S, V ] = svd( Dcl );
end 
u = U( :, 1 );
v = V( :, 1 );
beta = zeros( nx, 1 );
gamma = zeros( nx, 1 );
else 

if SuppliedH

[ U, S, V ] = svd( hB( :, :, iwB( k ) ) );
u = U( :, 1 );
v = V( :, 1 );


[ ~, beta, gamma ] = frkernel( Acl,  - Bcl * v,  - u' * Ccl, 0, [  ], sz );
beta = Ucl * beta;
gamma = Ucl * gamma';
else 

[ hB, beta, gamma ] = frkernel( Acl,  - Bcl,  - Ccl, Dcl, [  ], sz );
[ U, S, V ] = svd( hB );
u = U( :, 1 );
v = V( :, 1 );
beta = Ucl * ( beta * v );
gamma = Ucl * ( gamma' * u );
end 
end 
f( k ) = S( 1, 1 );
uk( xPerf, : ) = gamma( nxWDL + nxE + 1:nxWDL + nxE + nxr, : ) ./ sxr;
vk( xPerf, : ) = beta( nxWDL + nxE + 1:nxWDL + nxE + nxr, : ) .* sxr;
if noWT
zk( iy ) = u;
wk( iu ) = v;
else 
zk( iy ) = bL' * gamma( 1:nxWL, : ) + dL' * u;
wk( iu ) = cR * beta( nx - nxWR + 1:nx, : ) + dR * v;
end 
if DynamicScaling
betaDL = beta( nxWL + 1:nxWDL, : );
gammaDL = gamma( nxWL + 1:nxWDL, : );
betaDR = beta( nx - nxWDR + 1:nx - nxWR, : );
gammaDR = gamma( nx - nxWDR + 1:nx - nxWR, : );
zkD( iy ) = DL.d( iy, iy )' * zk( iy ) + DL.b( :, iy )' * gammaDL;
wkD( iu ) = DR.d( iu, iu ) * wk( iu ) + DR.c( iu, : ) * betaDR;
zkL( iy ) = Ccl0 * vk( xPerf ) + Dcl0 * wkD( iu );
wkR( iu ) = Bcl0' * uk( xPerf ) + Dcl0' * zkD( iy );
J( :, k ) = NSOptUtil.gradLFT( SYSDATA, tInfo, x, [ uk;zkD ], [ vk;wkD ] ) +  ...
NSOptUtil.gradDynamicScaling( tInfo, x, [ gammaDL;zk ], [ betaDL;zkL ], true ) +  ...
NSOptUtil.gradDynamicScaling( tInfo, x, [ gammaDR;wkR ], [ betaDR;wk ], false );
elseif StaticScaling
zkD( iy ) = DL.d( iy, iy )' * zk( iy );
wkD( iu ) = DR.d( iu, iu ) * wk( iu );
zkL( iy ) = Ccl0 * vk( xPerf ) + Dcl0 * wkD( iu );
wkR( iu ) = Bcl0' * uk( xPerf ) + Dcl0' * zkD( iy );
J( :, k ) = NSOptUtil.gradLFT( SYSDATA, tInfo, x, [ uk;zkD ], [ vk;wkD ] ) +  ...
NSOptUtil.gradStaticScaling( tInfo, x, zk, zkL, true ) +  ...
NSOptUtil.gradStaticScaling( tInfo, x, wkR, wk, false );
else 
J( :, k ) = NSOptUtil.gradLFT( SYSDATA, tInfo, x, [ uk;zk ], [ vk;wk ] );
end 

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


T = SPECDATA.Transform;
if ~( isempty( T ) || isempty( T.h ) )
for k = 1:nB
J( :, k ) = T.h( f( k ), 1 ) * J( :, k );
f( k ) = T.h( f( k ), 0 );
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpT4G1Jd.p.
% Please follow local copyright laws when handling this file.

