function result=isTurnkeyWorkflow(obj)


    result=strcmpi(obj.get('Workflow'),obj.TurnkeyWorkflowStr);
end
