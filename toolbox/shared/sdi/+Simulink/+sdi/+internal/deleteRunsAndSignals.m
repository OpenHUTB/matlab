function deleteRunsAndSignals(ids)

    eng=Simulink.sdi.Instance.engine();
    eng.deleteRunsAndSignals(ids,'sdi');
end