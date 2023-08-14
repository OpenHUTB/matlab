function customizationSimscapeFluidsPerformanceAdvisor()





    cm=DAStudio.CustomizationManager;


    [checkFcn,taskFcn]=sh.performanceadvisor.internal.define_checks();
    cm.addModelAdvisorCheckFcn(checkFcn);
    cm.addModelAdvisorTaskAdvisorFcn(taskFcn);

end
