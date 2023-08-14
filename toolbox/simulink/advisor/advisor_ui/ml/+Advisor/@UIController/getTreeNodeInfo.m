function result=getTreeNodeInfo(this,taskObj)

    result=repmat(struct('id','','state','','iconUri','','parent',''),0);

    result(end+1)=struct('id',taskObj.ID,'state',ModelAdvisor.CheckStatusUtil.getText(taskObj.State),'iconUri',['/',taskObj.getDisplayIcon],'parent',taskObj.getParent.ID);


    parentNode=taskObj.getParent;
    while~isempty(parentNode)&&~any(strcmp(parentNode.ID,{'_SYSTEM','SysRoot'}))
        result(end+1)=struct('id',parentNode.ID,'state',ModelAdvisor.CheckStatusUtil.getText(parentNode.State),'iconUri',['/',parentNode.getDisplayIcon],'parent',parentNode.getParent.ID);%#ok<AGROW>
        parentNode=parentNode.getParent;
    end
end