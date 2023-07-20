function res=isTaskManagerDrivingRateAdapterModel(tskMgrBlk)




    import soc.internal.connectivity.*

    res=false;
    mdl=getModelConnectedToTaskManager(tskMgrBlk);
    if~(isequal(get_param(mdl,'BlockType'),'ModelReference'))
        error(message('soc:scheduler:TaskMgrDrivesFcnCallSubsystem'));
    end
    val=get_param(mdl,'ShowModelPeriodicEventPorts');
    if isequal(val,'on')
        refMdlName=get_param(mdl,'ModelName');
        load_system(refMdlName);
        res=~slprivate('getIsExportFcnModel',refMdlName);
    end
end