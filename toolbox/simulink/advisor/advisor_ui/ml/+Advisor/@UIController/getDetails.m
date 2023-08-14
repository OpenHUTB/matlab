function result=getDetails(this,taskId,RDObjId)
    result=[];
    hasCheckJustification=false;
    taskObj=this.maObj.getTaskObj(taskId);
    RDs=taskObj.Check.ResultDetails;
    RDObj=RDs(arrayfun(@(x)isequal(x.ID,RDObjId),RDs));
    if isempty(RDObj)
        return;
    end
    style=ModelAdvisor.Report.SmartStyle();
    fts=style.generateReport(struct('ResultDetails',RDObj));

    result.taskID=taskId;
    result.RDObjID=RDObjId;
    if ischar(fts{1})
        result.html=fts{1};
    else
        result.html=fts{1}.emitContent.emitHTML();
    end
    result.justification=struct('message','','user','','timestamp','');
    manager=slcheck.getAdvisorJustificationManager(this.rootmodel);
    filter=manager.getAdvisorFilterSpecification(advisor.filter.FilterType.Block,RDObj.getHash(),taskObj.Check.ID);
    if~isempty(filter)
        result.justification=struct('message',filter.metadata.summary,'user',...
        filter.metadata.user,'timestamp',char(filter.metadata.timeStamp));
    else
        if(taskObj.Check.status==ModelAdvisor.CheckStatus.Justified)
            filter=manager.getAdvisorFilterSpecification(advisor.filter.FilterType.Block,taskObj.Check.ID,taskObj.Check.ID);
            if~isempty(filter)&&RDObj.getViolationStatus~=ModelAdvisor.CheckStatus.Passed
                result.justification=struct('message',filter.metadata.summary,'user',...
                filter.metadata.user,'timestamp',char(filter.metadata.timeStamp));

                hasCheckJustification=true;
            end
        end
    end
    result.disableJustification=RDObj.getViolationStatus==ModelAdvisor.CheckStatus.Passed||hasCheckJustification;
    result.disableEditJustification=hasCheckJustification;
    result.disableDeleteJustification=hasCheckJustification;
end
