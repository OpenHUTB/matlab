classdef TestCaseTag<metric.SimpleMetric



    properties
    end

    methods
        function obj=TestCaseTag()
            obj.AlgorithmID='TestCaseTag';
            obj.addSupportedValueDataType(metric.data.ValueType.String);
            obj.Version=1;
        end


        function result=algorithm(this,resultFactory,testArtifact)





            factory=alm.StorageFactory;
            selfContainedArtifact=testArtifact.getSelfContainedArtifact();
            storageHandler=factory.createHandler(selfContainedArtifact.Storage);
            testFile=storageHandler.getAbsoluteAddress(selfContainedArtifact.Address);
            id=stm.internal.getTestIdFromUUIDAndTestFile(testArtifact.Address,testFile);
            tCase=sltest.testmanager.Test.getTestObjFromID(id);

            tagArray=tCase.Tags;


            uniqueTag=unique(tagArray);
            result=resultFactory.createResult(this.ID,testArtifact);

            if isempty(uniqueTag)
                uniqueTag="-";
            end
            result.Value=strjoin(uniqueTag,', ');

        end
    end
end
