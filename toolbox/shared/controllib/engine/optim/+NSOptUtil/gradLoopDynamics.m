function J = gradLoopDynamics( SYSDATA, tInfo, p, xSpec, U, V, tau )










ZEROTOL = 100 * eps;
nx = size( SYSDATA.Acl, 1 );
nB = size( U, 2 );
if nargin < 7
tau = ones( nB, 1 );
end 



J = NaN( numel( p ), nB );
u = zeros( nx, 1 );
v = zeros( nx, 1 );
for k = 1:nB

u( xSpec, : ) = U( :, k );
v( xSpec, : ) = V( :, k );
vu = v' * u;
if abs( vu ) > ZEROTOL
J( :, k ) = NSOptUtil.gradLFT( SYSDATA, tInfo, p, ( tau( k ) / vu ) * u, v );
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpQ1btWL.p.
% Please follow local copyright laws when handling this file.

