function result=isSDRWorkflow(obj)


    result=strcmpi(obj.get('Workflow'),obj.SDRWorkflowStr);
end
