function customizationRealTimeAdvisor()




    cm=DAStudio.CustomizationManager;

    cm.addModelAdvisorCheckFcn(@defineUpgradeChecks);

    cm.addModelAdvisorTaskAdvisorFcn(@defineUpgradeTasks);

end

function defineUpgradeChecks


    check=ModelAdvisor.Check('mathworks.design.slrealtimeUpgrades');
    check.Title=DAStudio.message('slrealtime:advisor:upgradeCheckTitle');
    check.setCallbackFcn(@upgradeAdvisorCheckCB,'None','StyleOne');
    check.CSHParameters.MapKey='ma.slrealtime';
    check.CSHParameters.TopicID='UASlrealtimeCheck';


    action=ModelAdvisor.Action;
    action.setCallbackFcn(@upgradeAdvisorActionCB);
    action.Name=DAStudio.message('slrealtime:advisor:upgradeActionTitle');
    action.Description=DAStudio.message('slrealtime:advisor:upgradeActionDescription');
    check.setAction(action)


    modelAdvisor=ModelAdvisor.Root;
    modelAdvisor.register(check);

end

function defineUpgradeTasks


    task=ModelAdvisor.Task('mathworks.design.slrealtimeUpgrades');
    task.DisplayName=DAStudio.message('slrealtime:advisor:upgradeTaskTitle');
    task.Description=DAStudio.message('slrealtime:advisor:upgradeTaskDescription');
    task.setCheck('mathworks.design.slrealtimeUpgrades');


    mdlAdvisor=ModelAdvisor.Root;
    mdlAdvisor.register(task);


    upgAdvisor=UpgradeAdvisor;
    upgAdvisor.addTask(task);

end
