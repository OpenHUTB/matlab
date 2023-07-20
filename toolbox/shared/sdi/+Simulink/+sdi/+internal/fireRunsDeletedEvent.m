function fireRunsDeletedEvent()


    eng=Simulink.sdi.Instance.engine;
    notify(eng,'clearSDIEvent',Simulink.sdi.internal.SDIEvent('clearSDIEvent','allSDI'));
end
