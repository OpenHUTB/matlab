












function ids=getOwnedIds(rootId,~)

    ids={};
    linkSet=slreq.data.ReqData.getInstance.getLinkSet(rootId);
    if~isempty(linkSet)
        linkedItems=linkSet.getLinkedItems();
        for i=1:numel(linkedItems)
            ids{end+1}=linkedItems(i).id;%#ok<AGROW>
        end
    end

    if isempty(ids)



        ids=slreq.getDestinationIds(rootId);
    end
end

