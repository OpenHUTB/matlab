function updateMarkersForDatasetChanges( p, prevCursorAngles )







mc = p.hCursorAngleMarkers;
Nc = numel( mc );
if Nc > 0
rmList = [  ];
Nd = numel( getAllDatasets( p ) );
for i = 1:Nc
m_i = mc( i );
if getDataSetIndex( m_i ) > Nd
removeCursors( p, m_i.Index );
rmList = [ rmList, i ];%#ok<AGROW>
end 
end 


mc = p.hCursorAngleMarkers;
if ~isempty( mc )




prevCursorAngles( rmList ) = [  ];



updateActiveTraceMarkers( mc, prevCursorAngles, false );
end 
end 




if ~isempty( p.hPeakAngleMarkers )

updatePeaks( p, true );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp6KOcA9.p.
% Please follow local copyright laws when handling this file.

