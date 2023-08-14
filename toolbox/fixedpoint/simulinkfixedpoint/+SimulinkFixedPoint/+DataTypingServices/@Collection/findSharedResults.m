function addedResults=findSharedResults(this,info,runObj)










    totalNumAdded=0;
    totalRecAdded={};
    addedResults={};

    for idx=1:length(info.sharedList)





        [sharedRecords,numberOfResultsAdded,resultAdded]=this.getSharedRecords(info.sharedList{idx},runObj);

        if numberOfResultsAdded>0
            totalNumAdded=totalNumAdded+numberOfResultsAdded;
            totalRecAdded(end+1:end+totalNumAdded)=resultAdded(1:numberOfResultsAdded);
        end



        if~isempty(sharedRecords)

            for index=1:length(sharedRecords)-1
                runObj.dataTypeGroupInterface.addEdge(...
                sharedRecords(index).UniqueIdentifier.UniqueKey,...
                sharedRecords(index+1).UniqueIdentifier.UniqueKey);
            end
        end

        if totalNumAdded>0
            addedResults=[addedResults,totalRecAdded];%#ok<AGROW>
            totalNumAdded=0;
            totalRecAdded={};
        end
    end
end


