function result=runChecks(this,instanceId)

    rootID=this.maObj.TaskAdvisorRoot.ID;
    if strcmp(rootID,'SysRoot')
        rootID='_SYSTEM';
    end
    if isempty(instanceId)
        instanceId=rootID;
    end

    if strcmp(instanceId,rootID)
        taskObj=this.maObj.TaskAdvisorRoot;
    else
        taskObj=this.maObj.getTaskObj(instanceId);
    end

    taskObj.runTaskAdvisor();

    updatedNodeInfo=repmat(struct('id','','state','','iconUri','','parent',''),0);

    if strcmp(instanceId,rootID)
        updatedNodeInfo(end+1)=struct('id',rootID,'state',ModelAdvisor.CheckStatusUtil.getText(taskObj.State),'iconUri','/toolbox/simulink/simulink/modeladvisor/resources/ma.png','parent',NaN);
    else
        updatedNodeInfo(end+1)=struct('id',taskObj.ID,'state',ModelAdvisor.CheckStatusUtil.getText(taskObj.State),'iconUri',['/',taskObj.getDisplayIcon],'parent',taskObj.getParent.ID);
    end


    parentNode=taskObj.getParent;
    while~isempty(parentNode)&&~any(strcmp(parentNode.ID,{'_SYSTEM','SysRoot',rootID}))
        updatedNodeInfo(end+1)=struct('id',parentNode.ID,'state',ModelAdvisor.CheckStatusUtil.getText(parentNode.State),'iconUri',['/',parentNode.getDisplayIcon],'parent',parentNode.getParent.ID);%#ok<AGROW>
        parentNode=parentNode.getParent;
    end


    result=gatherNodeInfo(taskObj,updatedNodeInfo);

end

function nodeInfo=gatherNodeInfo(startNode,nodeInfo)
    children=startNode.getChildren();
    for i=1:numel(children)
        if children(i).Selected
            nodeInfo(end+1)=struct('id',children(i).ID,...
            'state',char(children(i).State),...
            'iconUri',['/',children(i).getDisplayIcon],...
            'parent',children(i).getParent.ID);%#ok<AGROW>
        end
        if~isempty(children(i).getChildren())
            nodeInfo=gatherNodeInfo(children(i),nodeInfo);
        end
    end
end