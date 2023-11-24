function customizationIEC61508()

    cm=DAStudio.CustomizationManager;

    cm.addModelAdvisorCheckFcn(@defineIEC61508ModelAdvisorChecks);
    cm.addModelAdvisorTaskFcn(@defineIECTasks);

end
