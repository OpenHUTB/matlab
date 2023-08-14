function defineMultiModelUpgradeTask()





    task=ModelAdvisor.Task('com.mathworks.Simulink.UpgradeAdvisor.UpgradeModelHierarchy.task');
    task.DisplayName=DAStudio.message('SimulinkUpgradeAdvisor:tasks:LooperTaskDisplayName');
    task.Description=DAStudio.message('SimulinkUpgradeAdvisor:tasks:LooperTaskDescription');
    task.setCheck(UpgradeAdvisor.UPGRADE_HIERARCHY_ID);


    mdlAdvisor=ModelAdvisor.Root;
    mdlAdvisor.register(task);


    upgAdvisor=UpgradeAdvisor;
    upgAdvisor.addTask(task);

end

