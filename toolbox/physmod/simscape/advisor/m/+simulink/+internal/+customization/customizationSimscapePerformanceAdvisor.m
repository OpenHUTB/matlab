function customizationSimscapePerformanceAdvisor()





    cm=DAStudio.CustomizationManager;


    [checkFcn,taskFcn]=simscape.performanceadvisor.internal.define_checks();
    cm.addModelAdvisorCheckFcn(checkFcn);
    cm.addModelAdvisorTaskAdvisorFcn(taskFcn);





    [checkFcn,taskFcn]=simscape.modeladvisor.internal.define_checks();
    cm.addModelAdvisorCheckFcn(checkFcn);
    cm.addModelAdvisorTaskAdvisorFcn(taskFcn);

end
