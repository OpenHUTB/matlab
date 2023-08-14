function defineUpgradeModelHistoryPropertyTasks





    task=ModelAdvisor.Task('mathworks.design.SLXModelProperties.task');
    task.DisplayName=DAStudio.message('Simulink:tools:SLXModelPropertyTaskTitle');
    task.Description=DAStudio.message('Simulink:tools:SLXModelPropertyTaskDescription');
    task.setCheck('mathworks.design.SLXModelProperties');


    mdlAdvisor=ModelAdvisor.Root;
    mdlAdvisor.register(task);


    upgAdvisor=UpgradeAdvisor;
    upgAdvisor.addTask(task);

end




