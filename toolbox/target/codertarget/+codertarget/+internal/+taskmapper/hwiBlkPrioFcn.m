function hwiBlkPrioFcn(blkH)






    mdl=codertarget.utils.getModelForBlock(blkH);
    mdlName=get(mdl,'Name');
    hCS=getActiveConfigSet(mdlName);
    if strcmp(get_param(mdl,'BlockDiagramType'),'library'),return;end

    if codertarget.peripherals.AppModel.isProcessorModel(bdroot(blkH))



        try
            newPrio=get_param(blkH,'TaskPriority');
            thisTaskName=get_param(blkH,'Name');

            thisTaskName=strrep(thisTaskName,' ','');
            data=get_param(hCS,'CoderTargetData');
            oldPrio=data.TaskMap.Tasks.(thisTaskName).TaskPriority;
            if~strcmp(oldPrio,newPrio)
                data.TaskMap.Tasks.(thisTaskName).TaskPriority=newPrio;
                val=data.TaskMap;
                codertarget.internal.taskmapper.setHWIInfo(hCS,val);
            end
        catch

        end
    end
end