function nComp=elaborate(this,hN,hC)






    blockInfo=getBlockInfo(this,hC);
    blockInfo.inResetSS=hN.isInResettableHierarchy;

    topNet=this.elaborateTopLevel(hN,hC,blockInfo);
    topNet.addComment('Discrete FIR Filter');





    if blockInfo.inResetSS
        topNet.setTreatNetworkAsResettableBlock;
    end


    nComp=pirelab.instantiateNetwork(hN,topNet,hC.PirInputSignals,hC.PirOutputSignals,hC.Name);

end
