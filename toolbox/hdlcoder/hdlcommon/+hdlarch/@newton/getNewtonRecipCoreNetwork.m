function hCoreNet=getNewtonRecipCoreNetwork(topNet,hInSignals,newtonInfo)




    topxin=hInSignals(1);
    topain=hInSignals(2);
    topsel=hInSignals(3);


    hCoreNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name',sprintf('%s_core',newtonInfo.networkName),...
    'InportNames',{'xin','ain','sel'},...
    'InportTypes',[topxin.Type,topain.Type,topsel.Type],...
    'InportRates',[topxin.SimulinkRate,topain.SimulinkRate,topsel.SimulinkRate],...
    'OutportNames',{'xout','aout'},...
    'OutportTypes',[topxin.Type,topain.Type]);


    xin=hCoreNet.PirInputSignals(1);
    ain=hCoreNet.PirInputSignals(2);
    sel=hCoreNet.PirInputSignals(3);
    xout=hCoreNet.PirOutputSignals(1);
    aout=hCoreNet.PirOutputSignals(2);


    pirelab.getAnnotationComp(hCoreNet,'anno',...
    'Iteration Core of the Recip Implementation using Newton Method');














    intermType=newtonInfo.intermType;

    rndMode=newtonInfo.rndMode;
    satMode=newtonInfo.satMode;


    muxout=hCoreNet.addSignal(intermType,'muxout');
    mulout=hCoreNet.addSignal(intermType,'mulout');
    delayout=hCoreNet.addSignal(intermType,'delayout');
    const2=hCoreNet.addSignal(intermType,'const2');
    const2.SimulinkRate=xin.SimulinkRate;
    subout=hCoreNet.addSignal(intermType,'subout');


    tSignalIn=[ain,subout];
    pireml.getMultiPortSwitchComp(hCoreNet,[sel,tSignalIn],muxout,1,'Zero-based contiguous');


    tSignalIn=[xin,muxout];
    pireml.getMulComp(hCoreNet,tSignalIn,mulout,rndMode,satMode,'mul1');


    [clock,hClkEnb,reset]=hCoreNet.getClockBundle(xin,2,1,0);


    delayComp=pireml.getUnitDelayComp(hCoreNet,mulout,delayout,'reg');
    delayComp.connectClockBundle(clock,hClkEnb,reset);


    pireml.getConstComp(hCoreNet,const2,2);


    tSignalIn=[const2,delayout];
    pireml.getSubComp(hCoreNet,tSignalIn,subout,rndMode,satMode);


    pireml.getUnitDelayComp(hCoreNet,mulout,xout,'xout_reg');
    pireml.getUnitDelayComp(hCoreNet,ain,aout,'aout_reg');
