function result=isIPWorkflow(obj)







    result=strcmpi(obj.get('Workflow'),obj.IPWorkflowStr)||...
    obj.isDLWorkflow;
end
