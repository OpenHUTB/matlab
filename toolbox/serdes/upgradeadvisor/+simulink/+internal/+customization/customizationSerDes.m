function customizationSerDes()




    cm=DAStudio.CustomizationManager;


    cm.addModelAdvisorCheckFcn(@defineSerDesUpgradeChecks);
    cm.addModelAdvisorTaskAdvisorFcn(@defineSerDesUpgradeCheckTasks);

end

function defineSerDesUpgradeChecks







    check=ModelAdvisor.Check('mathworks.design.serdesUpgrades');
    check.Title=DAStudio.message('serdes:advisor:upgradeCheckTitle');
    check.setCallbackFcn(@checkSerDesBlocks,'None','StyleOne');
    check.Group='Simulink';
    check.CSHParameters.MapKey='ma.simulink';
    check.CSHParameters.TopicID='serdesUpgrades';
    check.callbackcontext='None';
    check.SupportLibrary=false;
    check.SupportExclusion=true;
    check.Value=true;


    action=ModelAdvisor.Action;
    action.setCallbackFcn(@checkSerDesBlocksAction);
    action.Name=DAStudio.message('serdes:advisor:upgradeActionTitle');
    action.Description=DAStudio.message('serdes:advisor:upgradeActionDescription');

    check.setAction(action);


    modelAdvisor=ModelAdvisor.Root;
    modelAdvisor.register(check);


end

function defineSerDesUpgradeCheckTasks





    task=ModelAdvisor.Task('mathworks.design.serdesUpgrades.task');
    task.DisplayName=DAStudio.message('serdes:advisor:upgradeTaskTitle');
    task.Description=DAStudio.message('serdes:advisor:upgradeTaskDescription');
    task.setCheck('mathworks.design.serdesUpgrades');


    modelAdvisor=ModelAdvisor.Root;
    modelAdvisor.register(task);


    upgAdvisor=UpgradeAdvisor;
    upgAdvisor.addTask(task);

end
