function runNamingRule=getRunNamingRule()
    engine=Simulink.sdi.Instance.engine;
    runNamingRule=engine.runNameTemplate;
end
