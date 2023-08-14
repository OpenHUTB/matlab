function hNewC=elaborate(this,hN,hC)



    [tablein,tableout,oType_ex]=getBlockInfo(this,hC);


    hNewC=pirelab.getLookupComp(hN,hC.PirInputSignals,hC.PirOutputSignals,...
    tablein,tableout,tableout(end),oType_ex,hC.Name);

end
