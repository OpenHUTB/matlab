function internalCustomizationSLCI()

    cm=DAStudio.CustomizationManager;
    cm.addModelAdvisorCheckFcn(@defineSLCIModelAdvisorChecks);
    cm.addModelAdvisorTaskFcn(@defineSLCIModelAdvisorTasks);
end
