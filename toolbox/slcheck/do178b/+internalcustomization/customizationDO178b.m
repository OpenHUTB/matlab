function customizationDO178b()

    cm=DAStudio.CustomizationManager;

    cm.addModelAdvisorCheckFcn(@defineDO178bModelAdvisorChecks);

    cm.addModelAdvisorTaskFcn(@defineDO178ModelAdvisorTasks);

    cm.addModelAdvisorTaskFcn(@defineDO254ModelAdvisorTasks);

end
