function ret=isTaskManagerFound(modelName)




    tskMgrBlk=codertarget.utils.findTaskManager(modelName);
    ret=~isempty(tskMgrBlk);
end
