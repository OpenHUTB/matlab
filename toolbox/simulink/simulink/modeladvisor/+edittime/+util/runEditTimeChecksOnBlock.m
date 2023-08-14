function runEditTimeChecksOnBlock(model,blk)



    if isempty(blk)
        return;
    end
    if Simulink.ID.isValid(blk)
        blk=Simulink.ID.getHandle(blk);
    end

    if Advisor.Utils.Stateflow.isStateflowObject(blk)
        sf('CheckChartAtEditTime',blk.Chart.Id);
    elseif isSLETSupportedType(blk)
        edittimeEngine=edittimecheck.EditTimeEngine.getInstance();
        edittimeEngine.forceBlkUpdateEvent(model,get_param(blk,'handle'))
        blkEditTimeCheck.openDialogsRefresh(get_param(blk,'handle'))
    end
end


function flag=isSLETSupportedType(blk)
    flag=any(strcmp(get_param(blk,'Type'),{'block','port'}));
end
