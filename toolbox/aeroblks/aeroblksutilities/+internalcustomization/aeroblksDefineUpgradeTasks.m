function aeroblksDefineUpgradeTasks







    mdlAdvisor=ModelAdvisor.Root;


    taskDOF=ModelAdvisor.Task('mathworks.design.Aeroblks.TaskDOF');
    taskDOF.DisplayName=DAStudio.message('aeroblks:aeroupdate:upgradeDOFTitle');
    taskDOF.Description=DAStudio.message('aeroblks:aeroupdate:upgradeDOFDescription');
    taskDOF.setCheck('mathworks.design.Aeroblks.CheckDOF');
    mdlAdvisor.register(taskDOF);


    taskNAV=ModelAdvisor.Task('mathworks.design.Aeroblks.TaskNAV');
    taskNAV.DisplayName=DAStudio.message('aeroblks:aeroupdate:upgradeNAVTitle');
    taskNAV.Description=DAStudio.message('aeroblks:aeroupdate:upgradeNAVDescription');
    taskNAV.setCheck('mathworks.design.Aeroblks.CheckNAV');
    mdlAdvisor.register(taskNAV);


    upgAdvisor=UpgradeAdvisor;

    upgAdvisor.addTask(taskDOF);
    upgAdvisor.addTask(taskNAV);











end

