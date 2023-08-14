function verifyPartitionsHaveTasks(tskMgrBlk)




    taskNames=soc.internal.connectivity.getTaskNames(tskMgrBlk);
    refMdlBlk=soc.internal.connectivity.getModelConnectedToTaskManager(tskMgrBlk);
    refMdlName=get_param(refMdlBlk,'ModelName');
    schedule=get_param(refMdlName,'Schedule');
    idxMissingNames=ismember(schedule.Order.Partition,taskNames);
    if~all(idxMissingNames)
        lstMissingTasks=matlab.io.internal.text.cell2text(schedule.Order.Partition(~idxMissingNames));
        lstMissingTasks=strrep(lstMissingTasks,newline,', ');
        tskMgrName=get_param(tskMgrBlk,'Name');
        error(message('soc:scheduler:PartitionsMustHaveTasks',...
        refMdlName,...
        tskMgrName,...
        lstMissingTasks));
    end
end
