function defineSystemObjectUpdateTask

    task=ModelAdvisor.Task('mathworks.design.CheckSystemObjectUpdate.task');
    task.DisplayName=DAStudio.message('MATLAB:system:Advisor:CheckSystemObject_title');
    task.Description=DAStudio.message('MATLAB:system:Advisor:CheckSystemObject_tip');
    task.setCheck('mathworks.design.CheckSystemObjectUpdate');
    task.Enable=true;
    task.Value=false;

    mdlAdvisor=ModelAdvisor.Root;
    mdlAdvisor.register(task);

    upgradeAdvisor=UpgradeAdvisor;
    upgradeAdvisor.addTask(task);

end

