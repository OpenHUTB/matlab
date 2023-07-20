function hPIVNet=getNewtonPolynomialIVNetwork(topNet,hInSignals,hOutSignals,newtonInfo)




    topain=hInSignals(1);
    topsel=hInSignals(2);
    topxinit=hOutSignals(1);
    topinzero=hOutSignals(2);


    hPIVNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name',sprintf('%s_iv',newtonInfo.networkName),...
    'InportNames',{'ain','sel'},...
    'InportTypes',[topain.Type,topsel.Type],...
    'InportRates',[topain.SimulinkRate,topsel.SimulinkRate],...
    'OutportNames',{'xinit','inzero'},...
    'OutportTypes',[topxinit.Type,topinzero.Type]);


    ain=hPIVNet.PirInputSignals(1);
    sel=hPIVNet.PirInputSignals(2);
    xinit=hPIVNet.PirOutputSignals(1);
    inzero=hPIVNet.PirOutputSignals(2);


    pirelab.getAnnotationComp(hPIVNet,'anno',...
    'Polynomial initial value stage of the RecipSqrt Implementation using Newton Method');


    intermType=newtonInfo.intermType;
    normType=ain.Type;
    ufix2Type=pir_ufixpt_t(2,0);

    rndMode=newtonInfo.rndMode;
    satMode='Wrap';









    intermWL=intermType.WordLength;
    constAType=pir_sfixpt_t(intermWL,-(intermWL-2));
    constBType=pir_sfixpt_t(intermWL,-(intermWL-3));

    constAval=pirelab.getTypeInfoAsFi(constAType,'Nearest','Wrap',1.59320045511401);
    constBval=pirelab.getTypeInfoAsFi(constBType,'Nearest','Wrap',3.18258902474452);
    constCval=pirelab.getTypeInfoAsFi(constBType,'Nearest','Wrap',2.62566612941744);








    constBcast=pirelab.getTypeInfoAsFi(intermType,rndMode,satMode,constBval);
    constCcast=pirelab.getTypeInfoAsFi(intermType,rndMode,satMode,constCval);


    constBneg=pirelab.getTypeInfoAsFi(intermType,rndMode,satMode,-constBcast);



    multmpType=pir_sfixpt_t(intermWL+2,constAType.FractionLength);


    constAcast=pirelab.getTypeInfoAsFi(multmpType,rndMode,satMode,constAval);


    delaymul=hPIVNet.addSignal(multmpType,'delaymul');
    mmuxout=hPIVNet.addSignal(multmpType,'mmuxout');
    mulout=hPIVNet.addSignal(intermType,'mulout');
    sumout=hPIVNet.addSignal(intermType,'sumout');
    smuxout=hPIVNet.addSignal(intermType,'mmuxout');
    delayout=hPIVNet.addSignal(intermType,'delayout');
    constA=hPIVNet.addSignal(multmpType,'constA');
    constB=hPIVNet.addSignal(intermType,'constB');
    constC=hPIVNet.addSignal(intermType,'constC');


    pireml.getConstComp(hPIVNet,constA,constAcast);
    pireml.getConstComp(hPIVNet,constB,constBneg);
    pireml.getConstComp(hPIVNet,constC,constCcast);


    pireml.getDTCComp(hPIVNet,delayout,delaymul);


    tSignalIn=[delaymul,constA];
    pireml.getSwitchComp(hPIVNet,[sel,tSignalIn],mmuxout);


    tSignalIn=[mmuxout,ain];
    pireml.getMulComp(hPIVNet,tSignalIn,mulout,rndMode,satMode,'mul');


    tSignalIn=[constC,constB];
    pireml.getSwitchComp(hPIVNet,[sel,tSignalIn],smuxout);


    tSignalIn=[mulout,smuxout];
    pireml.getAddComp(hPIVNet,tSignalIn,sumout,rndMode,satMode);


    [clock,hClkEnb,reset]=hPIVNet.getClockBundle(ain,3,1,0);


    delayComp=pireml.getUnitDelayComp(hPIVNet,sumout,delayout,'reg',0,'');
    delayComp.connectClockBundle(clock,hClkEnb,reset);


    pireml.getUnitDelayComp(hPIVNet,delayout,xinit,'xinit_reg');


    mstwobit=hPIVNet.addSignal(ufix2Type,'mstwobit');
    normWL=normType.WordLength;
    pireml.getBitSliceComp(hPIVNet,ain,mstwobit,normWL-1,normWL-2);
    pireml.getCompareToValueComp(hPIVNet,mstwobit,inzero,'==',0);



