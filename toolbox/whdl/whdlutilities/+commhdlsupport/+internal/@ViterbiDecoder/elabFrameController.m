function fcNet=elabFrameController(~,topNet,blockInfo,dataRate)




    ufix1Type=pir_ufixpt_t(1,0);
    bufflen=4*blockInfo.tbd;


    fcNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','FrameController',...
    'Inportnames',{'startIn','endIn','validIn'},...
    'Inporttypes',[ufix1Type,ufix1Type,ufix1Type],...
    'InportRates',[dataRate,dataRate,dataRate],...
    'Outportnames',{'startOut','endOut','validOut','startFlag',...
    'frameGapInd','enbProcess'},...
    'OutportTypes',[ufix1Type,ufix1Type,ufix1Type,ufix1Type,...
    ufix1Type,ufix1Type]...
    );


    startin=fcNet.PirInputSignals(1);
    endin=fcNet.PirInputSignals(2);
    validin=fcNet.PirInputSignals(3);

    startout=fcNet.PirOutputSignals(1);
    endout=fcNet.PirOutputSignals(2);
    validout=fcNet.PirOutputSignals(3);
    startflagreg=fcNet.PirOutputSignals(4);
    framegapvalidReg=fcNet.PirOutputSignals(5);
    enbprocess=fcNet.PirOutputSignals(6);

    startflag=fcNet.addSignal(ufix1Type,'startflag');
    lcomp=pirelab.getLogicComp(fcNet,[startin,validin],startflag,'and');
    lcomp.addComment('Indicates the start of frame signal');


    scomp=pirelab.getUnitDelayComp(fcNet,startflag,startflagreg,'startvalid_reg',0);
    scomp.addComment('Delayed the statin flag');

    enbreg=fcNet.addSignal(ufix1Type,'enbReg');
    processstart=fcNet.addSignal(ufix1Type,'processStart');
    pcomp=pirelab.getLogicComp(fcNet,[startflag,enbreg],processstart,'or');
    pcomp.addComment('process start is the flag used for enable operations');

    ecomp=pirelab.getUnitDelayComp(fcNet,processstart,enbreg,'enbReg',0);
    ecomp.addComment('Delayed the processstart');


    enbframendop=fcNet.addSignal(ufix1Type,'enbFramEndOp');
    enbframendin=fcNet.addSignal(ufix1Type,'enbFramEndIn');
    efcomp=pirelab.getLogicComp(fcNet,[enbframendop,endin],enbframendin,'or');
    efcomp.addComment('Enable between Frame endin and next frame startin');

    startinv=fcNet.addSignal(ufix1Type,'startInv');
    pirelab.getLogicComp(fcNet,startin,startinv,'not');

    enbframendopint=fcNet.addSignal(ufix1Type,'enbFramEndOpInt');
    pirelab.getLogicComp(fcNet,[startinv,enbframendin],enbframendopint,'and');

    dcomp=pirelab.getIntDelayEnabledComp(fcNet,enbframendopint,enbframendop,validin,1,'',0);
    dcomp.addComment('Dalyed for endFrameOperation flag');


    endopvalid=fcNet.addSignal(ufix1Type,'endOpValid');
    pirelab.getLogicComp(fcNet,[validin,enbframendop],endopvalid,'or');


    enbprocessint=fcNet.addSignal(ufix1Type,'enbProcessInt');
    pirelab.getLogicComp(fcNet,[endopvalid,processstart],enbprocessint,'and');

    epcomp=pirelab.getUnitDelayComp(fcNet,enbprocessint,enbprocess,'enbProcessReg',0);
    epcomp.addComment('Enable process to start processing the control buffers');

    startflaginv=fcNet.addSignal(ufix1Type,'startflagInv');
    pirelab.getLogicComp(fcNet,startflag,startflaginv,'not');

    framegapvalid=fcNet.addSignal(ufix1Type,'frameGapVldD');
    fcomp=pirelab.getLogicComp(fcNet,[startflaginv,enbframendop],framegapvalid,'and');
    fcomp.addComment('frameGapValid will be high during Frame gap && its resets BM module during this time');

    pirelab.getUnitDelayComp(fcNet,framegapvalid,framegapvalidReg,'frameGapValidReg',0);



    startoutint=fcNet.addSignal(ufix1Type,'startoutInt');
    delayComp=pirelab.getIntDelayEnabledComp(fcNet,startflag,startoutint,enbprocessint,bufflen,'startOut_register',0,0);
    delayComp.addComment('startOut register with one delay less and other delay added in enbProcess switch');

    const0=fcNet.addSignal(ufix1Type,'const0');
    pirelab.getConstComp(fcNet,const0,0);

    startoutint1=fcNet.addSignal(ufix1Type,'startoutInt1');
    selComp=pirelab.getSwitchComp(fcNet,[startoutint,const0],startoutint1,enbprocessint,'','~=',0);
    selComp.addComment('select the startOut based on enbProcess');
    syncDelay=blockInfo.ConstraintLength+13;
    sdComp=pirelab.getIntDelayComp(fcNet,startoutint1,startout,syncDelay,'startoutReg',0);
    sdComp.addComment('Synchronizing startOut with dataOut');

    enbframendopinv=fcNet.addSignal(ufix1Type,'enbFramEndOpInv');
    pirelab.getLogicComp(fcNet,enbframendop,enbframendopinv,'not');

    invstartframeend=fcNet.addSignal(ufix1Type,'invStartFrameEnd');
    pirelab.getLogicComp(fcNet,[enbframendopinv,startinv],invstartframeend,'and');

    endouttemp=fcNet.addSignal(ufix1Type,'endOutTemp');
    pirelab.getLogicComp(fcNet,[invstartframeend,endin],endouttemp,'and');

    endoutint=fcNet.addSignal(ufix1Type,'endoutInt');
    delComp=pirelab.getIntDelayEnabledComp(fcNet,endouttemp,endoutint,enbprocessint,bufflen,'endout_register',0,0);
    delComp.addComment('endOut register with one delay less and other delay added in enbProcess switch');

    endoutint1=fcNet.addSignal(ufix1Type,'endoutInt1');
    selComp=pirelab.getSwitchComp(fcNet,[endoutint,const0],endoutint1,enbprocessint,'','~=',0);
    selComp.addComment('select the endOut based on enbprocess');

    edComp=pirelab.getIntDelayComp(fcNet,endoutint1,endout,syncDelay,'endoutReg',0);
    edComp.addComment('Synchronizing endOut with dataOut');

    framegapvalidinv=fcNet.addSignal(ufix1Type,'frameGapValidInv');
    pirelab.getLogicComp(fcNet,framegapvalid,framegapvalidinv,'not');

    validouttemp=fcNet.addSignal(ufix1Type,'validOutTemp');
    pirelab.getLogicComp(fcNet,[framegapvalidinv,validin],validouttemp,'and');

    validoutint=fcNet.addSignal(ufix1Type,'validoutInt');
    delComp=pirelab.getIntDelayEnabledComp(fcNet,validouttemp,validoutint,enbprocessint,bufflen,'validout_register',0,0);
    delComp.addComment('validOut register with one delay less and other delay added in enbProcess switch');


    validoutint1=fcNet.addSignal(ufix1Type,'validoutInt1');
    selComp=pirelab.getSwitchComp(fcNet,[validoutint,const0],validoutint1,enbprocessint,'','~=',0);
    selComp.addComment('select the validOut based on enbprocess');

    vdComp=pirelab.getIntDelayComp(fcNet,validoutint1,validout,syncDelay-1,'validoutReg',0);
    vdComp.addComment('Synchronizing validOut with dataOut');
end
