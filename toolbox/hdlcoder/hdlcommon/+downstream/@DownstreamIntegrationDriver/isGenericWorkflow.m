function result=isGenericWorkflow(obj)


    result=strcmpi(obj.get('Workflow'),obj.GenericWorkflowStr);
end
