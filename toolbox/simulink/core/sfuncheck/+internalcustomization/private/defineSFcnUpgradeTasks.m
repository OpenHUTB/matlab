function defineSFcnUpgradeTasks






    task=ModelAdvisor.Task('mathworks.design.CheckForSFcnUpgradeIssues');
    task.DisplayName=DAStudio.message('Simulink:tools:MASFcnMexAnalyzerTaskTitle');
    task.Description=DAStudio.message('Simulink:tools:MASFcnMexAnalyzerTaskTitleTips');
    task.setCheck('mathworks.design.CheckForSFcnUpgradeIssues');
    task.Enable=true;
    task.Value=false;
    mdlAdvisor=ModelAdvisor.Root;
    mdlAdvisor.register(task);

    upgradeAdvisor=UpgradeAdvisor;
    upgradeAdvisor.addTask(task);

end