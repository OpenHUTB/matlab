function hCoreNet=getNewtonRecipCoreSingleRateNetwork(topNet,hInSignals,newtonInfo)




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
    'Iteration Core of the Recip Implementation using Newton Method');














    intermType=newtonInfo.intermType;

    rndMode=newtonInfo.rndMode;
    satMode=newtonInfo.satMode;


    mulout1=hCoreNet.addSignal(intermType,'mulout1');
    mulout2=hCoreNet.addSignal(intermType,'mulout2');
    mulout2.SimulinkRate=xin.SimulinkRate;
    mulout1delay=hCoreNet.addSignal(intermType,'mulout1delay');
    const2=hCoreNet.addSignal(intermType,'const2');
    const2.SimulinkRate=xin.SimulinkRate;
    subout=hCoreNet.addSignal(intermType,'subout');
    xindelay1=hCoreNet.addSignal(xin.Type,'xindelay1');


    tSignalIn=[ain,xin];
    pireml.getMulComp(hCoreNet,tSignalIn,mulout1,rndMode,satMode,'mul1');


    pireml.getUnitDelayComp(hCoreNet,mulout1,mulout1delay,'xinterm1_reg');


    tSignalIn=[subout,xindelay1];
    pireml.getMulComp(hCoreNet,tSignalIn,mulout2,rndMode,satMode,'mul2');


    pireml.getUnitDelayComp(hCoreNet,mulout2,xout,'xout_reg');


    pireml.getConstComp(hCoreNet,const2,2);


    tSignalIn=[const2,mulout1delay];
    pireml.getSubComp(hCoreNet,tSignalIn,subout,rndMode,satMode);


    pireml.getUnitDelayComp(hCoreNet,xin,xindelay1,'xindelay1_reg');


    pireml.getIntDelayComp(hCoreNet,ain,aout,2,'aout_reg');



