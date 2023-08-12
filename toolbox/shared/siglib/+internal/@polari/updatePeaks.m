function updatePeaks( p, forceDatasetIdx )












if nargin > 1
changed_datasetIdxVec = peaksUpdateLocationList( p, forceDatasetIdx );
else 
changed_datasetIdxVec = peaksUpdateLocationList( p, [  ] );
end 

Nchanges = numel( changed_datasetIdxVec );
if Nchanges == 0
return 
end 



















plan = peakMarkerUpdatePlan( p, changed_datasetIdxVec );


peakLocs = p.pPeakLocationList;
map_addneg = plan.map_addneg;

new_m = internal.polariAngleMarker.empty;
new_idx = [  ];
new_cnt = 0;

for i = 1:Nchanges
datasetIdx = changed_datasetIdxVec( i );
all_peak_idx = peakLocs{ datasetIdx };
if ~isempty( all_peak_idx )





list_i = map_addneg{ datasetIdx };







for j = 1:numel( list_i )







markerFlatListIdx = list_i( j );





dataIdx = all_peak_idx( j, : );

if markerFlatListIdx < 0

m_j = angleMarker( p, 'P', j, dataIdx, datasetIdx );
m_j.ContextMenuFcn = @( h, ~ )updatePeaksContextMenu( p, h, m_j );





new_cnt = new_cnt + 1;
new_m( new_cnt, 1 ) = m_j;
new_idx( new_cnt, 1 ) = markerFlatListIdx;%#ok<AGROW>
else 

m_j = p.hPeakAngleMarkers( markerFlatListIdx );
assert( strcmpi( m_j.Type, 'p' ) )

disableUpdates( m_j, true );
m_j.Index = j;
m_j.DataSetIndex = datasetIdx;

if isscalar( dataIdx )
m_j.DataIndex = dataIdx;
m_j.MagIndex = [  ];
else 
m_j.DataIndex = dataIdx( 1 );
m_j.MagIndex = dataIdx( 2 );
end 

disableUpdates( m_j, false );
end 
m_j.DataDotLegend = true;
end 
end 
end 


moveAngleMarkerVectorToFront( p, new_m );




setNewPeakMarkerDetailState( p, new_m );
setNewPeakMarkerReadoutState( p, new_m );



werePreviousMarkers = ~isempty( p.hPeakAngleMarkers );
if werePreviousMarkers

readoutVis = p.hPeakAngleMarkers( 1 ).Visible;
else 


readoutVis = false;
end 

for i = 1:numel( new_m )
new_m( i ).Visible = readoutVis;
end 
m = [ p.hPeakAngleMarkers;new_m ];


if ~werePreviousMarkers && ~isempty( m )
peakTabularReadout( p, true );
end 












midx = plan.remove;

delete( m( midx ) );
m( midx ) = [  ];


p.hPeakAngleMarkers = m;
p.pAngleMarkerHoverID = '';


if werePreviousMarkers && isempty( m )
peakTabularReadout( p, false );
end 



setWidgetIDs( m );




















% Decoded using De-pcode utility v1.2 from file /tmp/tmpYCobtt.p.
% Please follow local copyright laws when handling this file.

