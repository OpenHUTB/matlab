function onRunsAutoDeleted(deletedRunIDs)

    eng=Simulink.sdi.Instance.engine;

    if~Simulink.sdi.getRunCount()
        eng.DiffRunResult=Simulink.sdi.DiffRunResult(0,eng);
        notify(eng,'clearSDIEvent',...
        Simulink.sdi.internal.SDIEvent('clearSDIEvent','allSDI'));
    else
        for idx=1:numel(deletedRunIDs)
            notify(eng,'runDeleteEvent',Simulink.sdi.internal.SDIEvent(...
            'runDeleteEvent',deletedRunIDs(idx),int32(0)));
        end
    end

end

