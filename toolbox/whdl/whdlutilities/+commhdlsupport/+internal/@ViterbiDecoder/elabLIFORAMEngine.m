function LIFONet=elabLIFORAMEngine(~,topNet,blockInfo,dataRate)




    ufix1Type=pir_ufixpt_t(1,0);
    cntType=pir_ufixpt_t(blockInfo.cntWL,0);
    if(~blockInfo.ResetPort)
        inportnames={'data','enb'};
        inporttypes=[ufix1Type,ufix1Type];
        inportrates=[dataRate,dataRate];
    else
        inportnames={'data','enb','rst'};
        inporttypes=[ufix1Type,ufix1Type,ufix1Type];
        inportrates=[dataRate,dataRate,dataRate];
    end

    LIFONet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','LIFORAMEngine',...
    'InportNames',inportnames,...
    'InportTypes',inporttypes,...
    'InportRates',inportrates,...
    'OutportNames',{'decoded','valid'},...
    'OutportTypes',[ufix1Type,ufix1Type]...
    );


    data=LIFONet.PirInputSignals(1);
    enb=LIFONet.PirInputSignals(2);
    if(blockInfo.ResetPort)
        rst=LIFONet.PirInputSignals(3);
    end
    decoded=LIFONet.PirOutputSignals(1);
    valid=LIFONet.PirOutputSignals(2);



    cnttbd=LIFONet.addSignal(cntType,'cntTbd');
    cnttbd.addComment('Forward counter');
    negcnttbd=LIFONet.addSignal(cntType,'negcntTbd');
    negcnttbd.addComment('Reverse counter');

    toggle=LIFONet.addSignal(ufix1Type,'toggle');
    toggle.addComment('Enable for pointer direction change');


    negwrdir=LIFONet.addSignal(ufix1Type,'negwrdir');
    dir_chng_enb=LIFONet.addSignal(ufix1Type,'dir_chng_enb');
    dir_reg=LIFONet.addSignal(ufix1Type,'dir_reg');


    rwAddrs=LIFONet.addSignal(cntType,'rwAddrs');
    rwAddrs.addComment('read and write address');


    decodedreg=LIFONet.addSignal(ufix1Type,'decodedreg');
    validenbreg=LIFONet.addSignal(ufix1Type,'validenbreg');
    validenb=LIFONet.addSignal(ufix1Type,'validenb');
    validd=LIFONet.addSignal(ufix1Type,'validd');



    if(blockInfo.ResetPort)
        cntcomp1=pirelab.getCounterComp(LIFONet,[rst,enb],cnttbd,'Count limited',...
        0,1,blockInfo.tbd-1,...
        true,false,true,false,...
        'counter');
    else
        cntcomp1=pirelab.getCounterComp(LIFONet,enb,cnttbd,'Count limited',...
        0,1,blockInfo.tbd-1,...
        false,false,true,false,...
        'counter');
    end
    cntcomp1.addComment('counts up to BankDepth');

    tbdminus1=LIFONet.addSignal(cntType,'tbdminus1');
    pirelab.getConstComp(LIFONet,tbdminus1,blockInfo.tbd-1,'tracebackdepth-1');


    revCount=pirelab.getSubComp(LIFONet,[tbdminus1,cnttbd],negcnttbd,'Floor','Wrap','reverse counter');
    revCount.addComment('reverse count from Bankedge');


    mscomp=pirelab.getMultiPortSwitchComp(LIFONet,[dir_reg,cnttbd,negcnttbd],...
    rwAddrs,1,1,'Floor','Wrap');
    mscomp.addComment('select read write adress');


    pirelab.getLogicComp(LIFONet,dir_reg,negwrdir,'not');
    rdcomp=pirelab.getLogicComp(LIFONet,[toggle,enb],dir_chng_enb,'and');
    rdcomp.addComment('read/write direction change enable');


    pirelab.getCompareToValueComp(LIFONet,cnttbd,toggle,'==',blockInfo.tbd-1);
    if(blockInfo.ResetPort)
        pirelab.getUnitDelayEnabledResettableComp(LIFONet,negwrdir,dir_reg,dir_chng_enb,rst,...
        'dir_reg',0);
    else
        pirelab.getUnitDelayEnabledComp(LIFONet,negwrdir,dir_reg,dir_chng_enb,...
        'dir_wr_rd ',0);
    end


    ramcomp=pirelab.getSimpleDualPortRamComp(LIFONet,[data,rwAddrs,enb,rwAddrs],...
    decodedreg,'lifo out',1,0);
    ramcomp.addComment('simple dualport RAM');


    pirelab.getUnitDelayComp(LIFONet,decodedreg,decoded,'decodedout',0);


    pirelab.getLogicComp(LIFONet,[enb,toggle],validenb,'and');

    if(blockInfo.ResetPort)
        pirelab.getUnitDelayEnabledResettableComp(LIFONet,enb,validenbreg,validenb,rst,...
        'validenbreg',0);
    else
        pirelab.getUnitDelayEnabledComp(LIFONet,enb,validenbreg,validenb,...
        'validenbreg',0);
    end
    pirelab.getLogicComp(LIFONet,[enb,validenbreg],validd,'and');


    if(blockInfo.ResetPort)
        high=LIFONet.addSignal(ufix1Type,'high');
        pirelab.getConstComp(LIFONet,high,1,'true');

        pirelab.getIntDelayEnabledResettableComp(LIFONet,validd,valid,high,rst,2,'validenbreg',0);
    else
        pirelab.getIntDelayComp(LIFONet,validd,valid,2,'validenbreg',0);
    end
end


