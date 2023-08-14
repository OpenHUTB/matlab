function result=highliteSID(this,taskId,RDId)
    result=[];
    taskObj=this.maObj.getTaskObj(taskId);
    RDs=taskObj.Check.ResultDetails;
    RDObj=RDs(arrayfun(@(x)strcmp(x.ID,RDId),RDs));
    if isempty(RDObj)
        return;
    end

    sid=ModelAdvisor.ResultDetail.getData(RDObj);
    if~isempty(sid)&&Simulink.ID.isValid(sid)
        Simulink.ID.hilite(sid);
    end
end