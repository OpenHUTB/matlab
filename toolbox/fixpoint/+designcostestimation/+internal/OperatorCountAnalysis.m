classdef OperatorCountAnalysis<designcostestimation.internal.AnalysisStrategy





    properties(Access=public)
OperatorsToExclude
InstrumentationLevel
    end

    methods


        function obj=OperatorCountAnalysis()

            obj.OperatorsToExclude={'CALL'};
            obj.InstrumentationLevel=2;
        end


        function analyze(obj,aModelsUnderSUDandAssociatedCostsMap)

            costStructs=values(aModelsUnderSUDandAssociatedCostsMap);
            for i=1:aModelsUnderSUDandAssociatedCostsMap.Count
                obj.analyzeThis(costStructs{i});
            end
        end
    end

    methods(Abstract)


        analyzeThis(~)
    end
end
