function result=isDynamicWorkflow(obj)



    workflow=obj.get('Workflow');
    hWorkflowList=hdlworkflow.getWorkflowList;
    result=hWorkflowList.isInWorkflowList(workflow);

end