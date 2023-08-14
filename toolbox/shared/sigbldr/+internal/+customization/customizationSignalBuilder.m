function customizationSignalBuilder()


    cm=DAStudio.CustomizationManager;


    cm.addModelAdvisorCheckFcn(@internal.customization.defineSignalBuilderUpgradeChecks);


    cm.addModelAdvisorTaskAdvisorFcn(@internal.customization.defineSignalBuilderUpgradeTasks);
end