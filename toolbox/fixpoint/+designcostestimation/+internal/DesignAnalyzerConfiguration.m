classdef DesignAnalyzerConfiguration<handle




    properties
AnalysisOptions
OperatorWeights
RunMode
        UseCustomWeights logical=false;
        EnableDiagnostics logical=false;
    end

    methods


        function obj=DesignAnalyzerConfiguration()

            obj.AnalysisOptions=designcostestimation.internal.AnalysisOptions.StaticOperatorCounts;

            obj.OperatorWeights=designcostestimation.internal.OperatorsWeight2d();

            obj.RunMode=designcostestimation.internal.DesignAnalyzerRunMode.RunAnalysisAndCostEstimation;
        end


        function setOperatorWeights(obj,aOperatorWeightObj)

            obj.OperatorWeights=aOperatorWeightObj;
        end


        function setRunMode(obj,aRunMode)
            obj.RunMode=aRunMode;
        end


        function setAnalysisOptions(obj,aAnalysisOptions)
            obj.AnalysisOptions=aAnalysisOptions;
        end


        function setUseCustomWeights(obj,aUseCustomWeights)
            obj.UseCustomWeights=aUseCustomWeights;
        end

    end
end
