function result=justify(this,instanceId,RDId,message)




    persistent value;
    if(isempty(value))
        value=true;
        Simulink.DDUX.logData('JUSTIFICATION','majustificationui',value);
    end



    taskObj=this.maObj.getTaskObj(instanceId);
    RDs=taskObj.Check.ResultDetails;
    checkId=taskObj.Check.ID;
    RDObj=RDs(arrayfun(@(x)strcmp(x.ID,RDId),RDs));
    manager=slcheck.getAdvisorJustificationManager(this.rootmodel);

    if isempty(RDObj)
        manager.justifyCheck(checkId,message);

        taskObj.Check.justify(true);
        taskObj.updateStates(ModelAdvisor.CheckStatus.Justified);
        updateUnderlyingRDs(taskObj);
    else
        Advisor.Utils.Justification.justifyViolation(this.rootmodel,RDObj,message,checkId);
        taskObj.updateStates(taskObj.Check.calculateCheckStatus);
    end

    taskObj.Check.ResultInHTML=this.updateReportForTask(instanceId);

    Advisor.Utils.Justification.serialize(this.rootmodel);

    filePath=manager.fileName;
    allJust=manager.filters.toArray();
    ts=char(allJust(end).metadata.timeStamp);
    user=allJust(end).metadata.user;

    updatedNodeInfo=repmat(struct('id','','state','','iconUri','','parent',''),0);
    updatedNodeInfo(end+1)=struct('id',taskObj.ID,'state',ModelAdvisor.CheckStatusUtil.getText(taskObj.State),'iconUri',['/',taskObj.getDisplayIcon],'parent',taskObj.getParent.ID)
    parentNode=taskObj.getParent;


    while~isempty(parentNode)&&~any(strcmp(parentNode.ID,{'_SYSTEM','SysRoot'}))
        updatedNodeInfo(end+1)=struct('id',parentNode.ID,'state',ModelAdvisor.CheckStatusUtil.getText(parentNode.State),'iconUri',['/',parentNode.getDisplayIcon],'parent',parentNode.getParent.ID);%#ok<AGROW>
        parentNode=parentNode.getParent;
    end

    result=struct('message',message,...
    'user',user,...
    'timestamp',ts,...
    'saveLocation',struct('inModel',isempty(filePath),'FileName',filePath),...
    'nodeInfo',updatedNodeInfo);


end

function updateUnderlyingRDs(taskObj)


    RDs=taskObj.Check.ResultDetails;
    for i=1:numel(RDs)
        if RDs(i).getViolationStatus==ModelAdvisor.CheckStatus.Warning||...
            RDs(i).getViolationStatus==ModelAdvisor.CheckStatus.Failed
            RDs(i).setViolationStatus(ModelAdvisor.CheckStatus.Justified);
        end
    end
end


