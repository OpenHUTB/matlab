function mNet=elabMetricCalculatorNetwork(this,topNet,blockInfo,dataRate)





    ufix1Type=pir_boolean_t;
    ufix2Type=pir_ufixpt_t(2,0);
    vType=pir_ufixpt_t(blockInfo.vWL,0);
    vType1=pir_ufixpt_t(blockInfo.vWL+1,0);
    cType=pir_ufixpt_t(blockInfo.vaddrWL,0);
    aType=pir_sfixpt_t(blockInfo.alphaWL,blockInfo.alphaFL);
    layType=pir_ufixpt_t(blockInfo.layWL,0);
    bcType=pir_ufixpt_t(blockInfo.betaCompWL,0);
    bcType3=pir_ufixpt_t(blockInfo.betaIdxWL,0);
    bcType4=pir_ufixpt_t(2*blockInfo.minWL,0);

    alphaVType=pirelab.getPirVectorType(aType,blockInfo.memDepth);
    eVType=pirelab.getPirVectorType(ufix1Type,blockInfo.memDepth);
    bcVType=pirelab.getPirVectorType(bcType,blockInfo.memDepth);
    bcVType3=pirelab.getPirVectorType(bcType3,blockInfo.memDepth);
    bcVType4=pirelab.getPirVectorType(bcType4,blockInfo.memDepth);


    mNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','MetricCalculator',...
    'Inportnames',{'data','valid','shift','count','betaread','rdenable','layeridx','reset','shiftsel'},...
    'InportTypes',[alphaVType,ufix1Type,vType,cType,ufix1Type,eVType,layType,ufix1Type,ufix2Type],...
    'InportRates',[dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate],...
    'Outportnames',{'gamma','gvalid','gdata','grdenb'},...
    'OutportTypes',[alphaVType,ufix1Type,alphaVType,eVType]...
    );



    data=mNet.PirInputSignals(1);
    valid=mNet.PirInputSignals(2);
    shift=mNet.PirInputSignals(3);
    count=mNet.PirInputSignals(4);
    betaread=mNet.PirInputSignals(5);
    rdenable=mNet.PirInputSignals(6);
    layeridx=mNet.PirInputSignals(7);
    reset=mNet.PirInputSignals(8);
    shiftsel=mNet.PirInputSignals(9);

    gamma=mNet.PirOutputSignals(1);
    validout=mNet.PirOutputSignals(2);
    gdata=mNet.PirOutputSignals(3);
    grdenb=mNet.PirOutputSignals(4);

    data_adj=mNet.addSignal(alphaVType,'dataAdj');
    if strcmpi(blockInfo.LDPCConfiguration,'(8160,7136) LDPC')
        pirelab.getWireComp(mNet,data,data_adj,'');
    else
        darray=this.demuxSignal(mNet,data,'dArray');
        data_64=mNet.addSignal(alphaVType,'data64');
        data_32=mNet.addSignal(alphaVType,'data32');
        for idx=1:blockInfo.memDepth
            darray_64(idx)=mNet.addSignal(aType,['dArray64_',num2str(idx)]);%#ok<*AGROW> 
            darray_32(idx)=mNet.addSignal(aType,['dArray32_',num2str(idx)]);
            if idx>64
                pirelab.getWireComp(mNet,darray(idx-64),darray_64(idx),'');
            else
                pirelab.getWireComp(mNet,darray(idx),darray_64(idx),'');
            end
            if idx>96
                pirelab.getWireComp(mNet,darray(idx-96),darray_32(idx),'');
            elseif idx>64
                pirelab.getWireComp(mNet,darray(idx-64),darray_32(idx),'');
            elseif idx>32
                pirelab.getWireComp(mNet,darray(idx-32),darray_32(idx),'');
            else
                pirelab.getWireComp(mNet,darray(idx),darray_32(idx),'');
            end
            this.muxSignal(mNet,darray_64,data_64);
            this.muxSignal(mNet,darray_32,data_32);
        end
        pirelab.getMultiPortSwitchComp(mNet,[shiftsel,data,data_64,data_32,data],data_adj,1,1,'Floor','Wrap');
    end

    sdata=mNet.addSignal(alphaVType,'sData');
    svalid=mNet.addSignal(ufix1Type,'sValid');
    enb_tmp=mNet.addSignal(ufix1Type,'enbTmp');



    cNet=this.elabCircularShifterNetwork(mNet,blockInfo,dataRate);
    cNet.addComment('Circular_Shifter_1');
    pirelab.instantiateNetwork(mNet,cNet,[data_adj,valid,shift],...
    [sdata,svalid],'Circular_Shifter_1');

    valid_reg=mNet.addSignal(ufix1Type,'validReg');
    valid_neg=mNet.addSignal(ufix1Type,'validNeg');

    pirelab.getUnitDelayComp(mNet,valid,valid_reg,'',0);
    pirelab.getLogicComp(mNet,valid_reg,valid_neg,'not');
    pirelab.getLogicComp(mNet,[valid,valid_neg],enb_tmp,'and');

    betaenb=mNet.addSignal(ufix1Type,'betaEnb');
    pirelab.getLogicComp(mNet,[enb_tmp,betaread],betaenb,'and');

    betaenb_reg=mNet.addSignal(ufix1Type,'betaEnbReg');
    pirelab.getWireComp(mNet,betaenb,betaenb_reg);

    bdecomp1=mNet.addSignal(bcVType,'bDecomp1');
    bdecomp2=mNet.addSignal(bcVType,'bDecomp2');
    bdecomp3=mNet.addSignal(bcVType3,'bDecomp3');
    bdecomp4=mNet.addSignal(bcVType4,'bDecomp4');
    bvalid=mNet.addSignal(ufix1Type,'bValid');

    cdecomp1=mNet.addSignal(bcVType,'cDecomp1');
    cdecomp2=mNet.addSignal(bcVType,'cDecomp2');
    cdecomp3=mNet.addSignal(bcVType3,'cDecomp3');
    cdecomp4=mNet.addSignal(bcVType4,'cDecomp4');
    cvalid=mNet.addSignal(ufix1Type,'cValid');

    betacomp1=mNet.addSignal(bcVType,'betaDecomp1');
    betacomp2=mNet.addSignal(bcVType,'betaDecomp2');
    betacomp3=mNet.addSignal(bcVType3,'betaDecomp3');
    betacomp4=mNet.addSignal(bcVType4,'betaDecomp4');
    bvalid_reg=mNet.addSignal(ufix1Type,'betaValid');

    fdata=mNet.addSignal(alphaVType,'fData');
    fvalid=mNet.addSignal(ufix1Type,'fValid');
    shiftout=mNet.addSignal(vType,'shiftOut');
    rdenbout=mNet.addSignal(eVType,'rdEnbOut');

    shift_reg=mNet.addSignal(shift.Type,'shiftReg');
    pirelab.getUnitDelayComp(mNet,shift,shift_reg,'',0);



    fNet=this.elabFunctionalUnitNetwork(mNet,blockInfo,dataRate);
    fNet.addComment('Functional_Unit');
    pirelab.instantiateNetwork(mNet,fNet,[sdata,svalid,count,rdenable,...
    cdecomp1,cdecomp2,cdecomp3,cdecomp4,cvalid,reset,shift_reg],[fdata,fvalid,bdecomp1,...
    bdecomp2,bdecomp3,bdecomp4,bvalid,shiftout,rdenbout],'Functional_Unit');

    pirelab.getIntDelayComp(mNet,bdecomp1,betacomp1,1,'',0);
    pirelab.getIntDelayComp(mNet,bdecomp2,betacomp2,1,'',0);
    pirelab.getIntDelayComp(mNet,bdecomp3,betacomp3,1,'',0);
    pirelab.getIntDelayComp(mNet,bdecomp4,betacomp4,1,'',0);
    pirelab.getIntDelayComp(mNet,bvalid,bvalid_reg,1,'',0);



    bmNet=this.elabeCheckNodeRAMNetwork(mNet,blockInfo,dataRate);
    bmNet.addComment('Beta Memory');
    pirelab.instantiateNetwork(mNet,bmNet,[betacomp1,betacomp2,betacomp3,betacomp4,layeridx,betaenb_reg,bvalid_reg],...
    [cdecomp1,cdecomp2,cdecomp3,cdecomp4,cvalid],'Beta Memory');

    fdata_adj=mNet.addSignal(alphaVType,'fDataAdj');
    shift_mem=mNet.addSignal(vType1,'shiftMem');
    if strcmpi(blockInfo.LDPCConfiguration,'(8160,7136) LDPC')
        pirelab.getWireComp(mNet,fdata,fdata_adj,'');
        pirelab.getConstComp(mNet,shift_mem,blockInfo.memDepth);
    else
        fdarray=this.demuxSignal(mNet,fdata,'fdArray');
        fdata_64=mNet.addSignal(alphaVType,'fdata64');
        fdata_32=mNet.addSignal(alphaVType,'fdata32');
        for idx=1:blockInfo.memDepth
            fdarray_64(idx)=mNet.addSignal(aType,['fdArray64_',num2str(idx)]);%#ok<*AGROW>
            fdarray_32(idx)=mNet.addSignal(aType,['fdArray32_',num2str(idx)]);
            if idx>64
                pirelab.getWireComp(mNet,fdarray(idx-64),fdarray_64(idx),'');
            else
                pirelab.getWireComp(mNet,fdarray(idx),fdarray_64(idx),'');
            end
            if idx>96
                pirelab.getWireComp(mNet,fdarray(idx-96),fdarray_32(idx),'');
            elseif idx>64
                pirelab.getWireComp(mNet,fdarray(idx-64),fdarray_32(idx),'');
            elseif idx>32
                pirelab.getWireComp(mNet,fdarray(idx-32),fdarray_32(idx),'');
            else
                pirelab.getWireComp(mNet,fdarray(idx),fdarray_32(idx),'');
            end
            this.muxSignal(mNet,fdarray_64,fdata_64);
            this.muxSignal(mNet,fdarray_32,fdata_32);
        end
        const128=mNet.addSignal(vType1,'const128');
        pirelab.getConstComp(mNet,const128,128);
        const64=mNet.addSignal(vType1,'const64');
        pirelab.getConstComp(mNet,const64,64);
        const32=mNet.addSignal(vType1,'const32');
        pirelab.getConstComp(mNet,const32,32);
        pirelab.getMultiPortSwitchComp(mNet,[shiftsel,fdata,fdata_64,fdata_32,fdata],fdata_adj,1,1,'Floor','Wrap');
        pirelab.getMultiPortSwitchComp(mNet,[shiftsel,const128,const64,const32,const128],shift_mem,1,1,'Floor','Wrap');
    end

    sdata2=mNet.addSignal(alphaVType,'sData2');
    svalid2=mNet.addSignal(ufix1Type,'sValid2');

    shiftout_dtc=mNet.addSignal(vType1,'shiftDTC');
    pirelab.getDTCComp(mNet,shiftout,shiftout_dtc,'Floor','Saturate');

    shiftval=mNet.addSignal(vType1,'shiftVal');
    pirelab.getSubComp(mNet,[shift_mem,shiftout_dtc],shiftval,'floor','wrap','Sub Comp');

    shiftval_dtc=mNet.addSignal(vType,'shiftValDTC');
    pirelab.getDTCComp(mNet,shiftval,shiftval_dtc,'Floor','Wrap');



    cNet=this.elabCircularShifterNetwork(mNet,blockInfo,dataRate);
    cNet.addComment('Circular_Shifter_2');
    pirelab.instantiateNetwork(mNet,cNet,[fdata_adj,fvalid,shiftval_dtc],...
    [sdata2,svalid2],'Circular_Shifter_2');

    pirelab.getUnitDelayComp(mNet,sdata2,gamma,'',0);
    pirelab.getUnitDelayComp(mNet,svalid2,validout,'',0);
    pirelab.getUnitDelayComp(mNet,fdata,gdata,'',0);
    pirelab.getUnitDelayComp(mNet,rdenbout,grdenb,'',0);


end



