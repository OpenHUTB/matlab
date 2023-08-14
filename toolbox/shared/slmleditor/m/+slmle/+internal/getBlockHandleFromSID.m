function blkH=getBlockHandleFromSID(sid)


    if isempty(sid)
        blkH=[];
        return;
    end

    blkH=Simulink.ID.getHandle(sid);
    if isa(blkH,'Stateflow.EMFunction')
        chartId=sf('get',blkH.Id,'.chart');
        chartObj=sf('IdToHandle',chartId);
        chartSid=Simulink.ID.getSID(chartObj);
        blkH=Simulink.ID.getHandle(chartSid);
    end
