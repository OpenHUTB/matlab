function mainEarlyElaborate(this,hN,hC)





    [hNewC,hNewNet]=elaborateToNetworkInst(this,hN,hC);
    hNewNet.dontTouch(true);




    hNewC.elaborate(hNewNet);




