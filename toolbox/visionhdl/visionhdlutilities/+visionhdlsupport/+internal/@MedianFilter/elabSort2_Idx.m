function miNet=elabSort2_Idx(~,topNet,dataRate,NSize,dinType)




    ctlType=pir_boolean_t();


    idxWL=ceil(log2(NSize));
    idxType=pir_ufixpt_t(idxWL,0);


    miNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','Sort2',...
    'InportNames',{'in1','idx1','in2','idx2'},...
    'InportTypes',[dinType,idxType,dinType,idxType],...
    'InportRates',[dataRate,dataRate,dataRate,dataRate],...
    'OutportNames',{'lowValue','lowIdx','highValue','highIdx'},...
    'OutportTypes',[dinType,idxType,dinType,idxType]...
    );


    in1=miNet.PirInputSignals(1);
    idx1=miNet.PirInputSignals(2);
    in2=miNet.PirInputSignals(3);
    idx2=miNet.PirInputSignals(4);

    lowValue=miNet.PirOutputSignals(1);
    lowIdx=miNet.PirOutputSignals(2);
    highValue=miNet.PirOutputSignals(3);
    highIdx=miNet.PirOutputSignals(4);

    sel=miNet.addSignal(ctlType,'sel');
    pirelab.getRelOpComp(miNet,[in1,in2],sel,'<');
    pirelab.getSwitchComp(miNet,[in1,in2],lowValue,sel,'','==',1);
    pirelab.getSwitchComp(miNet,[in2,in1],highValue,sel,'','==',1);
    pirelab.getSwitchComp(miNet,[idx1,idx2],lowIdx,sel,'','==',1);
    pirelab.getSwitchComp(miNet,[idx2,idx1],highIdx,sel,'','==',1);

end
