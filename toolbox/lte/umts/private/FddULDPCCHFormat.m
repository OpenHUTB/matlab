













function[cdata,cdims]=FddULDPCCHFormat(nsft,nslots,tpc,tfci,fbi)
    [cdata,cdims]=fdd('FddULDPCCHFormat',nsft,nslots,tpc,tfci,fbi);
    cdata=double(cdata);
end
