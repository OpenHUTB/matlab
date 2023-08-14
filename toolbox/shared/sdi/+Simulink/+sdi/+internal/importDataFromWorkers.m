function importDataFromWorkers()








    eng=Simulink.sdi.Instance.engine;
    eng.sigRepository.importDataFromWorkers();
    eng.dirty=true;
    Simulink.sdi.loadSDIEvent();
end