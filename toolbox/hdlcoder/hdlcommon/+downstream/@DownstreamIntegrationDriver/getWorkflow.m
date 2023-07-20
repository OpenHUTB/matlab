function hWorkflow=getWorkflow(obj,workflowID)





    cmpresult=strcmp(workflowID,obj.hToolDriver.WorkflowIDList);
    if any(cmpresult)
        hWorkflow=obj.hToolDriver.WorkflowList{cmpresult};
    else
        error(message('hdlcommon:workflow:InvalidWorkflowID',workflowID));
    end

end
