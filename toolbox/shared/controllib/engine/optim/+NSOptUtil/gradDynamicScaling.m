function g = gradDynamicScaling( tInfo, p, u, v, InvFlag )














LS = tInfo.LoopScalings;
nL = tInfo.nL;
np = numel( tInfo.iFree );
uL = u( end  - nL + 1:end  );
vL = v( end  - nL + 1:end  );
g = zeros( np, 1 );
ix = 0;
ip = np - sum( [ LS.np ] );
for ct = 1:nL
np = LS( ct ).np;
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
ux1 = u( ix + 1 );
vx = v( ix + 1:ix + nx );
tau = ( ( a - b )' * vx ) / 2;
if InvFlag
delta = exp(  - lambda / 2 );
else 
delta = exp( lambda / 2 );
end 
duL = delta * uL( ct );
end 

if ns > 0
if nx > 0
if InvFlag
g( ip + 1 ) = real( (  - delta ) * ( ( ux1 / 2 + duL )' * vL( ct ) ) + duL' * tau );
else 
g( ip + 1 ) = real( delta * ( ( ux1 / 2 + duL )' * vL( ct ) ) + duL' * tau );
end 
else 
if InvFlag
g( ip + 1 ) =  - exp(  - lambda ) * real( uL( ct )' * vL( ct ) );
else 
g( ip + 1 ) = exp( lambda ) * real( uL( ct )' * vL( ct ) );
end 
end 
end 

if nx > 0

if InvFlag
g( ipx + 1:ipx + 2 * nx ) = real( [  - ( ux1 + duL )' * vx;duL' * vx ] );
else 
g( ipx + 1:ipx + 2 * nx ) = real( [ duL' * vx; - ( ux1 + duL )' * vx ] );
end 
end 

ip = ip + np;
ix = ix + nx;
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp_msnoi.p.
% Please follow local copyright laws when handling this file.

