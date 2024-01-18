function ids=getNodeIds(rootId,linkedOnly)

    if nargin<2
        linkedOnly=false;
    end
    ids=slreq.getOwnedIds(rootId,linkedOnly);
end

