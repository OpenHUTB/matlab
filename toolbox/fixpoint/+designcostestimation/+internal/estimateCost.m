function result = estimateCost( model, AnalysisConfigObj )

arguments
    model( 1, 1 )string
    AnalysisConfigObj = designcostestimation.internal.DesignAnalyzerConfiguration(  );
end

fpdLicenseCheck(  );

result = designcostestimation.internal.dce( model, AnalysisConfigObj );
end


