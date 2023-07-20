function hNewC=elaborate(this,hN,hC)



    hCInSignals=hC.SLInputSignals;
    hCOutSignals=hC.SLOutputSignals;
    slbh=hC.SimulinkHandle;
    [rndMode,ovMode,pipelineDepth,adderSign,nfpOptions,fused]=getBlockInfo(this,slbh,hC);


    hNewC=pirelab.getScalarMACComp(hN,hCInSignals,hCOutSignals,rndMode,ovMode,hC.Name,'',-1,pipelineDepth,adderSign,...
    nfpOptions,fused);

end
