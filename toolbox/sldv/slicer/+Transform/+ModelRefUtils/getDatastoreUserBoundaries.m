function boundaryIds=getDatastoreUserBoundaries(ir,treeDescendantsIdinSS,RW)








    assert(islogical(RW));
    boundaryIds=[];
    globalDsmIds=ir.dfgIdxToGlobalDsmName.keys;

    if isempty(globalDsmIds)
        return;
    end

    treeDescendantsIdinSS=int32(arrayfun(@(t)t.Id,treeDescendantsIdinSS));
    userIds=[];
    for i=1:length(globalDsmIds)
        dsmId=globalDsmIds{i};
        if RW

            nodeV=ir.dfg.succ(MSUtils.graphVertices(dsmId));
        else

            nodeV=ir.dfg.pre(MSUtils.graphVertices(dsmId));
        end

        tIds=arrayfun(@(v)ir.handleToTreeIdx(ir.dfgIdxToHandle(v.vId)),nodeV);
        userIds=[userIds,tIds];
    end

    boundaryTreeIds=setdiff(userIds,treeDescendantsIdinSS);

    boundaryIds=arrayfun(@(id)ir.handleToDfgIdx(ir.treeIdxToHandle(id)),boundaryTreeIds);
end