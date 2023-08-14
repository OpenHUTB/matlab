function hCoreNet=getNewtonRSqrtCoreNetwork(topNet,hInSignals,newtonInfo)




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
    muxout=hCoreNet.addSignal(multmpType,'muxout');
    mulout=hCoreNet.addSignal(intermType,'mulout');
    delayout=hCoreNet.addSignal(intermType,'delayout');
    subout=hCoreNet.addSignal(intermType,'subout');
    shiftout=hCoreNet.addSignal(intermType,'shiftout');
    const3=hCoreNet.addSignal(intermType,'const3');


    pireml.getDTCComp(hCoreNet,ain,amul);
    pireml.getDTCComp(hCoreNet,delayout,delaymul);
    pireml.getDTCComp(hCoreNet,shiftout,shiftmul);


    tSignalIn=[amul,delaymul,shiftmul];
    pireml.getMultiPortSwitchComp(hCoreNet,[sel,tSignalIn],muxout,1,'Zero-based contiguous');


    tSignalIn=[muxout,xin];
    pireml.getMulComp(hCoreNet,tSignalIn,mulout,rndMode,satMode,'mul');


    [clock,hClkEnb,reset]=hCoreNet.getClockBundle(xin,3,1,0);


    delayComp=pireml.getUnitDelayComp(hCoreNet,mulout,delayout,'reg',0,'');
    delayComp.connectClockBundle(clock,hClkEnb,reset);


    pireml.getConstComp(hCoreNet,const3,3);


    tSignalIn=[const3,delayout];
    pireml.getSubComp(hCoreNet,tSignalIn,subout,rndMode,satMode);


    pireml.getBitShiftComp(hCoreNet,subout,shiftout,'sra',1);


    pireml.getUnitDelayComp(hCoreNet,mulout,xout,'xout_reg');
    pireml.getUnitDelayComp(hCoreNet,ain,aout,'aout_reg');




