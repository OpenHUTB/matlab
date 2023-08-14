function breakpointObjectEdges=getBreakpointObjectEdges(results)






    nResults=numel(results);
    uniqueIdentifiers=cell(1,nResults);
    dataObjectIndices=false(1,nResults);
    for iResult=1:nResults
        uniqueIdentifiers{iResult}=results{iResult}.UniqueIdentifier;
        dataObjectIndices(iResult)=isa(uniqueIdentifiers{iResult},'fxptds.SimulinkDataObjectIdentifier');
    end
    dataObjectUniqueIdentifier=uniqueIdentifiers(dataObjectIndices);


    breakpointObjectIndices=cellfun(@(x)isa(x.DataObjectWrapper,'Simulink.Breakpoint'),dataObjectUniqueIdentifier);
    breakpointObjectIdentifiers=dataObjectUniqueIdentifier(breakpointObjectIndices);


    structTypeName=cellfun(@(x)x.DataObjectWrapper.Object.StructTypeInfo.Name,breakpointObjectIdentifiers,'UniformOutput',false);
    nonEmptyNames=cellfun(@(x)~isempty(x),structTypeName);
    [uniqueNames,ii,jj]=unique(structTypeName(nonEmptyNames));


    breakpointObjectEdges={};
    if~isempty(uniqueNames)
        breakpointObjectIdentifiers=breakpointObjectIdentifiers(nonEmptyNames);
        uniqueKeys=cellfun(@(x)x.UniqueKey,breakpointObjectIdentifiers,'UniformOutput',false);




        for iCount=1:numel(ii)
            matchingIndices=jj==iCount;
            sharedKeys=uniqueKeys(matchingIndices);
            nEdges=numel(sharedKeys)-1;
            for kk=1:nEdges
                breakpointObjectEdges{end+1}={sharedKeys{kk},sharedKeys{kk+1}};%#ok<AGROW>
            end
        end
    end
end
