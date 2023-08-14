function customizationVariants()



    cm=DAStudio.CustomizationManager;


    cm.addModelAdvisorCheckFcn(@defineVariantsModelAdvisorChecks);
    cm.addModelAdvisorTaskFcn(@defineVariantsModelAdvisorTasks);
    cm.addModelAdvisorTaskAdvisorFcn(@defineVariantsModelAdvisorTaskAdvisor);
end




function defineVariantsModelAdvisorChecks()
    defineReplaceECBByVariantSourceCheck();
    if slfeature('InheritVAT')>0
        inheritVATMdlAdvisorCheck();
    end
end




function defineVariantsModelAdvisorTasks()
    mdladvRoot=ModelAdvisor.Root;


    rec=ModelAdvisor.FactoryGroup('mathworks.task.ObsoleteBlocksChecks');
    rec.DisplayName=DAStudio.message('Simulink:VariantAdvisorChecks:MAObsoleteBlksTaskTitle');
    rec.Description=DAStudio.message('Simulink:VariantAdvisorChecks:MAObsoleteBlksTaskTitleTips');
    rec.addCheck('mathworks.design.ReplaceEnvironmentControllerBlk');
    rec.CSHParameters.MapKey='ma.simulink';
    rec.CSHParameters.TopicID='obsoleteblockschecks_overview';
    rec.Value=true;
    mdladvRoot.publish(rec);




    rec1=ModelAdvisor.FactoryGroup('mathworks.task.InheritVATCheck');
    rec1.DisplayName=DAStudio.message('Simulink:VariantAdvisorChecks:MAInheritVATByTaskDisplay');
    rec1.Description=DAStudio.message('Simulink:VariantAdvisorChecks:MATitletipIdentifyNonSVCBlksWithInherit');
    rec1.addCheck('mathworks.simulink.InheritVATFromSlVarCtrlCheck');
    rec1.CSHParameters.MapKey='ma.simulink';
    rec1.CSHParameters.TopicID='MATitleIdentifyNonSVCBlksWithInherit';
    rec1.Value=true;
    mdladvRoot.publish(rec1);
end




function defineVariantsModelAdvisorTaskAdvisor()
    mdladvRoot=ModelAdvisor.Root;

    rec=ModelAdvisor.Task('mathworks.design.ReplaceEnvironmentControllerBlk.Task');
    rec.DisplayName=DAStudio.message('Simulink:VariantAdvisorChecks:MATitleReplaceECBByVariantSource');
    rec.Description=DAStudio.message('Simulink:VariantAdvisorChecks:MATitletipReplaceECBByVariantSource');
    rec.setCheck('mathworks.design.ReplaceEnvironmentControllerBlk');
    rec.Value=true;
    mdladvRoot.register(rec);

    upgradeAdvisor=UpgradeAdvisor;
    upgradeAdvisor.addTask(rec);
end
