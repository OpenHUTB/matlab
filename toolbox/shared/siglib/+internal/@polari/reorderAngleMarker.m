function reorderAngleMarker( p, ID, dir )















mPeaks = p.hPeakAngleMarkers;
mCursors = p.hCursorAngleMarkers;


switch lower( ID( 1 ) )
case 'o'

sel = strcmpi( ID, { mPeaks.ID } );
mOther = [ mCursors;mPeaks( ~sel ) ];
mThis = mPeaks( sel );
case 'c'

sel = strcmpi( ID, { mCursors.ID } );
mOther = [ mPeaks;mCursors( ~sel ) ];
mThis = mCursors( sel );
otherwise 
assert( false );
end 


assert( ~isempty( mThis ) );


[ ~, zOrder ] = sort( [ mOther.Z ] );


Nother = numel( mOther );
Nall = Nother + 1;
zi = 0.3;
del = ( 0.4 - zi ) / Nall;

if dir ==  - 1

mThis.Z = zi;
for i = 1:Nother
zi = zi + del;
mOther( zOrder( i ) ).Z = zi;
end 
else 

for i = 1:Nother
mOther( zOrder( i ) ).Z = zi;
zi = zi + del;
end 
mThis.Z = zi;
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpSYCyk5.p.
% Please follow local copyright laws when handling this file.

