function customizationHDLSSCAdvisor()





    cm=DAStudio.CustomizationManager;


    cm.addModelAdvisorCheckFcn(@ssccodegenadvisor.defineSSCCodeGenAdvisorChecks);

    cm.addModelAdvisorTaskAdvisorFcn(@ssccodegenadvisor.defineSSCCodeGenAdvisorTasks);

end

