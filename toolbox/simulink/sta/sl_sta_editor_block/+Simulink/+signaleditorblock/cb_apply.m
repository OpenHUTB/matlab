function[ret,msg]=cb_apply(obj)





    src=obj.getDialogSource;
    blk=src.getBlock;
    blockPath=getFullName(blk);

    if~Simulink.signaleditorblock.isFastRestartOn(blockPath)
        try
            Simulink.signaleditorblock.MaskSetting.enableMaskInitialization(blockPath);
            [ret,msg]=src.preApplyCallback(obj);
        catch ME
            if~isempty(ME.cause)
                msg=ME.cause{1}.message;
                ret=false;
            else
                msg=ME.message;
                ret=false;
            end
        end
    else
        [ret,msg]=src.preApplyCallback(obj);
    end

    if ret
        map=Simulink.signaleditorblock.ListenerMap.getInstance;
        dataModel=map.getListenerMap(num2str(getSimulinkBlockHandle(blockPath),32));
        dataModel.isUpdated=false;
    end

end