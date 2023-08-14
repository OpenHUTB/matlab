function res=hasEventDrivenTasks(model)




    res=false;
    tskMgrBlks={};
    if codertarget.utils.isMdlConfiguredForSoC(getActiveConfigSet(model))
        tskMgrBlks=soc.internal.connectivity.getTaskManagerBlock(model,true);
        if~iscell(tskMgrBlks),tskMgrBlks={tskMgrBlks};end
    end

    if~isempty(tskMgrBlks)
        for i=1:numel(tskMgrBlks)
            thisBlk=tskMgrBlks{i};
            res=res||soc.internal.taskmanager.hasEventDrivenTasks(thisBlk);
        end
    else

    end
end
