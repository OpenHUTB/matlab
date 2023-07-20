

function realignIterationsForEquivalenceTest(tcObj,oldItrList)
    if(strcmp(tcObj.TestType,'equivalence'))
        oldItrIdMap=Simulink.sdi.Map(int32(0),int32(0));
        for k=1:length(oldItrList)
            itrId=oldItrList(k).getIterationId();
            oldItrIdMap.insert(itrId,1);
        end

        newItrList=[];
        allItrList=tcObj.getIterations();
        for k=1:length(allItrList)
            itrId=allItrList(k).getIterationId();
            if(~oldItrIdMap.isKey(itrId))
                newItrList=[newItrList,allItrList(k)];
            end
        end



        propertyList={};
        for itrK=1:length(newItrList)
            itrParam={};
            for k=1:length(newItrList(itrK).TestParams)
                paramValue=newItrList(itrK).TestParams{k}{2};
                simIndex=newItrList(itrK).TestParams{k}{3};
                if(~isempty(paramValue)&&simIndex==1)
                    itrParam{end+1}=newItrList(itrK).TestParams{k};
                end
            end
            propertyList{end+1}=itrParam;
        end

        if(~isempty(newItrList))
            tcObj.deleteIterations(newItrList);
        end

        for k=1:length(propertyList)
            if~isempty(propertyList{k})
                testItr=sltestiteration();
                itrParam=propertyList{k};
                for indx=1:length(itrParam)
                    setTestParam(testItr,itrParam{indx}{1},itrParam{indx}{2},'SimulationIndex',1);
                    setTestParam(testItr,itrParam{indx}{1},itrParam{indx}{2},'SimulationIndex',2);
                end
                addIteration(tcObj,testItr);
            end
        end
    end
end