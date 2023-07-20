function customizationSb2Sl()






    cm=DAStudio.CustomizationManager;


    cm.addModelAdvisorCheckFcn(@sb2slDefineUpgradeChecks);


    cm.addModelAdvisorTaskAdvisorFcn(@sb2slDefineUpgradeTasks);
end

