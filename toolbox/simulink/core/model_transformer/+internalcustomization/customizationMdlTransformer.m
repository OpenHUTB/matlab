function customizationMdlTransformer()



    cm=DAStudio.CustomizationManager;



    cm.addModelAdvisorCheckFcn(@defineMdlTransformerChecks);



    cm.addModelAdvisorTaskAdvisorFcn(@defineMdlTransformerTask);
end

