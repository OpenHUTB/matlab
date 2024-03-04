classdef TestCaseTagDistribution<metric.GraphMetric

    properties
    end


    methods
        function obj=TestCaseTagDistribution()
            obj.AlgorithmID='TestCaseTagDistribution';
            obj.addSupportedValueDataType(metric.data.ValueType.Distribution);
            obj.Version=1;
        end


        function result=algorithm(this,resultFactory,queryResult)
            testArtifacts=queryResult.getSequences();
            if~isempty(testArtifacts)
                testArtifacts=cellfun(@(x)x{1},testArtifacts)';
            end

            tagArray={};
            countEmptyTag=0;
            refArts=alm.Artifact.empty;
            for k=1:length(testArtifacts)

                testArtifact=testArtifacts(k);

                if strcmp(testArtifact.Type,'sl_test_case')


                    factory=alm.StorageFactory;
                    selfContainedArtifact=testArtifact.getSelfContainedArtifact();
                    storageHandler=factory.createHandler(selfContainedArtifact.Storage);
                    testFile=storageHandler.getAbsoluteAddress(selfContainedArtifact.Address);

                    id=stm.internal.getTestIdFromUUIDAndTestFile(testArtifact.Address,testFile);
                    tCase=sltest.testmanager.Test.getTestObjFromID(id);
                    if isempty(tCase.Tags)
                        countEmptyTag=countEmptyTag+1;
                    end
                    tagArray=[tagArray,tCase.Tags];%#ok<AGROW>
                    refArts(end+1)=testArtifact;%#ok<AGROW>

                end
            end

            uniqueTag=unique(tagArray);
            tagCount=zeros(1,length(uniqueTag));
            for ut=1:length(uniqueTag)
                temp=ismember(tagArray,uniqueTag(ut));
                tagCount(ut)=sum(temp);
            end
            result=resultFactory.createResult(this.ID,refArts);

            if countEmptyTag~=0
                tagCount=[tagCount,countEmptyTag];
                if isempty(uniqueTag)
                    uniqueTag="-";
                else
                    uniqueTag=[uniqueTag,"-"];
                end
            end
            result.Value=struct('BinCounts',tagCount,'BinEdges',{uniqueTag});

        end
    end
end
