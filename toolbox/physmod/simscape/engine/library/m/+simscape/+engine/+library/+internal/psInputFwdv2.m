function out=psInputFwdv2(in)
    map={
    {
    {'InputFiltering',{'off','on','derivs'}}
    {'FilteringAndDerivatives',{'zero','filter','provide'}}
    }
    };
    out=simscape.engine.library.internal.mapParameters(in,map);
end
