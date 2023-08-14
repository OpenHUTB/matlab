function nComp=elaborate(this,hN,hC)






    blockInfo=getBlockInfo(this,hC);


    topNet=this.elaborateTopLevel(hN,hC,blockInfo);
    topNet.addComment('FIR Rate Converter');


    nComp=pirelab.instantiateNetwork(hN,topNet,hC.PirInputSignals,hC.PirOutputSignals,hC.Name);

end
