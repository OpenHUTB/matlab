function cvdSum = sum( cvdArray )




if size( cvdArray, 1 ) > size( cvdArray, 2 )
cvdArray = cvdArray';
end 

for i = 1:numel( cvdArray )
cvdArray( i ) = cvdata( cvdArray( i ) );
end 


checkDataCompatibility( cvdArray );

ati = cv.internal.cvdata.joinAggregatedTestInfo( [  ], cvdArray );
opFcn = @( x )( sum( x, 2 ) );
[ out_metrics, traceStruct ] = perform_operation( [  ], cvdArray, opFcn, '+', ati );
[ ati, traceStruct ] = cv.internal.cvdata.removeDuplicateTestTraces( ati, traceStruct );

cvdSum = cvdata;

cvdSum.createDerivedData( [  ], cvdArray, out_metrics, traceStruct );


cvdSum.sfcnCovData = cvdArray( 1 ).sfcnCovData;
cvdSum.codeCovData = cvdArray( 1 ).codeCovData;

for i = 2:numel( cvdArray )
cvdSum.sfcnCovData = SlCov.results.CodeCovDataGroup.performOp( cvdSum.sfcnCovData, cvdArray( i ).sfcnCovData, '+' );
cvdSum.codeCovData = SlCov.results.CodeCovData.performOp( cvdSum.codeCovData, cvdArray( i ).codeCovData, '+' );
end 



cvdSum.aggregatedTestInfo = ati;

% Decoded using De-pcode utility v1.2 from file /tmp/tmpvBbS4c.p.
% Please follow local copyright laws when handling this file.

