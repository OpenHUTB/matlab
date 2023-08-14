function elaborate(this,hN,hC)





    [hNewC,hNewNet]=elaborateToNetworkInst(this,hN,hC);




    hNewC.elaborate(hNewNet);




