function bmNet=elabBetaMemoryNetwork(~,topNet,blockInfo,dataRate)




    ufix1Type=pir_ufixpt_t(1,0);
    ufix4Type=pir_ufixpt_t(4,0);
    bc1Type=pir_ufixpt_t(blockInfo.betadecmpWL,0);
    bc2Type=pir_ufixpt_t(2*blockInfo.minWL,0);
    bcVType1=pirelab.getPirVectorType(bc1Type,blockInfo.memDepth);
    bcVType2=pirelab.getPirVectorType(bc2Type,blockInfo.memDepth);


    bmNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','CheckNodeRAM',...
    'Inportnames',{'bdecomp1','bdecomp2','countlayer','enbread','bvalid',},...
    'InportTypes',[bcVType1,bcVType2,ufix4Type,ufix1Type,ufix1Type],...
    'InportRates',[dataRate,dataRate,dataRate,dataRate,dataRate],...
    'Outportnames',{'bdecomp1Out','bdecomp2Out','bvalidOut'},...
    'OutportTypes',[bcVType1,bcVType2,ufix1Type]...
    );

    beta1=bmNet.PirInputSignals(1);
    beta2=bmNet.PirInputSignals(2);
    countlayer=bmNet.PirInputSignals(3);
    enbread=bmNet.PirInputSignals(4);
    validin=bmNet.PirInputSignals(5);

    betaout1=bmNet.PirOutputSignals(1);
    betaout2=bmNet.PirOutputSignals(2);
    validout=bmNet.PirOutputSignals(3);

    pirelab.getSimpleDualPortRamComp(bmNet,[beta1,countlayer,validin,countlayer],betaout1,'CheckNodeRAM1',blockInfo.memDepth,-1,[],'','');
    pirelab.getSimpleDualPortRamComp(bmNet,[beta2,countlayer,validin,countlayer],betaout2,'CheckNodeRAM2',blockInfo.memDepth,-1,[],'','');

    pirelab.getUnitDelayComp(bmNet,enbread,validout,'valid',0);
end

