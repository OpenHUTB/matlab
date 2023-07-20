function dspDefineUpgradeTasks







    task=ModelAdvisor.Task('mathworks.design.DSPFrameUpgrade');
    task.DisplayName=DAStudio.message('dsp:UpgradeAdvisor:Title');
    task.Description=DAStudio.message('dsp:UpgradeAdvisor:Description');
    task.setCheck('mathworks.design.DSPFrameUpgrade');


    mdlAdvisor=ModelAdvisor.Root;
    mdlAdvisor.register(task);


    upgAdvisor=UpgradeAdvisor;
    upgAdvisor.addTask(task);

end
