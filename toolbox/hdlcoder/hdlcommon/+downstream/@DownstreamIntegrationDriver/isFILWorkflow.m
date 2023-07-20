function result=isFILWorkflow(obj)


    result=strcmpi(obj.get('Workflow'),obj.FILWorkflowStr);
end
