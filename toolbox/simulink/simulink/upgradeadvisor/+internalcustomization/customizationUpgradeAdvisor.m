function customizationUpgradeAdvisor()




    cm=DAStudio.CustomizationManager;


    cm.addModelAdvisorCheckFcn(@defineUpgradeAdvisorCheck);
    cm.addModelAdvisorTaskFcn(@defineUpgradeAdvisorTask);



    cm.addModelAdvisorCheckFcn(@defineMultiModelUpgradeCheck);
    cm.addModelAdvisorTaskAdvisorFcn(@defineMultiModelUpgradeTask);


    cm.addModelAdvisorCheckFcn(@defineBlockUpgradeCheck);
    cm.addModelAdvisorCheckFcn(@defineBlockUpgradeCompileCheck);
    cm.addModelAdvisorCheckFcn(@defineCaseSensitiveBlockDiagramsCheck);
    cm.addModelAdvisorTaskAdvisorFcn(@defineBlockUpgradeAdvisorTasks);



    cm.addModelAdvisorCheckFcn(@defineResaveInCurrentVersionCheck);
    cm.addModelAdvisorTaskAdvisorFcn(@defineResaveInCurrentVersionTask);



    cm.addModelAdvisorCheckFcn(@defineSLXFileCompressionCheck);
    cm.addModelAdvisorTaskAdvisorFcn(@defineSLXFileCompressionTask);


    cm.addModelAdvisorCheckFcn(@defineSingleSimulationOutputCheck);
    cm.addModelAdvisorTaskAdvisorFcn(@defineSingleSimulationOutputTask);

end

