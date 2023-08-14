function customizationAeroblks()






    cm=DAStudio.CustomizationManager;


    cm.addModelAdvisorCheckFcn(@internalcustomization.aeroblksDefineUpgradeChecks);


    cm.addModelAdvisorTaskAdvisorFcn(@internalcustomization.aeroblksDefineUpgradeTasks);

end

