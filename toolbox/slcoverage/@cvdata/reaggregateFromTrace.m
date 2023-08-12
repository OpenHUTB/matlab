function reaggregateFromTrace( this, metricName, isTOMetric, traceMask )




metricStruct = this.metrics;
isSigrange = strcmpi( metricName, 'sigrange' ) || strcmpi( metricName, 'sigsize' );


if isTOMetric
maskedTrace = this.trace.testobjectives.( metricName );
else 
maskedTrace = this.trace.( metricName );
end 

if ~isempty( traceMask )
if isSigrange
maskedTrace( ~traceMask ) = NaN;
else 
maskedTrace = full( maskedTrace .* traceMask );
end 
end 


metricData = processMetric( this.rootId, metricName, maskedTrace );


if isTOMetric
tmpMtricStruct = [  ];
if ~isempty( metricData )
metricenumValue = cvi.MetricRegistry.getEnum( metricName );
metricdataId = cv( 'new', 'metricdata', '.metricName', metricName, '.metricenumValue', metricenumValue );
cv( 'set', metricdataId, '.data.rawdata', metricData, '.size', numel( metricData ) );
metricData = cv( 'ProcessTOData', this.rootId, metricdataId );
cv( 'delete', metricdataId );
end 
tmpMtricStruct.( metricName ) = metricData;
metricStruct.testobjectives = tmpMtricStruct;

else 
if ~isempty( metricData ) && ~isSigrange
metricEnumVal = cvi.MetricRegistry.getEnum( metricName );
metricData = cv( 'ProcessData', this.rootId, metricEnumVal, metricData );
end 
metricStruct.( metricName ) = metricData;
end 


this.setMetricData( metricStruct );
end 



function u = processMetric( rootId, metric, maskedTrace )
opFcn = @( x )( sum( x, 2 ) );
u = cvdata.processMetric( rootId, metric, maskedTrace, opFcn, '+' );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpcbde4D.p.
% Please follow local copyright laws when handling this file.

