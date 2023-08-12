function DesignAnalyzerResult = dce( model, AnalysisConfigObj )


R36
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

% Decoded using De-pcode utility v1.2 from file /tmp/tmpglL1dq.p.
% Please follow local copyright laws when handling this file.

