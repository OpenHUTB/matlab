function setupCCodeAnalysis(analyzer)
    analyzer.NodeAnalyzers(end+1)=dependencies.internal.analysis.ccode.CCodeNodeAnalyzer;

end

