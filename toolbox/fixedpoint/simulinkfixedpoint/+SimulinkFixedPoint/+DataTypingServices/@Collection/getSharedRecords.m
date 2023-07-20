function[sharedRecords,totalNumAdded,totalRecAdded]=getSharedRecords(this,sharedList,runObj)




    sharedRecords={};
    totalNumAdded=0;
    totalRecAdded={};

    busObjectHandleMap=runObj.getMetaData.getBusObjectHandleMap();



    for i=1:length(sharedList)
        curSignal=sharedList{i};
        if(isempty(curSignal.blkObj)||isempty(curSignal.pathItem))
            continue;
        end

        [curSharedRecord,recAdded,addedRecNum]=...
        this.getRecordWithBusObjectSwap(curSignal,busObjectHandleMap,runObj);

        if addedRecNum>0
            totalNumAdded=totalNumAdded+addedRecNum;
            totalRecAdded(end+1:end+addedRecNum)=recAdded(1:addedRecNum);
        end



        sharedRecords=[curSharedRecord,sharedRecords];%#ok<AGROW>

    end
end