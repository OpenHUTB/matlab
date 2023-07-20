function defineSignalBuilderUpgradeTasks()



    task=ModelAdvisor.Task('mathworks.design.Sigbldr.upgradeTask');
    task.DisplayName=DAStudio.message('Sigbldr:upgrade:upgradeTaskName1');
    task.Description=DAStudio.message('Sigbldr:upgrade:upgradeTaskDesc');
    task.setCheck('mathworks.design.Sigbldr.upgradeCheck');


    mdlAdvisor=ModelAdvisor.Root;
    mdlAdvisor.register(task);


    upgAdvisor=UpgradeAdvisor;
    upgAdvisor.addTask(task);
end