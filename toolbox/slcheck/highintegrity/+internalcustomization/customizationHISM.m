function customizationHISM()

    cm=DAStudio.CustomizationManager;

    cm.addModelAdvisorCheckFcn(@defineHismModelAdvisorChecks);

    cm.addModelAdvisorTaskFcn(@defineHismModelAdvisorTasks);
end
