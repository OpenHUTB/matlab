classdef ParameterAnalyzer<handle






    properties(SetAccess=private)
        ModelName char
        ParamEstimateResult designcostestimation.internal.costestimate.ParamCostEstimate
    end

    methods

        function obj=ParameterAnalyzer(modelName)
            obj.ModelName=modelName;
            obj.ParamEstimateResult=designcostestimation.internal.costestimate.ParamCostEstimate(modelName);
        end


        function analyze(obj)
            obj.buildDesign();
            [tunableMemoryConsumption,tunableParamTable]=designcostestimation.internal.util.tunableParamMetric();
            [inlineMemoryConsumption,inlineParamTable]=designcostestimation.internal.util.inlineParamMetric();
            TotalMemoryConsumption=tunableMemoryConsumption+inlineMemoryConsumption;
            CostTable=obj.mergeTable(tunableParamTable,inlineParamTable);
            obj.ParamEstimateResult.setCostInformation(TotalMemoryConsumption,CostTable);
        end



        function CostTable=mergeTable(~,TunableParamTable,InlineParamTable)
            CostTable=[TunableParamTable;InlineParamTable];
        end



        function checkDesign(obj)
            systemTargetFile=get_param(obj.ModelName,'SystemTargetFile');
            switch systemTargetFile
            case 'ert.tlc'
            case 'grt.tlc'
                return;
            otherwise
                DAStudio.error('SimulinkFixedPoint:designCostEstimation:incompatibleSystemTargetFile');
            end
        end

        function buildDesign(obj)
            obj.checkDesign();


            origGenParamCollection=get_param(obj.ModelName,'OpCountCollection');
            set_param(obj.ModelName,'OpCountCollection','ParameterMetricsCollection');
            restoreGenCodeOnly=onCleanup(@()set_param(obj.ModelName,'OpCountCollection',origGenParamCollection));
            rtwgen(obj.ModelName);
        end

    end
end
