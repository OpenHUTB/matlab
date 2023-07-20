
function customizationModelChecker()

    cm=DAStudio.CustomizationManager;


    cm.addModelAdvisorCheckFcn(@hdlcoder.ModelChecker.registerCheck_ModelAdvisor);



    cm.addModelAdvisorTaskAdvisorFcn(@hdlcoder.ModelChecker.registerTaskAdvisor);


    cm.addModelAdvisorCheckFcn(@hdlcoder.ModelChecker.registerCheck_ModelChecker);
end
