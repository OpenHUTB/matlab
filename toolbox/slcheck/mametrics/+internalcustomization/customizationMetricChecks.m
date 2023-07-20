function customizationMetricChecks()









    cm=DAStudio.CustomizationManager;

    cm.addModelAdvisorCheckFcn(@defineMetricChecks);


    cm.addModelAdvisorTaskFcn(@defineMetricByTaskGroup);

end
