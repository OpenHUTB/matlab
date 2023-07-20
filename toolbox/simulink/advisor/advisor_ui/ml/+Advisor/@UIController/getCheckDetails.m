function result=getCheckDetails(this,taskId)
    result=struct();
    taskObj=this.maObj.getTaskObj(taskId);
    if isa(taskObj,'ModelAdvisor.Task')
        result.hasJustify=taskObj.state~=ModelAdvisor.CheckStatus.NotRun&&taskObj.state~=ModelAdvisor.CheckStatus.Passed;
        manager=slcheck.getAdvisorJustificationManager(this.rootmodel);
        checkJustifications=manager.getAdvisorFilterSpecification(advisor.filter.FilterType.Block,...
        taskObj.Check.ID,taskObj.Check.ID);

        if~isempty(checkJustifications)
            result.justification=struct('message',checkJustifications(1).metadata.summary,'user',checkJustifications(1).metadata.user,'timestamp',char(checkJustifications(1).metadata.timeStamp));
        else
            result.justification=struct('message','','user','','timestamp','');
        end
    else
        result.hasJustify=false;
        result.justification=struct('message','','user','','timestamp','');
    end
end
