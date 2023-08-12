function setNewPeakMarkerReadoutState( p, newPeakMarkers )




mAllOther = p.hPeakAngleMarkers;
if ~isempty( mAllOther )
all_ds = getDataSetIndex( mAllOther );

for i = 1:numel( newPeakMarkers )
m_i = newPeakMarkers( i );


idx = find( all_ds == getDataSetIndex( m_i ) );
if ~isempty( idx )


m_i.Visible = mAllOther( idx( 1 ) ).Visible;
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp7uHTIA.p.
% Please follow local copyright laws when handling this file.

