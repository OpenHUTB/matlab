function DesignAnalyzerResult = dce( model, AnalysisConfigObj )

arguments
    model( 1, 1 )string
    AnalysisConfigObj = designcostestimation.internal.DesignAnalyzerConfiguration(  );
end

origDir = pwd;
dirName = tempname;
mkdir( dirName );
cd( dirName );
cleanup = onCleanup( @(  )cd( origDir ) );

DesignAnalyzer = designcostestimation.internal.DesignAnalyzer( model );

DesignAnalyzerResult = DesignAnalyzer.Analyze( AnalysisConfigObj );
end
