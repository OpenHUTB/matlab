function CostResult = estimateParameterCost( model )





R36
model( 1, 1 )string
end 


origDir = pwd;
dirName = tempname;
mkdir( dirName );
cd( dirName );
cleanup = onCleanup( @(  )cd( origDir ) );

Analyzer = designcostestimation.internal.ParameterAnalyzer( model );

Analyzer.analyze(  );
CostResult = Analyzer.ParamEstimateResult;
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmppKxJ9S.p.
% Please follow local copyright laws when handling this file.

