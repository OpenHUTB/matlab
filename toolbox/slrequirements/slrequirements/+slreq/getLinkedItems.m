













function[docs,locations,reqsys]=getLinkedItems(artifact,doFilter)

    docs={};
    locations={};
    reqsys={};

    if nargin<2
        doFilter=false;
    end

    linkedItems=slreq.internal.getLinkedItems(artifact);

    if isempty(linkedItems)
        return;
    end

    if nargout==1
        docs=geReferencedItems(linkedItems,doFilter);
    else
        [docs,locations,reqsys]=geReferencedItems(linkedItems,doFilter);
    end

end


function[docs,locations,reqsys]=geReferencedItems(linkedItems,doFilter)

    docs={};
    if nargout>1
        locations={};
        reqsys={};
    end


    if doFilter
        filters=rmi.settings_mgr('get','filterSettings');
        if filters.enabled
            dummyReq=rmi.createEmptyReqs(1);
        end
    else
        filters.enabled=false;
    end


    for i=1:numel(linkedItems)
        links=linkedItems(i).getLinks();

        for j=1:numel(links)
            link=links(j);
            if filters.enabled
                dummyReq.keywords=slreq.utils.getKeywords(link);
                filtered=rmi.filterTags(dummyReq,filters.tagsRequire,filters.tagsExclude);
                if isempty(filtered)
                    continue;
                end
            end
            doc=link.destUri;
            match=strcmp(docs,doc);
            if~any(match)
                docs{end+1}=doc;%#ok<*AGROW>
                if nargout>1
                    locations{end+1}={link.destId,1};
                    reqsys{end+1}=link.destDomain;
                end
            elseif nargout>1
                locations{match}=appendId(locations{match},link.destId);
            end
        end
    end
end

function ids=appendId(ids,id)
    match=strcmp(ids(:,1),id);
    if any(match)
        ids{match,2}=ids{match,2}+1;
    else
        ids(end+1,1:2)={id,1};
    end
end

