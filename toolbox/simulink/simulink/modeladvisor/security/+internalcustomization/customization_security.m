






function customization_security()
    cm=DAStudio.CustomizationManager;
    cm.addModelAdvisorCheckFcn(@registerSecurityModelAdvisorChecks);
    cm.addModelAdvisorTaskFcn(@registerSecurityModelAdvisorTasks);
end





function registerSecurityModelAdvisorChecks
    securityCheckCodeGenSettings();
    securityCheckBlockSupport();
end





function registerSecurityModelAdvisorTasks

    rec=ModelAdvisor.FactoryGroup('security');
    rec.DisplayName=DAStudio.message('ModelAdvisor:engine:SecurityGuidelinesTaskGroup');
    rec.Description=DAStudio.message('ModelAdvisor:engine:SecurityGuidelinesTaskGroup');

    rec.addCheck('mathworks.security.CodeGenSettings');
    rec.addCheck('mathworks.codegen.PCGSupport');
    rec.addCheck('mathworks.security.BlockSupport');
    rec.addCheck('mathworks.misra.AssignmentBlocks');
    rec.addCheck('mathworks.misra.SwitchDefault');
    rec.addCheck('mathworks.misra.CompliantCGIRConstructions');
    rec.addCheck('mathworks.misra.CompareFloatEquality');
    rec.addCheck('mathworks.misra.IntegerWordLengths');
    rec.addCheck('mathworks.sldv.deadlogic');
    rec.addCheck('mathworks.sldv.integeroverflow');
    rec.addCheck('mathworks.sldv.divbyzero');
    rec.addCheck('mathworks.sldv.arraybounds');
    rec.addCheck('mathworks.sldv.minmax');
    recHil=ModelAdvisor.Common.defineHISLTasks('security',false);
    rec.addFactoryGroup(recHil);


    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(recHil);
    mdladvRoot.publish(rec);

end

