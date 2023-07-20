function[cleanRun,msg]=cb_signalPropertiesChanged(obj)





    dialogSource=obj.getDialogSource();
    blockPath=getFullName(dialogSource.getBlock);

    if~Simulink.signaleditorblock.isFastRestartOn(blockPath)
        Simulink.signaleditorblock.MaskSetting.disableMaskInitialization(blockPath);
    end

    map=Simulink.signaleditorblock.ListenerMap.getInstance;
    UIDataModel=map.getListenerMap(num2str(getSimulinkBlockHandle(blockPath),32));
    blockProperties=Simulink.signaleditorblock.model.SignalEditorBlock.createBlockProperties(blockPath);
    try
        UIDataModel.updateDataModel(blockProperties);
    catch ME
        if strcmp(ME.identifier,'sl_sta_editor_block:message:LaunchSignalEditorCreateNewFile')
            suggestion=message('sl_sta_editor_block:message:LaunchSignalEditorAction',...
            num2str(getSimulinkBlockHandle(blockPath),32));
            action=MSLDiagnostic([],suggestion).action;
            ex=message('sl_sta_editor_block:message:NonExistentFile','untitled.mat');
            msg=MSLException(getSimulinkBlockHandle(blockPath),ex,'ACTION',action);
        else
            msg=MSLException(getSimulinkBlockHandle(blockPath),ME);
        end
        throw(msg);
    end



    grp_entries=UIDataModel.getScenarioList;
    activeScenarioName=get_param(blockPath,'ActiveScenario');
    foundCurrentActiveScenario=any(strcmp(activeScenarioName,grp_entries));
    blk=dialogSource.getBlock;
    if~foundCurrentActiveScenario&&~isempty(grp_entries)
        blk.ActiveScenario=grp_entries{1};
    end

    activeSignalName=get_param(blockPath,'ActiveSignal');
    sig_entries=UIDataModel.getSignalsForScenario(get_param(blockPath,'ActiveScenario'));
    foundCurrentActiveSignal=any(strcmp(activeSignalName,sig_entries));
    if~foundCurrentActiveSignal&&~isempty(sig_entries)
        blk.ActiveSignal=sig_entries{1};
        Simulink.signaleditorblock.cb_selectSignal(obj);
    end

    cleanRun=true;
    msg='No error';

end