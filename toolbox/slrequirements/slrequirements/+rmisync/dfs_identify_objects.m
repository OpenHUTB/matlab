function updateSyncIds=dfs_identify_objects(allObjH,allObjPidx,allSyncIds)





    updateSyncIds=rmisync.dfs_propagate(allObjH,allObjPidx,allSyncIds,[],...
    @dfs_post_identify_object,allSyncIds);
end

function[values,ind]=dfs_post_identify_object(itemIdx,childIdx,~,~,startvalue,propValue)
    startSyncId=startvalue(itemIdx);

    thisId=0;
    if startSyncId~=0
        thisId=startSyncId;
    else
        if~isempty(childIdx)
            childIds=propValue(childIdx);
            if(any(childIds~=0))
                thisId=-1;
            end
        end
    end
    values=thisId;
    ind=itemIdx;
end
