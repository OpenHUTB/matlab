function nvram=isAutosarNVRAM(~,hData)




    assert(isa(hData,'Simulink.Data'));

    nvram=false;


    ca=hData.CoderInfo.CustomAttributes;
    if isprop(ca,'needsNVRAMAccess')
        nvram=ca.needsNVRAMAccess;
    end



