function newComp=elaborate(this,hN,hC)


    [inputmode,rndMode,satMode,dataPortOrder,portSel,dataPortForDefault,numInputs,nfpOptions,diagForDefaultErr,codingStyle]=...
    this.getBlockInfo(hC);



    newComp=pirelab.getMultiPortSwitchComp(hN,hC.SLInputSignals,hC.SLOutputSignals,...
    inputmode,dataPortOrder,...
    rndMode,satMode,hC.Name,portSel,dataPortForDefault,numInputs,nfpOptions,diagForDefaultErr,codingStyle);
end
