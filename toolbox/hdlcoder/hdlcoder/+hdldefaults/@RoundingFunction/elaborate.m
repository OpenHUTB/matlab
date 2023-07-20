function hNewC=elaborate(this,hN,hC)



    hCInSignals=hC.SLInputSignals;
    hCOutSignals=hC.SLOutputSignals;


    slbh=hC.SimulinkHandle;
    op=get_param(slbh,'Operator');
    nfpOptions=getNFPBlockInfo(this);
    hNewC=pirelab.getRoundingFunctionComp(hN,hCInSignals,hCOutSignals,op,hC.Name,nfpOptions);

end
