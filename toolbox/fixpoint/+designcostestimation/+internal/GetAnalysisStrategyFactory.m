classdef GetAnalysisStrategyFactory




    methods(Static)
        function AnalysisObj=getAnalysisStrategy(AnalysisEnum)
            switch AnalysisEnum
            case designcostestimation.internal.AnalysisOptions.StaticOperatorCounts

                AnalysisObj=designcostestimation.internal.StaticOperatorCountAnalysis();
            end
        end
    end
end
