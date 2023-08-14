
















function[ids,reqSetName]=getDestinationIds(rootId)

    ids={};

    reqSet=slreq.data.ReqData.getInstance.getReqSet(rootId);
    if isempty(reqSet)

        [grpItems,reqSetName]=slreq.data.ReqData.getInstance.getGroupItems(rootId);
        for i=1:numel(grpItems)
            ids{end+1}=grpItems(i).id;%#ok<AGROW>
        end
    else
        reqSetName=reqSet.name;
        [intItems,extItems]=reqSet.getItems();
        allItems=[intItems;extItems];
        for i=1:numel(allItems)
            ids{end+1}=allItems(i).id;%#ok<AGROW>
        end
    end
end
