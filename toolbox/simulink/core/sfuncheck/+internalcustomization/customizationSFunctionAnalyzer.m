function customizationSFunctionAnalyzer()




    cm=DAStudio.CustomizationManager;

    cm.addModelAdvisorCheckFcn(@defineSfunModelAdvisorChecks);
    cm.addModelAdvisorTaskFcn(@defineSfunModelAdvisorTasks);
end

