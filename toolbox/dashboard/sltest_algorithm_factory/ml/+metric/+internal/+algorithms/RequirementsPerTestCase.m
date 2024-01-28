classdef RequirementsPerTestCase<metric.SimpleMetric

    properties
    end


    methods
        function obj=RequirementsPerTestCase()
            obj.AlgorithmID='RequirementsPerTestCase';
            obj.addSupportedValueDataType(metric.data.ValueType.Uint64);
            obj.Version=2;
        end


        function result=algorithm(this,resultFactory,testCaseAndRequirements)
            result=resultFactory.createResult(this.ID,testCaseAndRequirements);
            val=0;
            numberOfArtifacts=numel(testCaseAndRequirements);
            if numberOfArtifacts>1
                val=numberOfArtifacts-1;
            end
            result.Value=uint64(val);
        end
    end
end
