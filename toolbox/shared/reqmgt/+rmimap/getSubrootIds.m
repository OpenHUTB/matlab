function subroots=getSubrootIds(modelName,filters)
    subrootIds=rmimap.RMIRepository.getInstance.getSubrootIds(modelName);

    if isempty(subrootIds)
        subroots={};
        return;
    else
        subroots=strcat(modelName,subrootIds);

        if~isempty(filters)&&filters.enabled
            skipIdx=false(size(subroots));
            for i=1:length(skipIdx)
                if~rmimap.RMIRepository.getInstance.rootHasMatchingLinks(subroots{i},filters)
                    skipIdx(i)=false;
                end
            end
            if any(skipIdx)
                subroots(skipIdx)=[];
            end
        end
    end
end


