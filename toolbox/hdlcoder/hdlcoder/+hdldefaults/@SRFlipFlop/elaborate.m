function SRFlipFlopComp=elaborate(this,hN,hC)





    hInSignals=hC.PirInputSignals;
    hOutSignals=hC.PirOutputSignals;

    initialQ=this.getBlockInfo(hC);

    hNew=pirelab.createNewNetwork(...
    'Network',hN,...
    'Name','S-R Flip Flop',...
    'InportNames',{'in1','in2'},...
    'InportTypes',[hInSignals(1).Type,hInSignals(2).Type],...
    'InportRates',[hInSignals(1).SimulinkRate,hInSignals(2).SimulinkRate],...
    'OutportNames',{'out1','out2'},...
    'OutportTypes',[hOutSignals(1).Type,hOutSignals(2).Type]);

    hNew.generateModelFromPir;

    pirelab.getSRFlipFlopComp(hNew,hNew.PirInputSignals,hNew.PirOutputSignals,...
    initialQ,hC.Name,'',hC.SimulinkHandle);

    SRFlipFlopComp=pirelab.instantiateNetwork(hN,hNew,hInSignals,hOutSignals,...
    [hC.Name,'_inst']);
end
