function defineUpgradeAdvisorTask()




    task=ModelAdvisor.FactoryGroup('Model Updates');
    task.DisplayName=DAStudio.message('SimulinkUpgradeAdvisor:tasks:maGroupTitle');
    task.Description=DAStudio.message('SimulinkUpgradeAdvisor:tasks:maGroupDescription');
    task.addCheck('com.mathworks.Simulink.UpgradeAdvisor.MAEntryPoint');

    modelAdvisor=ModelAdvisor.Root;
    modelAdvisor.publish(task);

end

