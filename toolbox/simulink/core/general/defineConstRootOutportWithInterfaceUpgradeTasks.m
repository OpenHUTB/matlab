function defineConstRootOutportWithInterfaceUpgradeTasks






    task=ModelAdvisor.Task('mathworks.design.CheckForConstRootOutportWithInterface');
    task.DisplayName=DAStudio.message('ModelAdvisor:engine:TitleCheckIdentConstRootOutportWithInterfaceUpgrade');
    task.Description=DAStudio.message('ModelAdvisor:engine:TitletipCheckIdentConstRootOutportWithInterfaceUpgrade');
    task.setCheck('mathworks.design.CheckConstRootOutportWithInterfaceUpgrade');
    task.Enable=true;
    task.Value=false;


    modelAdvisor=ModelAdvisor.Root;
    modelAdvisor.register(task);


    upgAdvisor=UpgradeAdvisor;
    upgAdvisor.addTask(task);

end




