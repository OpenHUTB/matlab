function customizationAUTOSARChecks()








    cm=DAStudio.CustomizationManager;

    cm.addModelAdvisorCheckFcn(@defineAUTOSARChecks);

    cm.addModelAdvisorTaskFcn(@defineAUTOSARTasks);
end
