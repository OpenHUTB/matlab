classdef TestCaseWithRequirement<metric.SimpleMetric



    properties
    end

    methods
        function obj=TestCaseWithRequirement()
            obj.AlgorithmID='TestCaseWithRequirement';
            obj.addSupportedValueDataType(metric.data.ValueType.Uint64);
            obj.Version=2;
        end



        function result=algorithm(this,resultFactory,testCaseAndRequirements)
            result=resultFactory.createResult(this.ID,testCaseAndRequirements);

            if numel(testCaseAndRequirements)==1

                result.Value=uint64(0);
            else

                result.Value=uint64(1);
            end
        end
    end
end
