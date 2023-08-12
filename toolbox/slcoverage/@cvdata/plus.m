function r = plus( p, q )














p = cvdata( p );
q = cvdata( q );


p.checkDataCompatibility( q );

ati = cv.internal.cvdata.joinAggregatedTestInfo( p, q );
opFcn = @( x )( sum( x, 2 ) );
[ out_metrics, traceStruct ] = perform_operation( p, q, opFcn, '+', ati );
[ ati, traceStruct ] = cv.internal.cvdata.removeDuplicateTestTraces( ati, traceStruct );


r = cvdata;
r.createDerivedData( p, q, out_metrics, traceStruct );

r.sfcnCovData = SlCov.results.CodeCovDataGroup.performOp( p.sfcnCovData, q.sfcnCovData, '+' );
r.codeCovData = SlCov.results.CodeCovData.performOp( p.codeCovData, q.codeCovData, '+' );



r.aggregatedTestInfo = ati;

% Decoded using De-pcode utility v1.2 from file /tmp/tmpY9i0AM.p.
% Please follow local copyright laws when handling this file.

