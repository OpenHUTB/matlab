function elaborateTurboDecoder(this,topNet,blockInfo,insignals,outsignals)















    boolType=pir_boolean_t();
    addrType=blockInfo.dataRAMaddrType;
    dataType=blockInfo.dataType;
    alphaRAMaddrType=blockInfo.alphaRAMaddrType;
    extrinType=blockInfo.extrinType;




    dataIn=insignals(1);
    inRate=dataIn.SimulinkRate;

    startIn=insignals(2);
    endIn=insignals(3);
    validIn=insignals(4);



    dataOut=outsignals(1);
    startOut=outsignals(2);
    endOut=outsignals(3);
    validOut=outsignals(4);




    dataIn_reg=topNet.addSignal(dataIn.Type,'dataIn_reg');
    startIn_reg=topNet.addSignal(boolType,'startIn_reg');
    endIn_reg=topNet.addSignal(boolType,'endIn_reg');
    validIn_reg=topNet.addSignal(boolType,'validIn_reg');


    pirelab.getUnitDelayComp(topNet,dataIn,dataIn_reg);
    comp=pirelab.getUnitDelayComp(topNet,startIn,startIn_reg);
    comp.addComment('Input registers');
    pirelab.getUnitDelayComp(topNet,endIn,endIn_reg);
    pirelab.getUnitDelayComp(topNet,validIn,validIn_reg);




    bLen=topNet.addSignal(addrType,'bLen');
    bLen_ext=topNet.addSignal(addrType,'bLen_ext');

    if blockInfo.sizefromPort
        blkLen=insignals(5);
        bLenenb=topNet.addSignal(boolType,'bLenenb');
        blkLenDTC=topNet.addSignal(addrType,'bLenDTC');

        pirelab.getDTCComp(topNet,blkLen,blkLenDTC);

        pirelab.getLogicComp(topNet,[startIn,validIn],bLenenb,'and');

        comp=pirelab.getUnitDelayEnabledComp(topNet,blkLenDTC,bLen,bLenenb,'blkSize_register',6144);
        comp.addComment('Buffer block size from port and create extended block size signal');



        upperbits=topNet.addSignal(addrType,'upperbit');
        lowerbits=topNet.addSignal(pir_ufixpt_t(5,0),'lowerbits');

        upperplusone=topNet.addSignal(addrType,'upperplusone');
        shiftedbLen=topNet.addSignal(addrType,'shiftedbLen');
        selectedbLen=topNet.addSignal(addrType,'selectedbLen');



        pirelab.getBitShiftComp(topNet,bLen,upperbits,'srl',5);
        pirelab.getBitSliceComp(topNet,bLen,lowerbits,4,0);

        constOne=topNet.addSignal(boolType,'constOne');
        pirelab.getConstComp(topNet,constOne,true);

        pirelab.getAddComp(topNet,[upperbits,constOne],upperplusone);
        pirelab.getBitShiftComp(topNet,upperplusone,shiftedbLen,'sll',5);

        bLensel=topNet.addSignal(boolType,'bLenSel');



        pirelab.getCompareToValueComp(topNet,lowerbits,bLensel,'~=',0);
        pirelab.getSwitchComp(topNet,[shiftedbLen,bLen],selectedbLen,bLensel,'','==',1);
        pirelab.getUnitDelayComp(topNet,selectedbLen,bLen_ext);


    else

        comp=pirelab.getConstComp(topNet,bLen,blockInfo.blockLen);
        comp.addComment('Create bolck size and extended block size signals');
        pirelab.getConstComp(topNet,bLen_ext,blockInfo.blockLen_ext);

    end



    ori_addr=topNet.addSignal(addrType,'ori_addr_sys');
    r_addr=topNet.addSignal(addrType,'r_addr_sys');
    itlv_start=topNet.addSignal(boolType,'intlver_start');
    BB_Dr=topNet.addSignal(boolType,'BiBuffer_Dir');
    BB_Sc=topNet.addSignal(boolType,'BiBuffer_Src');
    BB_En=topNet.addSignal(boolType,'BiBuffer_En');
    Buffer_id=topNet.addSignal(boolType,'Buffer_ID');
    betaA_En=topNet.addSignal(boolType,'betaA_En');
    betaB_En=topNet.addSignal(boolType,'betaB_En');
    alpha_En=topNet.addSignal(boolType,'alpha_En');
    extrinsic_En=topNet.addSignal(boolType,'extrinsic_En');
    decoder_id=topNet.addSignal(boolType,'decoder_ID');
    aprior_Src=topNet.addSignal(boolType,'aprior_Src');
    addr_Src=topNet.addSignal(boolType,'addr_Src');
    output_start=topNet.addSignal(boolType,'output_start');

    alpha_raddr=topNet.addSignal(alphaRAMaddrType,'alpha_raddr');
    alpha_waddr=topNet.addSignal(alphaRAMaddrType,'alpha_waddr');

    dataSource=topNet.addSignal(boolType,'dataSource');
    w_en=topNet.addSignal(boolType,'w_en');
    w_addr=topNet.addSignal(addrType,'w_addr');

    ramout_Sel=topNet.addSignal(boolType,'ramout_Sel');

    ctrlNet=this.elabControllers(topNet,blockInfo,inRate);
    ctrlNet.addComment('Turbo Decoder Controllers');
    inports=[startIn_reg,endIn_reg,validIn_reg,bLen,bLen_ext];
    outports=[ori_addr,itlv_start,BB_Dr,BB_Sc,BB_En,Buffer_id,...
    betaA_En,betaB_En,alpha_En,extrinsic_En,...
    decoder_id,aprior_Src,alpha_raddr,alpha_waddr,addr_Src,output_start,dataSource,w_en,w_addr,ramout_Sel];

    pirelab.instantiateNetwork(topNet,ctrlNet,inports,outports,'ctrlNet_inst');


    itlv_addr=topNet.addSignal(addrType,'itlv_addr');
    itlvNet=this.elabItlvAddr(topNet,blockInfo,inRate);
    itlvNet.addComment('Iterleaver Address');
    pirelab.instantiateNetwork(topNet,itlvNet,[itlv_start,bLen,bLen_ext],itlv_addr,'itlvNet_inst');



    llr_sys_ramout=topNet.addSignal(dataType,'llr_sys_ramout');
    llr_prcA_ramout=topNet.addSignal(dataType,'llr_prcA_ramout');
    llr_prcB_ramout=topNet.addSignal(dataType,'llr_prcB_ramout');
    llr_ini=topNet.addSignal(dataType,'llr_ini');

    llr_sys=topNet.addSignal(dataType,'llr_sys');
    llr_prcA=topNet.addSignal(dataType,'llr_prcA');
    llr_prcB=topNet.addSignal(dataType,'llr_prcB');

    pirelab.getConstComp(topNet,llr_ini,0);
    pirelab.getSwitchComp(topNet,[llr_sys_ramout,llr_ini],llr_sys,ramout_Sel,'','==',1);
    pirelab.getSwitchComp(topNet,[llr_prcA_ramout,llr_ini],llr_prcA,ramout_Sel,'','==',1);
    pirelab.getSwitchComp(topNet,[llr_prcB_ramout,llr_ini],llr_prcB,ramout_Sel,'','==',1);

    dramNet=this.elabDataRAM(topNet,blockInfo,inRate);
    dramNet.addComment('Data RAM Group');


    r_addr_prc=topNet.addSignal(addrType,'r_addr_prc');
    r_addr_sys=topNet.addSignal(addrType,'r_addr_sys');

    pirelab.getSwitchComp(topNet,[itlv_addr,ori_addr],r_addr,addr_Src,'','==',1);

    pirelab.getIntDelayComp(topNet,r_addr,r_addr_sys,2,'r_addr_prc_register',0);


    pirelab.getIntDelayComp(topNet,ori_addr,r_addr_prc,2,'r_addr_prc_register',0);

    draminports=[dataIn_reg,dataSource,w_addr,w_en,r_addr_sys,r_addr_prc,bLen];
    dramoutports=[llr_sys_ramout,llr_prcA_ramout,llr_prcB_ramout];
    pirelab.instantiateNetwork(topNet,dramNet,draminports,dramoutports,'dramNet_inst');





    BB_Dr_delay=topNet.addSignal(boolType,'BiBuffer_Dir_delay');
    BB_Sc_delay=topNet.addSignal(boolType,'BiBuffer_Src_delay');
    BB_En_delay=topNet.addSignal(boolType,'BiBuffer_En_delay');
    Buffer_id_delay=topNet.addSignal(boolType,'Buffer_ID_delay');
    betaA_En_delay=topNet.addSignal(boolType,'betaA_En_delay');
    betaB_En_delay=topNet.addSignal(boolType,'betaB_En_delay');
    alpha_En_delay=topNet.addSignal(boolType,'alpha_En_delay');
    extrinsic_En_delay=topNet.addSignal(boolType,'extrinsic_En_delay');
    decoder_id_delay=topNet.addSignal(boolType,'decoder_ID_delay');
    aprior_Src_delay=topNet.addSignal(boolType,'aprior_Src_delay');

    pdelay=4;
    comp=pirelab.getIntDelayComp(topNet,BB_Dr,BB_Dr_delay,pdelay);
    comp.addComment('Control signal pipeline registers');
    pirelab.getIntDelayComp(topNet,BB_Sc,BB_Sc_delay,pdelay);
    pirelab.getIntDelayComp(topNet,BB_En,BB_En_delay,pdelay);
    pirelab.getIntDelayComp(topNet,Buffer_id,Buffer_id_delay,pdelay);
    pirelab.getIntDelayComp(topNet,betaA_En,betaA_En_delay,pdelay);
    pirelab.getIntDelayComp(topNet,betaB_En,betaB_En_delay,pdelay);
    pirelab.getIntDelayComp(topNet,alpha_En,alpha_En_delay,pdelay);
    pirelab.getIntDelayComp(topNet,extrinsic_En,extrinsic_En_delay,pdelay);
    pirelab.getIntDelayComp(topNet,decoder_id,decoder_id_delay,pdelay);
    pirelab.getIntDelayComp(topNet,aprior_Src,aprior_Src_delay,pdelay);

    llr_prc=topNet.addSignal(dataType,'llr_prc');
    prc=topNet.addSignal(extrinType,'prc');
    extrinsic=topNet.addSignal(extrinType,'extrinsic');
    decision=topNet.addSignal(boolType,'extrinsic');

    llr_apriori=topNet.addSignal(extrinType,'llr_apriori');
    extrininfo=topNet.addSignal(extrinType,'extrininfo');
    apriori_ini=topNet.addSignal(extrinType,'apriori_ini');
    llr_sys_dtc=topNet.addSignal(extrinType,'llr_sys_dtc');


    pirelab.getConstComp(topNet,apriori_ini,0);
    pirelab.getSwitchComp(topNet,[extrininfo,apriori_ini],llr_apriori,aprior_Src_delay,'','==',1);

    pirelab.getSwitchComp(topNet,[llr_prcB,llr_prcA],llr_prc,decoder_id_delay,'','==',1);
    pirelab.getDTCComp(topNet,llr_prc,prc);
    pirelab.getDTCComp(topNet,llr_sys,llr_sys_dtc);



    dcNet=this.elabDecoderCore(topNet,blockInfo,inRate);
    dcNet.addComment('Turbo Decoder Core');
    dcinports=[prc,llr_sys_dtc,llr_apriori,BB_Dr_delay,BB_Sc_delay,BB_En_delay,Buffer_id_delay,...
    betaA_En_delay,betaB_En_delay,alpha_En_delay,extrinsic_En_delay,...
    alpha_raddr,alpha_waddr];
    dcoutports=[extrinsic,decision];

    pirelab.instantiateNetwork(topNet,dcNet,dcinports,dcoutports,'dcNet_inst');



    decoded=topNet.addSignal(boolType,'decoded');
    startO=topNet.addSignal(boolType,'startO');
    endO=topNet.addSignal(boolType,'endO');
    validO=topNet.addSignal(boolType,'validO');


    ocNet=this.elabOutputControl(topNet,blockInfo,inRate);
    ocNet.addComment('Turbo Decoder Output Control');
    ocinports=[extrinsic,decision,r_addr_sys,extrinsic_En_delay,output_start,bLen];

    ocoutports=[extrininfo,decoded,startO,endO,validO];

    pirelab.instantiateNetwork(topNet,ocNet,ocinports,ocoutports,'ocNet_inst');




    comp=pirelab.getUnitDelayComp(topNet,decoded,dataOut);
    comp.addComment('Output registers');

    pirelab.getUnitDelayComp(topNet,startO,startOut);
    pirelab.getUnitDelayComp(topNet,endO,endOut);
    pirelab.getUnitDelayComp(topNet,validO,validOut);













