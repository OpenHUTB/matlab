function dspMdlAdvisor()


    cm=DAStudio.CustomizationManager;


    cm.addModelAdvisorCheckFcn(@dspDefineUpgradeChecks);


    cm.addModelAdvisorTaskAdvisorFcn(@dspDefineUpgradeTasks);
end
