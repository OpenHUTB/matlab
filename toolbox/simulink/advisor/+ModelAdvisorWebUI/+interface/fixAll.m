function resultJSON=fixAll(applicationID,nodeID)
    am=Advisor.Manager.getInstance;
    appObj=am.getApplication('ID',applicationID);
    if isa(appObj,'Advisor.Application')
        maObj=appObj.getRootMAObj;
    else
        return
    end

    nodeObj=maObj.getTaskObj(nodeID);
    if isa(nodeObj,'ModelAdvisor.Task')
        allchildren={nodeObj};
    else
        allchildren=nodeObj.getAllChildren;
    end

    for i=1:numel(allchildren)
        if isa(allchildren{i},'ModelAdvisor.Task')&&isa(allchildren{i}.Check,'ModelAdvisor.Check')...
            &&isa(allchildren{i}.Check.Action,'ModelAdvisor.Action')&&allchildren{i}.Check.Action.Enable
            allchildren{i}.runAction;
        end
    end
    result=struct('success',true,'message',jsonencode(struct('title','','content','')),'warning',false,'filepath','','value',jsonencode("a"));
    resultJSON=jsonencode(result);
end