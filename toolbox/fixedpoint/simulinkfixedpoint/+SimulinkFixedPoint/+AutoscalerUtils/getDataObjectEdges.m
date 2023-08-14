function[dataObjectEdges]=getDataObjectEdges(dataObjectUniqueKeyToResultMap)

















    if isempty(dataObjectUniqueKeyToResultMap)
        dataObjectEdges={};
    else
        setOfResultGroups=dataObjectUniqueKeyToResultMap.values;
        iDataObjectResultsToBeShared=cellfun(@(x)numel(x)>1,setOfResultGroups);

        dataObjectResultsToBeShared=setOfResultGroups(iDataObjectResultsToBeShared);

        nEntries=numel(dataObjectResultsToBeShared);

        cellOfNEdges=cellfun(@(x)numel(x)-1,dataObjectResultsToBeShared,'UniformOutput',false);
        nEdges=sum([cellOfNEdges{:}]);
        dataObjectEdges=cell(1,nEdges);
        edgeCount=1;
        for iEntry=1:nEntries
            resultSet=dataObjectResultsToBeShared{iEntry};
            uniqueKeys=cellfun(@(x)x.UniqueIdentifier.UniqueKey,resultSet,'UniformOutput',false);
            uniqueKeys=cat(1,uniqueKeys(1:end-1),uniqueKeys(2:end));
            for iEdge=1:cellOfNEdges{iEntry}
                dataObjectEdges(edgeCount)={uniqueKeys(:,iEdge)'};
                edgeCount=edgeCount+1;
            end
        end
    end
end
