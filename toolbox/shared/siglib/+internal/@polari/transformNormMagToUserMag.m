function userMag = transformNormMagToUserMag( p, normMag )

rlim = p.pMagnitudeLim;
userMag = normMag .* ( rlim( 2 ) - rlim( 1 ) ) + rlim( 1 );

% Decoded using De-pcode utility v1.2 from file /tmp/tmpGtI8sv.p.
% Please follow local copyright laws when handling this file.

