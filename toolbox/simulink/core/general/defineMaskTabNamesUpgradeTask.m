function defineMaskTabNamesUpgradeTask





    task=ModelAdvisor.Task('mathworks.design.CheckAndUpdateOldMaskTabnames.task');
    task.DisplayName=DAStudio.message('Simulink:tools:MATitleOldMaskTabnamesConversion');
    task.Description=DAStudio.message('Simulink:tools:MATitletipOldMaskTabnamesConversion');
    task.setCheck('mathworks.design.CheckAndUpdateOldMaskTabnames');


    mdlAdvisor=ModelAdvisor.Root;
    mdlAdvisor.register(task);


    upgradeAdvisor=UpgradeAdvisor;
    upgradeAdvisor.addTask(task);

end




