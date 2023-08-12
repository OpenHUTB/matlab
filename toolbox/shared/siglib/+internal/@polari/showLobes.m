function showLobes( p, datasetIndex )









proceed = hideLobesAndMarkers( p );
if proceed


a = createAntennaObjOnce( p );
if nargin < 2 || isempty( datasetIndex )
datasetIndex = p.pCurrentDataSetIndex;
end 
showLobes( a, datasetIndex );
showLobeSpan( a, 'hpbw', datasetIndex );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp87eWem.p.
% Please follow local copyright laws when handling this file.

