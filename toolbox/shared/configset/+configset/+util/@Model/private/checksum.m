function chk=checksum(csr,mdl)


    cs=resolveConfigSet(csr,mdl);
    if isa(cs,'Simulink.ConfigSet')
        chk=cs.computeChecksum('Normal');
    end

