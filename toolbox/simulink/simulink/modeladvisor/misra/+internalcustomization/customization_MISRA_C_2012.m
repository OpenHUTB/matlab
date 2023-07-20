function customization_MISRA_C_2012()




    cm=DAStudio.CustomizationManager;

    cm.addModelAdvisorCheckFcn(@define_MISRA_C_2012_ModelAdvisorChecks);
    cm.addModelAdvisorTaskFcn(@define_MISRA_C_2012_ModelAdvisorTasks);

end

function define_MISRA_C_2012_ModelAdvisorChecks
    misraCodeGenSettings();
    misraCheckBlockSupport();
    misraCheckBlockNames();
    misraCheckAssignmentBlocks();
    misraCheckModelFunctionInterface();
    misraCheckSignedBitwiseOperators();
    misraCheckFunctionRecursion();
    misraCheckSwitchDefault();
    misraCheckCompareFloatEquality();
    misraCheckIntegerWordLengths();
    misraCheckAutosarReceiverInterface();
    misraCheckBusElementNames();
end

function define_MISRA_C_2012_ModelAdvisorTasks
    mdladvRoot=ModelAdvisor.Root;
    rec=ModelAdvisor.FactoryGroup('misra_c');
    rec.DisplayName=DAStudio.message('ModelAdvisor:engine:MisraGuidelinesTaskGroup');
    rec.Description=DAStudio.message('ModelAdvisor:engine:MisraGuidelinesTaskGroup');

    rec.addCheck('mathworks.misra.CodeGenSettings');
    rec.addCheck('mathworks.codegen.PCGSupport');
    rec.addCheck('mathworks.misra.BlkSupport');
    rec.addCheck('mathworks.misra.BlockNames');
    rec.addCheck('mathworks.misra.AssignmentBlocks');
    rec.addCheck('mathworks.misra.SwitchDefault');
    rec.addCheck('mathworks.misra.AutosarReceiverInterface');
    rec.addCheck('mathworks.misra.CompliantCGIRConstructions');
    rec.addCheck('mathworks.misra.RecursionCompliance');
    rec.addCheck('mathworks.misra.CompareFloatEquality');
    rec.addCheck('mathworks.misra.ModelFunctionInterface');
    rec.addCheck('mathworks.misra.IntegerWordLengths');
    rec.addCheck('mathworks.misra.BusElementNames');

    mdladvRoot.publish(rec);
end

