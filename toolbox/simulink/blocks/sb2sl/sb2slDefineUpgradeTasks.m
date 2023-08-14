function sb2slDefineUpgradeTasks






    mdlAdvisor=ModelAdvisor.Root;


    task=ModelAdvisor.Task('mathworks.simulink.SB2SL.Task');
    task.DisplayName=DAStudio.message('sb2sl_blks:update:upgradeSB2SLTitle');
    task.Description=DAStudio.message('sb2sl_blks:update:upgradeSB2SLDescription');
    task.setCheck('mathworks.simulink.SB2SL.Check');
    mdlAdvisor.register(task);


    upgAdvisor=UpgradeAdvisor;
    upgAdvisor.addTask(task);

end