function [ metricStruct, traceStruct ] = processSubsystemMetric( targetRootId, targetCvd, targetIndices,  ...
sourceCvd, sourceIndices,  ...
joinedAggregatedTestInfo,  ...
metricNames, toMetricNames, op, isSameSubsys )



try 


targetMetricData = getMetricData( targetCvd, joinedAggregatedTestInfo );
sourceMetricData = getMetricData( sourceCvd, joinedAggregatedTestInfo );

[ metricStruct, traceStruct ] = processAllMetrics( sourceIndices, sourceMetricData,  ...
targetIndices, targetMetricData,  ...
metricNames, false, targetRootId, op, isSameSubsys,  ...
targetCvd, sourceCvd, joinedAggregatedTestInfo );


if ~isempty( toMetricNames )


targetMetricData = getTOMetricData( targetCvd, joinedAggregatedTestInfo );
sourceMetricData = getTOMetricData( sourceCvd, joinedAggregatedTestInfo );


[ tmpMetricStruct, tmpTraceStruct ] = processAllMetrics( sourceIndices, sourceMetricData,  ...
targetIndices, targetMetricData,  ...
toMetricNames, true, targetRootId, op, isSameSubsys,  ...
targetCvd, sourceCvd, joinedAggregatedTestInfo );

metricStruct.testobjectives = tmpMetricStruct;
if ~isempty( tmpTraceStruct )
traceStruct.testobjectives = tmpTraceStruct;
end 
end 

catch MEx
rethrow( MEx );
end 
end 

function metricData = getMetricData( cvd, joinedAggregatedTestInfo )
metricData.metric = [  ];
metricData.trace = [  ];
metricData.traceId = [  ];
metricData.traceOn = false;
if ~isempty( cvd )
metricData.metric = cvd.metrics;
metricData.traceOn = cvd.traceOn;
if cvd.traceOn
if ~isempty( joinedAggregatedTestInfo )
metricData.traceId = cv.internal.cvdata.getInternalTraceId( cvd.uniqueId, joinedAggregatedTestInfo );
end 
if ~isempty( cvd.trace )
metricData.trace = cvd.trace;
end 
end 
end 
end 

function metricData = getTOMetricData( cvd, joinedAggregatedTestInfo )

metricData.metric = [  ];
metricData.trace = [  ];
metricData.traceId = [  ];
metricData.traceOn = false;
if ~isempty( cvd )
metricData.metric = cvd.metrics.testobjectives;
metricData.traceOn = cvd.traceOn;
if cvd.traceOn
if ~isempty( joinedAggregatedTestInfo )
metricData.traceId = cv.internal.cvdata.getInternalTraceId( cvd.uniqueId, joinedAggregatedTestInfo );
end 
if ~isempty( cvd.trace ) && isfield( cvd.trace, 'testobjectives' )
metricData.trace = cvd.trace.testobjectives;
end 
end 
end 
end 


function [ metricStruct, traceStruct ] = processAllMetrics( sourceIndices, sourceMetricData,  ...
targetIndices, targetMetricData,  ...
metricNames, isTOMetrics, rootId, op, isSameSubsys,  ...
targetCvd, sourceCvd, joinedAggregatedTestInfo )

metricStruct = [  ];
traceStruct = [  ];

for metricI = metricNames( : )'
metricName = metricI{ 1 };

sourceMD = getRawMetricData( sourceMetricData, metricName, rootId );
targetMD = getRawMetricData( targetMetricData, metricName, rootId );


if isempty( targetMD ) && strcmpi( op, 'plus' )
continue ;
end 

isMcdc = strcmpi( metricName, 'mcdc' );
isMcdcModeUniqueCause = ( ( ~isempty( targetCvd ) && ( targetCvd.modelinfo.mcdcMode == SlCov.McdcMode.UniqueCause ) ) ||  ...
( ~isempty( sourceCvd ) && ( sourceCvd.modelinfo.mcdcMode == SlCov.McdcMode.UniqueCause ) ) );
if isMcdc && isMcdcModeUniqueCause

metricData = targetMD;
else 
metricData = processMetric( targetMD, sourceMD, targetIndices, sourceIndices, metricName, op, isSameSubsys );
end 

traceStruct.( metricName ) = calcTraceDataForMetric( metricName );

if ~isempty( metricData )
if isTOMetrics
metricenumValue = cvi.MetricRegistry.getEnum( metricName );
metricdataId = cv( 'new', 'metricdata', '.metricName', metricName, '.metricenumValue', metricenumValue );
cv( 'set', metricdataId, '.data.rawdata', metricData, '.size', numel( metricData ) );
metricData = cv( 'ProcessTOData', rootId, metricdataId );
cv( 'delete', metricdataId );
else 
metricEnumVal = cvi.MetricRegistry.getEnum( metricName );
metricData = cv( 'ProcessData', rootId, metricEnumVal, metricData );
end 
end 

metricStruct.( metricName ) = metricData;
end 


function traceData = calcTraceDataForMetric( locMetricName )
traceData = [  ];
targetTD = getRawTraceData( targetMD, targetMetricData, locMetricName );
switch op
case 'plus'
numRuns = length( joinedAggregatedTestInfo );
[ targetTraceLength, numCurrentTraces ] = size( targetTD );
sourceTD = getRawTraceData( sourceMD, sourceMetricData, locMetricName );
paddingWidth = numRuns - numCurrentTraces;
assert( isempty( sourceTD ) || ( paddingWidth == size( sourceTD, 2 ) ) );
newTracePadding = zeros( targetTraceLength, paddingWidth );
targetTD = [ targetTD, newTracePadding ];
traceData = processMetric( targetTD, sourceTD, targetIndices, sourceIndices, metricName, 'trace_plus', isSameSubsys );
case 'reset'
traceData = targetTD;
end 
end 
end 

function rawMD = getRawMetricData( metricData, metricName, rootId )
if ~isempty( metricData.metric )
rawMD = metricData.metric.( metricName );
else 
ms = getMetricDataSize( metricName, rootId );
rawMD = zeros( ms, 1 );
end 
end 

function rawTD = getRawTraceData( rawMD, metricData, metricName )

rawTD = [  ];
if isempty( metricData.trace ) || ~isfield( metricData.trace, metricName )

if metricData.traceOn
rawTD = rawMD;
end 
else 

rawTD = metricData.trace.( metricName );
end 

end 


function ms = getMetricDataSize( metric, rootId )
if contains( metric, 'cvmetric' )
tom = cv( 'get', rootId, '.testobjectives' );
md = cv( 'find', tom, '.metricName', metric );
ms = cv( 'get', md, '.size' );
else 
ms = cv( 'get', rootId, [ '.dataSize.', metric ] );
end 

end 


function targetMetricData = processMetric( targetMetricData, sourceMetricData, targetIndices, sourceIndices, metricName, op, isSameSubsys )

try 
isMcdc = strcmpi( metricName, 'mcdc' );
sourceKeys = [ sourceIndices.cvId ];
targetKeys = [ targetIndices.cvId ];


if ~isSameSubsys
assert( numel( targetKeys ) == numel( sourceKeys ) );
end 

for idx = 1:numel( sourceKeys )

if isSameSubsys
cvId = sourceKeys( idx );
tIdx = find( [ targetIndices.cvId ] == cvId );
if isempty( tIdx )
continue ;
end 
targetValue = targetIndices( tIdx );
sourceValue = sourceIndices( idx );
else 
targetValue = targetIndices( idx );
sourceValue = sourceIndices( idx );
end 

targetValue = targetValue.metricIndex.( metricName );
sourceValue = sourceValue.metricIndex.( metricName );

if isempty( targetValue )
continue ;
end 
for ii = 1:numel( sourceValue )
targetIndex = targetValue( ii ).idx;
targetSize = targetValue( ii ).size;
sourceIndex = sourceValue( ii ).idx;
sourceSize = targetValue( ii ).size;
if ~isempty( sourceMetricData )
sourceData = sourceMetricData( sourceIndex:sourceIndex + sourceSize - 1, : );
targetIdxRange = targetIndex:targetIndex + targetSize - 1;
switch op
case 'plus'
if isMcdc
targetMetricData = mcdcPlus( targetMetricData, sourceData, targetValue( ii ), targetSize, targetIdxRange );
else 
targetMetricData( targetIdxRange ) = targetMetricData( targetIdxRange ) + sourceData;
end 
case 'trace_plus'


tNumCols = size( targetMetricData, 2 );
sNumCols = size( sourceData, 2 );
targetRowIdxRange = targetIdxRange;
targetColIdxRange = ( tNumCols - sNumCols + 1 ):tNumCols;
targetMetricData( targetRowIdxRange, targetColIdxRange ) = sourceData;

case 'assign'
targetMetricData( targetIdxRange ) = sourceData;
case 'reset'
targetMetricData( targetIdxRange ) = zeros( numel( sourceData ), 1 );
end 
end 
end 

end 
catch MEx
rethrow( MEx );
end 

end 



function targetMetricData = mcdcPlus( targetMetricData, sourceMetricDataSubset, targetIdxStruct, numPredicates, targetIdxRange )





if isfield( targetIdxStruct, 'metadata' ) && isfield( targetIdxStruct.metadata, 'tableEntryType' )


entryType = targetIdxStruct.metadata.tableEntryType;
predSatIdx = targetIdxStruct.metadata.predSatisfiedIdx;
predSatIdxRange = predSatIdx:predSatIdx + numPredicates - 1;
predSat = targetMetricData( predSatIdxRange );
entryVals_R = sourceMetricDataSubset;
entryVals_L = targetMetricData( targetIdxRange );
entryVals_Joined = entryVals_R;
entryMask_L = ( predSat == entryType ) | ( predSat == SlCov.PredSatisfied.Fully_Satisfied );
entryVals_Joined( entryMask_L ) = entryVals_L( entryMask_L );
targetMetricData( targetIdxRange ) = entryVals_Joined;
else 
targetMetricData( targetIdxRange ) = cv( 'BitOp', targetMetricData( targetIdxRange ), '+', sourceMetricDataSubset );
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpddZZIU.p.
% Please follow local copyright laws when handling this file.

