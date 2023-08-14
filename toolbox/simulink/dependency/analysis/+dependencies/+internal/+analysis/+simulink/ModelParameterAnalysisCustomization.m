classdef ModelParameterAnalysisCustomization<dependencies.internal.engine.AnalysisCustomization




    properties(Constant)
        Key="AnalyzeModelParameters";
        Name=string(message("SimulinkDependencyAnalysis:Analyze:AnalyzeModelParameters"));
        DefaultEnabled=false;
    end

    methods(Static)
        function[analyzers,filters]=apply(~,analyzers,filters,enabled)
            import dependencies.internal.analysis.simulink.setupAdditionalModelAnalyzers;

            if enabled
                analyzers=setupAdditionalModelAnalyzers(...
                analyzers,[
                dependencies.internal.analysis.simulink.ParameterInitializationAnalyzer
                dependencies.internal.analysis.simulink.VariantControlAnalyzer
                ]);

                analyzers=[dependencies.internal.analysis.matlab.BaseWorkspaceAnalyzer;analyzers(:)];
            end
        end
    end

end
