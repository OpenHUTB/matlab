function registerModelAdvisorCallbacks()
    cm=DAStudio.CustomizationManager;

    cm.addModelAdvisorCheckFcn(@defineModelAdvisorCallbacks);


    cm.addModelAdvisorTaskFcn(@defineDataStoreTasks);


    cm.addModelAdvisorTaskFcn(@defineFileIntegrityTask);



    cm.addModelAdvisorCheckFcn(@defineUpgradeModelHistoryPropertyChecks);
    cm.addModelAdvisorTaskAdvisorFcn(@defineUpgradeModelHistoryPropertyTasks);



    cm.addModelAdvisorCheckFcn(@defineVirtualBusUsageUpgradeChecks);
    cm.addModelAdvisorTaskAdvisorFcn(@defineVirtualBusUsageUpgradeTasks);



    cm.addModelAdvisorCheckFcn(@defineConstRootOutportWithInterfaceUpgradeChecks);
    cm.addModelAdvisorTaskAdvisorFcn(@defineConstRootOutportWithInterfaceUpgradeTasks);



    cm.addModelAdvisorCheckFcn(@defineMaskTabNamesUpgradeCheck);
    cm.addModelAdvisorTaskAdvisorFcn(@defineMaskTabNamesUpgradeTask);


    cm.addModelAdvisorCheckFcn(@defineModelRefAdvisorChecks);
    cm.addModelAdvisorTaskAdvisorFcn(@defineModelRefTaskAdvisor);


    cm.addModelAdvisorCheckFcn(@Simulink.variant.upgradeAdvisor.defineEmptyVariantObjectUsageCheck);
    cm.addModelAdvisorTaskAdvisorFcn(@Simulink.variant.upgradeAdvisor.defineEmptyVariantObjectUsageTasks);


    cm.addModelAdvisorCheckFcn(@defineModelInfoKeywordSubstitutionChecks);
    cm.addModelAdvisorTaskAdvisorFcn(@defineModelInfoKeywordSubstitutionTasks);
end

