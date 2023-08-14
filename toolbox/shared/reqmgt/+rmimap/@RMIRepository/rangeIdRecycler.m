function varargout=rangeIdRecycler(this,src,varargin)




    srcRoot=rmimap.RMIRepository.getRoot(this.graph,src);

    switch length(varargin)
    case 0
        varargout{1}=getRecycledIds(srcRoot);
    case 1
        setRecycledIds(this.graph,srcRoot,varargin{1});
    case 2
        restoreId(this.graph,srcRoot,varargin{1},varargin{2});
    otherwise
        error('Invalid number of arguments in a call to RMIRepository.rangeIdRecycler()');
    end
end

function recycledIds=getRecycledIds(srcRoot)
    recycledIdsString=srcRoot.getProperty('lostLabels');
    if isempty(recycledIdsString)
        recycledIds={};
    else
        recycledIds=sort(eval(recycledIdsString));
    end
end

function setRecycledIds(myGraph,srcRoot,recycledIds)
    storedIds=getRecycledIds(srcRoot);
    allRecycledIds=unique([storedIds,recycledIds]);
    setLostLabels(myGraph,srcRoot,allRecycledIds);
end

function setLostLabels(myGraph,srcRoot,recycledIds)
    t=M3I.Transaction(myGraph);
    if isempty(recycledIds)
        recycledIdsString='{  }';
    else
        recycledIdsString=['{ ',sprintf('''%s'' ',recycledIds{:}),'}'];
    end
    srcRoot.setProperty('lostLabels',recycledIdsString);
    t.commit();
end

function restoreId(myGraph,srcRoot,id,range)

    recycledIds=getRecycledIds(srcRoot);
    isMatched=strcmp(recycledIds,id);
    if any(isMatched)
        remainingRecycledIds=recycledIds(~isMatched);
        setLostLabels(myGraph,srcRoot,remainingRecycledIds)
        ids=srcRoot.getProperty('rangeLabels');
        if~any(strcmp(ids,id))
            starts=srcRoot.getProperty('rangeStarts');
            ends=srcRoot.getProperty('rangeEnds');
            [starts,ends,ids]=rmiut.RangeUtils.appendRange(starts,ends,ids,range,id);
            t=M3I.Transaction(myGraph);
            srcRoot.setProperty('rangeStarts',starts);
            srcRoot.setProperty('rangeEnds',ends);
            srcRoot.setProperty('rangeLabels',ids);
            t.commit();
        end
    end
end



