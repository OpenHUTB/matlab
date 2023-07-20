function[newResults,numRecAdded]=createAndUpdateParameterResults(this,pObjInfoList,runObj,modelName)




    numRecAdded=0;
    newResults={};

    for infoIdx=1:length(pObjInfoList)

        [result,isNew,parameterObjectWrapper]=createParameterResult(this,modelName,pObjInfoList{infoIdx},runObj);
        if isNew
            numRecAdded=numRecAdded+1;
            newResults{end+1}=result;%#ok<AGROW>
        end


        varUsage=pObjInfoList{infoIdx}.usage;
        srcIDs=updateParameterSourceBlocks(this,varUsage,result,runObj);


        [newBusObjectResults,numbOfBusRecAdded]=createBusResultsFromParameter(this,parameterObjectWrapper,runObj,srcIDs);
        if numbOfBusRecAdded>0
            numRecAdded=numRecAdded+numbOfBusRecAdded;
            newResults(end+1:end+numbOfBusRecAdded)=newBusObjectResults;
        end


        createParameterConstraints(this,parameterObjectWrapper,result,runObj);


        updateParameterModelRequiredRanges(this,parameterObjectWrapper,pObjInfoList{infoIdx},result);
    end
end


