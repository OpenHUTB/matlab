function updateMdlBlkDataset(actualDataSet,viewOnlyDataSet,runName)










    viewOnlyRunObject=viewOnlyDataSet.getRun(runName);
    actualRunObject=actualDataSet.getRun(runName);


    actualRootFunctionIDsMap=actualRunObject.getRootFunctionIDsMap;
    keyCount=actualRootFunctionIDsMap.getCount;
    for idx=1:keyCount
        key=actualRootFunctionIDsMap.getKeyByIndex(idx);
        functionIds=actualRootFunctionIDsMap.getDataByIndex(idx);
        viewOnlyRunObject.insertRootFunctionIDs(key,functionIds{:});
    end


    actualResults=actualRunObject.getResults;

    for idx=1:length(actualResults)

        currentActualResult=actualResults(idx);
        uniqueID=currentActualResult.UniqueIdentifier;

        currentViewOnlyResult=viewOnlyRunObject.getResultByID(uniqueID);

        if~isempty(currentViewOnlyResult)



            s.SimMin=currentViewOnlyResult.SimMin;
            s.SimMax=currentViewOnlyResult.SimMax;
            s.DerivedMin=currentViewOnlyResult.DerivedMin;
            s.DerivedMax=currentViewOnlyResult.DerivedMax;
            scopingID=currentViewOnlyResult.getScopingId;

            currentViewOnlyResult=copy(currentActualResult);
            currentViewOnlyResult.addScopingId(scopingID);


            currentViewOnlyResult.updateResultData(s);
        else


            currentViewOnlyResult=copy(currentActualResult);


            currentViewOnlyResult.addScopingId({});
        end


        viewOnlyRunObject.addResult(currentViewOnlyResult);


        currentViewOnlyResult.setAsReadOnly(true);
    end



    actualMetaData=actualRunObject.getMetaData;
    if~isempty(actualMetaData)
        viewOnlyMetaData=viewOnlyRunObject.getMetaData;
        if isempty(viewOnlyMetaData)
            viewOnlyRunObject.setMetaData(fxptds.AutoscalerMetaData);
            viewOnlyMetaData=viewOnlyRunObject.getMetaData;
        end
        viewOnlyMetaData.updateFromMetaData(actualMetaData);
    end

end
