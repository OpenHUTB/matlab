function defineEmptyVariantObjectUsageTasks()




    task=ModelAdvisor.Task('mathworks.design.emptyVariantObject.task');
    task.DisplayName=DAStudio.message('Simulink:Variants:UAEmptyVarObjCheckName');
    task.Description=DAStudio.message('Simulink:Variants:UAEmptyVarObjCheckDescription');
    task.setCheck('mathworks.design.emptyVariantObject');


    mdlAdvisor=ModelAdvisor.Root;
    mdlAdvisor.register(task);


    upgAdvisor=UpgradeAdvisor;
    upgAdvisor.addTask(task);
end
