function userDeg = principalRangeUserDeg( p, userDeg )



userDeg = userDeg - fix( userDeg / 360 ) * 360;

if strcmpi( p.AngleRange, '180' )

userDeg = mod( userDeg + 180, 360 ) - 180;
else 


userDeg = mod( userDeg, 360 );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpr5fDdm.p.
% Please follow local copyright laws when handling this file.

