function cs=getSourceConfigSet(csRef)




    assert(isa(csRef,'Simulink.ConfigSetRef'));
    cs=csRef.getRefConfigSet();
end

