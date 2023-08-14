function map=getDataObjectUniqueKeyToResultMap(results)












    uniqueIdentifiers=cellfun(@(x)x.UniqueIdentifier,results,'UniformOutput',false);


    dataObjectIndices=cellfun(@(x)isa(x,'fxptds.SimulinkDataObjectIdentifier'),uniqueIdentifiers);
    dataObjectUniqueIdentifier=uniqueIdentifiers(dataObjectIndices);
    dataObjectResults=results(dataObjectIndices);


    dataObjectUniqueKeys=cellfun(@(x)x.DataObjectUniqueKey,dataObjectUniqueIdentifier,'UniformOutput',false);


    [~,iReverseLookup,iLookup]=unique(dataObjectUniqueKeys);


    keysForMap=dataObjectUniqueKeys(iReverseLookup)';


    nEntries=numel(keysForMap);
    valuesForMap=cell(nEntries,1);
    for ii=1:nEntries
        valuesForMap(ii)={dataObjectResults(iLookup==ii)};
    end


    if isempty(keysForMap)
        map=containers.Map.empty;
    else
        map=containers.Map(keysForMap,valuesForMap);
    end
end
