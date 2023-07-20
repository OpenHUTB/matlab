function[ret,msg]=cb_selectSignal(obj)






    src=obj.getDialogSource;
    blk=src.getBlock;
    blockPath=getFullName(blk);
    map=Simulink.signaleditorblock.ListenerMap.getInstance;
    UIDataModel=map.getListenerMap(num2str(getSimulinkBlockHandle(blockPath),32));
    UISignalProperties=UIDataModel.getSignalProperties(blk.ActiveSignal);
    if~any(strcmp(blk.ActiveSignal,UIDataModel.getSignalsForScenario(blk.ActiveScenario)))
        throw(MSLException(getSimulinkBlockHandle(blockPath),...
        message('sl_sta_editor_block:message:NonExistentSignal',blk.ActiveSignal,blk.ActiveScenario)));
    end
    Simulink.signaleditorblock.activateSignal(getSimulinkBlockHandle(blockPath),UIDataModel);
    BlockDataModel=get_param([blockPath,'/Model Info'],'UserData');
    BlockSignalProperties=BlockDataModel.getSignalProperties(blk.ActiveSignal);
    prop=properties(UISignalProperties);

    for id=1:length(prop)
        if isequal(UISignalProperties.(prop{id}),...
            BlockSignalProperties.(prop{id}))
            obj.clearWidgetDirtyFlag(prop{id});
        end
    end

    obj.clearWidgetDirtyFlag('ActiveSignal');
    if~UIDataModel.isUpdated
        obj.enableApplyButton(false);
    else
        obj.enableApplyButton(true);
    end

end