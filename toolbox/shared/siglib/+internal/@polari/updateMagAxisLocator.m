function updateMagAxisLocator( p )





hloc = p.hMagAxisLocator;
if isempty( hloc ) || ~ishghandle( hloc )
return 
end 

S = p.pMagnitudeLabelCoords;
costh = S.costh;
sinth = S.sinth;


xy = [ 0,  - sqrt( 1 - .5 ^ 2 ), 0;.5, 0,  - .5 ];





rotccw = [ costh,  - sinth;sinth, costh ];
xy = rotccw * xy * 0.08;
x = xy( 1, : )' + costh;
y = xy( 2, : )' + sinth;
z = 0.25 * ones( size( x ) );

set( hloc,  ...
'XData', x,  ...
'YData', y,  ...
'ZData', z );

% Decoded using De-pcode utility v1.2 from file /tmp/tmpXM_0E9.p.
% Please follow local copyright laws when handling this file.

