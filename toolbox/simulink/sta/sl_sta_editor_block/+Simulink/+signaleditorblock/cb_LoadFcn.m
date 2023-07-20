function cb_LoadFcn(block)




    if Simulink.signaleditorblock.MaskSetting.isBlockLocked(block)

        return;
    end

    PreSaveUserData=get_param(block,'UserData');
    if isfield(PreSaveUserData,'BlockData')
        DataModel=PreSaveUserData.BlockData;
        map=Simulink.signaleditorblock.ListenerMap.getInstance;
        map.addListener(num2str(getSimulinkBlockHandle(block),32),DataModel);






        try
            Simulink.Block.eval(block);
        catch



        end
        set_param(block,'UserData',PreSaveUserData.UserData);
    end
end
