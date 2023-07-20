function stats=getNodeStatistics(node)












    hasValidUnit=@(n)~strcmpi(n.series.unit,'INVALID');
    isZCSignal=@(n)hasTag(n,'ZeroCrossing');

    isVariable=@(n)(hasValidUnit(n)&&~isZCSignal(n));


    isZC=@(n)lHasTagValue(n,'SimulationStatistics','ZeroCrossing');

    allLogs=find_all(node);
    bVariable=arrayfun(isVariable,allLogs);
    bZC=arrayfun(isZC,allLogs);

    loggedVariables=allLogs(bVariable);
    loggedZeroCrossings=allLogs(bZC);

    if~isempty(loggedVariables)
        stats.nPoints=loggedVariables(1).series.points;
    elseif~isempty(loggedZeroCrossings)
        stats.nPoints=loggedZeroCrossings(1).values.series.points;
    else
        stats.nPoints=NaN;
    end

    stats.nVariables=numel(loggedVariables);
    stats.nZCs=numel(loggedZeroCrossings);

end

function res=lHasTagValue(node,name,value)
    if numel(node)>1
        node=node(1);
    end

    res=hasTag(node,name)&&all(strcmp(getTag(node,name),{name,value}));
end

function out=find_all(nodes)
    out=nodes(:);
    for iLog=1:numel(nodes)
        ids=nodes(iLog).childIds;
        for iChild=1:numel(ids)
            out=[out;find_all(getChild(nodes(iLog),ids{iChild}))];%#ok<AGROW> 
        end
    end
end