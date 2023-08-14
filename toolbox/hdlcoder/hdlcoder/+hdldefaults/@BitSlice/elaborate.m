function hNewC=elaborate(this,hN,hC)




    slbh=hC.SimulinkHandle;
    lidx=hdlslResolve('lidx',slbh);
    ridx=hdlslResolve('ridx',slbh);

    hNewC=pirelab.getBitSliceComp(hN,hC.SLInputSignals,hC.SLOutputSignals,lidx,ridx,hC.Name);

end



