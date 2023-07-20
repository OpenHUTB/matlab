function customizationSimRF




    cm=DAStudio.CustomizationManager;


    cm.addModelAdvisorCheckFcn(@defineSimRFUpgradeAdvisorChecks);


    cm.addModelAdvisorTaskAdvisorFcn(@defineSimRFUpgradeAdvisorTasks);

end


function defineSimRFUpgradeAdvisorChecks



    mdladvRoot=ModelAdvisor.Root;



    check=ModelAdvisor.Check(...
    'mathworks.design.rfblockset.ce.checkDisconnectedDividerBlocks');
    check.Title=DAStudio.message(...
    'simrf:advisor:DisconnectedDividerBlocks_CheckTitle');
    check.TitleTips=DAStudio.message(...
    'simrf:advisor:DisconnectedDividerBlocks_CheckDescription');
    check.setCallbackFcn(@checkDisconnectedDividerBlocks,'None','DetailStyle');
    check.SupportLibrary=true;
    check.CSHParameters.MapKey='ma.simulink';
    check.CSHParameters.TopicID='DisconnectedDividerBlocks';


    myAction=ModelAdvisor.Action;
    myAction.Name=DAStudio.message(...
    'simrf:advisor:DisconnectedDividerBlocks_ActionName');
    myAction.Description=DAStudio.message(...
    'simrf:advisor:DisconnectedDividerBlocks_ActionDescription');
    myAction.setCallbackFcn(@actionDisconnectedDividerBlocks);
    check.setAction(myAction);


    mdladvRoot.register(check);
end


function defineSimRFUpgradeAdvisorTasks



    mdladvRoot=ModelAdvisor.Root;
    upgAdvisor=UpgradeAdvisor;



    task=ModelAdvisor.Task(...
    'mathworks.design.rfblockset.ce.DisconnectedDividerBlocks.task');
    task.DisplayName=DAStudio.message(...
    'simrf:advisor:DisconnectedDividerBlocks_TaskDisplayName');
    task.Description=DAStudio.message(...
    'simrf:advisor:DisconnectedDividerBlocks_TaskDescription');
    task.setCheck(...
    'mathworks.design.rfblockset.ce.checkDisconnectedDividerBlocks');


    mdladvRoot.register(task);
    upgAdvisor.addTask(task);
end