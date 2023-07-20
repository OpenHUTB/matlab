function hasLinks=rootHasMatchingLinks(this,srcName,filters)




    hasLinks=false;
    srcRoot=rmimap.RMIRepository.getRoot(this.graph,srcName);
    if~isempty(srcRoot)

        myLinks=srcRoot.links;
        if~isempty(filters)&&filters.enabled
            dummyReq=rmi.createEmptyReqs(1);
        end
        for i=1:myLinks.size
            link=myLinks.at(i);
            if~strcmp(link.getProperty('linked'),'0')
                if isempty(filters)||~filters.enabled
                    hasLinks=true;
                    return;
                else
                    dummyReq.keywords=link.getProperty('keywords');
                    filtered=rmi.filterTags(dummyReq,filters.tagsRequire,filters.tagsExclude);
                    if~isempty(filtered)
                        hasLinks=true;
                        return;
                    end
                end
            end
        end
    end
end


