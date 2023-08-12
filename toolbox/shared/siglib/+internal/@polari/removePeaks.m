function removePeaks( p, datasetIndex )



if nargin < 2 || isempty( datasetIndex )
p.pPeaks = [  ];
else 
p.pPeaks( datasetIndex ) = 0;
end 
updatePeaks( p );

% Decoded using De-pcode utility v1.2 from file /tmp/tmpgEOYBT.p.
% Please follow local copyright laws when handling this file.

