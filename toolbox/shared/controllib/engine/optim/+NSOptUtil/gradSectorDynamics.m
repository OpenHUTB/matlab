function J = gradSectorDynamics( SYSDATA, tInfo, p, SPECDATA, UB, VB, tau )









ZEROTOL = 100 * eps;
nB = size( UB, 2 );
if nargin < 7
tau = ones( nB, 1 );
end 


nx0 = size( SYSDATA.Acl, 1 );
[ nz, nw ] = size( SYSDATA.Dcl );
iu = SPECDATA.Input;
iy = SPECDATA.Output;
W2 = SPECDATA.Sector.W2;
xPerf = SPECDATA.xPerf;


Acl = SYSDATA.Acl( xPerf, xPerf );
Bcl = SYSDATA.Bcl( xPerf, iu );
Ccl = SYSDATA.Ccl( iy, xPerf );
Dcl = SYSDATA.Dcl( iy, iu );
nx = size( Acl, 1 );


T = SPECDATA.Transform;
if isempty( T )
E = 0;F = 1;
else 
E = T.E.d;F = T.F;
end 
WL = SPECDATA.WL;
if isempty( WL )
dL = W2' * F;
bL = zeros( 0, size( dL, 2 ) );
bH2 = Bcl;cH2 = dL * Ccl;dH2 = W2' * E + dL * Dcl;
else 
bL = WL.b;cL = W2' * WL.c;dL = W2' * WL.d;
aux = E + F * Dcl;
bH2 = [ bL * aux;Bcl ];
cH2 = [ cL, dL * F * Ccl ];
dH2 = dL * aux;
bL = bL * F;dL = dL * F;
end 
nxW = size( bL, 1 );


J = NaN( numel( p ), nB );
uk = zeros( nx0, 1 );
vk = zeros( nx0, 1 );
zk = zeros( nz, 1 );
wk = zeros( nw, 1 );
for k = 1:nB

U = UB( :, k );
V = VB( :, k );
vu = V' * U;
if abs( vu ) > ZEROTOL
uk( xPerf, : ) = U( nxW + 1:nxW + nx );
vk( xPerf, : ) = V( nxW + 1:nxW + nx );
aux1 =  - dH2\( cH2 * V );
aux2 =  - dH2'\( bH2' * U );
if hasInfNaN( aux1 ) || hasInfNaN( aux2 )
continue 
end 
wk( iu ) = aux1;
zk( iy ) = bL' * U( 1:nxW, : ) + dL' * aux2;
J( :, k ) = NSOptUtil.gradLFT( SYSDATA, tInfo, p, ( tau( k ) / vu ) * [ uk;zk ], [ vk;wk ] );
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpb3HfDr.p.
% Please follow local copyright laws when handling this file.

