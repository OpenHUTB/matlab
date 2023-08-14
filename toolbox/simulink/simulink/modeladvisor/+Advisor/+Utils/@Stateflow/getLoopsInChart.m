function loops=getLoopsInChart(chartObj)













    allJcns=chartObj.find('-isa','Stateflow.Junction','Type','CONNECTIVE');
    allJcnIds=arrayfun(@(x)x.Id,allJcns);
    loops={};
    for i=1:length(allJcns)
        loopAtJcn=collectLoops(allJcnIds,allJcns(i).Id,setdiff(allJcnIds,allJcns(i).Id),[],{});

        for j=1:length(loopAtJcn)
            if~isempty(loopAtJcn{j})&&~any(cellfun(@(x)isequal(sort(x),sort(loopAtJcn{j})),loops))
                loops{end+1}=loopAtJcn{j};%#ok<AGROW>
            end
        end
    end
end

function loops=collectLoops(allJunctions,thisJcnId,nonVisitedJcns,currentPath,loops)
    thisJcn=idToHandle(sfroot,thisJcnId);

    sourcedTrH=thisJcn.sourcedTransitions;


    sourcedDest=arrayfun(@(x)x.Destination.Id,sourcedTrH);
    sourcedDestJuncIds=intersect(sourcedDest,allJunctions);
    if ismember(thisJcnId,sourcedDestJuncIds)
        sourcedDestJuncIds=setdiff(sourcedDestJuncIds,thisJcnId);
        loops{end+1}=thisJcnId;
    else
        currentPath=[currentPath,thisJcnId];
    end
    for i=1:length(sourcedDestJuncIds)
        if ismember(sourcedDestJuncIds(i),nonVisitedJcns)

            nonVisitedJcns=setdiff(nonVisitedJcns,sourcedDestJuncIds(i));
            loops=collectLoops(allJunctions,sourcedDestJuncIds(i),nonVisitedJcns,currentPath,loops);
        elseif~isempty(currentPath)&&isequal(sourcedDestJuncIds(i),currentPath(1))

            loops{end+1}=currentPath;%#ok<AGROW>
            continue;
        end
    end
end