function customizationSystemObjectTask()




    cm=DAStudio.CustomizationManager;

    cm.addModelAdvisorCheckFcn(@systemblock.defineCheckSystemObjectUpdate);
    cm.addModelAdvisorTaskAdvisorFcn(@systemblock.defineSystemObjectUpdateTask);

end