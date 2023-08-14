function setEngine(engine)
    if isa(engine,'Simulink.sdi.internal.Engine')
        Simulink.sdi.Instance.getSetEngine(engine);
    else
        Simulink.sdi.Instance.getSetEngine([]);
    end
end
