function status=setSimrfConfigBlkUserData(blkH,delayVal)










    status=true;
    if delayVal>=0
        try
            mdlDirty=get_param(bdroot(blkH),'dirty');
            configBlk=get_param(get_param(get_param(blkH,'Parent'),...
            'Parent'),'Parent');
            ud=get_param(configBlk,'UserData');
            ud.FilterDelay=delayVal;
            set_param(configBlk,'UserData',ud);
            set_param(bdroot(blkH),'dirty',mdlDirty);
        catch
            status=false;
        end
    end
end