





function[hasLinkSet,hasLinkedBlocks,hasLinkedOther]=artifactHasOutgoingLinks(artifact)


    hasLinkedBlocks=false;
    hasLinkedOther=false;

    if isnumeric(artifact)

        artifact=get_param(artifact,'FileName');
    end

    linkSet=slreq.data.ReqData.getInstance.getLinkSet(artifact);
    hasLinkSet=~isempty(linkSet);



    if hasLinkSet&&nargout>1
        linkedItems=linkSet.getLinkedItems();
        for i=1:numel(linkedItems)
            item=linkedItems(i);
            if isempty(item.getLinks())
                continue;
            end
            if~isempty(regexp(item.id,'^:\d','once'))
                hasLinkedBlocks=true;
                return;






            else
                hasLinkedOther=true;


            end
        end
    end
end
