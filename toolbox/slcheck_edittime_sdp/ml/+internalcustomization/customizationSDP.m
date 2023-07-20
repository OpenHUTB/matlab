function customizationSDP()









    cm=DAStudio.CustomizationManager;

    cm.addModelAdvisorCheckFcn(@defineSDPModelAdvisorChecks);


    cm.addModelAdvisorTaskFcn(@defineSDPModelAdvisorTasks);


end
