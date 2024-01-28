classdef TestCaseType<metric.SimpleMetric

    properties
    end


    methods
        function obj=TestCaseType()
            obj.AlgorithmID='TestCaseType';
            obj.addSupportedValueDataType(metric.data.ValueType.Uint64);
            obj.Version=1;

        end


        function result=algorithm(this,resultFactory,testCaseArtifact)
            result=resultFactory.createResult(this.ID,testCaseArtifact);

            factory=alm.StorageFactory;
            selfContainedArtifact=testCaseArtifact.getSelfContainedArtifact();
            storageHandler=factory.createHandler(selfContainedArtifact.Storage);
            testFile=storageHandler.getAbsoluteAddress(selfContainedArtifact.Address);
            id=stm.internal.getTestIdFromUUIDAndTestFile(testCaseArtifact.Address,testFile);
            tCase=sltest.testmanager.Test.getTestObjFromID(id);
            result.Value=uint64(metric.internal.algorithms.TestCaseTypeEnum(tCase.TestType));
        end
    end
end
