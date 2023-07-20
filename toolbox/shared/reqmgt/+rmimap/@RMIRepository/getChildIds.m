function childIds=getChildIds(this,modelName,idPrefix)







    model=rmimap.RMIRepository.getRoot(this.graph,modelName);


    if isempty(model)
        if isempty(idPrefix)
            childIds={};
        else
            error(message('Slvnv:rmigraph:UnmatchedModelName',modelName));
        end
    else

        childIds=findChildIdsFor(model,idPrefix);
    end
end

function matchedIds=findChildIdsFor(model,idPrefix)




    matchedIds={};


    prefixLength=length(idPrefix);
    for i=1:model.nodes.size
        element=model.nodes.at(i);
        if prefixLength==0||strncmp(element.id,idPrefix,prefixLength)
            matchedIds{end+1}=element.id;%#ok<AGROW>
        end
    end


    if~isempty(matchedIds)&&prefixLength>0
        isExactMatch=strcmp(matchedIds,idPrefix);
        matchedIds=matchedIds(~isExactMatch);
    end
end


