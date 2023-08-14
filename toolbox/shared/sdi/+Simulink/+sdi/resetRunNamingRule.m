function resetRunNamingRule






    engine=Simulink.sdi.Instance.engine;
    engine.runNameTemplate=engine.getDefaultRunNameTemplate;
end