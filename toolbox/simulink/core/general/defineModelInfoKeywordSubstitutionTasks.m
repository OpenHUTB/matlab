function defineModelInfoKeywordSubstitutionTasks





    task=ModelAdvisor.Task('mathworks.design.ModelInfoKeywordSubstitution.task');
    task.DisplayName=DAStudio.message('Simulink:tools:ModelInfoKeywordSubstitutionTaskTitle');
    task.Description=DAStudio.message('Simulink:tools:ModelInfoKeywordSubstitutionTaskDescription');
    task.setCheck('mathworks.design.ModelInfoKeywordSubstitution');


    mdlAdvisor=ModelAdvisor.Root;
    mdlAdvisor.register(task);


    upgAdvisor=UpgradeAdvisor;
    upgAdvisor.addTask(task);

end
