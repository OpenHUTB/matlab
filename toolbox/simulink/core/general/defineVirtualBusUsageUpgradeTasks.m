function defineVirtualBusUsageUpgradeTasks






    task=ModelAdvisor.Task('mathworks.design.VirtualBusUsage');
    task.DisplayName=DAStudio.message('Simulink:tools:MATitleCheckVirtualBusUsageUpgrade');
    task.Description=DAStudio.message('Simulink:tools:MATitletipCheckVirtualBusUsageUpgrade');

    task.setCheck('mathworks.design.VirtualBusUsage');
    task.Enable=true;
    task.Value=false;


    modelAdvisor=ModelAdvisor.Root;
    modelAdvisor.register(task);


    upgAdvisor=UpgradeAdvisor;
    upgAdvisor.addTask(task);

end




