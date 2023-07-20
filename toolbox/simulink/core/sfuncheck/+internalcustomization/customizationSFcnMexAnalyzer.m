function customizationSFcnMexAnalyzer()




    cm=DAStudio.CustomizationManager;


    cm.addModelAdvisorCheckFcn(@defineSFcnUpgradeChecks);
    cm.addModelAdvisorTaskAdvisorFcn(@defineSFcnUpgradeTasks);

end
