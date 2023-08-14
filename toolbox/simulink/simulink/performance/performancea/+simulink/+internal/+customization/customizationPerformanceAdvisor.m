function customizationPerformanceAdvisor()



    cm=DAStudio.CustomizationManager;


    cm.addModelAdvisorCheckFcn(@definePerformanceAdvisorChecks);


    cm.addModelAdvisorTaskAdvisorFcn(@definePerformanceAdvisorTask);

end

