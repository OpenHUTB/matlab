function setMetricData( this, metricData )




id = this.id;
if id == 0
this.localData.metrics = metricData;
else 
[ allMetricNames, allTOMetricNames ] = cvi.MetricRegistry.getAllMetricNames(  );

for idx = 1:numel( allMetricNames )
metricName = allMetricNames{ idx };
if isfield( metricData, metricName )
cv( 'set', id, [ 'testdata.data', metricName ], metricData.( metricName ) );
end 
end 

metricdataIds = cv( 'get', id, '.testobjectives' );
if ~isempty( metricdataIds )
for idx = 1:numel( allTOMetricNames )
metricName = allTOMetricNames{ idx };
if isfield( metricData.testobjectives, metricName )
metricD = metricData.testobjectives.( metricName );
metricEnum = cvi.MetricRegistry.getEnum( metricName );
cv( 'set', metricdataIds( metricEnum ), '.data.rawdata', metricD );
end 
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpOSyWjm.p.
% Please follow local copyright laws when handling this file.

