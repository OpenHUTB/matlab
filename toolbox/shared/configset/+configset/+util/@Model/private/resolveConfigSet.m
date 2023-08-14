function[cs,t]=resolveConfigSet(csr,~)

    cs=[];
    t=false;

    if isa(csr,'Simulink.ConfigSet')
        cs=csr;
        t=true;
    else
        csr.refresh(true);
        if strcmp(csr.SourceResolved,'on')
            t=true;
            cs=csr.getResolvedConfigSetCopy();
        else
            t=false;
            cs=[];
        end
    end