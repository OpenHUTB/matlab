function tbctlNet=elabTraceback_control(~,tbNet,blockInfo,dataRate)








    ufix1Type=pir_ufixpt_t(1,0);
    bankdepth=blockInfo.tbd;
    cntWlen=ceil(log2(bankdepth));
    cntType=pir_ufixpt_t(cntWlen,0);
    ramaddrWlen=ceil(log2(3*bankdepth));
    ramaddrType=pir_ufixpt_t(ramaddrWlen,0);


    tbctlNet=pirelab.createNewNetwork(...
    'Network',tbNet,...
    'Name','Traceback_control',...
    'OutportNames',{'wr_addr','tb_addr','bwd_addr','reachTbd'},...
    'OutportTypes',[ramaddrType,ramaddrType,cntType,ufix1Type]);



    wr_addr=tbctlNet.PirOutputSignals(1);
    tb_addr=tbctlNet.PirOutputSignals(2);
    bwd_addr=tbctlNet.PirOutputSignals(3);
    reachTbd=tbctlNet.PirOutputSignals(4);




    cntout=tbctlNet.addSignal(cntType,'cntout');
    comp=pirelab.getCounterLimitedComp(tbctlNet,cntout,bankdepth-1);
    comp.addComment('Address Counter');
    cntout.SimulinkRate=dataRate;

    ufix2Type=pir_ufixpt_t(2,0);
    wpt=tbctlNet.addSignal(ufix2Type,'wpt');
    tbpt=tbctlNet.addSignal(ufix2Type,'tbpt');
    negdirShift=tbctlNet.addSignal(ufix1Type,'negdirShift');
    reachBankNo=tbctlNet.addSignal(ufix1Type,'reachBankNo');
    wptaddout=tbctlNet.addSignal(ufix2Type,'wptaddout');
    const0=tbctlNet.addSignal(ufix2Type,'const0');
    const1=tbctlNet.addSignal(ufix2Type,'const1');
    const2=tbctlNet.addSignal(ufix2Type,'const2');
    const3=tbctlNet.addSignal(ufix2Type,'const3');
    swtout=tbctlNet.addSignal(ufix2Type,'swtout');

    c0=pirelab.getConstComp(tbctlNet,const0,0,'const0');
    c1=pirelab.getConstComp(tbctlNet,const1,1,'const1');
    c2=pirelab.getConstComp(tbctlNet,const2,2,'const2');
    c3=pirelab.getConstComp(tbctlNet,const3,3,'const3');


    comp=pirelab.getCompareToValueComp(tbctlNet,cntout,reachTbd,'>=',bankdepth-1);
    comp.addComment('Check if reach trace back depth');


    comp=pirelab.getUnitDelayEnabledComp(tbctlNet,swtout,wpt,reachTbd,'wpt',0.0,'',false);
    comp.addComment('Memory write pointer');
    pirelab.getCompareToValueComp(tbctlNet,wpt,reachBankNo,'>=',2);
    pirelab.getAddComp(tbctlNet,[const1,wpt],wptaddout,'Floor','Wrap');
    pirelab.getSwitchComp(tbctlNet,[const0,wptaddout],swtout,reachBankNo,'','~=',0);


    dsdelayenb=tbctlNet.addSignal(ufix1Type,'dsdelayenb');
    dsdelayout=tbctlNet.addSignal(ufix1Type,'dsdelayout');
    dsdelayout.SimulinkRate=dataRate;

    pirelab.getLogicComp(tbctlNet,[reachBankNo,reachTbd],dsdelayenb,'and');
    pirelab.getUnitDelayEnabledComp(tbctlNet,negdirShift,dsdelayout,dsdelayenb,'',0.0,'',false);
    comp=pirelab.getLogicComp(tbctlNet,dsdelayout,negdirShift,'not');
    comp.addComment('Memory write direction control');


    ufix3Type=pir_ufixpt_t(3,0);
    tbptaddout=tbctlNet.addSignal(ufix3Type,'tbptaddout');
    tbptsubout=tbctlNet.addSignal(ufix3Type,'tbptsubout');
    tbptswtsel=tbctlNet.addSignal(ufix1Type,'tbptswtsel');

    pirelab.getAddComp(tbctlNet,[const2,wpt],tbptaddout,'Floor','Wrap');
    pirelab.getSubComp(tbctlNet,[tbptaddout,const3],tbptsubout,'Floor','Wrap');
    pirelab.getCompareToValueComp(tbctlNet,tbptaddout,tbptswtsel,'<',3);
    comp=pirelab.getSwitchComp(tbctlNet,[tbptaddout,tbptsubout],tbpt,tbptswtsel,'','~=',0);
    comp.addComment('Memory read pointer');



    tbdWlen=ceil(log2(bankdepth+1));
    dtbdWlen=ceil(log2(2*bankdepth+1));
    tbdType=pir_ufixpt_t(tbdWlen,0);
    dtbdType=pir_ufixpt_t(dtbdWlen,0);

    constTbdminus1=tbctlNet.addSignal(cntType,'constTbdminus1');
    constTbd=tbctlNet.addSignal(tbdType,'constTbd');
    constdTbd=tbctlNet.addSignal(dtbdType,'constdtbd');

    pirelab.getConstComp(tbctlNet,constTbdminus1,bankdepth-1,'constTbdminus1');
    pirelab.getConstComp(tbctlNet,constTbd,bankdepth,'constTbd');
    pirelab.getConstComp(tbctlNet,constdTbd,2*bankdepth,'constdTbd');


    comp=pirelab.getSubComp(tbctlNet,[constTbdminus1,cntout],bwd_addr,'Floor','Wrap');
    comp.addComment('Reverse Address');


    wr_addr_base=tbctlNet.addSignal(cntType,'wr_addr_base');
    pirelab.getSwitchComp(tbctlNet,[cntout,bwd_addr],wr_addr_base,negdirShift,'','~=',0);

    wr_addr_adjust=tbctlNet.addSignal(dtbdType,'wr_addr_adjust');
    pirelab.getMultiPortSwitchComp(tbctlNet,[wpt,const0,constTbd,constdTbd],wr_addr_adjust,1,1,'Floor','Wrap');

    comp=pirelab.getAddComp(tbctlNet,[wr_addr_base,wr_addr_adjust],wr_addr,'Floor','Wrap');
    comp.addComment('RAM write address');


    ptcmp=tbctlNet.addSignal(ufix1Type,'ptcmp');
    tbaddrSel=tbctlNet.addSignal(ufix1Type,'tbaddrSel');
    tb_addr_base=tbctlNet.addSignal(cntType,'tb_addr_base');
    tb_addr_adjust=tbctlNet.addSignal(dtbdType,'tb_addr_adjust');

    pirelab.getRelOpComp(tbctlNet,[wpt,tbpt],ptcmp,'<=');
    pirelab.getLogicComp(tbctlNet,[ptcmp,negdirShift],tbaddrSel,'nxor');
    pirelab.getSwitchComp(tbctlNet,[cntout,bwd_addr],tb_addr_base,tbaddrSel,'','~=',0);
    pirelab.getMultiPortSwitchComp(tbctlNet,[tbpt,const0,constTbd,constdTbd],tb_addr_adjust,1,1,'Floor','Wrap');

    comp=pirelab.getAddComp(tbctlNet,[tb_addr_base,tb_addr_adjust],tb_addr,'Floor','Wrap');
    comp.addComment('RAM read address');



