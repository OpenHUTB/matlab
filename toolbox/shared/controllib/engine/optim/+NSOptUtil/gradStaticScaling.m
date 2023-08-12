function g = gradStaticScaling( tInfo, p, u, v, InvFlag )














LS = tInfo.LoopScalings;
nL = tInfo.nL;
uL = u( end  - nL + 1:end  );
vL = v( end  - nL + 1:end  );
np = numel( tInfo.iFree );
g = zeros( np, 1 );
ip = np - sum( [ LS.np ] );
for ct = 1:nL
np = LS( ct ).np;
if LS( ct ).ns > 0

lambda = p( ip + 1 );
if InvFlag
g( ip + 1 ) =  - exp(  - lambda ) * real( uL( ct )' * vL( ct ) );
else 
g( ip + 1 ) = exp( lambda ) * real( uL( ct )' * vL( ct ) );
end 
end 
ip = ip + np;
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmprUEdrv.p.
% Please follow local copyright laws when handling this file.

