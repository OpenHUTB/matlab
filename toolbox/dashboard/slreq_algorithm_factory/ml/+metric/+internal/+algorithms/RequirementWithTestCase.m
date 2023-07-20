classdef RequirementWithTestCase<metric.SimpleMetric



    properties
    end

    methods
        function obj=RequirementWithTestCase()
            obj.AlgorithmID='RequirementWithTestCase';
            obj.addSupportedValueDataType(metric.data.ValueType.Uint64);
            obj.Version=1;
        end

        function result=algorithm(this,resultFactory,reqArtifact)
            result=resultFactory.createResult(this.ID,reqArtifact);
            val=uint64(0);




            if length(reqArtifact)>1&&strcmp(reqArtifact(2).Type,'sl_test_case')
                val=uint64(1);
            end
            result.Value=val;
        end
    end
end
