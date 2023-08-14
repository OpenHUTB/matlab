function customizationStyleGuide()










    cm=DAStudio.CustomizationManager;

    cm.addModelAdvisorCheckFcn(@defineStyleGuideModelAdvisorChecks);

    cm.addModelAdvisorCheckFcn(@defineJMAABModelAdvisorChecks);


    cm.addModelAdvisorTaskFcn(@defineStyleGuideModelAdvisorTasks);

    cm.addModelAdvisorTaskFcn(@defineJMAABModelAdvisorTasks);

end
