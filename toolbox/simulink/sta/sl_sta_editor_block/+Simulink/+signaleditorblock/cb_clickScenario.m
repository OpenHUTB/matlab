function[ret,msg]=cb_clickScenario(obj)




    dialogSource=obj.getDialogSource();
    blk=dialogSource.getBlock;
    blockPath=getFullName(blk);
    map=Simulink.signaleditorblock.ListenerMap.getInstance;
    UIDataModel=map.getListenerMap(num2str(getSimulinkBlockHandle(blockPath),32));


    if~any(strcmp(blk.ActiveScenario,UIDataModel.getScenarioList))
        throw(MSLException(getSimulinkBlockHandle(blockPath),...
        message('sl_sta_editor_block:message:NonExistentScenario',blk.ActiveScenario)));
    end

    UIDataModel.isUpdated=true;
    Simulink.signaleditorblock.cb_signalPropertiesChanged(obj);
    ret=true;
    msg='No error';

end
