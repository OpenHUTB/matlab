function suspendDataMarkers( p )










p.pUpdateCalled = true;

if isempty( p.pSuspendDataMarkerAngles )



mC = p.hCursorAngleMarkers;
if isempty( mC )
p.pSuspendDataMarkerAngles = [  ];
else 
p.pSuspendDataMarkerAngles = getAngleFromVec( mC );
end 

hideAngleMarkerDataDots( p, true );
end 


p.NextPlot = 'replacechildren';

% Decoded using De-pcode utility v1.2 from file /tmp/tmp33uyTW.p.
% Please follow local copyright laws when handling this file.

