function[runID,dispNotification]=invokeSDI(bd,metadata,stepping)




    runID=[];
    dispNotification=Simulink.sdi.Instance.displayNotificationForModel(bd,stepping);


    if~locRecordIsOn(bd)&&~Simulink.sdi.Instance.isRepositoryCreated
        return
    end


    try
        sde=Simulink.sdi.Instance.engine;
        runID=sde.createRunFromModel(bd,metadata,stepping);

        if(isempty(runID)||sde.getSignalCount(runID)==0)
            runID=[];
        end
    catch ME
        runID=[];
        errordlg(ME.message,'Error','modal');
    end

    if~isempty(runID)
        Simulink.sdi.internal.SLMenus.getSetNewDataAvailable(bd,true);
    end
end

function ret=locRecordIsOn(bd)
    try
        val=get_param(bd,'InspectSignalLogs');
        ret=strcmpi(val,'on')||Simulink.sdi.Instance.record;
    catch me %#ok<NASGU>
        ret=false;
    end
end
