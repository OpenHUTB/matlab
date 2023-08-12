function reorderRelatedAngleMarkers( p, ID, dir )
















mRelatedPlusThis = findAllMarkersWithSameTypeAndDataset( p, ID );
sel = strcmpi( ID, { mRelatedPlusThis.ID } );
assert( sum( sel ) == 1 );
mThis = mRelatedPlusThis( sel );
mRelated = mRelatedPlusThis( ~sel );
mAll = [ p.hPeakAngleMarkers;p.hCursorAngleMarkers ];
sel = ismember( mAll, mRelatedPlusThis );
mOther = mAll( ~sel );






if isempty( mOther )
zOrderOther = [  ];
else 
[ ~, zOrderOther ] = sort( [ mOther.Z ] );
end 
if isempty( mRelated )
zOrderRelated = [  ];
else 
[ ~, zOrderRelated ] = sort( [ mRelated.Z ] );
end 


Nother = numel( mOther );
Nrelated = numel( mRelated );
Nall = Nother + Nrelated + 1;
zi = 0.3;
del = ( 0.4 - zi ) / Nall;

if dir ==  - 1



mThis.Z = zi;
for i = 1:Nrelated
zi = zi + del;
mRelated( zOrderRelated( i ) ).Z = zi;
end 
for i = 1:Nother
zi = zi + del;
mOther( zOrderOther( i ) ).Z = zi;
end 
else 



for i = 1:Nother
mOther( zOrderOther( i ) ).Z = zi;
zi = zi + del;
end 
for i = 1:Nrelated
mRelated( zOrderRelated( i ) ).Z = zi;
zi = zi + del;
end 
mThis.Z = zi;
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpChs9D9.p.
% Please follow local copyright laws when handling this file.

