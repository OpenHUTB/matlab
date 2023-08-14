function defineSLXFileCompressionTask()




    task=ModelAdvisor.Task('mathworks.design.CheckSLXFileCompressionLevel.task');
    task.DisplayName=DAStudio.message('SimulinkUpgradeAdvisor:slxCompressionCheck:CheckName');
    task.Description=DAStudio.message('SimulinkUpgradeAdvisor:slxCompressionCheck:CheckDescription');
    task.setCheck('mathworks.design.CheckSLXFileCompressionLevel');


    mdlAdvisor=ModelAdvisor.Root;
    mdlAdvisor.register(task);


    upgAdvisor=UpgradeAdvisor;
    upgAdvisor.addTask(task);

end

