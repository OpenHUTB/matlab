function CostResult = estimateDataSegmentCost( model )





R36
model( 1, 1 )string
end 


origDir = pwd;
dirName = tempname;
mkdir( dirName );
cd( dirName );
cleanup = onCleanup( @(  )cd( origDir ) );

Analyzer = designcostestimation.internal.DataSegmentAnalyzer( model );

Analyzer.analyze(  );
CostResult = Analyzer.CostEstimate;
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpmUMyqo.p.
% Please follow local copyright laws when handling this file.

