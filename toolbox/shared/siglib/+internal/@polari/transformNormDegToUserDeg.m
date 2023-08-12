function userDeg = transformNormDegToUserDeg( p, normDeg )



if strcmpi( p.AngleDirection, 'ccw' )
userDeg = normDeg - 90 + p.AngleAtTop;
else 
userDeg = 90 - normDeg + p.AngleAtTop;
end 
userDeg = principalRangeUserDeg( p, userDeg );

% Decoded using De-pcode utility v1.2 from file /tmp/tmpTJqo1x.p.
% Please follow local copyright laws when handling this file.

