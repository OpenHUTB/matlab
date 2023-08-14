function mainElaborate(this,hN,hC)





    [hNewC,hNewNet]=elaborateToNetworkInst(this,hN,hC);

    hNewC.insertPipelinePlaceholders;




    hNewC.elaborate(hNewNet);




