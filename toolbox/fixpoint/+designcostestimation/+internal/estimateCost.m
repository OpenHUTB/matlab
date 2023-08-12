function result = estimateCost( model, AnalysisConfigObj )








R36
model( 1, 1 )string
AnalysisConfigObj = designcostestimation.internal.DesignAnalyzerConfiguration(  );
end 


fpdLicenseCheck(  );


result = designcostestimation.internal.dce( model, AnalysisConfigObj );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmphRdDQc.p.
% Please follow local copyright laws when handling this file.

