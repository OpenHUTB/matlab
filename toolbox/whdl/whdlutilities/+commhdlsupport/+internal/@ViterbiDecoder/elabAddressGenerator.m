function addrNet=elabAddressGenerator(~,topNet,blockInfo,dataRate)




    ufix1Type=pir_ufixpt_t(1,0);
    cntType=pir_ufixpt_t(blockInfo.cntWL,0);
    addrType=pir_ufixpt_t(blockInfo.addrWL,0);
    cntType2=pir_ufixpt_t(2,0);

    if(blockInfo.ResetPort)
        inportnames={'enb','rst'};
        inporttypes=[ufix1Type,ufix1Type];
        inportrates=[dataRate,dataRate];
    else
        inportnames={'enb'};
        inporttypes=ufix1Type;
        inportrates=dataRate;
    end

    addrNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','AddressGenerator',...
    'InportNames',inportnames,...
    'InportTypes',inporttypes,...
    'InportRates',inportrates,...
    'OutportNames',{'wradrrs','valid','tbadrrs'},...
    'OutportTypes',[addrType,ufix1Type,addrType]...
    );



    enb=addrNet.PirInputSignals(1);
    if(blockInfo.ResetPort)
        rst=addrNet.PirInputSignals(2);
    end

    out1=addrNet.PirOutputSignals(1);
    valid=addrNet.PirOutputSignals(2);
    out2=addrNet.PirOutputSignals(3);


    cnttbd=addrNet.addSignal(cntType,'cntTbd');
    negcnttbd=addrNet.addSignal(cntType,'negcntTbd');
    nxtbank=addrNet.addSignal(ufix1Type,'nxtbank');
    tmp=addrNet.addSignal(ufix1Type,'tmp');
    bankno=addrNet.addSignal(cntType2,'bankno');

    if(blockInfo.ResetPort)
        pirelab.getUnitDelayResettableComp(addrNet,enb,valid,rst,'valid out',0,'',true);
    else
        pirelab.getUnitDelayComp(addrNet,enb,valid,'valid out',0);
    end


    if(blockInfo.ResetPort)
        cntcomp1=pirelab.getCounterComp(addrNet,[rst,enb],cnttbd,'Count limited',...
        0,1,blockInfo.tbd-1,...
        true,false,true,false,...
        'counter');
    else
        cntcomp1=pirelab.getCounterComp(addrNet,enb,cnttbd,'Count limited',...
        0,1,blockInfo.tbd-1,...
        false,false,true,false,...
        'counter');
    end
    cntcomp1.addComment('counts to BankDepth tbd');
    tbdm1=addrNet.addSignal(cntType,'tbdm1');
    pirelab.getConstComp(addrNet,tbdm1,blockInfo.tbd-1,'tracebackdepth-1');
    revcount=pirelab.getSubComp(addrNet,[tbdm1,cnttbd],negcnttbd,'Floor','Wrap','reverse counter');
    revcount.addComment('reverse count from bank edge');

    pirelab.getCompareToValueComp(addrNet,cnttbd,tmp,'==',blockInfo.tbd-1);
    pirelab.getLogicComp(addrNet,[tmp,enb],nxtbank,'and','nxtbank_chnge');

    if(blockInfo.ResetPort)
        cntcomp2=pirelab.getCounterComp(addrNet,[rst,nxtbank],bankno,'Count limited',...
        0,1,2,...
        true,false,true,false,...
        'bankno');
    else
        cntcomp2=pirelab.getCounterComp(addrNet,nxtbank,bankno,'Count limited',...
        0,1,2,...
        false,false,true,false,...
        'bankno');
    end
    cntcomp2.addComment('counts to bankNo');


    wradrplus0=addrNet.addSignal(addrType,'wradroffset0');
    wradrplus1=addrNet.addSignal(addrType,'wradroffset1');
    wradrplus2=addrNet.addSignal(addrType,'wradroffset2');

    tbadrplus0=addrNet.addSignal(addrType,'tbadroffset0');
    tbadrplus1=addrNet.addSignal(addrType,'tbadroffset1');
    tbadrplus2=addrNet.addSignal(addrType,'tbadroffset2');

    pirelab.getConstComp(addrNet,wradrplus0,0,'wradroffset0');
    pirelab.getConstComp(addrNet,wradrplus1,blockInfo.tbd,'wradroffset1');
    pirelab.getConstComp(addrNet,wradrplus2,2*blockInfo.tbd,'wradroffset2');

    pirelab.getConstComp(addrNet,tbadrplus0,2*blockInfo.tbd,'tbadroffset0');
    pirelab.getConstComp(addrNet,tbadrplus1,0,'tbadroffset1');
    pirelab.getConstComp(addrNet,tbadrplus2,blockInfo.tbd,'tbadroffset2');

    wradroffset=addrNet.addSignal(addrType,'wradroffset');
    tbadroffset=addrNet.addSignal(addrType,'tbadroffset');

    muxcomp1=pirelab.getMultiPortSwitchComp(addrNet,[bankno,wradrplus0,wradrplus1,wradrplus2,wradrplus0],...
    wradroffset,1,1,'Floor','Wrap');
    muxcomp1.addComment('writeadroffset based on bank no');
    muxcomp2=pirelab.getMultiPortSwitchComp(addrNet,[bankno,tbadrplus0,tbadrplus1,tbadrplus2,tbadrplus0],...
    tbadroffset,1,1,'Floor','Wrap');
    muxcomp2.addComment('tracebackadroffset based on bank no');

    wradroffsetreg=addrNet.addSignal(addrType,'wradroffsetreg');
    tbadroffsetreg=addrNet.addSignal(addrType,'tbadroffsetreg');


    if(blockInfo.ResetPort)
        pirelab.getUnitDelayResettableComp(addrNet,wradroffset,wradroffsetreg,rst,'wradroffsetreg',0,'',true);
        pirelab.getUnitDelayResettableComp(addrNet,tbadroffset,tbadroffsetreg,rst,'tbadroffsetreg',2*blockInfo.tbd,'',true);
    else
        pirelab.getUnitDelayComp(addrNet,wradroffset,wradroffsetreg,'wradroffsetreg',0);
        pirelab.getUnitDelayComp(addrNet,tbadroffset,tbadroffsetreg,'tbadroffsetreg',2*blockInfo.tbd);
    end


    inbankno2=addrNet.addSignal(ufix1Type,'inbankno2');
    pirelab.getCompareToValueComp(addrNet,bankno,inbankno2,'==',2);
    wrdir_chng=addrNet.addSignal(ufix1Type,'wrdir_chng');
    pirelab.getLogicComp(addrNet,[nxtbank,inbankno2],wrdir_chng,'and','wrdir_change');

    inbankno0=addrNet.addSignal(ufix1Type,'inbankno0');
    pirelab.getCompareToValueComp(addrNet,bankno,inbankno0,'==',0);
    tbdir_chng=addrNet.addSignal(ufix1Type,'tbdir_chng');
    pirelab.getLogicComp(addrNet,[nxtbank,inbankno0],tbdir_chng,'and','tbdir_change');


    wrdir_reg=addrNet.addSignal(ufix1Type,'wrdir_reg');
    tbdir_reg=addrNet.addSignal(ufix1Type,'tbdir_reg');

    negwrdir=addrNet.addSignal(ufix1Type,'negwrdir');
    negtbdir=addrNet.addSignal(ufix1Type,'negtbdir');


    pirelab.getLogicComp(addrNet,wrdir_reg,negwrdir,'not');
    pirelab.getLogicComp(addrNet,tbdir_reg,negtbdir,'not');

    if(blockInfo.ResetPort)
        pirelab.getUnitDelayEnabledResettableComp(addrNet,negwrdir,wrdir_reg,wrdir_chng,rst,...
        'write direction reg',1,'',1);
        pirelab.getUnitDelayEnabledResettableComp(addrNet,negtbdir,tbdir_reg,tbdir_chng,rst,...
        'traceback direction reg',1,'',1);
    else
        pirelab.getUnitDelayEnabledComp(addrNet,negwrdir,wrdir_reg,wrdir_chng,'write direction registing',1);
        pirelab.getUnitDelayEnabledComp(addrNet,negtbdir,tbdir_reg,tbdir_chng,'traceback direction registing',1);
    end


    wrcnt=addrNet.addSignal(cntType,'wrcnt');
    tbcnt=addrNet.addSignal(cntType,'tbcnt');

    wrcntreg=addrNet.addSignal(cntType,'wrcntreg');
    tbcntreg=addrNet.addSignal(cntType,'tbcntreg');


    pirelab.getSwitchComp(addrNet,[cnttbd,negcnttbd],wrcnt,wrdir_reg,'wr adrs Sel Comp','==',1);
    pirelab.getSwitchComp(addrNet,[cnttbd,negcnttbd],tbcnt,tbdir_reg,'tb adrs Sel Comp','==',1);

    if(blockInfo.ResetPort)
        pirelab.getUnitDelayResettableComp(addrNet,wrcnt,wrcntreg,rst,...
        'write direction reg',0,'',true);
        pirelab.getUnitDelayResettableComp(addrNet,tbcnt,tbcntreg,rst,...
        'traceback direction reg',0,'',true);
    else
        pirelab.getUnitDelayComp(addrNet,wrcnt,wrcntreg,'wr count reg',0);
        pirelab.getUnitDelayComp(addrNet,tbcnt,tbcntreg,'tb count reg',0);
    end


    wradrrs=pirelab.getAddComp(addrNet,[wrcntreg,wradroffsetreg],out1,'Floor','Wrap');
    wradrrs.addComment('write address');
    tbadrrs=pirelab.getAddComp(addrNet,[tbcntreg,tbadroffsetreg],out2,'Floor','Wrap');
    tbadrrs.addComment('traceback address');

end


