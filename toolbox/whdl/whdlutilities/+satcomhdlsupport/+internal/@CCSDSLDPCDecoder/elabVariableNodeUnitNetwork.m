function vNet=elabVariableNodeUnitNetwork(this,topNet,blockInfo,dataRate)




    ufix1Type=pir_boolean_t;
    vType1=pir_sfixpt_t(blockInfo.alphaWL,blockInfo.alphaFL);
    vType2=pir_sfixpt_t(blockInfo.betaWL,blockInfo.alphaFL);

    v1Type=pirelab.getPirVectorType(vType1,blockInfo.memDepth);
    v2Type=pirelab.getPirVectorType(vType2,blockInfo.memDepth);


    vNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','VariableNodeUnit',...
    'Inportnames',{'data','beta','valid','valid_beta','reset'},...
    'InportTypes',[v1Type,v2Type,ufix1Type,ufix1Type,ufix1Type],...
    'InportRates',[dataRate,dataRate,dataRate,dataRate,dataRate],...
    'Outportnames',{'alpha','valid'},...
    'OutportTypes',[v1Type,ufix1Type]...
    );



    data=vNet.PirInputSignals(1);
    beta=vNet.PirInputSignals(2);
    valid=vNet.PirInputSignals(3);
    valid_beta=vNet.PirInputSignals(4);
    reset=vNet.PirInputSignals(5);

    dataout=vNet.PirOutputSignals(1);
    validout=vNet.PirOutputSignals(2);

    v1Type=data.Type;

    sub=vNet.addSignal(v1Type,'sub');
    datad=vNet.addSignal(v1Type,'dataD');
    dataD=vNet.addSignal(v1Type,'dataD1');

    pirelab.getUnitDelayComp(vNet,valid,validout,'',0);
    pirelab.getUnitDelayEnabledResettableComp(vNet,data,datad,valid,reset,'',0);

    pirelab.getSubComp(vNet,[datad,beta],sub,'floor','saturate','sub_Comp');
    pirelab.getSwitchComp(vNet,[sub,datad],dataD,valid_beta,'switchComp','==',1);
    pirelab.getWireComp(vNet,dataD,dataout,'');

end




