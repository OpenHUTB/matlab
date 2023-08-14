







function[sids,nestedItems]=getSidsWithLinks(modelH)


    modelName=get_param(modelH,'Name');
    artifact=get_param(modelH,'FileName');

    sids={};
    nestedItems={};

    linkSet=slreq.data.ReqData.getInstance.getLinkSet(artifact);
    if isempty(linkSet)
        return;
    end

    linkedItems=linkSet.getLinkedItems();
    for i=1:numel(linkedItems)
        item=linkedItems(i);
        if item.isTextRange()
            continue;
        end
        chMatch=regexp(item.id,'^(:urn:uuid:\w+)','tokens');
        if~isempty(chMatch)
            nestedItems{end+1}=[modelName,chMatch{1}{1}];%#ok<AGROW>
        else
            if(sysarch.isZCElement(item.id))



                sids{end+1}=[modelName,':',item.id];%#ok<AGROW>
            else
                sids{end+1}=[modelName,item.id];%#ok<AGROW>
            end

        end
    end
    textItemsIds=linkSet.getTextItemIds;
    for i=1:numel(textItemsIds)
        nestedItems{end+1}=[modelName,textItemsIds{i}];%#ok<AGROW>
    end
end
