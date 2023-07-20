function cb_PreSaveFcn(block)





    if Simulink.signaleditorblock.MaskSetting.isBlockLocked(block)

        return;
    end

    UserData=get_param(block,'UserData');
    UserDataPersistent=get_param(block,'UserDataPersistent');
    if strcmp(UserDataPersistent,'on')
        PreSaveUserData.UserData=UserData;
    else
        PreSaveUserData.UserData=[];
        set_param(block,'UserDataPersistent','on');
    end
    PreSaveUserData.BlockData=get_param([block,'/Model Info'],'UserData');
    PreSaveUserData.UserDataPersistent=UserDataPersistent;
    set_param(block,'UserData',PreSaveUserData);
end