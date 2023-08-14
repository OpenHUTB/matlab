






function dotpComp=elaborate(this,hN,hC)
    blockInfo=this.getBlockInfo(hC);
    rndMode=blockInfo.rndMode;
    satMode=blockInfo.satMode;
    hOutSignals=hC.PirOutputSignals;
    hInSignals=hC.PirInputSignals;
    architecture='tree';
    nfpOptions=getNFPBlockInfo(this);

    if hN.optimizationsRequested
        dotpComp=pirelab.getDotproductComp(hN,hInSignals,hOutSignals,...
        hC.Name,rndMode,satMode,architecture,nfpOptions);
    else

        hNew=pirelab.createNewNetwork(...
        'Network',hN,...
        'Name','DotProduct',...
        'InportNames',{'in1','in2'},...
        'InportTypes',[hInSignals(1).Type,hInSignals(2).Type],...
        'InportRates',[hInSignals(1).SimulinkRate,hInSignals(2).SimulinkRate],...
        'OutportNames',{'out1'},...
        'OutportTypes',[hOutSignals(1).Type]);
        hNew.generateModelFromPir;

        pirelab.getDotproductComp(hNew,hNew.PirInputSignals,hNew.PirOutputSignals,...
        hC.Name,rndMode,satMode,architecture,nfpOptions);
        dotpComp=pirelab.instantiateNetwork(hN,hNew,hInSignals,hOutSignals,...
        [hC.Name,'_inst']);
    end
end
