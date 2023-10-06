classdef CCodeAnalysisCustomization<dependencies.internal.engine.AnalysisCustomization

    properties(Constant)
        Key="AnalyzeCCode";
        Name=string(message("MATLAB:dependency:analysis:AnalyzeCCode"));
        DefaultEnabled=true;
    end

    methods(Static)
        function[analyzers,filters]=apply(~,analyzers,filters,enabled)
            if enabled
                analyzers(end+1)=dependencies.internal.analysis.ccode.CCodeNodeAnalyzer;
            end
        end
    end

end
