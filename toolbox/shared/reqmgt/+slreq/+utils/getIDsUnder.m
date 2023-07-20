function ids=getIDsUnder(artifactName,parentId)











    if~isempty(parentId)
        prefix1=[parentId,':'];
        prefix2=[parentId,'.'];
    end

    compareLength=length(prefix1);
    ids={};
    linkSet=slreq.data.ReqData.getInstance.getLinkSet(artifactName);
    if~isempty(linkSet)
        linkedItems=linkSet.getLinkedItems();
        for i=1:numel(linkedItems)
            oneId=linkedItems(i).id;
            if isempty(parentId)
                ids{end+1}=oneId;%#ok<AGROW>
            elseif length(oneId)<=compareLength
                continue;
            elseif any(strncmp(oneId,{prefix1,prefix2},compareLength))
                ids{end+1}=oneId;%#ok<AGROW>
            end
        end
    end
end
