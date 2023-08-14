function olderBroIds=dfs_older_bro(allObjH,allObjPidx,allLastSyncIds)





    olderBroIds=rmisync.dfs_propagate(allObjH,allObjPidx,allLastSyncIds,[],...
    @dfs_post_older_bro);
    if length(olderBroIds)<length(allObjH)
        olderBroIds(length(allObjH))=0;
    end
end

function[values,ind]=dfs_post_older_bro(~,childIdx,~,~,allLastSyncIds,~)
    values=[];
    ind=[];
    if isempty(childIdx)
        return;
    end

    childIdx(allLastSyncIds(childIdx)==0)=[];
    if isempty(childIdx)
        values=[];
    else
        values=[0;allLastSyncIds(childIdx(1:(end-1)))];
    end
    ind=childIdx;
end
