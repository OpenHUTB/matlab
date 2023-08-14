function betaNet=elaborateBetaCompute(~,topNet,blockInfo,dataRate)


    WINDLEN=blockInfo.WindowLength;
    WORDLEN=blockInfo.wordSize;
    FRACLEN=blockInfo.fracSize;
    VECLEN=blockInfo.vecSize;
    BETASIZE=blockInfo.alphaSize;
    BIT0IND=blockInfo.bit0indices;
    BIT1IND=blockInfo.bit1indices;
    TERMMODE=blockInfo.TermMode;
    ALGO=blockInfo.Algorithm;
    LOGMAPLUT=blockInfo.logMAPLUT;
    K=blockInfo.ConstrLen;
    INPWL=WORDLEN+floor(log2(VECLEN))+2+floor(log2(K-1));
    OUTWL=INPWL;

    boolType=pir_boolean_t();
    inDataType=pir_sfixpt_t(INPWL,FRACLEN);
    inVecType=pirelab.getPirVectorType(inDataType,2^VECLEN);
    outDataType=pir_sfixpt_t(OUTWL,FRACLEN);
    outVecType=pirelab.getPirVectorType(outDataType,BETASIZE);



    inportNames={'gamma0','gamma1','validIn','loadSig','endIn'};
    inTypes=[inVecType,inVecType,boolType,boolType,boolType];
    indataRates=dataRate*ones(1,length(inportNames));

    outportNames={'beta0','beta1','validOut'};
    outTypes=[outVecType,outVecType,boolType];

    betaNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','betaNetwork',...
    'InportNames',inportNames,...
    'InportTypes',inTypes,...
    'InportRates',indataRates,...
    'OutportNames',outportNames,...
    'OutportTypes',outTypes...
    );

    gamma0=betaNet.PirInputSignals(1);
    gamma1=betaNet.PirInputSignals(2);
    validIn=betaNet.PirInputSignals(3);
    loadSig=betaNet.PirInputSignals(4);
    endIn=betaNet.PirInputSignals(5);

    beta0=betaNet.PirOutputSignals(1);
    beta1=betaNet.PirOutputSignals(2);
    validOut=betaNet.PirOutputSignals(3);

    endInReg=betaNet.addSignal(boolType,'endInReg');
    endInReg1=betaNet.addSignal(boolType,'endInReg1');
    pirelab.getIntDelayComp(betaNet,endIn,endInReg,3,'',0);
    pirelab.getIntDelayComp(betaNet,endInReg,endInReg1,1,'',0);

    loadSigReg=betaNet.addSignal(boolType,'loadSigReg');
    pirelab.getIntDelayComp(betaNet,loadSig,loadSigReg,3,'',0);

    ctrlSig=betaNet.addSignal(boolType,'ctrlSig');
    ctrlSigReg=betaNet.addSignal(boolType,'ctrlSigReg');
    validInReg=betaNet.addSignal(boolType,'validInReg');
    pirelab.getLogicComp(betaNet,[endInReg,loadSigReg],ctrlSig,'or');
    pirelab.getIntDelayComp(betaNet,loadSigReg,ctrlSigReg,1,'',0);

    pirelab.getIntDelayComp(betaNet,validIn,validInReg,0,'',0);

    for ind=1:BETASIZE
        betaMax(ind)=newDataSignal(betaNet,['betaMax_',num2str(ind)],outDataType,dataRate);%#ok<AGROW>
        betaMaxT(ind)=newDataSignal(betaNet,['betaMaxT_',num2str(ind)],outDataType,dataRate);%#ok<AGROW>
        betaMax0(ind)=newDataSignal(betaNet,['betaMax0_',num2str(ind)],outDataType,dataRate);%#ok<AGROW>
        betaMax1(ind)=newDataSignal(betaNet,['betaMax1_',num2str(ind)],outDataType,dataRate);%#ok<AGROW>
        betaReg0(ind)=newDataSignal(betaNet,['betaReg0_',num2str(ind)],outDataType,dataRate);%#ok<AGROW>
        betaReg1(ind)=newDataSignal(betaNet,['betaReg1_',num2str(ind)],outDataType,dataRate);%#ok<AGROW>
        betaReg0Temp(ind)=newDataSignal(betaNet,['betaReg0Temp_',num2str(ind)],outDataType,dataRate);%#ok<AGROW>
        betaReg1Temp(ind)=newDataSignal(betaNet,['betaReg1Temp_',num2str(ind)],outDataType,dataRate);%#ok<AGROW>
        betaMaxM(ind)=newDataSignal(betaNet,['betaMaxM_',num2str(ind)],outDataType,dataRate);%#ok<AGROW>
        LUTout(ind)=newDataSignal(betaNet,['LUTout_',num2str(ind)],outDataType,dataRate);%#ok<AGROW>
        betaCtrl(ind)=newDataSignal(betaNet,['betaCtrl',num2str(ind)],boolType,dataRate);%#ok<AGROW>
        betaSub(ind)=newDataSignal(betaNet,['betaSub',num2str(ind)],outDataType,dataRate);%#ok<AGROW>
    end

    betaTemp1=newDataSignal(betaNet,'betaTemp1',outVecType,dataRate);
    betaTemp2=newDataSignal(betaNet,'betaTemp2',outVecType,dataRate);
    betaDiff=newDataSignal(betaNet,'betaDiff',outVecType,dataRate);
    betaDiffAbs=newDataSignal(betaNet,'betaDiffAbs',outVecType,dataRate);
    betaDiffShift=newDataSignal(betaNet,'betaDiffShift',outVecType,dataRate);
    LUTInp=newDataSignal(betaNet,'LUTInp',pirelab.getPirVectorType(pir_ufixpt_t(7,0),BETASIZE),dataRate);
    LUTout1=newDataSignal(betaNet,'LUTout1',outVecType,dataRate);
    betaDiffOverflow=newDataSignal(betaNet,'betaDiffOverflow',pirelab.getPirVectorType(boolType,BETASIZE),dataRate);

    zeroSig=newDataSignal(betaNet,'zeroSig',outDataType,dataRate);
    pirelab.getConstComp(betaNet,zeroSig,0);

    for ind=1:2*BETASIZE
        betaTemp(ind)=newDataSignal(betaNet,['betaTemp_',num2str(ind)],outDataType,dataRate);%#ok<AGROW>
    end

    gam0Demx=[];
    gam1Demx=[];
    for ind=1:2^VECLEN
        gamma0Demux(ind)=newDataSignal(betaNet,['Gamma0Demux_',num2str(ind)],inDataType,dataRate);%#ok<AGROW> 
        gam0Demx=[gam0Demx,gamma0Demux(ind)];%#ok<AGROW>
        gamma1Demux(ind)=newDataSignal(betaNet,['Gamma1Demux_',num2str(ind)],inDataType,dataRate);%#ok<AGROW> 
        gam1Demx=[gam1Demx,gamma1Demux(ind)];%#ok<AGROW>
    end
    pirelab.getDemuxComp(betaNet,gamma0,gam0Demx);
    pirelab.getDemuxComp(betaNet,gamma1,gam1Demx);


    for ind=1:BETASIZE
        pirelab.getAddComp(betaNet,[betaReg0(ind),gam0Demx(BIT0IND(ind))],betaTemp(2*ind-1),'Floor','Wrap','beta0 adders');
        pirelab.getAddComp(betaNet,[betaReg1(ind),gam1Demx(BIT1IND(ind))],betaTemp(2*ind),'Floor','Wrap','beta0 adders');
    end
    pirelab.getMuxComp(betaNet,betaTemp(1:2:end),betaTemp1);
    pirelab.getMuxComp(betaNet,betaTemp(2:2:end),betaTemp2);

    for ind=1:2:2*BETASIZE
        pirelab.getSubComp(betaNet,[betaTemp(ind),betaTemp(ind+1)],betaSub(floor(ind/2)+1),'Floor','Wrap');
        pirelab.getBitSliceComp(betaNet,betaSub(floor(ind/2)+1),betaCtrl(floor(ind/2)+1),INPWL-1,INPWL-1,'bit_extract');
        pirelab.getSwitchComp(betaNet,[betaTemp(ind),betaTemp(ind+1)],betaMaxM(floor(ind/2)+1),betaCtrl(floor(ind/2)+1));
    end

    for ind=1:BETASIZE
        LUTout1Dmx(ind)=newDataSignal(betaNet,['LUTout1Dmx',num2str(ind)],outDataType,dataRate);%#ok<AGROW>
        betaDiffOverflowDmx(ind)=newDataSignal(betaNet,['betaDiffOverflowDmx',num2str(ind)],boolType,dataRate);%#ok<AGROW>
    end

    if strcmpi(ALGO,'Log MAP (max*)')
        pirelab.getSubComp(betaNet,[betaTemp1,betaTemp2],betaDiff,'Floor','Wrap','');
        pirelab.getAbsComp(betaNet,betaDiff,betaDiffAbs);
        pirelab.getBitShiftComp(betaNet,betaDiffAbs,betaDiffShift,'sll',4);
        pirelab.getDTCComp(betaNet,betaDiffShift,LUTInp,'Floor','Wrap');
        pirelab.getDirectLookupComp(betaNet,LUTInp,LUTout1,LOGMAPLUT,'LogMAPLUT','','','','',outDataType,true);
        pirelab.getCompareToValueComp(betaNet,betaDiffAbs,betaDiffOverflow,'>',7.9375);
    end

    pirelab.getDemuxComp(betaNet,betaDiffOverflow,betaDiffOverflowDmx);
    pirelab.getDemuxComp(betaNet,LUTout1,LUTout1Dmx);

    for ind=1:BETASIZE
        if strcmpi(ALGO,'Log MAP (max*)')
            pirelab.getSwitchComp(betaNet,[LUTout1Dmx(ind),zeroSig],LUTout(ind),betaDiffOverflowDmx(ind));
            pirelab.getAddComp(betaNet,[betaMaxM(ind),LUTout(ind)],betaMax(ind),'Floor','Wrap','');
        else
            pirelab.getWireComp(betaNet,betaMaxM(ind),betaMax(ind));
        end
    end

    for ind=1:BETASIZE
        pirelab.getSubComp(betaNet,[betaMax(ind),betaMax(1)],betaMaxT(ind),'Floor','Wrap','reduce bit width');
    end

    for ind=0:(BETASIZE-1)
        pirelab.getWireComp(betaNet,betaMaxT(floor(ind/2)+1),betaMax0(ind+1));
        pirelab.getWireComp(betaNet,betaMaxT(floor(ind/2)+1+(BETASIZE/2)),betaMax1(ind+1));
    end

    val0=newDataSignal(betaNet,'val0',outDataType,dataRate);
    val1=newDataSignal(betaNet,'val1',outDataType,dataRate);

    pirelab.getConstComp(betaNet,val0,0);
    pirelab.getConstComp(betaNet,val1,-2^(OUTWL+FRACLEN-2));

    for ind=1:BETASIZE
        init0(ind)=newDataSignal(betaNet,['init0',num2str(ind)],outDataType,dataRate);%#ok<AGROW> 
        init1(ind)=newDataSignal(betaNet,['init1',num2str(ind)],outDataType,dataRate);%#ok<AGROW> 
        init0Reg(ind)=newDataSignal(betaNet,['init0Reg',num2str(ind)],outDataType,dataRate);%#ok<AGROW> 
        init1Reg(ind)=newDataSignal(betaNet,['init1Reg',num2str(ind)],outDataType,dataRate);%#ok<AGROW> 

        if strcmpi(TERMMODE,'Truncated')
            pirelab.getWireComp(betaNet,val0,init0(ind));
            pirelab.getWireComp(betaNet,val0,init1(ind));
        else
            if ind==1||ind==2
                pirelab.getWireComp(betaNet,val0,init0(ind));
            else
                pirelab.getWireComp(betaNet,val1,init0(ind));
            end
            pirelab.getWireComp(betaNet,val1,init1(ind));
        end

        pirelab.getSwitchComp(betaNet,[val0,init0(ind)],init0Reg(ind),endInReg1);
        pirelab.getSwitchComp(betaNet,[val0,init1(ind)],init1Reg(ind),endInReg1);
    end

    for ind=1:BETASIZE
        pirelab.getUnitDelayEnabledComp(betaNet,betaMax0(ind),betaReg0Temp(ind),validInReg,['betaRegister_',num2str(ind)]);
        pirelab.getUnitDelayEnabledComp(betaNet,betaMax1(ind),betaReg1Temp(ind),validInReg,['betaRegister_',num2str(ind)]);

        pirelab.getSwitchComp(betaNet,[betaReg0Temp(ind),init0Reg(ind)],betaReg0(ind),ctrlSigReg);
        pirelab.getSwitchComp(betaNet,[betaReg1Temp(ind),init1Reg(ind)],betaReg1(ind),ctrlSigReg);
    end

    pirelab.getMuxComp(betaNet,betaReg0,beta0);
    pirelab.getMuxComp(betaNet,betaReg1,beta1);


    pirelab.getIntDelayComp(betaNet,validInReg,validOut,1,'validIn_register',0);


    function signal=newDataSignal(betaNet,name,inType,rate)
        signal=betaNet.addSignal(inType,name);
        signal.SimulinkRate=rate;
    end

end

