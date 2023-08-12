function removeAllCursors( p, datasetIdx )




m = p.hCursorAngleMarkers;
if ~isempty( m )
if nargin < 2 || strcmpi( datasetIdx, 'all' )


delete( m );
p.hCursorAngleMarkers = [  ];

elseif ~isempty( datasetIdx )


sel = getDataSetIndex( m ) == datasetIdx;
delete( m( sel ) );


m( sel ) = [  ];
p.hCursorAngleMarkers = m;
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpfs3NAI.p.
% Please follow local copyright laws when handling this file.

