function alphaNet=elaborateAlphaCompute(~,topNet,blockInfo,dataRate)


    WINDLEN=blockInfo.WindowLength;
    WORDLEN=blockInfo.wordSize;
    FRACLEN=blockInfo.fracSize;
    VECLEN=blockInfo.vecSize;
    ALPHASIZE=blockInfo.alphaSize;
    BIT0IND=blockInfo.bit0indices;
    BIT1IND=blockInfo.bit1indices;
    K=blockInfo.ConstrLen;
    ALGO=blockInfo.Algorithm;
    LOGMAPLUT=double(blockInfo.logMAPLUT);
    INPWL=WORDLEN+floor(log2(VECLEN))+2+floor(log2(K-1));
    OUTWL=INPWL;

    boolType=pir_boolean_t();
    inDataType=pir_sfixpt_t(INPWL,FRACLEN);
    inVecType=pirelab.getPirVectorType(inDataType,2^VECLEN);
    outDataType=pir_sfixpt_t(OUTWL,FRACLEN);
    outVecType=pirelab.getPirVectorType(outDataType,ALPHASIZE);



    inportNames={'gamma0','gamma1','validIn','startIn'};
    inTypes=[inVecType,inVecType,boolType,boolType];
    indataRates=dataRate*ones(1,length(inportNames));

    outportNames={'alpha0','alpha1','alphaPrev0','alphaPrev1','validOut'};
    outTypes=[outVecType,outVecType,outVecType,outVecType,boolType];

    alphaNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','AlphaNetwork',...
    'InportNames',inportNames,...
    'InportTypes',inTypes,...
    'InportRates',indataRates,...
    'OutportNames',outportNames,...
    'OutportTypes',outTypes...
    );

    gamma0=alphaNet.PirInputSignals(1);
    gamma1=alphaNet.PirInputSignals(2);
    validIn=alphaNet.PirInputSignals(3);
    startIn=alphaNet.PirInputSignals(4);


    alpha0=alphaNet.PirOutputSignals(1);
    alpha1=alphaNet.PirOutputSignals(2);
    alphaPrev0=alphaNet.PirOutputSignals(3);
    alphaPrev1=alphaNet.PirOutputSignals(4);
    validOut=alphaNet.PirOutputSignals(5);

    for ind=1:ALPHASIZE
        alphaMax(ind)=newDataSignal(alphaNet,['alphaMax_',num2str(ind)],outDataType,dataRate);%#ok<AGROW>
        alphaMax1(ind)=newDataSignal(alphaNet,['alphaMax1_',num2str(ind)],outDataType,dataRate);%#ok<AGROW>
        alphaMax2(ind)=newDataSignal(alphaNet,['alphaMax2_',num2str(ind)],outDataType,dataRate);%#ok<AGROW>
        alphaMaxM(ind)=newDataSignal(alphaNet,['alphaMaxM_',num2str(ind)],outDataType,dataRate);%#ok<AGROW>
        alphaReg(ind)=newDataSignal(alphaNet,['alphaReg_',num2str(ind)],outDataType,dataRate);%#ok<AGROW>
        LUTout(ind)=newDataSignal(alphaNet,['LUTout_',num2str(ind)],outDataType,dataRate);%#ok<AGROW>
        alphaCtrl(ind)=newDataSignal(alphaNet,['alphaCtrl',num2str(ind)],boolType,dataRate);%#ok<AGROW>
        alphaSub(ind)=newDataSignal(alphaNet,['alphaSub',num2str(ind)],outDataType,dataRate);%#ok<AGROW>
    end

    startInReg=alphaNet.addSignal(boolType,'startInReg');
    pirelab.getIntDelayComp(alphaNet,startIn,startInReg,1,'',0);

    zeroSig=newDataSignal(alphaNet,'zeroSig',outDataType,dataRate);
    pirelab.getConstComp(alphaNet,zeroSig,0);

    for ind=1:2*ALPHASIZE
        alphaTemp(ind)=newDataSignal(alphaNet,['alphaTemp_',num2str(ind)],outDataType,dataRate);%#ok<AGROW>
    end

    alphaTemp1=newDataSignal(alphaNet,'alphaTemp1',outVecType,dataRate);
    alphaTemp2=newDataSignal(alphaNet,'alphaTemp2',outVecType,dataRate);
    alphaDiff=newDataSignal(alphaNet,'alphaDiff',outVecType,dataRate);
    alphaDiffAbs=newDataSignal(alphaNet,'alphaDiffAbs',outVecType,dataRate);
    alphaDiffShift=newDataSignal(alphaNet,'alphaDiffShift',outVecType,dataRate);
    LUTInp=newDataSignal(alphaNet,'LUTInp',pirelab.getPirVectorType(pir_ufixpt_t(7,0),ALPHASIZE),dataRate);
    LUTout1=newDataSignal(alphaNet,'LUTout1',outVecType,dataRate);
    alphaDiffOverflow=newDataSignal(alphaNet,'alphaDiffOverflow',pirelab.getPirVectorType(boolType,ALPHASIZE),dataRate);

    gam0Demx=[];
    gam1Demx=[];
    for ind=1:2^VECLEN
        gamma0Demux(ind)=newDataSignal(alphaNet,['Gamma0Demux_',num2str(ind)],inDataType,dataRate);%#ok<AGROW> 
        gam0Demx=[gam0Demx,gamma0Demux(ind)];%#ok<AGROW>
        gamma1Demux(ind)=newDataSignal(alphaNet,['Gamma1Demux_',num2str(ind)],inDataType,dataRate);%#ok<AGROW> 
        gam1Demx=[gam1Demx,gamma1Demux(ind)];%#ok<AGROW>
    end
    pirelab.getDemuxComp(alphaNet,gamma0,gam0Demx);
    pirelab.getDemuxComp(alphaNet,gamma1,gam1Demx);


    for ind=1:ALPHASIZE
        pirelab.getAddComp(alphaNet,[alphaReg(ind),gam0Demx(BIT0IND(ind))],alphaTemp(ind),'Floor','Wrap','alpha0 adders');
        pirelab.getAddComp(alphaNet,[alphaReg(ind),gam1Demx(BIT1IND(ind))],alphaTemp(ind+ALPHASIZE),'Floor','Wrap','alpha1 adders');
    end
    pirelab.getMuxComp(alphaNet,alphaTemp(1:2:end),alphaTemp1);
    pirelab.getMuxComp(alphaNet,alphaTemp(2:2:end),alphaTemp2);


    for ind=1:2:2*ALPHASIZE
        pirelab.getSubComp(alphaNet,[alphaTemp(ind),alphaTemp(ind+1)],alphaSub(floor(ind/2)+1),'Floor','Wrap');
        pirelab.getBitSliceComp(alphaNet,alphaSub(floor(ind/2)+1),alphaCtrl(floor(ind/2)+1),INPWL-1,INPWL-1,'bit_extract');
        pirelab.getSwitchComp(alphaNet,[alphaTemp(ind),alphaTemp(ind+1)],alphaMaxM(floor(ind/2)+1),alphaCtrl(floor(ind/2)+1));
    end

    for ind=1:ALPHASIZE
        LUTout1Dmx(ind)=newDataSignal(alphaNet,['LUTout1Dmx',num2str(ind)],outDataType,dataRate);%#ok<AGROW>
        alphaDiffOverflowDmx(ind)=newDataSignal(alphaNet,['alphaDiffOverflowDmx',num2str(ind)],boolType,dataRate);%#ok<AGROW>
    end

    if strcmpi(ALGO,'Log MAP (max*)')
        pirelab.getSubComp(alphaNet,[alphaTemp1,alphaTemp2],alphaDiff,'Floor','Wrap','');
        pirelab.getAbsComp(alphaNet,alphaDiff,alphaDiffAbs);
        pirelab.getBitShiftComp(alphaNet,alphaDiffAbs,alphaDiffShift,'sll',4);
        pirelab.getDTCComp(alphaNet,alphaDiffShift,LUTInp,'Floor','Wrap');
        pirelab.getDirectLookupComp(alphaNet,LUTInp,LUTout1,LOGMAPLUT,'LogMAPLUT','','','','',outDataType,true);
        pirelab.getCompareToValueComp(alphaNet,alphaDiffAbs,alphaDiffOverflow,'>',7.9375);
    end

    pirelab.getDemuxComp(alphaNet,alphaDiffOverflow,alphaDiffOverflowDmx);
    pirelab.getDemuxComp(alphaNet,LUTout1,LUTout1Dmx);

    for ind=1:ALPHASIZE
        if strcmpi(ALGO,'Log MAP (max*)')
            pirelab.getSwitchComp(alphaNet,[LUTout1Dmx(ind),zeroSig],LUTout(ind),alphaDiffOverflowDmx(ind));
            pirelab.getAddComp(alphaNet,[alphaMaxM(ind),LUTout(ind)],alphaMax(ind),'Floor','Wrap','');
        else
            pirelab.getWireComp(alphaNet,alphaMaxM(ind),alphaMax(ind));
        end
    end


    for ind=1:ALPHASIZE
        pirelab.getSubComp(alphaNet,[alphaMax(ind),alphaMax(1)],alphaMax1(ind),'Floor','Wrap','reduce bit width');
    end

    oneSig=alphaNet.addSignal(pir_ufixpt_t(8,0),'oneSig');
    pirelab.getConstComp(alphaNet,oneSig,1);

    count=alphaNet.addSignal(pir_ufixpt_t(8,0),'count');
    count1=alphaNet.addSignal(pir_ufixpt_t(8,0),'count1');
    zeroSig1=newDataSignal(alphaNet,'zeroSig1',pir_ufixpt_t(8,0),dataRate);
    pirelab.getConstComp(alphaNet,zeroSig1,0);

    pirelab.getCounterComp(alphaNet,[startInReg,oneSig,validIn],count1,...
    'Count limited',...
    0.0,...
    1.0,...
    WINDLEN-1,...
    false,...
    true,...
    true,...
    false,...
    'InputCounter');

    pirelab.getSwitchComp(alphaNet,[count1,zeroSig1],count,startIn);

    countAfter2=alphaNet.addSignal(boolType,'countAfter2');
    countAfter2Val=alphaNet.addSignal(boolType,'countAfter2Val');
    countAfter2V=alphaNet.addSignal(boolType,'countAfter2V');
    startInRegNOT=alphaNet.addSignal(boolType,'startInRegNOT');
    pirelab.getCompareToValueComp(alphaNet,count,countAfter2,'>',K-2);

    pirelab.getLogicComp(alphaNet,startInReg,startInRegNOT,'not');
    pirelab.getLogicComp(alphaNet,[countAfter2,validIn],countAfter2Val,'and');
    pirelab.getLogicComp(alphaNet,[countAfter2Val,startInRegNOT],countAfter2V,'and');

    for ii=1:ALPHASIZE
        pirelab.getSwitchComp(alphaNet,[alphaMax(ii),alphaMax1(ii)],alphaMax2(ii),countAfter2V);
    end

    for ind=1:ALPHASIZE
        if ind==1
            initVal=fi(0,1,INPWL,-FRACLEN);
        else
            initVal=fi(-2^(INPWL+FRACLEN-2),1,INPWL,-FRACLEN);
        end

        pirelab.getUnitDelayEnabledResettableComp(alphaNet,alphaMax2(ind),alphaReg(ind),validIn,startIn,...
        ['alphaRegister_',num2str(ind)],initVal,'',true);
    end

    pirelab.getMuxComp(alphaNet,alphaReg,alpha0);
    pirelab.getMuxComp(alphaNet,alphaReg,alpha1);

    pirelab.getMuxComp(alphaNet,alphaTemp(1:ALPHASIZE),alphaPrev0);
    pirelab.getMuxComp(alphaNet,alphaTemp(ALPHASIZE+(1:ALPHASIZE)),alphaPrev1);

    pirelab.getIntDelayComp(alphaNet,validIn,validOut,0,'validIn_register',0);

    function signal=newDataSignal(alphaNet,name,inType,rate)
        signal=alphaNet.addSignal(inType,name);
        signal.SimulinkRate=rate;
    end

end

