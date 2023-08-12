function showAngleLimCursors( p, vis, prefAng )%#ok<INUSD>

















if nargin < 2


vis = p.pAngleLimCursorVis;
else 
p.pAngleLimCursorVis = vis;
end 
h = p.hAngleLimCursors;
N = numel( h );
if vis
lim = p.pAngleLim;
if nargin < 3

prefAng = lim( 1 );
end 
if N == 0


m1 = createAngleLimCursor( p, 1 );
m2 = createAngleLimCursor( p, 2 );
p.hAngleLimCursors = [ m1, m2 ];

else 

h( 1 ).LocalAngle = lim( 1 );
h( 2 ).LocalAngle = lim( 2 );
end 
i_changeAngleLim( p );
else 

delete( h );
p.hAngleLimCursors = [  ];
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpoBPX0L.p.
% Please follow local copyright laws when handling this file.

