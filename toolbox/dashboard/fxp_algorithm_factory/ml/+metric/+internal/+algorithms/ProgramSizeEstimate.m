classdef ProgramSizeEstimate<metric.GraphMetric




    methods
        function obj=ProgramSizeEstimate()
            obj.AlgorithmID='OperatorCount';
            obj.addSupportedValueDataType(metric.data.ValueType.Uint64);
            obj.Version=1;
        end

        function res=algorithm(this,resultFactory,queryResult,dataServiceData)

            artifacts=queryResult.getSequences();
            topLevelDesign=artifacts{1}{1};
            res=resultFactory.createResult(this.ID,topLevelDesign);
            res.Value=uint64(dataServiceData.EstimationData.ProgramSizeEstimate(topLevelDesign.Id).TotalCost);
        end
    end
end


