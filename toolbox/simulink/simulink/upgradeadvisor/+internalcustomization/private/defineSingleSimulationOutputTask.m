function defineSingleSimulationOutputTask()




    task=ModelAdvisor.Task('mathworks.design.CheckSingleSimulationOutput.task');
    task.DisplayName=DAStudio.message('SimulinkUpgradeAdvisor:singleSimulationOutput:CheckName');
    task.Description=DAStudio.message('SimulinkUpgradeAdvisor:singleSimulationOutput:CheckDescription');
    task.setCheck('mathworks.design.CheckSingleSimulationOutput');


    mdlAdvisor=ModelAdvisor.Root;
    mdlAdvisor.register(task);


    upgAdvisor=UpgradeAdvisor;
    upgAdvisor.addTask(task);
end

