function clearNewDataNotification(~)
    Simulink.sdi.internal.SLMenus.getSetNewDataAvailable('',false);
end
