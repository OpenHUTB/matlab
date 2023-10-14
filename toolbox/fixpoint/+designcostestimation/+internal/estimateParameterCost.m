function CostResult = estimateParameterCost( model )

arguments
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

