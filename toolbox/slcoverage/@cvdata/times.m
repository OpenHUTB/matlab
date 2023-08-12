function r = times( p, q )














p = cvdata( p );
q = cvdata( q );


p.checkDataCompatibility( q );

opFcn = @( x )( min( x, [  ], 2 ) );
out_metrics = perform_operation( p, q, opFcn, '*', [  ] );

r = cvdata;
r.createDerivedData( p, q, out_metrics, [  ] );

r.sfcnCovData = SlCov.results.CodeCovDataGroup.performOp( p.sfcnCovData, q.sfcnCovData, '*' );
r.codeCovData = SlCov.results.CodeCovData.performOp( p.codeCovData, q.codeCovData, '*' );

% Decoded using De-pcode utility v1.2 from file /tmp/tmpBuGwRF.p.
% Please follow local copyright laws when handling this file.

