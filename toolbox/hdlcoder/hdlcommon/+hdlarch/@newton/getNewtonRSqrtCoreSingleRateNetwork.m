function hCoreNet=getNewtonRSqrtCoreSingleRateNetwork(topNet,hInSignals,newtonInfo)




    topxin=hInSignals(1);
    topain=hInSignals(2);



    hCoreNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name',sprintf('%s_core',newtonInfo.networkName),...
    'InportNames',{'xin','ain'},...
    'InportTypes',[topxin.Type,topain.Type],...
    'InportRates',[topxin.SimulinkRate,topain.SimulinkRate],...
    'OutportNames',{'xout','aout'},...
    'OutportTypes',[topxin.Type,topain.Type]);


    xin=hCoreNet.PirInputSignals(1);
    ain=hCoreNet.PirInputSignals(2);
    xout=hCoreNet.PirOutputSignals(1);
    aout=hCoreNet.PirOutputSignals(2);


    pirelab.getAnnotationComp(hCoreNet,'anno',...
    'Iteration Core of the RecipSqrt Implementation using Newton Method');















    intermType=xin.Type;

    rndMode=newtonInfo.rndMode;
    satMode='Wrap';



    normType=newtonInfo.normType;
    normFL=-normType.FractionLength;
    intermFL=-intermType.FractionLength;
    multmpFL=max(normFL,intermFL);
    multmpWL=multmpFL+4;
    multmpType=pir_sfixpt_t(multmpWL,-multmpFL);


    amul=hCoreNet.addSignal(multmpType,'amul');
    delaymul=hCoreNet.addSignal(multmpType,'delaymul');
    shiftmul=hCoreNet.addSignal(multmpType,'shiftmul');
    mulout1=hCoreNet.addSignal(intermType,'mulout1');
    mulout2=hCoreNet.addSignal(intermType,'mulout2');
    mulout3=hCoreNet.addSignal(intermType,'mulout3');
    mulout1delay=hCoreNet.addSignal(intermType,'mulout1delay');
    mulout2delay=hCoreNet.addSignal(intermType,'mulout2delay');

    subout=hCoreNet.addSignal(intermType,'subout');
    shiftout=hCoreNet.addSignal(intermType,'shiftout');
    shiftout.SimulinkRate=xin.SimulinkRate;
    shiftoutdelay=hCoreNet.addSignal(intermType,'shiftoutdelay');
    const3=hCoreNet.addSignal(intermType,'const3');
    const3.SimulinkRate=xin.SimulinkRate;

    xindelay1=hCoreNet.addSignal(xin.Type,'xindelay1');
    xindelay2=hCoreNet.addSignal(xin.Type,'xindelay2');
    xindelay3=hCoreNet.addSignal(xin.Type,'xindelay3');



    pirelab.getDTCComp(hCoreNet,ain,amul);
    pirelab.getDTCComp(hCoreNet,mulout1delay,delaymul);
    pirelab.getDTCComp(hCoreNet,shiftoutdelay,shiftmul);



    tSignalIn=[amul,xin];
    pirelab.getMulComp(hCoreNet,tSignalIn,mulout1,rndMode,satMode,'mul1');


    pirelab.getUnitDelayComp(hCoreNet,mulout1,mulout1delay,'xinterm1_reg');


    tSignalIn=[delaymul,xindelay1];
    pirelab.getMulComp(hCoreNet,tSignalIn,mulout2,rndMode,satMode,'mul2');


    pirelab.getUnitDelayComp(hCoreNet,mulout2,mulout2delay,'xinterm2_reg');


    pirelab.getConstComp(hCoreNet,const3,3);


    tSignalIn=[const3,mulout2delay];
    pirelab.getSubComp(hCoreNet,tSignalIn,subout,rndMode,satMode);


    pirelab.getBitShiftComp(hCoreNet,subout,shiftout,'sra',1);


    pirelab.getUnitDelayComp(hCoreNet,shiftout,shiftoutdelay,'xinterm3_reg');


    tSignalIn=[shiftmul,xindelay3];
    pirelab.getMulComp(hCoreNet,tSignalIn,mulout3,rndMode,satMode,'mul2');


    pirelab.getUnitDelayComp(hCoreNet,xin,xindelay1,'xindelay1_reg');
    pirelab.getUnitDelayComp(hCoreNet,xindelay1,xindelay2,'xindelay2_reg');
    pirelab.getUnitDelayComp(hCoreNet,xindelay2,xindelay3,'xindelay3_reg');


    pirelab.getUnitDelayComp(hCoreNet,mulout3,xout,'xout_reg');
    pirelab.getIntDelayComp(hCoreNet,ain,aout,4,'aout_reg');


