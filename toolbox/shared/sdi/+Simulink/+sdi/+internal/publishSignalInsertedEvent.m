function publishSignalInsertedEvent(mdl,targetName)
    r=Simulink.sdi.getCurrentSimulationRun(mdl,targetName);
    if~isempty(r)
        eng=Simulink.sdi.Instance.engine;
        notify(eng,'signalsInsertedEvent',...
        Simulink.sdi.internal.SDIEvent('signalsInsertedEvent',r.id));
    end
end
