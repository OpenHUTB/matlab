function aNet=elabAposterioriNodeUnitNetwork(this,topNet,blockInfo,dataRate)



    ufix1Type=pir_boolean_t;
    vType1=pir_sfixpt_t(blockInfo.alphaWL,blockInfo.alphaFL);
    vType2=pir_sfixpt_t(blockInfo.betaWL,blockInfo.alphaFL);

    v1Type=pirelab.getPirVectorType(vType1,blockInfo.memDepth);
    v2Type=pirelab.getPirVectorType(vType2,blockInfo.memDepth);


    aNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','AposterioriUnit',...
    'Inportnames',{'alpha','beta','valid','reset'},...
    'InportTypes',[v1Type,v2Type,ufix1Type,ufix1Type],...
    'InportRates',[dataRate,dataRate,dataRate,dataRate],...
    'Outportnames',{'gamma','valid'},...
    'OutportTypes',[v1Type,ufix1Type]...
    );



    data=aNet.PirInputSignals(1);
    beta=aNet.PirInputSignals(2);
    valid=aNet.PirInputSignals(3);
    reset=aNet.PirInputSignals(4);

    dataout=aNet.PirOutputSignals(1);
    validout=aNet.PirOutputSignals(2);


    add=aNet.addSignal(v1Type,'add');

    pirelab.getAddComp(aNet,[data,beta],add,'floor','saturate','add_Comp');
    pirelab.getWireComp(aNet,add,dataout,'');
    pirelab.getWireComp(aNet,valid,validout,'');
end




