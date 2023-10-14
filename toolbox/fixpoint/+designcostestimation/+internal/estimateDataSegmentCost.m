function CostResult = estimateDataSegmentCost( model )

arguments
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
