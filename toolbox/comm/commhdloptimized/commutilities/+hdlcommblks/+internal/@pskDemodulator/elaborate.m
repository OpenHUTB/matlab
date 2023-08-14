function hNewC=elaborate(this,hN,hC)







    hNewNet=pirelab.createNewNetworkWithInterface(...
    'Network',hN,...
    'RefComponent',hC...
    );

    if isa(hC,'hdlcoder.sysobj_comp')
        sysObjHandle=hC.getSysObjImpl;
        prm=this.buildSysObjParams(sysObjHandle);
    else
        prm=this.buildBlockParams(hC);
    end


    prm.hN=hNewNet;
    prm.InputSignals=hNewNet.PirInputSignals;
    prm.OutputSignals=hNewNet.PirOutputSignals;



    switch prm.M
    case 2
        elaborateBPSK(this,prm);
    case 4
        elaborateQPSK(this,prm);
    case 8
        elaborateMPSK(this,prm);
    end


    hNewC=pirelab.instantiateNetwork(hN,hNewNet,hC.PirInputSignals,hC.PirOutputSignals,hC.Name);

end
