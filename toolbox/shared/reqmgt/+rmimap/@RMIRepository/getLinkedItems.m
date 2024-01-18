function[docs,items,reqsys]=getLinkedItems(linkSource)
    graph=rmimap.RMIRepository.getInstance.graph;
    docs={};
    if nargout>1
        items={};
        reqsys={};
    end

    myRoot=[];
    for i=1:graph.roots.size
        if strcmp(graph.roots.at(i).url,linkSource)
            myRoot=graph.roots.at(i);
            break;
        end
    end

    if~isempty(myRoot)&&myRoot.links.size>0
        filters=rmi.settings_mgr('get','filterSettings');
        if filters.enabled
            dummyReq=rmi.createEmptyReqs(1);
        end

        links=myRoot.links;
        for j=1:links.size
            link=links.at(j);
            if filters.enabled
                dummyReq.keywords=link.getProperty('keywords');
                filtered=rmi.filterTags(dummyReq,filters.tagsRequire,filters.tagsExclude);
                if isempty(filtered)
                    continue;
                end
            end
            url=link.getProperty('dependeeUrl');
            match=strcmp(docs,url);
            if~any(match)
                docs{end+1}=url;%#ok<*AGROW>
                if nargout>1
                    items{end+1}={link.getProperty('dependeeId'),1};
                    reqsys{end+1}=link.getProperty('source');
                end
            elseif nargout>1
                items{match}=appendId(items{match},link.getProperty('dependeeId'));
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

