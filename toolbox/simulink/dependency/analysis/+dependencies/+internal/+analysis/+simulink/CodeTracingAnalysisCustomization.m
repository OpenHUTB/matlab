classdef CodeTracingAnalysisCustomization<dependencies.internal.engine.AnalysisCustomization




    properties(Constant)
        Key="AnalyzeCodegenTrace";
        Name=string(message("SimulinkDependencyAnalysis:Analyze:AnalyzeCodegenTrace"));
        DefaultEnabled=false;
    end

    methods(Static)
        function[analyzers,filters]=apply(~,analyzers,filters,enabled)
            import dependencies.internal.analysis.simulink.setupAdditionalModelAnalyzers;
            if enabled&&dependencies.internal.util.isProductInstalled('EC','embeddedcoder')
                analyzers=setupAdditionalModelAnalyzers(analyzers,...
                dependencies.internal.analysis.simulink.CodeTracingAnalyzer);

                isCcodeAnalyzer=arrayfun(@(a)isa(a,'dependencies.internal.analysis.ccode.CCodeNodeAnalyzer'),analyzers);
                analyzers(isCcodeAnalyzer)=dependencies.internal.analysis.ccode.CCodeTracingNodeAnalyzer;
            end
        end
    end

end
