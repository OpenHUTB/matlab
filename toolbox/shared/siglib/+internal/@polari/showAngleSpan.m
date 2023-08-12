function showAngleSpan( p, newVis, markerParent )





















if nargin < 3
markerParent = [  ];
end 
if nargin < 2
newVis = true;
end 

if newVis && p.AddMarkersToEnableSpanMode





m = [ p.hPeakAngleMarkers;p.hCursorAngleMarkers ];
Nmarkers = numel( m );
if Nmarkers < 2















if Nmarkers == 0
angNew = p.AngleAtTop + [  - 15,  + 15 ];
else 

ang0 = getNormalizedAngle( p, getAngleFromVec( m ) );
d = internal.polariCommon.angleDiffRel( ang0, pi / 2 );
if d == 0


angNewNorm = ang0 - 30 * pi / 180;
else 
angNewNorm = ang0 + sign( d ) * 30 * pi / 180;
end 
angNew = transformNormRadToUserDeg( p, angNewNorm );
end 


addCursor( p, angNew );
end 
end 


s = p.hAngleSpan;
if isempty( s )
if ~newVis
return 
end 



s = internal.polariAngleSpan;
p.hAngleSpan = s;
init( s, p );
end 

if ~newVis







hiliteSpanDrag_Init( p, 'off' );


delete( s );
p.hAngleSpan = [  ];




changeMouseBehavior( p, 'general' );

return 
end 

if newVis && ~isempty( markerParent ) && Nmarkers > 2









angParent = getNormalizedAngle( p,  ...
getAngleFromVec( markerParent ) );

mOther = m( ~strcmpi( markerParent.ID, { m.ID } ) );

angOther = getNormalizedAngle( p,  ...
getAngleFromVec( mOther ) );

d = internal.polariCommon.angleAbsDiff( angParent, angOther );

[ ~, idx ] = min( d );
mOther = mOther( idx );
angOther = angOther( idx );

cParent = complex( cos( angParent ), sin( angParent ) );
cOther = complex( cos( angOther ), sin( angOther ) );
if internal.polariCommon.isCW( cParent, cOther )
m1 = mOther;
m2 = markerParent;
else 
m1 = markerParent;
m2 = mOther;
end 
s.SpanIDs_LiveUpdate = { m1.ID, m2.ID };

end 



s.Fill = ~isIntensityData( p );

s.Visible = newVis;

% Decoded using De-pcode utility v1.2 from file /tmp/tmpbVg8H3.p.
% Please follow local copyright laws when handling this file.

