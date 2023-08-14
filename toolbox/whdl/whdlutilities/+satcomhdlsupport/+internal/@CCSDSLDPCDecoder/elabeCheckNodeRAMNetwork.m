function crNet=elabeCheckNodeRAMNetwork(this,topNet,blockInfo,dataRate)



    ufix1Type=pir_boolean_t;
    bcType=pir_ufixpt_t(blockInfo.betaCompWL,0);
    bcType3=pir_ufixpt_t(blockInfo.betaIdxWL,0);
    bcType4=pir_ufixpt_t(2*blockInfo.minWL,0);
    layType=pir_ufixpt_t(blockInfo.layWL,0);
    conType=pir_ufixpt_t(blockInfo.betaIdxWL+2*blockInfo.minWL,0);
    bcVType=pirelab.getPirVectorType(bcType,blockInfo.memDepth);
    bcVType3=pirelab.getPirVectorType(bcType3,blockInfo.memDepth);
    bcVType4=pirelab.getPirVectorType(bcType4,blockInfo.memDepth);
    conVType=pirelab.getPirVectorType(conType,blockInfo.memDepth);


    crNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','CheckNodeRAM',...
    'Inportnames',{'beta1','beta2','beta3','beta4','layerIdx','endRead','valid'},...
    'InportTypes',[bcVType,bcVType,bcVType3,bcVType4,layType,ufix1Type,ufix1Type],...
    'InportRates',[dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate],...
    'Outportnames',{'betaOut1','betaOut2','betaOut3','betaOut4','valid'},...
    'OutportTypes',[bcVType,bcVType,bcVType3,bcVType4,ufix1Type]...
    );



    beta1=crNet.PirInputSignals(1);
    beta2=crNet.PirInputSignals(2);
    beta3=crNet.PirInputSignals(3);
    beta4=crNet.PirInputSignals(4);
    countlayer=crNet.PirInputSignals(5);
    enbread=crNet.PirInputSignals(6);
    validin=crNet.PirInputSignals(7);

    betaout1=crNet.PirOutputSignals(1);
    betaout2=crNet.PirOutputSignals(2);
    betaout3=crNet.PirOutputSignals(3);
    betaout4=crNet.PirOutputSignals(4);
    validout=crNet.PirOutputSignals(5);

    if blockInfo.memDepth==128
        pirelab.getWireComp(crNet,beta2,betaout2,'beta2');
    else
        pirelab.getSimpleDualPortRamComp(crNet,[beta2,countlayer,validin,countlayer],betaout2,'CheckNodeRAM2',blockInfo.memDepth,-1,[],'','',blockInfo.ramAttr_block);
    end
    pirelab.getSimpleDualPortRamComp(crNet,[beta1,countlayer,validin,countlayer],betaout1,'CheckNodeRAM1',blockInfo.memDepth,-1,[],'','',blockInfo.ramAttr_block);
    pirelab.getSimpleDualPortRamComp(crNet,[beta3,countlayer,validin,countlayer],betaout3,'CheckNodeRAM3',blockInfo.memDepth,-1,[],'','',blockInfo.ramAttr_block);
    pirelab.getSimpleDualPortRamComp(crNet,[beta4,countlayer,validin,countlayer],betaout4,'CheckNodeRAM4',blockInfo.memDepth,-1,[],'','',blockInfo.ramAttr_dist);

    pirelab.getUnitDelayComp(crNet,enbread,validout,'valid',0);

end


