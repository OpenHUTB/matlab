classdef DataSegmentEstimate<metric.GraphMetric






    methods
        function obj=DataSegmentEstimate()
            obj.AlgorithmID='DataSegmentEstimate';
            obj.addSupportedValueDataType(metric.data.ValueType.Uint64);
            obj.Version=1;
        end

        function res=algorithm(this,resultFactory,queryResult,dataServiceData)

            artifacts=queryResult.getSequences();
            topLevelDesign=artifacts{1}{1};
            res=resultFactory.createResult(this.ID,topLevelDesign);
            res.Value=uint64(dataServiceData.EstimationData.DataSegmentEstimate(topLevelDesign.Id).TotalMemoryConsumption);
        end
    end
end


