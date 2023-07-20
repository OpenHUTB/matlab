function customizationSimscapeDrivelinePerformanceAdvisor()





    cm=DAStudio.CustomizationManager;


    [checkFcn,taskFcn]=sdl.performanceadvisor.internal.define_checks();
    cm.addModelAdvisorCheckFcn(checkFcn);
    cm.addModelAdvisorTaskAdvisorFcn(taskFcn);

end
