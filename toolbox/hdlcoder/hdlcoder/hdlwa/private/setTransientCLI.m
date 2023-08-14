function setTransientCLI(system,param,value)



    hDriver=hdlmodeldriver(bdroot(system));
    hDI=hDriver.DownstreamIntegrationDriver;
    assert(hDI.transientCLIMaps.isKey(param),[param,' is not registered as transient CLI.']);
    hDI.transientCLIMaps(param)=value;
end