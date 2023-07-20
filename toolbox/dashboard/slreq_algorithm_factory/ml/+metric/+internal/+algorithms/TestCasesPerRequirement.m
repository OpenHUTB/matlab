classdef TestCasesPerRequirement<metric.SimpleMetric



    properties
    end

    methods
        function obj=TestCasesPerRequirement()
            obj.AlgorithmID='TestCasesPerRequirement';
            obj.addSupportedValueDataType(metric.data.ValueType.Uint64);
            obj.Version=1;
        end

        function result=algorithm(this,resultFactory,reqArtifact)
            result=resultFactory.createResult(this.ID,reqArtifact);
            val=0;


            reqArtifactSize=length(reqArtifact);
            if reqArtifactSize>1
                val=reqArtifactSize-1;
            end
            result.Value=uint64(val);
        end
    end
end
