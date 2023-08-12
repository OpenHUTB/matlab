function removeCursors( p, idx )






m = p.hCursorAngleMarkers;
if ~isempty( m ) && ~isempty( idx )


[ m_j, sel ] = findCursorAngleMarkerByID( p, sprintf( 'C%d', idx ) );

delete( m_j );


m( sel ) = [  ];
p.hCursorAngleMarkers = m;


p.pAngleMarkerHoverID = '';
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpmj4if9.p.
% Please follow local copyright laws when handling this file.

