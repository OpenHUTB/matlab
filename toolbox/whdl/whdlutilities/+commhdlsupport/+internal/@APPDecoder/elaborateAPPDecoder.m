function elaborateAPPDecoder(this,topNet,blockInfo,insignals,outsignals)

    WINDLEN=blockInfo.WindowLength;
    WINDLENM1=WINDLEN-1;
    WINDLENM2=WINDLEN-2;
    WORDLEN=blockInfo.wordSize;
    FRACLEN=blockInfo.fracSize;
    VECLEN=blockInfo.vecSize;
    ALPHASIZE=blockInfo.alphaSize;
    BITINDCODED=blockInfo.bitIndicesCoded;
    ALGO=blockInfo.Algorithm;
    LOGMAPLUT=blockInfo.logMAPLUT;
    K=blockInfo.ConstrLen;
    INPWL=WORDLEN+floor(log2(VECLEN))+2+floor(log2(K-1));
    pipelines=ALPHASIZE+2;
    INITVAL=-2^(INPWL+FRACLEN-2);


    llrC=insignals(1);
    llrU=insignals(2);
    startIn=insignals(3);
    endIn=insignals(4);
    validIn=insignals(5);
    dataRate=llrC.SimulinkRate;


    if strcmpi(blockInfo.DisableAprOut,'on')
        llruOut=outsignals(1);
        startOut=outsignals(2);
        endOut=outsignals(3);
        validOut=outsignals(4);
        nextFrame=outsignals(5);
        llrcOut=newDataSignal(topNet,'llrcOut',pirelab.getPirVectorType(pir_sfixpt_t(INPWL,FRACLEN),VECLEN),dataRate);
    else
        llruOut=outsignals(1);
        llrcOut=outsignals(2);
        startOut=outsignals(3);
        endOut=outsignals(4);
        validOut=outsignals(5);
        nextFrame=outsignals(6);
    end


    startInp=newControlSignal(topNet,'startInp',dataRate);
    endInp=newControlSignal(topNet,'endInp',dataRate);
    validInp=newControlSignal(topNet,'validInp',dataRate);
    sampleControlNet=this.elabSampleControl(topNet,dataRate);
    sampleControlNet.addComment('Sample control for valid start and end');
    pirelab.instantiateNetwork(topNet,sampleControlNet,[startIn,endIn,validIn],[startInp,endInp,validInp],'sampleControlNet_inst');


    wrAddr=newDataSignal(topNet,'wrAddr',pir_ufixpt_t(8,0),dataRate);
    rdAddr=newDataSignal(topNet,'rdAddr',pir_ufixpt_t(8,0),dataRate);
    wrAddrOut=newDataSignal(topNet,'wrAddrOut',pir_ufixpt_t(8,0),dataRate);
    rdAddrOut=newDataSignal(topNet,'rdAddrOut',pir_ufixpt_t(8,0),dataRate);
    winLenMin2=newDataSignal(topNet,'winLenMin2',pir_ufixpt_t(8,0),dataRate);
    pirelab.getConstComp(topNet,winLenMin2,WINDLENM2);
    wrEnOut=newControlSignal(topNet,'wrEnOut',dataRate);
    wrEnOutBeta=newControlSignal(topNet,'wrEnOutBeta',dataRate);
    loadSig=newControlSignal(topNet,'loadSig',dataRate);
    nextFrameLowTime=newDataSignal(topNet,'nextFrameLowTime',pir_ufixpt_t(8,0),dataRate);
    lastWinLen=newDataSignal(topNet,'lastWinLen',pir_ufixpt_t(8,0),dataRate);
    lastWinLen1=newDataSignal(topNet,'lastWinLen1',pir_ufixpt_t(8,0),dataRate);
    lastWinLenReg=newDataSignal(topNet,'lastWinLenReg',pir_ufixpt_t(8,0),dataRate);
    lastWinLenReg1=newDataSignal(topNet,'lastWinLenReg1',pir_ufixpt_t(8,0),dataRate);
    lastWind=newControlSignal(topNet,'lastWind',dataRate);
    addressGenNet=this.elabAddressGenerate(topNet,blockInfo,dataRate);
    addressGenNet.addComment('Generate write and read address for RAM');
    endFlag=newControlSignal(topNet,'endFlag',dataRate);
    endFlag1=newControlSignal(topNet,'endFlag1',dataRate);
    rstCounter=newControlSignal(topNet,'rstCounter',dataRate);
    startOutReg=newControlSignal(topNet,'startOutReg',dataRate);
    nextFrameNOT=newControlSignal(topNet,'nextFrameNOT',dataRate);
    startAndNFNOT=newControlSignal(topNet,'startAndNFNOT',dataRate);
    rstEndInp=newControlSignal(topNet,'rstEndInp',dataRate);

    pirelab.getBitwiseOpComp(topNet,nextFrame,nextFrameNOT,'not');
    pirelab.getBitwiseOpComp(topNet,[startInp,nextFrameNOT],startAndNFNOT,'and');
    pirelab.getBitwiseOpComp(topNet,[nextFrame,startAndNFNOT],rstEndInp,'or');

    pirelab.getUnitDelayEnabledResettableComp(topNet,endInp,endFlag,endInp,rstEndInp,...
    '',0,'',true);

    pirelab.getBitwiseOpComp(topNet,[endFlag,nextFrame],endFlag1,'and');

    pirelab.instantiateNetwork(topNet,addressGenNet,[validInp,endInp,startInp,endFlag,nextFrame],[wrAddr,rdAddr,wrAddrOut,rdAddrOut,wrEnOut,loadSig,nextFrameLowTime,lastWinLen,lastWinLenReg,lastWind,rstCounter,startOutReg,wrEnOutBeta],'addressGenNet_inst');


    llrUDTC=newDataSignal(topNet,'llrUDTC',pir_sfixpt_t(INPWL,FRACLEN),dataRate);
    llrCDTC=newDataSignal(topNet,'llrCDTC',pirelab.getPirVectorType(pir_sfixpt_t(INPWL,FRACLEN),VECLEN),dataRate);
    pirelab.getDTCComp(topNet,llrU,llrUDTC);
    pirelab.getDTCComp(topNet,llrC,llrCDTC);

    LcRAM=newDataSignal(topNet,'LcRAM',pirelab.getPirVectorType(pir_sfixpt_t(INPWL,FRACLEN),VECLEN),dataRate);
    LuRAM=newDataSignal(topNet,'LuRAM',pir_sfixpt_t(INPWL,FRACLEN),dataRate);
    ramLu=pirelab.getSimpleDualPortRamComp(topNet,[llrUDTC,wrAddr,validInp,rdAddr],...
    LuRAM,'RAM for LLRu',1,-1,[],'','','distributed');
    ramLu.addComment('');
    ramLc=pirelab.getSimpleDualPortRamComp(topNet,[llrCDTC,wrAddr,validInp,rdAddr],...
    LcRAM,'RAM for LLRc',VECLEN,-1,[],'','','distributed');
    ramLc.addComment('');


    outDataTypeG=pir_sfixpt_t(INPWL,FRACLEN);
    outVecTypeG=pirelab.getPirVectorType(outDataTypeG,2^VECLEN);
    gamma0=newDataSignal(topNet,'gamma0',outVecTypeG,dataRate);
    gamma1=newDataSignal(topNet,'gamma1',outVecTypeG,dataRate);
    startOutG=newControlSignal(topNet,'startOutG',dataRate);
    endOutG=newControlSignal(topNet,'endOutG',dataRate);
    validOutG=newControlSignal(topNet,'validOutG',dataRate);

    inports=[llrC,llrU,startInp,endInp,validInp];
    outports=[gamma0,gamma1,startOutG,endOutG,validOutG];

    gammaNet=this.elaborateGamma(topNet,blockInfo,dataRate);
    pirelab.instantiateNetwork(topNet,gammaNet,inports,outports,'Gamma_inst');




    counterRst=newControlSignal(topNet,'counterRst',dataRate);
    counterMax=newControlSignal(topNet,'counterMax',dataRate);
    counterEnb=newControlSignal(topNet,'counterEnb',dataRate);
    counterVal=newDataSignal(topNet,'counterVal',pir_ufixpt_t(16,0),dataRate);

    oneconst=newDataSignal(topNet,'oneconst',pir_ufixpt_t(16,0),dataRate);
    pirelab.getConstComp(topNet,oneconst,1,'oneconst');

    pirelab.getCompareToValueComp(topNet,counterVal,counterEnb,'>',0,'counterEnbComp');

    pirelab.getRelOpComp(topNet,[counterVal,nextFrameLowTime],counterMax,'==');
    pirelab.getBitwiseOpComp(topNet,[startIn,counterMax],counterRst,'OR');

    pirelab.getCounterComp(topNet,[counterRst,endInp,oneconst,counterEnb],counterVal,...
    'Count limited',...
    0,...
    1.0,...
    WINDLENM1,...
    true,...
    true,...
    true,...
    false,...
    'nextFramecounter');

    nxtFrameNet=this.elabNxtFrameCtrl(topNet,dataRate);
    nxtFrameNet.addComment('Next Frame Signal State Machine');

    inports1(1)=startInp;
    inports1(2)=endInp;
    inports1(3)=counterEnb;
    outports1(1)=nextFrame;

    pirelab.instantiateNetwork(topNet,nxtFrameNet,inports1,outports1,'nxtFrameNet_inst');







    outDataTypeA=pir_sfixpt_t(INPWL,FRACLEN);
    outVecTypeA=pirelab.getPirVectorType(outDataTypeA,ALPHASIZE);
    alpha0=newDataSignal(topNet,'alpha0',outVecTypeA,dataRate);
    alpha1=newDataSignal(topNet,'alpha1',outVecTypeA,dataRate);
    validOutA=newControlSignal(topNet,'validOutA',dataRate);
    alphaPrev0=newDataSignal(topNet,'alphaPrev0',outVecTypeA,dataRate);
    alphaPrev1=newDataSignal(topNet,'alphaPrev1',outVecTypeA,dataRate);
    inportsA=[gamma0,gamma1,validOutG,startOutG];
    outportsA=[alpha0,alpha1,alphaPrev0,alphaPrev1,validOutA];

    alphaNet=this.elaborateAlphaCompute(topNet,blockInfo,dataRate);
    pirelab.instantiateNetwork(topNet,alphaNet,inportsA,outportsA,'Alpha_inst');


    gamma0RAM=newDataSignal(topNet,'gamma0RAM',outVecTypeG,dataRate);
    gamma1RAM=newDataSignal(topNet,'gamma1RAM',outVecTypeG,dataRate);
    alpha0RAM=newDataSignal(topNet,'alpha0RAM',pirelab.getPirVectorType(outDataTypeA,ALPHASIZE),dataRate);
    alpha1RAM=newDataSignal(topNet,'alpha1RAM',pirelab.getPirVectorType(outDataTypeA,ALPHASIZE),dataRate);
    validOutM=newControlSignal(topNet,'validOutM',dataRate);
    inportsM=[gamma0,gamma1,alphaPrev0,alphaPrev1,wrAddr,validOutG,validOutA,rdAddr];
    outportsM=[gamma0RAM,gamma1RAM,alpha0RAM,alpha1RAM,validOutM];

    memUnitNet=this.elaborateMemUnit(topNet,blockInfo,dataRate);
    pirelab.instantiateNetwork(topNet,memUnitNet,inportsM,outportsM,'MemUnit_inst');



    beta0=newDataSignal(topNet,'beta0',outVecTypeA,dataRate);
    beta1=newDataSignal(topNet,'beta1',outVecTypeA,dataRate);
    validOutB=newControlSignal(topNet,'validOutB',dataRate);
    inportsB=[gamma0RAM,gamma1RAM,wrEnOutBeta,loadSig,endFlag];
    outportsB=[beta0,beta1,validOutB];

    betaNet=this.elaborateBetaCompute(topNet,blockInfo,dataRate);
    pirelab.instantiateNetwork(topNet,betaNet,inportsB,outportsB,'Beta_inst');


    for ind=1:ALPHASIZE
        metric0(ind)=newDataSignal(topNet,['metric0_',num2str(ind)],outDataTypeA,dataRate);%#ok<AGROW> 
        metric1(ind)=newDataSignal(topNet,['metric1_',num2str(ind)],outDataTypeA,dataRate);%#ok<AGROW> 
    end
    maxMetric0=newDataSignal(topNet,'maxMetric0',outDataTypeA,dataRate);
    maxMetric1=newDataSignal(topNet,'maxMetric1',outDataTypeA,dataRate);

    diffMetrics=newDataSignal(topNet,'diffMetrics',outDataTypeA,dataRate);
    for ii=1:VECLEN
        diffMetricsCoded(ii)=newDataSignal(topNet,['diffMetricsCoded_',num2str(ii)],outDataTypeA,dataRate);%#ok<AGROW> 
    end

    llruRev=newDataSignal(topNet,'llruRev',outDataTypeA,dataRate);
    llruRevReg=newDataSignal(topNet,'llruRevReg',outDataTypeA,dataRate);
    for ii=1:VECLEN
        lcRAMDemux(ii)=newDataSignal(topNet,['lcRAMDemux_',num2str(ii)],outDataTypeA,dataRate);%#ok<AGROW> 
        llrcRev(ii)=newDataSignal(topNet,['llrcRev_',num2str(ii)],outDataTypeA,dataRate);%#ok<AGROW> 
    end

    LcRAMReg=newDataSignal(topNet,'LcRAMReg',pirelab.getPirVectorType(pir_sfixpt_t(INPWL,FRACLEN),VECLEN),dataRate);
    pirelab.getIntDelayComp(topNet,LcRAM,LcRAMReg,pipelines,'',0);
    pirelab.getDemuxComp(topNet,LcRAMReg,lcRAMDemux);

    for ind=1:ALPHASIZE
        alpha0RAMDemux(ind)=newDataSignal(topNet,['alpha0RAMDemux_',num2str(ind)],outDataTypeA,dataRate);%#ok<AGROW> 
        alpha1RAMDemux(ind)=newDataSignal(topNet,['alpha1RAMDemux_',num2str(ind)],outDataTypeA,dataRate);%#ok<AGROW> 
        beta0Demux(ind)=newDataSignal(topNet,['beta0Demux_',num2str(ind)],outDataTypeA,dataRate);%#ok<AGROW> 
        beta1Demux(ind)=newDataSignal(topNet,['beta1Demux_',num2str(ind)],outDataTypeA,dataRate);%#ok<AGROW> 
    end

    pirelab.getDemuxComp(topNet,alpha0RAM,alpha0RAMDemux);
    pirelab.getDemuxComp(topNet,beta0,beta0Demux);
    pirelab.getDemuxComp(topNet,alpha1RAM,alpha1RAMDemux);
    pirelab.getDemuxComp(topNet,beta1,beta1Demux);

    for ind=1:ALPHASIZE
        pirelab.getAddComp(topNet,[alpha0RAMDemux(ind),beta0Demux(ind)],metric0(ind),'Floor','Wrap','');
        pirelab.getAddComp(topNet,[alpha1RAMDemux(ind),beta1Demux(ind)],metric1(ind),'Floor','Wrap','');
    end

    zeroSig=newDataSignal(topNet,'zeroSig',outDataTypeA,dataRate);
    pirelab.getConstComp(topNet,zeroSig,0);

    if strcmpi(ALGO,'Log MAP (max*)')
        temp0=metric0(1);
        temp1=metric1(1);
        for ind=1:ALPHASIZE-1
            metric0Temp(ind)=newDataSignal(topNet,['metric0Temp_',num2str(ind)],outDataTypeA,dataRate);%#ok<AGROW> 
            metric1Temp(ind)=newDataSignal(topNet,['metric1Temp_',num2str(ind)],outDataTypeA,dataRate);%#ok<AGROW>
            metric0Reg(ind)=newDataSignal(topNet,['metric0Reg',num2str(ind)],outDataTypeA,dataRate);%#ok<AGROW> 
            metric1Reg(ind)=newDataSignal(topNet,['metric1Reg',num2str(ind)],outDataTypeA,dataRate);%#ok<AGROW> 

            met0Diff(ind)=newDataSignal(topNet,['met0Diff_',num2str(ind)],outDataTypeA,dataRate);%#ok<AGROW>
            met0DiffAbs(ind)=newDataSignal(topNet,['met0DiffAbs',num2str(ind)],outDataTypeA,dataRate);%#ok<AGROW>
            met0DiffShift(ind)=newDataSignal(topNet,['met0DiffShift',num2str(ind)],outDataTypeA,dataRate);%#ok<AGROW>
            met0DiffShiftOvrflw(ind)=newDataSignal(topNet,['met0DiffShiftOvrflw',num2str(ind)],outDataTypeA,dataRate);%#ok<AGROW>
            LUTInp0(ind)=newDataSignal(topNet,['LUTInp0',num2str(ind)],pir_ufixpt_t(7,0),dataRate);%#ok<AGROW>
            LUTout0(ind)=newDataSignal(topNet,['LUTout0',num2str(ind)],outDataTypeA,dataRate);%#ok<AGROW>
            LUTout0Reg(ind)=newDataSignal(topNet,['LUTout0Reg',num2str(ind)],outDataTypeA,dataRate);%#ok<AGROW>
            LUTout0Reg1(ind)=newDataSignal(topNet,['LUTout0Reg1',num2str(ind)],outDataTypeA,dataRate);%#ok<AGROW>
            metric0Temp1(ind)=newDataSignal(topNet,['metric0Temp1',num2str(ind)],outDataTypeA,dataRate);%#ok<AGROW>

            met1Diff(ind)=newDataSignal(topNet,['met1Diff_',num2str(ind)],outDataTypeA,dataRate);%#ok<AGROW>
            met1DiffAbs(ind)=newDataSignal(topNet,['met1DiffAbs',num2str(ind)],outDataTypeA,dataRate);%#ok<AGROW>
            met1DiffShift(ind)=newDataSignal(topNet,['met1DiffShift',num2str(ind)],outDataTypeA,dataRate);%#ok<AGROW>
            met1DiffShiftOvrflw(ind)=newDataSignal(topNet,['met1DiffShiftOvrflw',num2str(ind)],outDataTypeA,dataRate);%#ok<AGROW>
            LUTInp1(ind)=newDataSignal(topNet,['LUTInp1',num2str(ind)],pir_ufixpt_t(7,0),dataRate);%#ok<AGROW>
            LUTout1(ind)=newDataSignal(topNet,['LUTout1',num2str(ind)],outDataTypeA,dataRate);%#ok<AGROW>
            LUTout1Reg(ind)=newDataSignal(topNet,['LUTout1Reg',num2str(ind)],outDataTypeA,dataRate);%#ok<AGROW>
            LUTout1Reg1(ind)=newDataSignal(topNet,['LUTout1Reg1',num2str(ind)],outDataTypeA,dataRate);%#ok<AGROW>
            metric1Temp1(ind)=newDataSignal(topNet,['metric1Temp1',num2str(ind)],outDataTypeA,dataRate);%#ok<AGROW>

            pirelab.getIntDelayComp(topNet,metric0(ind+1),metric0Reg(ind),ind-1,'',0);
            pirelab.getTreeArch(topNet,[temp0,metric0Reg(ind)],metric0Temp(ind),'max','Floor','Wrap','','Zero',true);

            pirelab.getSubComp(topNet,[temp0,metric0Reg(ind)],met0Diff(ind),'Floor','Wrap','');
            pirelab.getAbsComp(topNet,met0Diff(ind),met0DiffAbs(ind));
            pirelab.getBitShiftComp(topNet,met0DiffAbs(ind),met0DiffShift(ind),'sll',4);
            pirelab.getDTCComp(topNet,met0DiffShift(ind),LUTInp0(ind),'Floor','Wrap');
            pirelab.getDirectLookupComp(topNet,LUTInp0(ind),LUTout0(ind),LOGMAPLUT,'LogMAPLUT','','','','',outDataTypeA);
            pirelab.getCompareToValueComp(topNet,met0DiffAbs(ind),met0DiffShiftOvrflw(ind),'>',7.9375);
            pirelab.getSwitchComp(topNet,[LUTout0(ind),zeroSig],LUTout0Reg(ind),met0DiffShiftOvrflw(ind));
            pirelab.getIntDelayComp(topNet,LUTout0Reg(ind),LUTout0Reg1(ind),1,'',0);
            pirelab.getAddComp(topNet,[metric0Temp(ind),LUTout0Reg1(ind)],metric0Temp1(ind),'Floor','Wrap','');
            temp0=metric0Temp1(ind);

            pirelab.getIntDelayComp(topNet,metric1(ind+1),metric1Reg(ind),ind-1,'',0);
            pirelab.getTreeArch(topNet,[temp1,metric1Reg(ind)],metric1Temp(ind),'max','Floor','Wrap','','Zero',true);

            pirelab.getSubComp(topNet,[temp1,metric1Reg(ind)],met1Diff(ind),'Floor','Wrap','');
            pirelab.getAbsComp(topNet,met1Diff(ind),met1DiffAbs(ind));
            pirelab.getBitShiftComp(topNet,met1DiffAbs(ind),met1DiffShift(ind),'sll',4);
            pirelab.getDTCComp(topNet,met1DiffShift(ind),LUTInp1(ind),'Floor','Wrap');
            pirelab.getDirectLookupComp(topNet,LUTInp1(ind),LUTout1(ind),LOGMAPLUT,'LogMAPLUT','','','','',outDataTypeA);
            pirelab.getCompareToValueComp(topNet,met1DiffAbs(ind),met1DiffShiftOvrflw(ind),'>',7.9375);
            pirelab.getSwitchComp(topNet,[LUTout1(ind),zeroSig],LUTout1Reg(ind),met1DiffShiftOvrflw(ind));
            pirelab.getIntDelayComp(topNet,LUTout1Reg(ind),LUTout1Reg1(ind),1,'',0);
            pirelab.getAddComp(topNet,[metric1Temp(ind),LUTout1Reg1(ind)],metric1Temp1(ind),'Floor','Wrap','');
            temp1=metric1Temp1(ind);
        end
        pirelab.getWireComp(topNet,metric0Temp1(ALPHASIZE-1),maxMetric0);
        pirelab.getWireComp(topNet,metric1Temp1(ALPHASIZE-1),maxMetric1);
    else
        temp0=metric0(1);
        temp1=metric1(1);
        for ind=1:ALPHASIZE-1
            metric0Temp(ind)=newDataSignal(topNet,['metric0Temp_',num2str(ind)],outDataTypeA,dataRate);%#ok<AGROW> 
            metric1Temp(ind)=newDataSignal(topNet,['metric1Temp_',num2str(ind)],outDataTypeA,dataRate);%#ok<AGROW> 
            metric0Reg(ind)=newDataSignal(topNet,['metric0Reg',num2str(ind)],outDataTypeA,dataRate);%#ok<AGROW> 
            metric1Reg(ind)=newDataSignal(topNet,['metric1Reg',num2str(ind)],outDataTypeA,dataRate);%#ok<AGROW> 

            pirelab.getIntDelayComp(topNet,metric0(ind+1),metric0Reg(ind),ind-1,'',INITVAL);
            pirelab.getIntDelayComp(topNet,metric1(ind+1),metric1Reg(ind),ind-1,'',INITVAL);

            pirelab.getTreeArch(topNet,[temp0,metric0Reg(ind)],metric0Temp(ind),'max','Floor','Wrap','','Zero',true);
            temp0=metric0Temp(ind);

            pirelab.getTreeArch(topNet,[temp1,metric1Reg(ind)],metric1Temp(ind),'max','Floor','Wrap','','Zero',true);
            temp1=metric1Temp(ind);
        end
        pirelab.getWireComp(topNet,metric0Temp(ALPHASIZE-1),maxMetric0);
        pirelab.getWireComp(topNet,metric1Temp(ALPHASIZE-1),maxMetric1);
    end

    LuRAMReg=newDataSignal(topNet,'LuRAMReg',pir_sfixpt_t(INPWL,FRACLEN),dataRate);
    pirelab.getIntDelayComp(topNet,LuRAM,LuRAMReg,pipelines,'',0);
    pirelab.getSubComp(topNet,[maxMetric1,maxMetric0],diffMetrics,'Floor','Wrap','');
    pirelab.getSubComp(topNet,[diffMetrics,LuRAMReg],llruRev,'Floor','Wrap','');
    pirelab.getIntDelayComp(topNet,llruRev,llruRevReg,1,'',0);

    t1=metric1;
    t0=metric0;
    totalMetrics=[metric0,metric1];
    for ind=1:VECLEN
        maxt0(ind)=newDataSignal(topNet,['maxt0_',num2str(ind)],outDataTypeA,dataRate);%#ok<AGROW>
        maxt1(ind)=newDataSignal(topNet,['maxt1_',num2str(ind)],outDataTypeA,dataRate);%#ok<AGROW>
        idx1=1;
        idx2=1;
        for idx=1:2*ALPHASIZE
            if BITINDCODED(idx,ind)
                t1(idx1)=totalMetrics(idx);
                idx1=idx1+1;
            else
                t0(idx2)=totalMetrics(idx);
                idx2=idx2+1;
            end
        end


        if strcmpi(ALGO,'Log MAP (max*)')
            temp0=t0(1);
            temp1=t1(1);
            for ind1=1:ALPHASIZE-1
                metric0TempLc(ind1)=newDataSignal(topNet,['metric0TempLc_',num2str(ind1),num2str(ind)],outDataTypeA,dataRate);%#ok<AGROW>
                metric1TempLc(ind1)=newDataSignal(topNet,['metric1TempLc_',num2str(ind1),num2str(ind)],outDataTypeA,dataRate);%#ok<AGROW>
                metric0LcReg(ind1)=newDataSignal(topNet,['metric0LcReg',num2str(ind1),num2str(ind)],outDataTypeA,dataRate);%#ok<AGROW>
                metric1LcReg(ind1)=newDataSignal(topNet,['metric1LcReg',num2str(ind1),num2str(ind)],outDataTypeA,dataRate);%#ok<AGROW>

                met0LcDiff(ind1)=newDataSignal(topNet,['met0LcDiff_',num2str(ind1),num2str(ind)],outDataTypeA,dataRate);%#ok<AGROW>
                met0LcDiffAbs(ind1)=newDataSignal(topNet,['met0LcDiffAbs',num2str(ind1),num2str(ind)],outDataTypeA,dataRate);%#ok<AGROW>
                met0LcDiffShift(ind1)=newDataSignal(topNet,['met0LcDiffShift',num2str(ind1),num2str(ind)],outDataTypeA,dataRate);%#ok<AGROW>
                met0LcDiffShiftOvrflw(ind1)=newDataSignal(topNet,['met0LcDiffShiftOvrflw',num2str(ind1),num2str(ind)],outDataTypeA,dataRate);%#ok<AGROW>
                LUTInp0Lc(ind1)=newDataSignal(topNet,['LUTInp0Lc',num2str(ind1),num2str(ind)],pir_ufixpt_t(7,0),dataRate);%#ok<AGROW>
                LUTout0Lc(ind1)=newDataSignal(topNet,['LUTout0Lc',num2str(ind1),num2str(ind)],pir_ufixpt_t(16,-16),dataRate);%#ok<AGROW>
                LUTout0LcReg(ind1)=newDataSignal(topNet,['LUTout0LcReg',num2str(ind1),num2str(ind)],outDataTypeA,dataRate);%#ok<AGROW>
                LUTout0LcReg1(ind1)=newDataSignal(topNet,['LUTout0LcReg1',num2str(ind1),num2str(ind)],outDataTypeA,dataRate);%#ok<AGROW>
                metric0LcTemp1(ind1)=newDataSignal(topNet,['metric0LcTemp1',num2str(ind1),num2str(ind)],outDataTypeA,dataRate);%#ok<AGROW>


                met1LcDiff(ind1)=newDataSignal(topNet,['met1LcDiff_',num2str(ind1),num2str(ind)],outDataTypeA,dataRate);%#ok<AGROW>
                met1LcDiffAbs(ind1)=newDataSignal(topNet,['met1LcDiffAbs',num2str(ind1),num2str(ind)],outDataTypeA,dataRate);%#ok<AGROW>
                met1LcDiffShift(ind1)=newDataSignal(topNet,['met1LcDiffShift',num2str(ind1),num2str(ind)],outDataTypeA,dataRate);%#ok<AGROW>
                met1LcDiffShiftOvrflw(ind1)=newDataSignal(topNet,['met1LcDiffShiftOvrflw',num2str(ind1),num2str(ind)],outDataTypeA,dataRate);%#ok<AGROW>
                LUTInp1Lc(ind1)=newDataSignal(topNet,['LUTInp1Lc',num2str(ind1),num2str(ind)],pir_ufixpt_t(7,0),dataRate);%#ok<AGROW>
                LUTout1Lc(ind1)=newDataSignal(topNet,['LUTout1Lc',num2str(ind1),num2str(ind)],pir_ufixpt_t(16,-16),dataRate);%#ok<AGROW>
                LUTout1LcReg(ind1)=newDataSignal(topNet,['LUTout1LcReg',num2str(ind1),num2str(ind)],outDataTypeA,dataRate);%#ok<AGROW>
                LUTout1LcReg1(ind1)=newDataSignal(topNet,['LUTout1LcReg1',num2str(ind1),num2str(ind)],outDataTypeA,dataRate);%#ok<AGROW>
                metric1LcTemp1(ind1)=newDataSignal(topNet,['metric1LcTemp1',num2str(ind1),num2str(ind)],outDataTypeA,dataRate);%#ok<AGROW>

                pirelab.getIntDelayComp(topNet,t0(ind1+1),metric0LcReg(ind1),ind1-1,'',0);
                pirelab.getTreeArch(topNet,[temp0,metric0LcReg(ind1)],metric0TempLc(ind1),'max','Floor','Wrap','','Zero',true);

                pirelab.getSubComp(topNet,[temp0,metric0LcReg(ind1)],met0LcDiff(ind1),'Floor','Wrap','');
                pirelab.getAbsComp(topNet,met0LcDiff(ind1),met0LcDiffAbs(ind1));
                pirelab.getBitShiftComp(topNet,met0LcDiffAbs(ind1),met0LcDiffShift(ind1),'sll',4);
                pirelab.getDTCComp(topNet,met0LcDiffShift(ind1),LUTInp0Lc(ind1),'Floor','Wrap');
                pirelab.getDirectLookupComp(topNet,LUTInp0Lc(ind1),LUTout0Lc(ind1),LOGMAPLUT,'LogMAPLUT','','','','',outDataTypeA);
                pirelab.getCompareToValueComp(topNet,met0LcDiffAbs(ind1),met0LcDiffShiftOvrflw(ind1),'>',7.9375);
                pirelab.getSwitchComp(topNet,[LUTout0Lc(ind1),zeroSig],LUTout0LcReg(ind1),met0LcDiffShiftOvrflw(ind1));
                pirelab.getIntDelayComp(topNet,LUTout0LcReg(ind1),LUTout0LcReg1(ind1),1,'',0);
                pirelab.getAddComp(topNet,[metric0TempLc(ind1),LUTout0LcReg1(ind1)],metric0LcTemp1(ind1),'Floor','Wrap','');
                temp0=metric0LcTemp1(ind1);

                pirelab.getIntDelayComp(topNet,t1(ind1+1),metric1LcReg(ind1),ind1-1,'',0);
                pirelab.getTreeArch(topNet,[temp1,metric1LcReg(ind1)],metric1TempLc(ind1),'max','Floor','Wrap','','Zero',true);

                pirelab.getSubComp(topNet,[temp1,metric1LcReg(ind1)],met1LcDiff(ind1),'Floor','Wrap','');
                pirelab.getAbsComp(topNet,met1LcDiff(ind1),met1LcDiffAbs(ind1));
                pirelab.getBitShiftComp(topNet,met1LcDiffAbs(ind1),met1LcDiffShift(ind1),'sll',4);
                pirelab.getDTCComp(topNet,met1LcDiffShift(ind1),LUTInp1Lc(ind1),'Floor','Wrap');
                pirelab.getDirectLookupComp(topNet,LUTInp1Lc(ind1),LUTout1Lc(ind1),LOGMAPLUT,'LogMAPLUT','','','','',outDataTypeA);
                pirelab.getCompareToValueComp(topNet,met1LcDiffAbs(ind1),met1LcDiffShiftOvrflw(ind1),'>',7.9375);
                pirelab.getSwitchComp(topNet,[LUTout1Lc(ind1),zeroSig],LUTout1LcReg(ind1),met1LcDiffShiftOvrflw(ind1));
                pirelab.getIntDelayComp(topNet,LUTout1LcReg(ind1),LUTout1LcReg1(ind1),1,'',0);
                pirelab.getAddComp(topNet,[metric1TempLc(ind1),LUTout1LcReg1(ind1)],metric1LcTemp1(ind1),'Floor','Wrap','');

                temp1=metric1LcTemp1(ind1);
            end
            pirelab.getWireComp(topNet,metric0LcTemp1(ALPHASIZE-1),maxt0(ind));
            pirelab.getWireComp(topNet,metric1LcTemp1(ALPHASIZE-1),maxt1(ind));
        else
            temp0=t0(1);
            temp1=t1(1);
            for ind1=1:ALPHASIZE-1
                metric0TempLc(ind1)=newDataSignal(topNet,['metric0TempLc_',num2str(ind1),num2str(ind)],outDataTypeA,dataRate);
                metric1TempLc(ind1)=newDataSignal(topNet,['metric1TempLc_',num2str(ind1),num2str(ind)],outDataTypeA,dataRate);
                metric0LcReg(ind1)=newDataSignal(topNet,['metric0LcReg',num2str(ind1),num2str(ind)],outDataTypeA,dataRate);
                metric1LcReg(ind1)=newDataSignal(topNet,['metric1LcReg',num2str(ind1),num2str(ind)],outDataTypeA,dataRate);

                pirelab.getIntDelayComp(topNet,t0(ind1+1),metric0LcReg(ind1),ind1-1,'',INITVAL);
                pirelab.getIntDelayComp(topNet,t1(ind1+1),metric1LcReg(ind1),ind1-1,'',INITVAL);

                pirelab.getTreeArch(topNet,[temp0,metric0LcReg(ind1)],metric0TempLc(ind1),'max','Floor','Wrap','','Zero',true);
                temp0=metric0TempLc(ind1);

                pirelab.getTreeArch(topNet,[temp1,metric1LcReg(ind1)],metric1TempLc(ind1),'max','Floor','Wrap','','Zero',true);
                temp1=metric1TempLc(ind1);
            end
            pirelab.getWireComp(topNet,metric0TempLc(ALPHASIZE-1),maxt0(ind));
            pirelab.getWireComp(topNet,metric1TempLc(ALPHASIZE-1),maxt1(ind));
        end

        pirelab.getSubComp(topNet,[maxt1(ind),maxt0(ind)],diffMetricsCoded(ind),'Floor','Wrap','');
        pirelab.getSubComp(topNet,[diffMetricsCoded(ind),lcRAMDemux(ind)],llrcRev(ind),'Floor','Wrap','');
    end



    llrcOutRAM=newDataSignal(topNet,'llrcOutRAM',pirelab.getPirVectorType(pir_sfixpt_t(INPWL,FRACLEN),VECLEN),dataRate);
    llruOutRAM=newDataSignal(topNet,'llruOutRAM',pir_sfixpt_t(INPWL,FRACLEN),dataRate);
    llrcRevMux=newDataSignal(topNet,'llrcRevMux',pirelab.getPirVectorType(pir_sfixpt_t(INPWL,FRACLEN),VECLEN),dataRate);
    ramLu=pirelab.getSimpleDualPortRamComp(topNet,[llruRev,wrAddrOut,wrEnOut,rdAddrOut],...
    llruOutRAM,'RAM for LLRu',1,-1,[],'','','none');
    ramLu.addComment('');
    pirelab.getMuxComp(topNet,llrcRev,llrcRevMux);
    ramLc=pirelab.getSimpleDualPortRamComp(topNet,[llrcRevMux,wrAddrOut,wrEnOut,rdAddrOut],...
    llrcOutRAM,'RAM for LLRc',VECLEN,-1,[],'','','none');
    ramLc.addComment('');


    lastWind1=newControlSignal(topNet,'lastWind1',dataRate);
    lastWind1Reg=newControlSignal(topNet,'lastWind1Reg',dataRate);

    finalCount=newDataSignal(topNet,'finalCount',pir_ufixpt_t(8,0),dataRate);
    pirelab.getCounterComp(topNet,[rstCounter,wrEnOut],finalCount,...
    'Count limited',...
    0.0,...
    1.0,...
    WINDLEN-1,...
    true,...
    false,...
    true,...
    false,...
    'FinalOutputCounter');
    outWindStart=newControlSignal(topNet,'outWindStart',dataRate);
    outWindStart1=newControlSignal(topNet,'outWindStart1',dataRate);
    loadCounter=newControlSignal(topNet,'loadCounter',dataRate);
    loadCounterReg=newControlSignal(topNet,'loadCounterReg',dataRate);
    lastWinStart=newControlSignal(topNet,'lastWinStart',dataRate);
    outCount=newDataSignal(topNet,'outCount',pir_ufixpt_t(8,0),dataRate);
    outCntEnb=newControlSignal(topNet,'outCntEnb',dataRate);

    pirelab.getCompareToValueComp(topNet,finalCount,outWindStart1,'==',WINDLENM1);

    pirelab.getRelOpComp(topNet,[finalCount,lastWinLen],loadCounter,'==');
    pirelab.getLogicComp(topNet,[loadCounter,lastWind1],loadCounterReg,'and');

    rstCntEnb=newControlSignal(topNet,'rstCntEnb',dataRate);
    rstCounterReg=newControlSignal(topNet,'rstCounterReg',dataRate);
    countForResetLast=newDataSignal(topNet,'countForResetLast',pir_ufixpt_t(8,0),dataRate);
    zeroSig=newDataSignal(topNet,'zeroSig',pir_ufixpt_t(8,0),dataRate);
    pirelab.getConstComp(topNet,zeroSig,0);

    pirelab.getCounterComp(topNet,[rstCounter,zeroSig,rstCntEnb],countForResetLast,...
    'Count limited',...
    WINDLEN,...
    1.0,...
    WINDLEN,...
    false,...
    true,...
    true,...
    false,...
    'OutputCounterforReset');
    pirelab.getCompareToValueComp(topNet,countForResetLast,rstCntEnb,'<',WINDLEN);
    outStart1=newControlSignal(topNet,'outStart1',dataRate);
    remSamples=newDataSignal(topNet,'remSamples',pir_ufixpt_t(8,0),dataRate);
    pirelab.getSubComp(topNet,[winLenMin2,lastWinLenReg],remSamples);
    pirelab.getRelOpComp(topNet,[countForResetLast,remSamples],outStart1,'==');
    pirelab.getCompareToValueComp(topNet,countForResetLast,lastWinStart,'==',WINDLENM1);
    pirelab.getLogicComp(topNet,[outStart1,outWindStart1],outWindStart,'or');

    outCntRst=newControlSignal(topNet,'outCntRst',dataRate);
    outCountRst=newControlSignal(topNet,'outCountRst',dataRate);
    outCountRstReg=newControlSignal(topNet,'outCountRstReg',dataRate);
    endReg=newControlSignal(topNet,'endReg',dataRate);
    endReg1=newControlSignal(topNet,'endReg1',dataRate);
    endOutReg=newControlSignal(topNet,'endOutReg',dataRate);
    rstCounterNOT=newControlSignal(topNet,'rstCounterNOT',dataRate);
    strtOutReg=newControlSignal(topNet,'strtOutReg',dataRate);


    startWind=newControlSignal(topNet,'startWind',dataRate);
    startWindSwitchOut=newControlSignal(topNet,'startWindSwitchOut',dataRate);
    windEnd=newControlSignal(topNet,'windEnd',dataRate);

    pirelab.getWireComp(topNet,outWindStart,startWind);
    pirelab.getLogicComp(topNet,[outCountRst,endReg],outCountRstReg,'and');

    pirelab.getSwitchComp(topNet,[outWindStart,startWind],startWindSwitchOut,endReg);

    pirelab.getCounterComp(topNet,[outCountRstReg,startWindSwitchOut,zeroSig,outCntEnb],outCount,...
    'Count limited',...
    WINDLEN,...
    1.0,...
    WINDLEN,...
    true,...
    true,...
    true,...
    false,...
    'OutputCounter1');
    pirelab.getCompareToValueComp(topNet,outCount,outCntEnb,'<',WINDLEN);
    pirelab.getCompareToValueComp(topNet,outCount,windEnd,'==',WINDLENM1);
    pirelab.getLogicComp(topNet,[rstCntEnb,windEnd],rstCounterReg,'and');

    pirelab.getIntDelayComp(topNet,outCntEnb,validOut,1,'',0);

    pirelab.getLogicComp(topNet,[startOutReg,outWindStart],strtOutReg,'and');

    pirelab.getIntDelayComp(topNet,strtOutReg,startOut,2,'',0);

    pirelab.getIntDelayComp(topNet,lastWinLenReg,lastWinLenReg1,1,'',0);
    pirelab.getRelOpComp(topNet,[outCount,lastWinLenReg1],endReg1,'==');
    pirelab.getCompareToValueComp(topNet,lastWinLenReg1,endReg,'~=',WINDLENM1);

    pirelab.getLogicComp(topNet,rstCounter,rstCounterNOT,'not');
    pirelab.getLogicComp(topNet,[outCountRst,rstCounterNOT],outCntRst,'and');
    pirelab.getUnitDelayEnabledResettableComp(topNet,lastWinStart,lastWind1Reg,lastWinStart,outCntRst,...
    '',0,'',true);
    pirelab.getLogicComp(topNet,[lastWinStart,lastWind1Reg],lastWind1,'or');

    pirelab.getLogicComp(topNet,[endReg1,lastWind1],outCountRst,'and');

    pirelab.getWireComp(topNet,outCountRst,endOutReg);

    pirelab.getIntDelayComp(topNet,endOutReg,endOut,1,'',0);


    zeroLuSig=newDataSignal(topNet,'zeroLuSig',pir_sfixpt_t(INPWL,FRACLEN),dataRate);
    pirelab.getConstComp(topNet,zeroLuSig,0);
    pirelab.getSwitchComp(topNet,[zeroLuSig,llruOutRAM],llruOut,validOut);

    for ind=1:VECLEN
        zeroLcSig(ind)=newDataSignal(topNet,['zeroLcSig_',num2str(ind)],pir_sfixpt_t(INPWL,FRACLEN),dataRate);%#ok<AGROW>
        pirelab.getConstComp(topNet,zeroLcSig(ind),0);
    end
    zeroLcSigMux=newDataSignal(topNet,'zeroLcSigMux',pirelab.getPirVectorType(pir_sfixpt_t(INPWL,FRACLEN),VECLEN),dataRate);
    pirelab.getMuxComp(topNet,zeroLcSig,zeroLcSigMux);
    pirelab.getSwitchComp(topNet,[zeroLcSigMux,llrcOutRAM],llrcOut,validOut);



    function signal=newControlSignal(topNet,name,rate)
        controlType=pir_ufixpt_t(1,0);
        signal=topNet.addSignal(controlType,name);
        signal.SimulinkRate=rate;
    end

    function signal=newDataSignal(topNet,name,inType,rate)
        signal=topNet.addSignal(inType,name);
        signal.SimulinkRate=rate;
    end


end



