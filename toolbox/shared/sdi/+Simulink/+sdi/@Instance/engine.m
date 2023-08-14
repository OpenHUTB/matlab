function sdiEngine=engine()

    sdiEngine=Simulink.sdi.Instance.getSetEngine();
    if isempty(sdiEngine)



        engArg=sdi.Repository(1);
        sdiEngine=Simulink.sdi.internal.Engine(engArg);
        parseOptions(sdiEngine);
        Simulink.sdi.Instance.getSetEngine(sdiEngine);
        init(sdiEngine);
    end
end
