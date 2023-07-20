function result=hasLinks(ddPath,filters)




    if nargin==1
        filters=[];
    end

    [~,ddName]=fileparts(ddPath);
    linkSet=slreq.data.ReqData.getInstance.getLinkSet(ddName);
    if~isempty(linkSet)
        linkedItems=linkSet.getLinkedItems();
        for i=1:numel(linkedItems)
            links=linkedItems(i).getLinks();
            if~isempty(links)
                if isempty(filters)||~filters.enabled||...
                    hasLinkWithMatchingTags(links,filters)
                    result=true;
                    return;
                end
            end
        end
    end
    result=false;

end

function tf=hasLinkWithMatchingTags(links,filters)
    reqs=slreq.utils.linkToStruct(links);
    filteredReqs=rmi.filterTags(reqs,filters.tagsRequire,filters.tagsExcluded);
    tf=~isempty(filteredReqs);
end


