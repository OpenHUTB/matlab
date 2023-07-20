function ret=isCLATaskManagerFound(modelName)




    tskMgrBlk=codertarget.utils.findCLATaskManager(modelName);
    ret=~isempty(tskMgrBlk);
end
