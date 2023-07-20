function analyzers=registerMatlabNodeAnalyzers(~)




    analyzers=[
    dependencies.internal.analysis.matlab.MatlabNodeAnalyzer
    dependencies.internal.analysis.matlab.PCodeNodeAnalyzer
    dependencies.internal.analysis.matlab.CodeNodeAnalyzer
    ];

end
