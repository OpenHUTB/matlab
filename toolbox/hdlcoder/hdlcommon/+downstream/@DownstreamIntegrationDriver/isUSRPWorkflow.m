function result=isUSRPWorkflow(obj)


    result=strcmpi(obj.get('Workflow'),obj.USRPWorkflowStr);
end
