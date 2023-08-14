function analyzer=setupParameterAnalysis(analyzer)




    import dependencies.internal.analysis.simulink.setupAdditionalModelAnalyzers;
    analyzer.NodeAnalyzers=setupAdditionalModelAnalyzers(analyzer.NodeAnalyzers,[
    dependencies.internal.analysis.simulink.ParameterInitializationAnalyzer
    dependencies.internal.analysis.simulink.VariantControlAnalyzer
    ]);

    analyzer.NodeAnalyzers=[dependencies.internal.analysis.matlab.BaseWorkspaceAnalyzer;analyzer.NodeAnalyzers(:)];

end
