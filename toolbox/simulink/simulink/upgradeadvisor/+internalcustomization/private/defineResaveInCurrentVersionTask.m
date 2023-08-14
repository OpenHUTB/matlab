function defineResaveInCurrentVersionTask()




    task=ModelAdvisor.Task('mathworks.design.CheckSavedInCurrentVersion.task');
    task.DisplayName=DAStudio.message('SimulinkUpgradeAdvisor:resavecheck:CheckName');
    task.Description=DAStudio.message('SimulinkUpgradeAdvisor:resavecheck:CheckDescription');
    task.setCheck('mathworks.design.CheckSavedInCurrentVersion');


    mdlAdvisor=ModelAdvisor.Root;
    mdlAdvisor.register(task);


    upgAdvisor=UpgradeAdvisor;
    upgAdvisor.addTask(task);

end

