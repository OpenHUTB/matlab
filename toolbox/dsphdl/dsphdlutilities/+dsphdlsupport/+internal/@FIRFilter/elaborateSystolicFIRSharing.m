function elaborateSystolicFIRSharing(this,net,inSignals,outSignals,params)




%#ok<*AGROW>




    dataIn=inSignals(1);
    validIn=inSignals(2);
    ready=outSignals(3);
    if params.inMode(2)
        syncReset=inSignals(3);
    else
        syncReset='';
    end
    dataRate=dataIn.SimulinkRate;
    dataInType=pirgetdatatypeinfo(dataIn.Type);
    DATAIN_WORDLENGTH=dataInType.wordsize;
    DATAIN_FRACTIONLENGTH=dataInType.binarypoint;
    DATAIN_SIGN=dataInType.issigned;
    DATAIN_ISCOMPLEX=dataInType.iscomplex;
    dinDT=pir_fixpt_t(DATAIN_SIGN,DATAIN_WORDLENGTH,DATAIN_FRACTIONLENGTH);

    dataOut=outSignals(1);
    dataOutType=pirgetdatatypeinfo(dataOut.Type);
    DATAOUT_WORDLENGTH=dataOutType.wordsize;
    DATAOUT_FRACTIONLENGTH=dataOutType.binarypoint;
    DATAOUT_SIGN=dataOutType.issigned;

    doutDT=pir_fixpt_t(DATAOUT_SIGN,DATAOUT_WORDLENGTH,DATAOUT_FRACTIONLENGTH);

    COEFF_ISCOMPLEX=~isreal(params.Numerator);

    din=net.addSignal(dataIn.Type,'din');
    din.SimulinkRate=dataRate;
    dinSM=net.addSignal(dataIn.Type,'dinSM');
    dinSM.SimulinkRate=dataRate;
    dinVld=net.addSignal(pir_boolean_t,'dinVld');
    dinVld.SimulinkRate=dataRate;
    dinVldSM=net.addSignal(pir_boolean_t,'dinVldSM');
    dinVldSM.SimulinkRate=dataRate;
    validInREG=net.addSignal(pir_boolean_t,'validInREG');
    validInREG.SimulinkRate=dataRate;




    [symmInfo,isSymmetry]=getCoefficientsSymmetry(this,params);

    if length(params.Numerator)==2&&params.SharingFactor==2||size(params.Numerator,1)>1
        isSymmetry=false;
    end

    [a,numMuxInputs,numDlyLine,c,d]=getDesignParameter(this,isSymmetry,params);%#ok<*ASGLU>
    sharingCountWordLength=max(1,ceil(log2(params.SharingFactor)));



    sharingCountType=pir_fixpt_t(0,sharingCountWordLength,0);

    resetCountWordLength=max(2,ceil(log2((length(params.Numerator)+(params.SharingFactor*2))+2)));

    resetCountType=pir_fixpt_t(0,resetCountWordLength+1,0);
    sharingCount=net.addSignal(sharingCountType,'sharingCount');
    sharingCount.SimulinkRate=dataRate;
    rdCount=net.addSignal(sharingCountType,'rdCount');
    rdCount.SimulinkRate=dataRate;
    rdCountReverse=net.addSignal(sharingCountType,'rdCountReverse');
    rdCountReverse.SimulinkRate=dataRate;
    rdCountIncrement=net.addSignal(sharingCountType,'rdCountReverse');
    rdCountIncrement.SimulinkRate=dataRate;
    rdCountReverseIncrement=net.addSignal(sharingCountType,'rdCountReverse');
    rdCountReverseIncrement.SimulinkRate=dataRate;
    wrCount=net.addSignal(sharingCountType,'wrCount');
    wrCount.SimulinkRate=dataRate;
    nextSharingCount=net.addSignal(sharingCountType,'nextSharingCount');
    nextSharingCount.SimulinkRate=dataRate;
    nextDelayLineRdAddr=net.addSignal(sharingCountType,'nextDelayLineRdAddr');
    nextDelayLineRdAddr.SimulinkRate=dataRate;
    nextDelayLineRdAddrReverse=net.addSignal(sharingCountType,'nextDelayLineRdAddrReverse');
    nextDelayLineRdAddrReverse.SimulinkRate=dataRate;
    nextDelayLineWrAddr=net.addSignal(sharingCountType,'nextDelayLineWrAddr');
    nextDelayLineWrAddr.SimulinkRate=dataRate;
    lastPhaseStrobe=net.addSignal(pir_boolean_t,'lastPhaseStrobe');
    lastPhaseStrobe.SimulinkRate=dataRate;
    delayLineShiftEn(1)=net.addSignal(pir_boolean_t,'delayLineShiftEn0');
    delayLineShiftEn(1).SimulinkRate=dataRate;
    delayLineValidIn(1)=net.addSignal(pir_boolean_t,'delayLineValidIn0');
    delayLineValidIn(1).SimulinkRate=dataRate;
    delayLineShiftEnP=net.addSignal(pir_boolean_t,'delayLineShiftEnP');
    delayLineShiftEnP.SimulinkRate=dataRate;
    delayLineValidInP=net.addSignal(pir_boolean_t,'delayLineValidInP');
    delayLineValidInP.SimulinkRate=dataRate;
    rdAddr(1)=net.addSignal(sharingCountType,'rdAddr0');
    rdAddr(1).SimulinkRate=dataRate;
    rdAddrDelayLine(1)=net.addSignal(sharingCountType,'rdAddrDelayLine0');
    rdAddrDelayLine(1).SimulinkRate=dataRate;
    wrAddr(1)=net.addSignal(sharingCountType,'wrAddr0');
    wrAddr(1).SimulinkRate=dataRate;
    wrAddrP=net.addSignal(sharingCountType,'wrAddrP');
    wrAddrP.SimulinkRate=dataRate;
    resetCount=net.addSignal(resetCountType,'resetCount');
    resetCount.SimulinkRate=dataRate;
    rdAddrDelayLineReverse(1)=net.addSignal(sharingCountType,'rdAddrReverse0');
    rdAddrDelayLineReverse(1).SimulinkRate=dataRate;
    readyS=net.addSignal(pir_boolean_t,'readyS');
    readyS.SimulinkRate=dataRate;
    readySM=net.addSignal(pir_boolean_t,'readySM');
    readySM.SimulinkRate=dataRate;
    syncResetN=net.addSignal(pir_boolean_t,'syncResetN');
    syncResetN.SimulinkRate=dataRate;
    syncResetREG=net.addSignal(pir_boolean_t,'syncResetREG');
    syncResetREG.SimulinkRate=dataRate;
    syncResetRst=net.addSignal(pir_boolean_t,'syncResetRst');
    syncResetRst.SimulinkRate=dataRate;
    transientPad=net.addSignal(pir_boolean_t,'transientPad');
    transientPad.SimulinkRate=dataRate;
    transientClear=net.addSignal(pir_boolean_t,'transientClear');
    transientClear.SimulinkRate=dataRate;
    transientNotClear=net.addSignal(pir_boolean_t,'transientNotClear');
    transientNotClear.SimulinkRate=dataRate;
    resetCountOverOne=net.addSignal(pir_boolean_t,'resetCountOverOne');
    resetCountOverOne.SimulinkRate=dataRate;
    resetEn=net.addSignal(pir_boolean_t,'resetEn');
    resetEn.SimulinkRate=dataRate;
    resetRst=net.addSignal(pir_boolean_t,'resetRst');
    resetRst.SimulinkRate=dataRate;
    transientEn=net.addSignal(pir_boolean_t,'transientEn');
    transientEn.SimulinkRate=dataRate;
    RAMNotFull=net.addSignal(pir_boolean_t,'RAMNotFull');
    RAMNotFull.SimulinkRate=dataRate;
    transientNotClearEn=net.addSignal(pir_boolean_t,'transientNotClearEn');
    transientNotClearEn.SimulinkRate=dataRate;
    transientClearEn=net.addSignal(pir_boolean_t,'transientClearEn');
    transientClearEn.SimulinkRate=dataRate;
    zeroOutput=net.addSignal(pir_boolean_t,'zeroOutput');
    zeroOutput.SimulinkRate=dataRate;
    notValid=net.addSignal(pir_boolean_t,'notValid');
    notValid.SimulinkRate=dataRate;
    resetEn1=net.addSignal(pir_boolean_t,'resetEn1');
    resetEn1.SimulinkRate=dataRate;
    resetEn2=net.addSignal(pir_boolean_t,'resetEn2');
    resetEn2.SimulinkRate=dataRate;
    dinVldZero=net.addSignal(pir_boolean_t,'dinVldZero');
    dinVldZero.SimulinkRate=dataRate;
    dinVldSwitch=net.addSignal(pir_boolean_t,'dinVldSwitch');
    dinVldSwitch.SimulinkRate=dataRate;
    dinSwitch=net.addSignal(dataIn.Type,'dinSwitch');
    dinSwitch.SimulinkRate=dataRate;
    dinZero=net.addSignal(dataIn.Type,'dinZero');
    dinZero.SimulinkRate=dataRate;

    for k=2:numDlyLine
        idxStr=int2str(k-1);
        delayLineShiftEn(k)=net.addSignal(pir_boolean_t,['delayLineShiftEn',idxStr]);
        delayLineShiftEn(k).SimulinkRate=dataRate;

        delayLineValidIn(k)=delayLineShiftEn(k);
        rdAddr(k)=net.addSignal(sharingCountType,['rdAddr',idxStr]);
        rdAddr(k).SimulinkRate=dataRate;
        rdAddrDelayLine(k)=net.addSignal(sharingCountType,['rdAddrDelayLine',idxStr]);
        rdAddrDelayLine(k).SimulinkRate=dataRate;
        wrAddr(k)=net.addSignal(sharingCountType,['wrAddr',idxStr]);
        wrAddr(k).SimulinkRate=dataRate;
        rdAddrDelayLineReverse(k)=net.addSignal(sharingCountType,['rdAddReverse',idxStr]);
        rdAddrDelayLineReverse(k).SimulinkRate=dataRate;
    end

    for k=1:numDlyLine-1
        if isSymmetry&&k>ceil(numDlyLine/2)
            dly=0;
        else
            dly=1;
        end

        if k>1
            pirelab.getIntDelayEnabledResettableComp(net,delayLineShiftEn(k),delayLineShiftEn(k+1),'',syncResetRst,dly,delayLineShiftEn(k+1).name);
        else
            pirelab.getIntDelayEnabledResettableComp(net,delayLineShiftEn(k),delayLineShiftEn(k+1),'','',dly,delayLineShiftEn(k+1).name);
        end
        pirelab.getIntDelayEnabledResettableComp(net,rdAddr(k),rdAddr(k+1),'',syncReset,dly,rdAddr(k).name);
        pirelab.getIntDelayEnabledResettableComp(net,rdAddrDelayLine(k),rdAddrDelayLine(k+1),'',syncReset,dly,rdAddrDelayLine(k).name);
        pirelab.getIntDelayEnabledResettableComp(net,wrAddr(k),wrAddr(k+1),'','',dly,wrAddr(k).name);
        pirelab.getIntDelayEnabledResettableComp(net,rdAddrDelayLineReverse(k),rdAddrDelayLineReverse(k+1),'',syncReset,dly,rdAddrDelayLineReverse(k).name);


    end




    firRdyLogic=elaborateFIRReadyLogic(this,net,params,dataRate,...
    dataIn,validIn,syncReset,...
    readySM,dinSM,dinVldSM,...
    DATAIN_SIGN,DATAIN_WORDLENGTH,DATAIN_FRACTIONLENGTH,params.SharingFactor);

    if params.inMode(2)
        pirelab.getConstComp(net,dinVldZero,false);
        pirelab.getSwitchComp(net,[validIn,dinVldZero],dinVldSwitch,syncReset,'validReset');
        pirelab.getConstComp(net,dinZero,0);
        pirelab.getSwitchComp(net,[dataIn,dinZero],dinSwitch,syncReset,'validReset');
    else
        pirelab.getWireComp(net,validIn,dinVldSwitch);
        pirelab.getWireComp(net,dataIn,dinSwitch);
    end

    pirelab.instantiateNetwork(net,firRdyLogic,[dinSwitch,dinVldSwitch,syncReset],...
    [readyS,dinSM,dinVldSM],...
    'firRdyLogic');


    pirelab.getWireComp(net,dinSM,din);
    pirelab.getWireComp(net,dinVldSM,dinVld);





    din_re=net.addSignal2('Type',dinDT,'Name','din_re');
    din_re.SimulinkRate=dataRate;
    dout_re=net.addSignal2('Type',doutDT,'Name','dout_re');
    dout_re.SimulinkRate=dataRate;
    dataZero=net.addSignal2('Type',doutDT,'Name','dataZero');
    dataZero.SimulinkRate=dataRate;

    if DATAIN_ISCOMPLEX||~isreal(params.Numerator)
        din_im=net.addSignal2('Type',dinDT,'Name','din_im');
        din_im.SimulinkRate=dataRate;
        dout_im=net.addSignal2('Type',doutDT,'Name','dout_im');
        dout_im.SimulinkRate=dataRate;
    end

    if DATAIN_ISCOMPLEX
        pirelab.getComplex2RealImag(net,din,[din_re,din_im],'Real and Imag');
    else
        pirelab.getWireComp(net,din,din_re);
    end

    doutVld=net.addSignal2('Type',pir_boolean_t,'Name','vldOut');
    doutVld.SimulinkRate=dataRate;




    pirelab.getConstComp(net,dataZero,0);


    if params.inMode(2)
        [numMults,numMuxInputs,numDlyLine,dlyLineLen,numCoeffTable]=getDesignParameter(this,isSymmetry,params);

        if size(params.Numerator,1)==1
            resetCycleLength=length(params.Numerator);
            sharingCycle=params.SharingFactor;

        else
            usedCoeff=params.Numerator;
            subLength=size(usedCoeff,2);
            resetCycleLength=(subLength*2);
            sharingCycle=3;
        end

        pirelab.getLogicComp(net,[delayLineValidInP,syncReset],delayLineValidIn(1),'or');
        pirelab.getLogicComp(net,[delayLineShiftEnP,syncReset],delayLineShiftEn(1),'or');
        pirelab.getLogicComp(net,syncReset,syncResetN,'not');
        pirelab.getIntDelayEnabledResettableComp(net,syncReset,syncResetREG,'','',1,syncResetREG.name);
        pirelab.getLogicComp(net,[syncResetREG,syncResetN],syncResetRst,'and');

        pirelab.getCounterComp(net,[resetRst,resetEn],resetCount,'Free running',...
        0,1,[],true,false,true,false,'Reset Count',1);

        pirelab.getCompareToValueComp(net,resetCount,RAMNotFull,'<=',(sharingCycle)+ceil(resetCycleLength)/sharingCycle);

        if sharingCycle==2&&size(params.Numerator,1)==1
            if(length(params.Numerator))==2
                pirelab.getCompareToValueComp(net,resetCount,transientNotClear,'<=',(resetCycleLength+(sharingCycle*2))+1);
            else
                pirelab.getCompareToValueComp(net,resetCount,transientNotClear,'<=',(resetCycleLength+(sharingCycle*2))+2);

            end
        else
            pirelab.getCompareToValueComp(net,resetCount,transientNotClear,'<=',(resetCycleLength+(sharingCycle))+1);
        end

        pirelab.getLogicComp(net,transientNotClear,transientClear,'not');
        pirelab.getCompareToValueComp(net,resetCount,resetCountOverOne,'>',0);

        pirelab.getLogicComp(net,[transientPad,lastPhaseStrobe],transientNotClearEn,'and');
        pirelab.getWireComp(net,transientNotClearEn,resetEn1);
        pirelab.getLogicComp(net,[syncReset,RAMNotFull],resetEn2,'and');
        pirelab.getLogicComp(net,[resetEn1,resetEn2],resetEn,'or');
        pirelab.getLogicComp(net,[resetCountOverOne,RAMNotFull,syncResetRst],transientEn,'and');
        pirelab.getLogicComp(net,[transientClear,syncResetRst],resetRst,'or');
        pirelab.getLogicComp(net,[transientClear,lastPhaseStrobe],transientClearEn,'and');

        if DATAIN_ISCOMPLEX&&COEFF_ISCOMPLEX
            doutVldReg=net.addSignal2('Type',pir_boolean_t,'Name','doutVldReg');
            doutVldReg.SimulinkRate=dataRate;
            pirelab.getLogicComp(net,doutVldReg,notValid,'not');
        else
            pirelab.getLogicComp(net,doutVld,notValid,'not');
        end

        pirelab.getLogicComp(net,[notValid,transientPad],zeroOutput,'or');

        pirelab.getIntDelayEnabledResettableComp(net,transientEn,transientPad,transientEn,transientClear,1,transientPad.name);

        pirelab.getSwitchComp(net,[wrAddrP,resetCount],wrAddr(1),syncReset);

    else
        if DATAIN_ISCOMPLEX&&COEFF_ISCOMPLEX
            doutVldReg=net.addSignal2('Type',pir_boolean_t,'Name','doutVldReg');
            doutVldReg.SimulinkRate=dataRate;
            pirelab.getLogicComp(net,doutVldReg,notValid,'not');
        else
            pirelab.getLogicComp(net,doutVld,notValid,'not');
        end

        pirelab.getWireComp(net,notValid,zeroOutput);
        pirelab.getWireComp(net,wrAddrP,wrAddr(1));
        pirelab.getWireComp(net,delayLineValidInP,delayLineValidIn(1));
        pirelab.getWireComp(net,delayLineShiftEnP,delayLineShiftEn(1));
    end




    if DATAIN_ISCOMPLEX&&COEFF_ISCOMPLEX
        DATAIN_WORDLENGTH=DATAIN_WORDLENGTH+1;
        din_cast=pir_fixpt_t(DATAIN_SIGN,DATAIN_WORDLENGTH,DATAIN_FRACTIONLENGTH);
        din_P=net.addSignal2('Type',din_cast,'Name','din_P');
        din_P.SimulinkRate=dataRate;
        din_M=net.addSignal2('Type',din_cast,'Name','din_M');
        din_M.SimulinkRate=dataRate;
        din_I=net.addSignal2('Type',din_cast,'Name','din_I');
        din_I.SimulinkRate=dataRate;
        dinReg_P=net.addSignal2('Type',din_cast,'Name','dinReg_P');
        dinReg_P.SimulinkRate=dataRate;
        dinReg_M=net.addSignal2('Type',din_cast,'Name','dinReg_M');
        dinReg_M.SimulinkRate=dataRate;
        dinReg_I=net.addSignal2('Type',din_cast,'Name','dinReg_I');
        dinReg_I.SimulinkRate=dataRate;
        dinVldReg=net.addSignal2('Type',pir_boolean_t,'Name','dinVldReg');
        dinVldReg.SimulinkRate=dataRate;
        pirelab.getDTCComp(net,din_re,din_P);
        pirelab.getDTCComp(net,din_im,din_M);
        pirelab.getAddComp(net,[din_re,din_im],din_I);
        pirelab.getIntDelayEnabledResettableComp(net,din_P,dinReg_P,dinVld,syncReset,1);
        pirelab.getIntDelayEnabledResettableComp(net,din_M,dinReg_M,dinVld,syncReset,1);
        pirelab.getIntDelayEnabledResettableComp(net,din_I,dinReg_I,dinVld,syncReset,1);
        pirelab.getIntDelayEnabledResettableComp(net,dinVld,dinVldReg,'',syncReset,1);

        coeffDT=fi(0,numerictype(params.NumeratorQuantized));
        Numerator_P=cast(real(params.Numerator),'like',coeffDT)+cast(imag(params.Numerator),'like',coeffDT);
        Numerator_M=cast(real(params.Numerator),'like',coeffDT)-cast(imag(params.Numerator),'like',coeffDT);
        Numerator_I=cast(imag(params.Numerator),'like',Numerator_P);
        params.NumeratorQuantized=cast(params.NumeratorQuantized,'like',Numerator_P);
        pirTypes=this.determineDataTypes(dinReg_P.Type,params);

        dout_P=net.addSignal2('Type',pirTypes.accumulatorType,'Name','dout_P');
        dout_P.SimulinkRate=dataRate;
        dout_M=net.addSignal2('Type',pirTypes.accumulatorType,'Name','dout_M');
        dout_M.SimulinkRate=dataRate;
        dout_I=net.addSignal2('Type',pirTypes.accumulatorType,'Name','dout_I');
        dout_I.SimulinkRate=dataRate;
        doutVld_M=net.addSignal2('Type',pir_boolean_t,'Name','vldOut_M');
        doutVld_M.SimulinkRate=dataRate;
        doutVld_I=net.addSignal2('Type',pir_boolean_t,'Name','vldOut_I');
        doutVld_I.SimulinkRate=dataRate;

        Fullprecision=true;



        numRows=size(params.Numerator,1);

        inputControlParams=struct(...
        'SHARING_FACTOR_ACTUAL',params.SharingFactor,...
        'NUM_MUX_INPUTS_ACTUAL',numMuxInputs,...
        'NUM_ROWS',numRows);

        if numRows==1
            controlFile='inputControl';
        else
            controlFile='inputControlInterleave';
        end

        this.elaborateCGIREML(net,inputControlParams,...
        [dinVldReg,sharingCount,rdCount,wrCount,rdCountReverse],...
        [delayLineValidInP,lastPhaseStrobe,nextSharingCount,nextDelayLineRdAddr,nextDelayLineWrAddr,nextDelayLineRdAddrReverse],...
        controlFile,...
        'Input control counter combinatorial logic');


        pirelab.getIntDelayEnabledResettableComp(net,nextSharingCount,sharingCount,'',syncReset,1,'sharingCount');
        pirelab.getIntDelayEnabledResettableComp(net,nextDelayLineRdAddr,rdCount,'',syncReset,1,'rdCount');
        pirelab.getIntDelayEnabledResettableComp(net,nextDelayLineWrAddr,wrCount,'',syncReset,1,'wrCount');
        pirelab.getIntDelayEnabledResettableComp(net,nextDelayLineRdAddrReverse,rdCountReverse,'',syncReset,1,'rdCountReverse');


        pirelab.getIntDelayEnabledResettableComp(net,sharingCount,rdAddr(1),'',syncReset,1,rdAddr(1).name);
        pirelab.getIntDelayEnabledResettableComp(net,rdCount,rdAddrDelayLine(1),'',syncReset,1,'rdAddrDelayLine');
        pirelab.getIntDelayEnabledResettableComp(net,wrCount,wrAddrP,'',syncReset,1,'wrAddr');
        pirelab.getWireComp(net,rdCountReverse,rdAddrDelayLineReverse(1));
        pirelab.getIntDelayEnabledResettableComp(net,lastPhaseStrobe,delayLineShiftEnP,'',syncReset,1,delayLineShiftEn(1).name);


        elabSystolicFIRSharingReal(this,net,[dinReg_P,dinVldReg,delayLineShiftEn,delayLineValidIn,rdAddr,rdAddrDelayLine,wrAddr,rdAddrDelayLineReverse,syncReset],[dout_P,doutVld],real(Numerator_P),symmInfo,isSymmetry,params,pirTypes,sharingCountType,Fullprecision);
        elabSystolicFIRSharingReal(this,net,[dinReg_M,dinVldReg,delayLineShiftEn,delayLineValidIn,rdAddr,rdAddrDelayLine,wrAddr,rdAddrDelayLineReverse,syncReset],[dout_M,doutVld_M],real(Numerator_M),symmInfo,isSymmetry,params,pirTypes,sharingCountType,Fullprecision);
        elabSystolicFIRSharingReal(this,net,[dinReg_I,dinVldReg,delayLineShiftEn,delayLineValidIn,rdAddr,rdAddrDelayLine,wrAddr,rdAddrDelayLineReverse,syncReset],[dout_I,doutVld_I],real(Numerator_I),symmInfo,isSymmetry,params,pirTypes,sharingCountType,Fullprecision);


        dout_FP_type=pir_fixpt_t(dout_P.Type.Signed,dout_P.Type.WordLength+1,dout_P.Type.FractionLength);
        dout_r=net.addSignal2('Type',dout_FP_type,'Name','dout_r');
        dout_r.SimulinkRate=dataRate;
        dout_i=net.addSignal2('Type',dout_FP_type,'Name','dout_i');
        dout_i.SimulinkRate=dataRate;
        dout_cast_r=net.addSignal2('Type',dataOut.Type.BaseType,'Name','dout_cast_r');
        dout_cast_r.SimulinkRate=dataRate;
        dout_cast_i=net.addSignal2('Type',dataOut.Type.BaseType,'Name','dout_cast_i');
        dout_cast_i.SimulinkRate=dataRate;
        dout_re=net.addSignal2('Type',dataOut.Type.BaseType,'Name','dout_re');
        dout_re.SimulinkRate=dataRate;
        dout_im=net.addSignal2('Type',dataOut.Type.BaseType,'Name','dout_im');
        dout_im.SimulinkRate=dataRate;




        pirelab.getSubComp(net,[dout_P,dout_I],dout_r);
        pirelab.getAddComp(net,[dout_M,dout_I],dout_i);
        pirelab.getDTCComp(net,dout_r,dout_cast_r,params.RoundingMethod,params.OverflowAction);
        pirelab.getDTCComp(net,dout_i,dout_cast_i,params.RoundingMethod,params.OverflowAction);
        pirelab.getIntDelayEnabledResettableComp(net,dout_cast_r,dout_re,doutVld,syncReset,1);
        pirelab.getIntDelayEnabledResettableComp(net,dout_cast_i,dout_im,doutVld,syncReset,1);
        pirelab.getIntDelayEnabledResettableComp(net,doutVld,doutVldReg,'',syncReset,1);

        dout_cmplx=net.addSignal2('Type',outSignals(1).Type,'Name','dout_cmplx');
        dout_cmplx.SimulinkRate=dataRate;
        pirelab.getRealImag2Complex(net,[dout_re,dout_im],dout_cmplx);
        pirelab.getSwitchComp(net,[dout_cmplx,dataZero],outSignals(1),zeroOutput);
        pirelab.getWireComp(net,doutVldReg,outSignals(2));
    elseif COEFF_ISCOMPLEX
        Fullprecision=false;



        numRows=size(params.Numerator,1);

        inputControlParams=struct(...
        'SHARING_FACTOR_ACTUAL',params.SharingFactor,...
        'NUM_MUX_INPUTS_ACTUAL',numMuxInputs,...
        'NUM_ROWS',numRows);

        if numRows==1
            controlFile='inputControl';
        else
            controlFile='inputControlInterleave';
        end

        this.elaborateCGIREML(net,inputControlParams,...
        [dinVld,sharingCount,rdCount,wrCount,rdCountReverse],...
        [delayLineValidInP,lastPhaseStrobe,nextSharingCount,nextDelayLineRdAddr,nextDelayLineWrAddr,nextDelayLineRdAddrReverse],...
        controlFile,...
        'Input control counter combinatorial logic');


        pirelab.getIntDelayEnabledResettableComp(net,nextSharingCount,sharingCount,'',syncReset,1,'sharingCount');
        pirelab.getIntDelayEnabledResettableComp(net,nextDelayLineRdAddr,rdCount,'',syncReset,1,'rdCount');
        pirelab.getIntDelayEnabledResettableComp(net,nextDelayLineWrAddr,wrCount,'',syncReset,1,'wrCount');
        pirelab.getIntDelayEnabledResettableComp(net,nextDelayLineRdAddrReverse,rdCountReverse,'',syncReset,1,'rdCountReverse');


        pirelab.getIntDelayEnabledResettableComp(net,sharingCount,rdAddr(1),'',syncReset,1,rdAddr(1).name);
        pirelab.getIntDelayEnabledResettableComp(net,rdCount,rdAddrDelayLine(1),'',syncReset,1,'rdAddrDelayLine');
        pirelab.getIntDelayEnabledResettableComp(net,wrCount,wrAddrP,'',syncReset,1,'wrAddr');
        pirelab.getWireComp(net,rdCountReverse,rdAddrDelayLineReverse(1));
        pirelab.getIntDelayEnabledResettableComp(net,lastPhaseStrobe,delayLineShiftEnP,'',syncReset,1,delayLineShiftEn(1).name);

        pirTypes=this.determineDataTypes(din_re.Type,params);
        coeffType=fi(0,pirTypes.coefficientsType.Signed,pirTypes.coefficientsType.WordLength,-pirTypes.coefficientsType.FractionLength,'OverflowAction','Saturate','RoundingMethod','Nearest');
        Numerator=cast(params.Numerator,'like',coeffType);
        doutVld_i=net.addSignal2('Type',pir_boolean_t,'Name','vldOut_i');
        doutVld_i.SimulinkRate=dataRate;
        elabSystolicFIRSharingReal(this,net,[din_re,dinVld,delayLineShiftEn,delayLineValidIn,rdAddr,rdAddrDelayLine,wrAddr,rdAddrDelayLineReverse,syncReset],[dout_re,doutVld],real(Numerator),symmInfo,isSymmetry,params,pirTypes,sharingCountType,Fullprecision);
        elabSystolicFIRSharingReal(this,net,[din_re,dinVld,delayLineShiftEn,delayLineValidIn,rdAddr,rdAddrDelayLine,wrAddr,rdAddrDelayLineReverse,syncReset],[dout_im,doutVld_i],imag(Numerator),symmInfo,isSymmetry,params,pirTypes,sharingCountType,Fullprecision);
        dout_cmplx=net.addSignal2('Type',outSignals(1).Type,'Name','dout_cmplx');
        dout_cmplx.SimulinkRate=dataRate;
        pirelab.getRealImag2Complex(net,[dout_re,dout_im],dout_cmplx);
        pirelab.getSwitchComp(net,[dout_cmplx,dataZero],outSignals(1),zeroOutput);
        pirelab.getWireComp(net,doutVld,outSignals(2));
    elseif DATAIN_ISCOMPLEX
        Fullprecision=false;



        numRows=size(params.Numerator,1);

        inputControlParams=struct(...
        'SHARING_FACTOR_ACTUAL',params.SharingFactor,...
        'NUM_MUX_INPUTS_ACTUAL',numMuxInputs,...
        'NUM_ROWS',numRows);

        if numRows==1
            controlFile='inputControl';
        else
            controlFile='inputControlInterleave';
        end

        this.elaborateCGIREML(net,inputControlParams,...
        [dinVld,sharingCount,rdCount,wrCount,rdCountReverse],...
        [delayLineValidInP,lastPhaseStrobe,nextSharingCount,nextDelayLineRdAddr,nextDelayLineWrAddr,nextDelayLineRdAddrReverse],...
        controlFile,...
        'Input control counter combinatorial logic');


        pirelab.getIntDelayEnabledResettableComp(net,nextSharingCount,sharingCount,'',syncReset,1,'sharingCount');
        pirelab.getIntDelayEnabledResettableComp(net,nextDelayLineRdAddr,rdCount,'',syncReset,1,'rdCount');
        pirelab.getIntDelayEnabledResettableComp(net,nextDelayLineWrAddr,wrCount,'',syncReset,1,'wrCount');
        pirelab.getIntDelayEnabledResettableComp(net,nextDelayLineRdAddrReverse,rdCountReverse,'',syncReset,1,'rdCountReverse');


        pirelab.getIntDelayEnabledResettableComp(net,sharingCount,rdAddr(1),'',syncReset,1,rdAddr(1).name);
        pirelab.getIntDelayEnabledResettableComp(net,rdCount,rdAddrDelayLine(1),'',syncReset,1,'rdAddrDelayLine');
        pirelab.getIntDelayEnabledResettableComp(net,wrCount,wrAddrP,'',syncReset,1,'wrAddr');
        pirelab.getWireComp(net,rdCountReverse,rdAddrDelayLineReverse(1));

        pirelab.getIntDelayEnabledResettableComp(net,lastPhaseStrobe,delayLineShiftEnP,'',syncReset,1,delayLineShiftEn(1).name);
        pirTypes=this.determineDataTypes(din_re.Type,params);
        coeffType=fi(0,pirTypes.coefficientsType.Signed,pirTypes.coefficientsType.WordLength,-pirTypes.coefficientsType.FractionLength,'OverflowAction','Saturate','RoundingMethod','Nearest');
        Numerator=cast(params.Numerator,'like',coeffType);
        doutVld_i=net.addSignal2('Type',pir_boolean_t,'Name','vldOut_i');
        doutVld_i.SimulinkRate=dataRate;
        elabSystolicFIRSharingReal(this,net,[din_re,dinVld,delayLineShiftEn,delayLineValidIn,rdAddr,rdAddrDelayLine,wrAddr,rdAddrDelayLineReverse,syncReset],[dout_re,doutVld],Numerator,symmInfo,isSymmetry,params,pirTypes,sharingCountType,Fullprecision);
        elabSystolicFIRSharingReal(this,net,[din_im,dinVld,delayLineShiftEn,delayLineValidIn,rdAddr,rdAddrDelayLine,wrAddr,rdAddrDelayLineReverse,syncReset],[dout_im,doutVld_i],Numerator,symmInfo,isSymmetry,params,pirTypes,sharingCountType,Fullprecision);
        dout_cmplx=net.addSignal2('Type',outSignals(1).Type,'Name','dout_cmplx');
        dout_cmplx.SimulinkRate=dataRate;
        dout_cmplxSW=net.addSignal2('Type',outSignals(1).Type,'Name','dout_cmplxSW');
        dout_cmplxSW.SimulinkRate=dataRate;
        pirelab.getRealImag2Complex(net,[dout_re,dout_im],dout_cmplx);
        pirelab.getSwitchComp(net,[dout_cmplx,dataZero],dout_cmplxSW,zeroOutput);
        pirelab.getDTCComp(net,dout_cmplxSW,outSignals(1));
        pirelab.getWireComp(net,doutVld,outSignals(2));
    else
        Fullprecision=false;




        numRows=size(params.Numerator,1);

        inputControlParams=struct(...
        'SHARING_FACTOR_ACTUAL',params.SharingFactor,...
        'NUM_MUX_INPUTS_ACTUAL',numMuxInputs,...
        'NUM_ROWS',numRows);

        if numRows==1
            controlFile='inputControl';
        else
            controlFile='inputControlInterleave';
        end

        this.elaborateCGIREML(net,inputControlParams,...
        [dinVld,sharingCount,rdCount,wrCount,rdCountReverse],...
        [delayLineValidInP,lastPhaseStrobe,nextSharingCount,nextDelayLineRdAddr,nextDelayLineWrAddr,nextDelayLineRdAddrReverse],...
        controlFile,...
        'Input control counter combinatorial logic');





        pirelab.getIntDelayEnabledResettableComp(net,nextSharingCount,sharingCount,'',syncReset,1,'sharingCount');
        pirelab.getIntDelayEnabledResettableComp(net,nextDelayLineRdAddr,rdCount,'',syncReset,1,'rdCount');
        pirelab.getIntDelayEnabledResettableComp(net,nextDelayLineWrAddr,wrCount,'',syncReset,1,'wrCount');
        pirelab.getIntDelayEnabledResettableComp(net,nextDelayLineRdAddrReverse,rdCountReverse,'',syncReset,1,'rdCountReverse');



        pirelab.getIntDelayEnabledResettableComp(net,sharingCount,rdAddr(1),'',syncReset,1,rdAddr(1).name);
        pirelab.getIntDelayEnabledResettableComp(net,rdCount,rdAddrDelayLine(1),'',syncReset,1,'rdAddrDelayLine');
        pirelab.getIntDelayEnabledResettableComp(net,wrCount,wrAddrP,'',syncReset,1,'wrAddr');
        pirelab.getWireComp(net,rdCountReverse,rdAddrDelayLineReverse(1));


        pirelab.getIntDelayEnabledResettableComp(net,lastPhaseStrobe,delayLineShiftEnP,'',syncReset,1,delayLineShiftEn(1).name);
        pirTypes=this.determineDataTypes(din_re.Type,params);
        coeffType=fi(0,pirTypes.coefficientsType.Signed,pirTypes.coefficientsType.WordLength,-pirTypes.coefficientsType.FractionLength,'OverflowAction','Saturate','RoundingMethod','Nearest');
        Numerator=cast(params.Numerator,'like',coeffType);
        elabSystolicFIRSharingReal(this,net,[din_re,dinVld,delayLineShiftEn,delayLineValidIn,rdAddr,rdAddrDelayLine,wrAddr,rdAddrDelayLineReverse,syncReset],[dout_re,doutVld],Numerator,symmInfo,isSymmetry,params,pirTypes,sharingCountType,Fullprecision);

        pirelab.getSwitchComp(net,[dout_re,dataZero],outSignals(1),zeroOutput);
        pirelab.getWireComp(net,doutVld,outSignals(2));
    end
    pirelab.getWireComp(net,readyS,outSignals(3));
end
