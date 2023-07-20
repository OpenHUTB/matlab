function cb_PostSaveFcn(block)





    if Simulink.signaleditorblock.MaskSetting.isBlockLocked(block)

        return;
    end


    PreSaveUserData=get_param(block,'UserData');
    if isfield(PreSaveUserData,'UserData')
        set_param(block,'UserData',PreSaveUserData.UserData);
        set_param(block,'UserDataPersistent',PreSaveUserData.UserDataPersistent);
    end

end