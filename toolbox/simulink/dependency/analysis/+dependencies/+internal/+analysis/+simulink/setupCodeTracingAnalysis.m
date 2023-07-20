function setupCodeTracingAnalysis(analyzer)




    if~dependencies.internal.util.isProductInstalled('EC','embeddedcoder')
        return;
    end

    import dependencies.internal.analysis.simulink.setupAdditionalModelAnalyzers;
    analyzer.NodeAnalyzers=setupAdditionalModelAnalyzers(analyzer.NodeAnalyzers,...
    dependencies.internal.analysis.simulink.CodeTracingAnalyzer);

    isCcodeAnalyzer=arrayfun(@(a)isa(a,'dependencies.internal.analysis.ccode.CCodeNodeAnalyzer'),analyzer.NodeAnalyzers);
    analyzer.NodeAnalyzers(isCcodeAnalyzer)=dependencies.internal.analysis.ccode.CCodeTracingNodeAnalyzer;
end
