
function u = processMetric( rootId, metric, collectedMetricData, opFcn, opChar )






try 
if isempty( collectedMetricData )
u = [  ];
return ;
end 

metricEnumVal = cvi.MetricRegistry.getEnum( metric );
checkVarSize = true;


if ( strcmp( metric, 'mcdc' ) )
u = process_metric_mcdc( rootId, collectedMetricData, opChar, metricEnumVal );
elseif strcmpi( metric, 'sigrange' ) || strcmpi( metric, 'sigsize' )
u = process_metric_sig( collectedMetricData, opChar );
checkVarSize = false;
else 
u = opFcn( collectedMetricData );
end 

if checkVarSize
u = adjust_variable_size_data( rootId, metricEnumVal, u, collectedMetricData );
end 

catch MEx
rethrow( MEx );
end 
end 

function u = process_metric_mcdc( rootId, collectedMetricData, opChar, metricEnumVal )
firstTest = cv( 'get', rootId, '.firstTest' );
mcdcMode = cv( 'get', firstTest, '.mcdcMode' );




u = collectedMetricData( :, 1 );
for i = 2:size( collectedMetricData, 2 )
lhs = u;
rhs = collectedMetricData( :, i );
u = cv( 'BitOp', lhs, opChar, rhs );



if ( mcdcMode == SlCov.McdcMode.Masking )



cvId = cv( 'get', rootId, '.topSlsf' );
allSlsfObjs = cv( 'DecendentsOf', cvId );
mcdcObjs = cv( 'MetricGet', allSlsfObjs, metricEnumVal, '.baseObjs' );
mcdcObjs( mcdcObjs == 0 ) = [  ];

for mcdcIdx = 1:length( mcdcObjs )
[ numPredicates, predSatisfied, trueTableEntry, falseTableEntry ] =  ...
cv( 'get', mcdcObjs( mcdcIdx ), '.numPredicates',  ...
'.dataBaseIdx.predSatisfied',  ...
'.dataBaseIdx.trueTableEntry',  ...
'.dataBaseIdx.falseTableEntry' );

for predIdx = 1:numPredicates
predSatIdx = predSatisfied + predIdx;
trueIdx = trueTableEntry + predIdx;
falseIdx = falseTableEntry + predIdx;





if ( opChar ~= '+' ) || ( lhs( predSatIdx ) == SlCov.PredSatisfied.True_Only ) || ( lhs( predSatIdx ) == SlCov.PredSatisfied.Fully_Satisfied )
u( trueIdx ) = lhs( trueIdx );
else 
u( trueIdx ) = rhs( trueIdx );
end 
if ( opChar ~= '+' ) || ( lhs( predSatIdx ) == SlCov.PredSatisfied.False_Only ) || ( lhs( predSatIdx ) == SlCov.PredSatisfied.Fully_Satisfied )
u( falseIdx ) = lhs( falseIdx );
else 
u( falseIdx ) = rhs( falseIdx );
end 

if ( opChar == '-' )

u( predSatIdx ) = bitor( u( predSatIdx ), 1 );
end 

end 
end 
end 
end 
end 

function u = process_metric_sig( collectedMetricData, opChar )
[ numRows, numCols ] = size( collectedMetricData );
minIdxs = 1:2:( numRows - 1 );
maxIdxs = 2:2:numRows;
minRows = collectedMetricData( minIdxs, : );
maxRows = collectedMetricData( maxIdxs, : );
u = zeros( numRows, 1 );
switch opChar
case '+'
u( minIdxs ) = min( minRows, [  ], 2 );
u( maxIdxs ) = max( maxRows, [  ], 2 );

case '*'
minout = max( minRows, [  ], 2 );
maxout = min( maxRows, [  ], 2 );
u( minIdxs ) = minout;
u( maxIdxs ) = maxout;
infIdx = find( maxout < minout );
if ~isempty( infIdx )
u( 2 * infIdx - 1 ) = inf;
u( 2 * infIdx ) =  - inf;
end 

case '-'











minlhs = minRows( :, 1 );
maxlhs = maxRows( :, 1 );
minrhs = minRows( :, 2 );
maxrhs = maxRows( :, 2 );

empty_lhs = maxlhs < minlhs;

emptyIdx = empty_lhs | ( ~empty_lhs & minrhs <= minlhs & maxrhs >= maxlhs );

inter_min = max( [ minlhs, minrhs ]' )';%#ok<UDIM> % min
inter_max = min( [ maxlhs, maxrhs ]' )';%#ok<UDIM> % max

hasMinOverlap = inter_min == minlhs;
hasMaxOverlap = inter_max == maxlhs;


minout = inter_max;
minout( ~hasMinOverlap ) = minlhs( ~hasMinOverlap );
maxout = inter_min;
maxout( ~hasMaxOverlap ) = maxlhs( ~hasMaxOverlap );

minout( emptyIdx ) = inf;
maxout( emptyIdx ) =  - inf;

u( minIdxs ) = minout;
u( maxIdxs ) = maxout;
end 
end 


function u = adjust_variable_size_data( rootId, metricEnumVal, u, trace )

cvId = cv( 'get', rootId, '.topSlsf' );
if cv( 'MetricGet', cvId, metricEnumVal, '.hasVariableSize' )
allSlsfObjs = [ cv( 'DecendentsOf', cvId ), cvId ];
[ metricObjs, varShallowIdxs, varDeepIdxs ] = cv( 'MetricGet', allSlsfObjs, metricEnumVal, '.baseObjs',  ...
'.dataCnt.varShallowIdx', '.dataCnt.varDeepIdx' );
u = get_max_idx( varShallowIdxs, u, trace );
u = get_max_idx( varDeepIdxs, u, trace );

switch ( metricEnumVal )
case cvi.MetricRegistry.getEnum( 'decision' )
fieldTxt = '.dc.activeOutcomeIdx';
case cvi.MetricRegistry.getEnum( 'condition' )
fieldTxt = '.coverage.activeCondIdx';
case cvi.MetricRegistry.getEnum( 'mcdc' )
fieldTxt = '.dataBaseIdx.activeCondIdx';
otherwise 
fieldTxt = '';
end 
if ~isempty( fieldTxt )
u = fix_metrics( metricObjs, u, trace, fieldTxt );
end 
end 
end 

function u = fix_metrics( metricObjs, u, trace, fieldTxt )
activeCondIdx = cv( 'get', metricObjs, fieldTxt )';
u = get_max_idx( activeCondIdx, u, trace );
end 

function u = get_max_idx( activeIdx, u, trace )
activeIdx( activeIdx < 0 ) = [  ];
if ~isempty( activeIdx )
activeIdx = activeIdx + 1;
u( activeIdx ) = max( trace( activeIdx, : ), [  ], 2 );
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpOCRhWb.p.
% Please follow local copyright laws when handling this file.

