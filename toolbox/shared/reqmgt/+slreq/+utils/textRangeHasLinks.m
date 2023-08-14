function tf=textRangeHasLinks(textRange,filters)


    links=textRange.getLinks;
    if isempty(links)
        tf=false;
    else
        reqs=slreq.utils.linkToStruct(links);
        if isempty(filters)
            tf=true;
        else
            matchingReqs=rmi.filterTags(reqs,filters.tagsRequire,filters.tagsExclude);
            tf=~isempty(matchingReqs);
        end
    end
end
