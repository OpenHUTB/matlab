function customizationModelAdvisorMain()




    cm=DAStudio.CustomizationManager;



    cm.addModelAdvisorCheckFcn(@defineModelAdvisorChecks);


    cm.addModelAdvisorTaskFcn(@defineModelAdvisorTasks);








    cm.addModelAdvisorTaskAdvisorFcn(@defineUpgradeAdvisorTasks);


end

