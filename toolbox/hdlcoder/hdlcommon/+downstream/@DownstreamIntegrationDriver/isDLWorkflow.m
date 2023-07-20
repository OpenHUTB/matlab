function result=isDLWorkflow(obj)


    result=strcmpi(obj.get('Workflow'),obj.DLWorkflowStr);
end
