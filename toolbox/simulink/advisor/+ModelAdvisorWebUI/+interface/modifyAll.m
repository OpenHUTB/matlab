function[result,FolderIds,FolderStats]=modifyAll(modelId,fullID,parentIds)


    appObj=Advisor.Manager.getApplication('id',modelId);
    targetObj=appObj.getMAObjs{1,1};
    selectedNode=targetObj.getTaskObj(fullID);
    selectedNode.runAction;
    result=selectedNode.check.Action.ResultInHTML;


    FolderIds={};
    FolderStats={};
    for s=1:size(parentIds,1)
        temp=targetObj.getTaskObj(parentIds{s,1});
        FolderIds=[FolderIds,temp.ID];
        FolderStats=[FolderStats,modeladvisorprivate('modeladvisorutil2','getNodeSummaryInfo',temp)];
    end

end