function result=fixChecks(this,instanceId)
    taskObj=this.maObj.getTaskObj(instanceId);
    taskObj.runAction();
    result=struct('actionReport',taskObj.check.Action.ResultInHTML,'nodeInfo',this.getTreeNodeInfo(taskObj));
    taskObj.check.ResultInHTML='';
end