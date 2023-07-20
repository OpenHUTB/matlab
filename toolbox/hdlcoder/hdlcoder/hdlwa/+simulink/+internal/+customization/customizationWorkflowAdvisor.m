function customizationWorkflowAdvisor()

    cm=DAStudio.CustomizationManager;


    cm.addModelAdvisorCheckFcn(@defineHDLWorkflowAdvisorChecks);


    cm.addModelAdvisorTaskAdvisorFcn(@defineHDLWorkflowAdvisorTask);

end

