function nComp=elaborate(this,hN,hC)






    blockInfo=getBlockInfo(this,hC);
    blockInfo.inResetSS=hN.isInResettableHierarchy;



    FarrowFilter=dsphdlsupport.internal.AbstractFarrowFilter;
    topNet=FarrowFilter.elaborateTopLevel(hN,hC,blockInfo);



    nComp=pirelab.instantiateNetwork(hN,topNet,hC.PirInputSignals,hC.PirOutputSignals,hC.Name);

end
