function [ ProgramSizeEstimate, DataSegmentEstimate ] = estimateSLMetricsCost( model, AnalysisConfig )

arguments
    model( 1, 1 )string
    AnalysisConfig = designcostestimation.internal.DesignAnalyzerConfiguration(  );
end

fpdLicenseCheck(  );

origDir = pwd;
dirName = tempname;
mkdir( dirName );
cd( dirName );
cleanup = onCleanup( @(  )cd( origDir ) );

DesignAnalyzer = designcostestimation.internal.DesignAnalyzer( model );

ProgramSizeEstimate = DesignAnalyzer.Analyze( AnalysisConfig );


Analyzer = designcostestimation.internal.DataSegmentAnalyzer( model );

Analyzer.NeedsBuild = false;

Analyzer.analyze(  );
DataSegmentEstimate = Analyzer.CostEstimate;
end


