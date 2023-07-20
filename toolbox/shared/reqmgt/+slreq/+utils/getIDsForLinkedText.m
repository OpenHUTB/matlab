function mfIDs=getIDsForLinkedText(slModelName,tagFilters)

    mfIDs={};

    slModelFile=get_param(slModelName,'FileName');
    linkSet=slreq.data.ReqData.getInstance.getLinkSet(slModelFile);
    if isempty(linkSet)
        return;
    end

    localIDs=linkSet.getTextItemIds();
    if isempty(localIDs)
        return;
    end

    for i=1:length(localIDs)
        oneID=localIDs{i};
        textItem=linkSet.getTextItem(oneID);
        textRanges=textItem.getRanges();
        hasLinks=false;
        for j=1:length(textRanges)
            links=textRanges(j).getLinks();
            if isempty(links)
                continue;
            end
            if~isempty(tagFilters)&&tagFilters.enabled
                reqs=slreq.utils.linkToStruct(links);
                filtered=rmi.filterTags(reqs,tagFilters.tagsRequire,tagFilters.tagsExclude);
                if~isempty(filtered)
                    hasLinks=true;
                    break;
                end
            else
                hasLinks=true;
                break;
            end
        end
        if hasLinks
            mfIDs{end+1}=[slModelName,oneID];%#ok<AGROW>
        end
    end
end

