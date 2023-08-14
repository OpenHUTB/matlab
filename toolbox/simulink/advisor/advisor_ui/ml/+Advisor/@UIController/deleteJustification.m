function result=deleteJustification(this,taskId,RDId)




    taskObj=this.maObj.getTaskObj(taskId);
    RDs=taskObj.Check.ResultDetails;
    RDObj=RDs(arrayfun(@(x)strcmp(x.ID,RDId),RDs));
    manager=slcheck.getAdvisorJustificationManager(this.rootmodel);

    if isempty(RDObj)
        manager.removeAnnotation(taskObj.check.ID);
        taskObj.Check.justify(false);
        taskObj.updateStates(ModelAdvisor.CheckStatus.Warning);
        updateUnderlyingRDs(taskObj);
    else
        Advisor.Utils.Justification.unjustifyViolation(this.rootmodel,RDObj);
        Advisor.Utils.Justification.serialize(this.rootmodel);
        taskObj.updateStates(taskObj.Check.calculateCheckStatus);
    end

    taskObj.Check.ResultInHTML=this.updateReportForTask(taskId);
    filePath=manager.fileName;
    result=struct('message','',...
    'user','','timestamp','',...
    'saveLocation',struct('inModel',isempty(filePath),'FileName',filePath),...
    'nodeInfo',[struct('id',taskObj.ID,'state',ModelAdvisor.CheckStatusUtil.getText(taskObj.State),'iconUri',['/',taskObj.getDisplayIcon],'parent',taskObj.getParent.ID)]);
end

function updateUnderlyingRDs(taskObj)


    RDs=taskObj.Check.ResultDetails;
    for i=1:numel(RDs)
        if RDs(i).getViolationStatus==ModelAdvisor.CheckStatus.Justified
            RDs(i).resetViolationStatus;
        end
    end
end
