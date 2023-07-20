function cpNet=elabCodeParametersNetwork(this,topNet,blockInfo,dataRate)





    ufix1Type=pir_ufixpt_t(1,0);
    ufix3Type=pir_ufixpt_t(3,0);
    ufix6Type=pir_ufixpt_t(6,0);
    ufix8Type=pir_ufixpt_t(8,0);
    ufix9Type=pir_ufixpt_t(9,0);

    aType=pir_sfixpt_t(blockInfo.InputWL,blockInfo.InputFL);
    aVType=pirelab.getPirVectorType(aType,blockInfo.VectorSize);


    cpNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','CodeParameters',...
    'Inportnames',{'dataIn','startIn','endIn','validIn','bgn','liftsize','niter','nRow'},...
    'InportTypes',[aVType,ufix1Type,ufix1Type,ufix1Type,ufix1Type,ufix9Type,ufix8Type,ufix6Type],...
    'InportRates',[dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate],...
    'Outportnames',{'dataOut','validOut','frameValid','reset','bgn','iLS','liftsize','endInd','niter','zAddr','rstNextFrame','nRowOut'},...
    'OutportTypes',[aVType,ufix1Type,ufix1Type,ufix1Type,ufix1Type,ufix3Type,ufix9Type,ufix1Type,ufix8Type,ufix3Type,ufix1Type,ufix6Type]...
    );




    datain=cpNet.PirInputSignals(1);
    startin=cpNet.PirInputSignals(2);
    endin=cpNet.PirInputSignals(3);
    validin=cpNet.PirInputSignals(4);
    bgnin=cpNet.PirInputSignals(5);
    liftsizein=cpNet.PirInputSignals(6);
    iterin=cpNet.PirInputSignals(7);
    nrowin=cpNet.PirInputSignals(8);

    dataout=cpNet.PirOutputSignals(1);
    validout=cpNet.PirOutputSignals(2);
    framevalid=cpNet.PirOutputSignals(3);
    reset=cpNet.PirOutputSignals(4);
    bgnout=cpNet.PirOutputSignals(5);
    setindex=cpNet.PirOutputSignals(6);
    liftsizeout=cpNet.PirOutputSignals(7);
    endind=cpNet.PirOutputSignals(8);
    iterout=cpNet.PirOutputSignals(9);
    zaddr=cpNet.PirOutputSignals(10);
    nextframe=cpNet.PirOutputSignals(11);
    nrowout=cpNet.PirOutputSignals(12);

    sof_vld=cpNet.addSignal(ufix1Type,'startValid');
    pirelab.getLogicComp(cpNet,[startin,validin],sof_vld,'and');

    range_iter=cpNet.addSignal(ufix1Type,'rangeIter');
    pirelab.getCompareToValueComp(cpNet,iterin,range_iter,'>',63,'iter range');

    const8=cpNet.addSignal(iterin.Type,'const8');
    pirelab.getConstComp(cpNet,const8,8);

    iteract=cpNet.addSignal(iterin.Type,'iterAct');
    pirelab.getSwitchComp(cpNet,[iterin,const8],iteract,range_iter,'sel','==',0,'Floor','Wrap');

    pirelab.getUnitDelayEnabledComp(cpNet,iteract,iterout,sof_vld,'',8);
    invld_row=cpNet.addSignal(ufix1Type,'invalidRow');
    zenb=cpNet.addSignal(ufix1Type,'zEnb');
    nrowtmp=cpNet.addSignal(nrowin.Type,'nRowTmp');


    if blockInfo.RateCompatible
        pirelab.getUnitDelayEnabledComp(cpNet,nrowin,nrowtmp,sof_vld,'',46);
        pirelab.getUnitDelayEnabledResettableComp(cpNet,nrowtmp,nrowout,zenb,invld_row,'',46);
    else
        const46=cpNet.addSignal(ufix6Type,'const46');
        pirelab.getConstComp(cpNet,const46,46);

        const42=cpNet.addSignal(ufix6Type,'const42');
        pirelab.getConstComp(cpNet,const42,42);
        pirelab.getSwitchComp(cpNet,[const46,const42],nrowout,bgnout,'sel','==',0,'Floor','Wrap');
    end

    const1=cpNet.addSignal(ufix1Type,'const1');
    pirelab.getConstComp(cpNet,const1,1);

    const1reg=cpNet.addSignal(ufix1Type,'const1');
    pirelab.getUnitDelayComp(cpNet,const1,const1reg,'',0);

    const0=cpNet.addSignal(ufix1Type,'const0');
    pirelab.getConstComp(cpNet,const0,0);

    eof_vld=cpNet.addSignal(ufix1Type,'endValid');
    pirelab.getLogicComp(cpNet,[endin,validin],eof_vld,'and');

    svldreg=cpNet.addSignal(ufix1Type,'startValidReg');
    validz=cpNet.addSignal(ufix1Type,'validZ');

    bcomp=pirelab.getUnitDelayEnabledComp(cpNet,bgnin,bgnout,sof_vld,'bgn_sampling',0);
    bcomp.addComment('bgn Sampling');

    Z_1=cpNet.addSignal(liftsizein.Type,'ZIn');

    lcomp=pirelab.getUnitDelayEnabledComp(cpNet,liftsizein,Z_1,sof_vld,'Z_sampling',2);
    lcomp.addComment('liftingSize Sampling');

    pirelab.getUnitDelayComp(cpNet,sof_vld,zenb,'',0);

    invld_z=cpNet.addSignal(ufix1Type,'invalidZ');
    llcomp=pirelab.getUnitDelayEnabledResettableComp(cpNet,Z_1,liftsizeout,zenb,invld_z,'ZOut',2);
    llcomp.addComment('liftingSizeOut');


    iLS=cpNet.addSignal(ufix3Type,'iLS');
    zcount=cpNet.addSignal(zaddr.Type,'zCount');

    fid=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
    '+nrhdlsupport','+internal','@LDPCDecoder','cgireml','calculateSetIndex.m'),'r');
    calculateSetIndex=fread(fid,Inf,'char=>char');
    fclose(fid);

    cpNet.addComponent2(...
    'kind','cgireml',...
    'Name','calculateSetIndex',...
    'InputSignals',[Z_1,sof_vld],...
    'OutputSignals',[iLS,validz,zcount],...
    'ExternalSynchronousResetSignal','',...
    'EMLFileName','calculateSetIndex',...
    'EMLFileBody',calculateSetIndex,...
    'EMLFlag_TreatInputIntsAsFixpt',true);


    newframe=cpNet.addSignal(ufix1Type,'newFrame');
    nfreg=cpNet.addSignal(ufix1Type,'newFrameReg');
    newcount=cpNet.addSignal(ufix3Type,'newCount');
    newcntmax=cpNet.addSignal(ufix1Type,'newCountMax');

    ncomp=pirelab.getCompareToValueComp(cpNet,newcount,newcntmax,'==',6,'newCount Compare');
    ncomp.addComment('newCount comparison with value 6');

    nfcomp=pirelab.getUnitDelayEnabledResettableComp(cpNet,sof_vld,newframe,sof_vld,newcntmax,'newFrame',0);
    nfcomp.addComment('newFrame register');

    pirelab.getUnitDelayComp(cpNet,newframe,nfreg,'newFrame',0);

    rstcount=cpNet.addSignal(ufix1Type,'rstCount');
    pirelab.getLogicComp(cpNet,[sof_vld,newcntmax],rstcount,'or');

    ncomp=pirelab.getCounterComp(cpNet,[rstcount,newframe],newcount,'Count limited',0,1,6,1,0,1,0,'new Count',0);
    ncomp.addComment('newCount counter');


    delaynum=8;

    dreg=cpNet.addSignal(datain.Type,'dataReg');
    dcomp=pirelab.getIntDelayComp(cpNet,datain,dreg,delaynum,'data',0);
    dcomp.addComment('data register');

    sreg=cpNet.addSignal(ufix1Type,'startReg');
    scomp=pirelab.getIntDelayComp(cpNet,startin,sreg,delaynum,'start',0);
    scomp.addComment('start register');

    ereg=cpNet.addSignal(ufix1Type,'endReg');
    ecomp=pirelab.getIntDelayEnabledResettableComp(cpNet,endin,ereg,const1reg,sof_vld,delaynum,'end',0);
    ecomp.addComment('end register');

    vreg=cpNet.addSignal(ufix1Type,'validReg');
    vcomp=pirelab.getIntDelayComp(cpNet,validin,vreg,delaynum,'valid',0);
    vcomp.addComment('valid register');

    pirelab.getLogicComp(cpNet,[sreg,vreg],svldreg,'and');

    evldreg=cpNet.addSignal(ufix1Type,'endValidReg');
    pirelab.getLogicComp(cpNet,[ereg,vreg],evldreg,'and');

    evldregd=cpNet.addSignal(ufix1Type,'endValidRegD');
    pirelab.getUnitDelayComp(cpNet,evldreg,evldregd,'end valid',0);

    svldneg=cpNet.addSignal(ufix1Type,'startValidNeg');
    pirelab.getLogicComp(cpNet,svldreg,svldneg,'not');

    rstframe=cpNet.addSignal(ufix1Type,'rstFrame');
    pirelab.getLogicComp(cpNet,[evldregd,svldneg],rstframe,'and');

    frameD=cpNet.addSignal(ufix1Type,'frameD');
    fcomp=pirelab.getUnitDelayEnabledResettableComp(cpNet,svldreg,frameD,svldreg,rstframe,'frame',0);
    fcomp.addComment('frame register');

    frame=cpNet.addSignal(ufix1Type,'frame');
    pirelab.getLogicComp(cpNet,[frameD,svldreg],frame,'or');

    cntenb=cpNet.addSignal(ufix1Type,'cntEnb');
    pirelab.getLogicComp(cpNet,[frame,vreg],cntenb,'and');



    zero_data=cpNet.addSignal(datain.Type,'zData');
    pirelab.getConstComp(cpNet,zero_data,0);

    dataoutreg=cpNet.addSignal(datain.Type,'dataOutReg');
    dscomp=pirelab.getSwitchComp(cpNet,[dreg,zero_data],dataoutreg,nfreg,'data sel','==',0,'Floor','Wrap');
    dscomp.addComment('data selection comp');


    validoutreg=cpNet.addSignal(ufix1Type,'validOutReg');
    vscomp=pirelab.getSwitchComp(cpNet,[vreg,const0],validoutreg,nfreg,'valid sel','==',0,'Floor','Wrap');
    vscomp.addComment('valid selection comp');


    fvalidreg=cpNet.addSignal(ufix1Type,'fValidReg');
    fscomp=pirelab.getSwitchComp(cpNet,[frame,const0],fvalidreg,nfreg,'frame sel','==',0,'Floor','Wrap');
    fscomp.addComment('framevalid selection comp');


    resetreg=cpNet.addSignal(ufix1Type,'resetReg');
    pirelab.getUnitDelayComp(cpNet,sof_vld,resetreg,'reset',0);


    pirelab.getWireComp(cpNet,zcount,zaddr);


    pirelab.getWireComp(cpNet,iLS,setindex);


    endreg=cpNet.addSignal(ufix1Type,'endReg');

    endind_neg=cpNet.addSignal(ufix1Type,'endIndNeg');
    pirelab.getLogicComp(cpNet,endreg,endind_neg,'not');

    endindreg=cpNet.addSignal(ufix1Type,'endIndReg');
    pirelab.getLogicComp(cpNet,[endind_neg,evldreg],endindreg,'and');

    ecomp=pirelab.getUnitDelayEnabledResettableComp(cpNet,endindreg,endreg,endindreg,svldreg,'Frame_valid',0,'',1);
    ecomp.addComment('endInd signal generation');




    zrel=cpNet.addSignal(ufix1Type,'rel_z');
    nzcomp=pirelab.getLogicComp(cpNet,validz,zrel,'not');
    nzcomp.addComment('Signal indicating invalid Z');

    count=cpNet.addSignal(ufix3Type,'counter');
    cntenb=cpNet.addSignal(ufix1Type,'cntEnb');
    pirelab.getLogicComp(cpNet,[newframe,nfreg],cntenb,'or');

    zvld=cpNet.addSignal(ufix1Type,'z_tmp1');
    pirelab.getCounterComp(cpNet,[sof_vld,cntenb],count,'Count limited',0,1,7,1,0,1,0,'counter',0);
    pirelab.getCompareToValueComp(cpNet,count,zvld,'==',7,'Compare');

    svldreg1=cpNet.addSignal(ufix1Type,'startValidReg1');
    pirelab.getUnitDelayComp(cpNet,svldreg,svldreg1,'',0);

    zvld1=cpNet.addSignal(ufix1Type,'z_tmp2');
    pirelab.getLogicComp(cpNet,[zvld,svldreg1],zvld1,'and');

    pirelab.getLogicComp(cpNet,[zrel,zvld1],invld_z,'and');


    rowless4=cpNet.addSignal(ufix1Type,'rowLess4');
    rowgreat46=cpNet.addSignal(ufix1Type,'rowGreat46');
    rowgreat42=cpNet.addSignal(ufix1Type,'rowGreat42');
    rowgreat=cpNet.addSignal(ufix1Type,'rowGreat');

    pirelab.getCompareToValueComp(cpNet,nrowtmp,rowless4,'<',4,'Compare less');
    pirelab.getCompareToValueComp(cpNet,nrowtmp,rowgreat46,'>',46,'Compare greater');
    pirelab.getCompareToValueComp(cpNet,nrowtmp,rowgreat42,'>',42,'Compare greater');
    pirelab.getSwitchComp(cpNet,[rowgreat46,rowgreat42],rowgreat,bgnout,'layer sel','==',0,'Floor','Wrap');

    invld=cpNet.addSignal(ufix1Type,'invalidFrame');

    pirelab.getLogicComp(cpNet,[rowgreat,rowless4],invld_row,'or');
    pirelab.getLogicComp(cpNet,[invld_row,invld_z],invld,'or');

    sof_vldd=cpNet.addSignal(ufix1Type,'sofVldD');
    pirelab.getLogicComp(cpNet,[sreg,vreg],sof_vldd,'and');

    nextcomp=pirelab.getUnitDelayEnabledResettableComp(cpNet,invld_z,nextframe,invld,sof_vldd,'reset next frame',0);
    nextcomp.addComment('Resetting next frame incase of invalid conditions');


    pirelab.getUnitDelayComp(cpNet,dataoutreg,dataout,'dataOut',0);
    pirelab.getUnitDelayComp(cpNet,validoutreg,validout,'validOut',0);
    pirelab.getUnitDelayComp(cpNet,fvalidreg,framevalid,'fValidOut',0);
    pirelab.getUnitDelayComp(cpNet,resetreg,reset,'reset',0);
    pirelab.getUnitDelayComp(cpNet,endreg,endind,'endInd',0);

end
