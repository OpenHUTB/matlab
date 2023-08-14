function[artifacts,linkedIds]=getDependentItems(linkedArtifact,linkedId)











    artifacts={};
    linkedIds={};

    [itemIds,reqSetName]=slreq.getDestinationIds(linkedArtifact);
    if~isempty(itemIds)&&any(strcmp(itemIds,linkedId))

        reqSet=slreq.data.ReqData.getInstance.getReqSet(reqSetName);
        item=reqSet.find('customId',linkedId);
        if~isempty(item)
            links=item.getLinks();
            for j=1:numel(links)
                src=links(j).source;
                artifacts{end+1}=src.artifactUri;%#ok<AGROW>
                linkedIds{end+1}=src.id;%#ok<AGROW>
            end
        end
    end
end


