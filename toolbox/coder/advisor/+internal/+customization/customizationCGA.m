function customizationCGA()



    if~license('test','Real-Time_Workshop')
        return
    end

    cm=DAStudio.CustomizationManager;


    cm.addModelAdvisorCheckFcn(@defineCGOCheck);


    cm.addModelAdvisorTaskAdvisorFcn(@defineCodeGenGroup);
