function customizationUnitsModelAdvisor()




    cm=DAStudio.CustomizationManager;

    cm.addModelAdvisorCheckFcn(@defineModelAdvisorChecks);
    cm.addModelAdvisorTaskFcn(@defineModelAdvisorTasks);


end

