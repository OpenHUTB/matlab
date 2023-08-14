function nComp=elaborate(this,hN,hC)






    blockInfo=getBlockInfo(this,hC);


    topNet=this.elaborateTopLevel(hN,hC,blockInfo);
    topNet.addComment('Farrow Rate Converter HDL Optimized');


    nComp=pirelab.instantiateNetwork(hN,topNet,hC.PirInputSignals,hC.PirOutputSignals,hC.Name);

end
