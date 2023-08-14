function elabSystolicFIRSharingReal(this,net,inSignals,outSignals,Numerator,symmInfo,isSymmetry,params,pirTypes,sharingCountType,FullPrecision)




%#ok<*AGROW>





    dataIn=inSignals(1);
    validIn=inSignals(2);

    dataOut=outSignals(1);
    validOut=outSignals(2);

    dataRate=dataIn.SimulinkRate;




    numTaps=length(Numerator);

    [numMults,numMuxInputs,numDlyLine,dlyLineLen,numCoeffTable]=getDesignParameter(this,isSymmetry,params);




    for k=1:numDlyLine
        delayLineShiftEn(k)=inSignals(2+k);
        delayLineValidIn(k)=inSignals(2+k+numDlyLine);
        rdAddr(k)=inSignals(2+k+2*numDlyLine);
        rdAddrDelayLine(k)=inSignals(2+k+3*numDlyLine);
        wrAddr(k)=inSignals(2+k+4*numDlyLine);
        rdAddrDelayLineReverse(k)=inSignals(2+k+5*numDlyLine);
    end
    if params.inMode(2)
        syncReset=inSignals(3+k+5*numDlyLine);
    else
        syncReset='';
    end


    sumOutRegDepth=1;
    if strcmpi(params.synthesisTool,'Altera Quartus II')


        accumulateDelayAmount=3+sumOutRegDepth-double(isSymmetry)-double(numMults==1)+double(numMults>1);
    else
        accumulateDelayAmount=4+sumOutRegDepth-double(isSymmetry)-double(numMults==1)+double(numMults>1);
    end
    validDelayAmount=5+sumOutRegDepth-double(numMults==1)+double(numMults>1);
























    delayLineDataIn(1)=dataIn;
    delayLineEnd(1)=net.addSignal(pirTypes.inputType,'delayLineEnd0');
    delayLineEnd(1).SimulinkRate=dataRate;
    delayLineDataOut(1)=net.addSignal(pirTypes.inputType,'delayLineDataOut0');
    delayLineDataOut(1).SimulinkRate=dataRate;

    for k=2:numDlyLine
        idxStr=int2str(k-1);
        delayLineDataIn(k)=net.addSignal(pirTypes.inputType,['delayLineDataIn',idxStr]);
        delayLineDataIn(k).SimulinkRate=dataRate;






        delayLineEnd(k)=net.addSignal(pirTypes.inputType,['delayLineEnd',idxStr]);
        delayLineEnd(k).SimulinkRate=dataRate;
        delayLineDataOut(k)=net.addSignal(pirTypes.inputType,['delayLineDataOut',idxStr]);
        delayLineDataOut(k).SimulinkRate=dataRate;
    end

    for k=1:numCoeffTable
        idxStr=int2str(k-1);
        coeffTableReg(k)=net.addSignal(pirTypes.coefficientsType,['coeffTableReg',idxStr]);
        coeffTableReg(k).SimulinkRate=dataRate;
        coeffTableRegP(k)=net.addSignal(pirTypes.coefficientsType,['coeffTableRegP',idxStr]);
        coeffTableRegP(k).SimulinkRate=dataRate;
    end


    sumOutReg=net.addSignal(pirTypes.accumulatorType,'sumOutReg');
    sumOutReg.SimulinkRate=dataRate;
    validOutLookAhead=net.addSignal(pir_boolean_t,'validOutLookahead');
    validOutLookAhead.SimulinkRate=dataRate;
    accumulate=net.addSignal(pir_boolean_t,'accumulate');
    accumulate.SimulinkRate=dataRate;
    lutCountReached=net.addSignal(pir_boolean_t,'lutCountReached');
    lutCountReached.SimulinkRate=dataRate;
    rdCountReached=net.addSignal(pir_boolean_t,'rdCountReached');
    rdCountReached.SimulinkRate=dataRate;
    rdAddrEndZero=net.addSignal(pir_boolean_t,'rdAddrEndZero');
    rdAddrEndZero.SimulinkRate=dataRate;
    accumulateValid=net.addSignal(pir_boolean_t,'accumulateValid');
    accumulateValid.SimulinkRate=dataRate;
    accumulateRST=net.addSignal(pir_boolean_t,'accumulateRST');
    accumulateRST.SimulinkRate=dataRate;
    accumulateRSTP=net.addSignal(pir_boolean_t,'accumulateRSTP');
    accumulateRSTP.SimulinkRate=dataRate;
    accSwitchZeroIn=net.addSignal(pirTypes.accumulatorType,'accDataOut');
    accSwitchZeroIn.SimulinkRate=dataRate;
    accSwitchOut=net.addSignal(pirTypes.accumulatorType,'accSwitchOut');
    accSwitchOut.SimulinkRate=dataRate;
    accAdderOut=net.addSignal(pirTypes.accumulatorType,'accAdderOut');
    accAdderOut.SimulinkRate=dataRate;
    accDataOut=net.addSignal(pirTypes.accumulatorType,'accDataOut');
    accDataOut.SimulinkRate=dataRate;
    converterOut=net.addSignal(dataOut.Type,'converterOut');
    converterOut.SimulinkRate=dataRate;




    if(size(Numerator,1)==1)

        if isSymmetry
            oddSymm=mod(numTaps,2);
            if oddSymm
                if params.SharingFactor>=ceil(numTaps/2)
                    coeffsPadded=Numerator(1:ceil(numTaps/2));
                else
                    L=floor(numTaps/2);
                    Lhat=ceil(L/numMuxInputs)*numMuxInputs;
                    Lpad=Lhat-L;
                    usedCoeff=Numerator(1:L);
                    if Lpad>0
                        coeffsPadded=[usedCoeff,zeros(1,Lpad,'like',Numerator)];
                    else
                        coeffsPadded=usedCoeff;
                    end
                    coeffsPadded=[coeffsPadded,Numerator(L+1),zeros(1,numMuxInputs-1,'like',Numerator)];
                end
            else
                L=ceil(numTaps/2);
                Lhat=ceil(L/numMuxInputs)*numMuxInputs;
                Lpad=Lhat-L;
                usedCoeff=Numerator(1:L);
                if Lpad>0
                    coeffsPadded=[usedCoeff,zeros(1,Lpad,'like',Numerator)];
                else
                    coeffsPadded=usedCoeff;
                end
            end

        else
            L=numTaps;
            Lhat=ceil(L/numMuxInputs)*numMuxInputs;
            Lpad=Lhat-L;
            usedCoeff=Numerator;
            coeffsPadded=[usedCoeff,zeros(1,Lpad,'like',Numerator)];
        end
        coeffTable=reshape(coeffsPadded,numMuxInputs,[]);


    else

        numFilter=size(Numerator,1);
        subLength=size(Numerator,2);
        tableSubSize=ceil(subLength/numMults);

        if rem(subLength,numMults)==0
            usedCoeff=Numerator;
        else
            usedCoeff=zeros(numFilter,tableSubSize*numMults);
            usedCoeff(1:numFilter,1:subLength)=Numerator;
        end

        for ii=1:1:numFilter
            for jj=1:1:numMults
                coeffTable(((ii-1)*tableSubSize)+1:ii*tableSubSize,jj)=usedCoeff(ii,((jj-1)*tableSubSize)+1:jj*tableSubSize);
            end
        end

    end


    for k=1:numCoeffTable
        if any(coeffTable(:,k))
            idxStr=int2str(k-1);

            coeffTableOut=net.addSignal(pirTypes.coefficientsType,['coeffTableOut',idxStr]);
            coeffTableOut.SimulinkRate=dataRate;
            this.getSimpleLookupComp(net,rdAddr(k),coeffTableOut,coeffTable(:,k),...
            ['coeffTable',idxStr],['Coefficient table for multiplier',idxStr]);


            pirelab.getUnitDelayComp(net,coeffTableOut,coeffTableRegP(k),coeffTableRegP(k).name,0,1);

            if isSymmetry
                pirelab.getIntDelayEnabledResettableComp(net,coeffTableRegP(k),coeffTableReg(k),'','',1,coeffTableReg(k).name);
            else
                pirelab.getWireComp(net,coeffTableRegP(k),coeffTableReg(k));
            end
        end
    end



























    if params.inMode(2)
        delayLineNet=this.elaborateDelayLineResettable(net,numMuxInputs,pirTypes.inputType,sharingCountType);
        if isSymmetry
            delayLineNetReverse=this.elaborateDelayLineReverseResettable(net,numMuxInputs,oddSymm,numMults,pirTypes.inputType,sharingCountType);
            if any(dlyLineLen~=dlyLineLen(1))
                idx=find(dlyLineLen~=dlyLineLen(1),1);
                shortDlyLineNet=this.elaborateDelayLineShortResettable(net,numMuxInputs,dlyLineLen(idx),pirTypes.inputType,sharingCountType);
                shortDlyLineNetReverse=this.elaborateDelayLineShortReverseResettable(net,numMuxInputs,dlyLineLen(idx),pirTypes.inputType,sharingCountType);
            end
            if oddSymm&&numMults>1
                oddDlyLineNet=this.elaborateDelayLineOddResettable(net,numMuxInputs,pirTypes.inputType,sharingCountType);
            end
        end
    else
        delayLineNet=this.elaborateDelayLine(net,numMuxInputs,pirTypes.inputType,sharingCountType);
        if isSymmetry
            delayLineNetReverse=this.elaborateDelayLineReverse(net,numMuxInputs,oddSymm,numMults,pirTypes.inputType,sharingCountType);
            if any(dlyLineLen~=dlyLineLen(1))
                idx=find(dlyLineLen~=dlyLineLen(1),1);
                shortDlyLineNet=this.elaborateDelayLineShort(net,numMuxInputs,dlyLineLen(idx),pirTypes.inputType,sharingCountType);
                shortDlyLineNetReverse=this.elaborateDelayLineShortReverse(net,numMuxInputs,dlyLineLen(idx),pirTypes.inputType,sharingCountType);
            end
            if oddSymm&&numMults>1
                oddDlyLineNet=this.elaborateDelayLineOdd(net,numMuxInputs,pirTypes.inputType,sharingCountType);
            end
        end
    end



    for k=1:numDlyLine

        if params.inMode(2)
            if isSymmetry
                if oddSymm&&k==ceil(numDlyLine/2)&&numMults>1
                    pirelab.instantiateNetwork(net,oddDlyLineNet,...
                    [delayLineDataIn(k),delayLineValidIn(k),delayLineShiftEn(k),rdAddr(k),syncReset],...
                    [delayLineEnd(k),delayLineDataOut(k)],...
                    ['delayLine',int2str(k-1)]);
                elseif(k>ceil(numDlyLine/2))
                    if dlyLineLen(k)==dlyLineLen(1)
                        if dlyLineLen(k)<=3
                            pirelab.instantiateNetwork(net,delayLineNetReverse,...
                            [delayLineDataIn(k),delayLineValidIn(numDlyLine-k+2),wrAddr(numDlyLine-k+2),rdAddr(numDlyLine-k+2),syncReset],...
                            [delayLineEnd(k),delayLineDataOut(k)],...
                            ['delayLine',int2str(k-1)]);
                        else
                            pirelab.instantiateNetwork(net,delayLineNetReverse,...
                            [delayLineDataIn(k),delayLineValidIn(numDlyLine-k+2),wrAddr(numDlyLine-k+2),rdAddrDelayLineReverse(numDlyLine-k+2),syncReset],...
                            [delayLineEnd(k),delayLineDataOut(k)],...
                            ['delayLine',int2str(k-1)]);

                        end
                    else
                        if dlyLineLen(k)<=3
                            pirelab.instantiateNetwork(net,shortDlyLineNetReverse,...
                            [delayLineDataIn(k),delayLineValidIn(numDlyLine-k+2),wrAddr(numDlyLine-k+2),rdAddr(numDlyLine-k+2),rdAddr(numDlyLine-k+2),syncReset],...
                            [delayLineEnd(k),delayLineDataOut(k)],...
                            ['delayLine',int2str(k-1)]);
                        else
                            pirelab.instantiateNetwork(net,shortDlyLineNetReverse,...
                            [delayLineDataIn(k),delayLineValidIn(numDlyLine-k+2),wrAddr(numDlyLine-k+2),rdAddrDelayLineReverse(numDlyLine-k+2),rdAddr(numDlyLine-k+2),syncReset],...
                            [delayLineEnd(k),delayLineDataOut(k)],...
                            ['delayLine',int2str(k-1)]);
                        end
                    end
                else
                    if dlyLineLen(k)==dlyLineLen(1)
                        if dlyLineLen(k)<=2
                            pirelab.instantiateNetwork(net,delayLineNet,...
                            [delayLineDataIn(k),delayLineValidIn(k),wrAddr(k),rdAddr(k),syncReset],...
                            [delayLineEnd(k),delayLineDataOut(k)],...
                            ['delayLine',int2str(k-1)]);
                        else
                            pirelab.instantiateNetwork(net,delayLineNet,...
                            [delayLineDataIn(k),delayLineValidIn(k),wrAddr(k),rdAddrDelayLine(k),syncReset],...
                            [delayLineEnd(k),delayLineDataOut(k)],...
                            ['delayLine',int2str(k-1)]);
                        end
                    else
                        if dlyLineLen(k)<=3
                            pirelab.instantiateNetwork(net,shortDlyLineNet,...
                            [delayLineDataIn(k),delayLineValidIn(k),wrAddr(k),rdAddr(k),rdAddr(k),syncReset],...
                            [delayLineEnd(k),delayLineDataOut(k)],...
                            ['delayLine',int2str(k-1)]);
                        else
                            pirelab.instantiateNetwork(net,shortDlyLineNet,...
                            [delayLineDataIn(k),delayLineValidIn(k),wrAddr(k),rdAddrDelayLine(k),rdAddr(k),syncReset],...
                            [delayLineEnd(k),delayLineDataOut(k)],...
                            ['delayLine',int2str(k-1)]);
                        end
                    end
                end
            else

                if dlyLineLen(k)<=2
                    if size(usedCoeff,1)>1
                        pirelab.instantiateNetwork(net,delayLineNet,...
                        [delayLineDataIn(k),delayLineValidIn(k),wrAddr(k),rdAddrDelayLine(k),syncReset],...
                        [delayLineEnd(k),delayLineDataOut(k)],...
                        ['delayLine',int2str(k-1)]);
                    else
                        pirelab.instantiateNetwork(net,delayLineNet,...
                        [delayLineDataIn(k),delayLineValidIn(k),wrAddr(k),rdAddr(k),syncReset],...
                        [delayLineEnd(k),delayLineDataOut(k)],...
                        ['delayLine',int2str(k-1)]);
                    end
                else
                    pirelab.instantiateNetwork(net,delayLineNet,...
                    [delayLineDataIn(k),delayLineValidIn(k),wrAddr(k),rdAddrDelayLine(k),syncReset],...
                    [delayLineEnd(k),delayLineDataOut(k)],...
                    ['delayLine',int2str(k-1)]);

                end
            end
        else
            if isSymmetry
                if oddSymm&&k==ceil(numDlyLine/2)&&numMults>1
                    pirelab.instantiateNetwork(net,oddDlyLineNet,...
                    [delayLineDataIn(k),delayLineValidIn(k),delayLineShiftEn(k),rdAddr(k)],...
                    [delayLineEnd(k),delayLineDataOut(k)],...
                    ['delayLine',int2str(k-1)]);
                elseif(k>ceil(numDlyLine/2))
                    if dlyLineLen(k)==dlyLineLen(1)
                        if dlyLineLen(k)<=3
                            pirelab.instantiateNetwork(net,delayLineNetReverse,...
                            [delayLineDataIn(k),delayLineValidIn(numDlyLine-k+2),wrAddr(numDlyLine-k+2),rdAddr(numDlyLine-k+2)],...
                            [delayLineEnd(k),delayLineDataOut(k)],...
                            ['delayLine',int2str(k-1)]);
                        else
                            pirelab.instantiateNetwork(net,delayLineNetReverse,...
                            [delayLineDataIn(k),delayLineValidIn(numDlyLine-k+2),wrAddr(numDlyLine-k+2),rdAddrDelayLineReverse(numDlyLine-k+2)],...
                            [delayLineEnd(k),delayLineDataOut(k)],...
                            ['delayLine',int2str(k-1)]);
                        end
                    else
                        if dlyLineLen(k)<=3
                            pirelab.instantiateNetwork(net,shortDlyLineNetReverse,...
                            [delayLineDataIn(k),delayLineValidIn(numDlyLine-k+2),wrAddr(numDlyLine-k+2),rdAddr(numDlyLine-k+2),rdAddr(numDlyLine-k+2)],...
                            [delayLineEnd(k),delayLineDataOut(k)],...
                            ['delayLine',int2str(k-1)]);
                        else
                            pirelab.instantiateNetwork(net,shortDlyLineNetReverse,...
                            [delayLineDataIn(k),delayLineValidIn(numDlyLine-k+2),wrAddr(numDlyLine-k+2),rdAddrDelayLineReverse(numDlyLine-k+2),rdAddr(numDlyLine-k+2)],...
                            [delayLineEnd(k),delayLineDataOut(k)],...
                            ['delayLine',int2str(k-1)]);
                        end
                    end
                else
                    if dlyLineLen(k)==dlyLineLen(1)
                        if dlyLineLen(k)<=2
                            pirelab.instantiateNetwork(net,delayLineNet,...
                            [delayLineDataIn(k),delayLineValidIn(k),wrAddr(k),rdAddr(k)],...
                            [delayLineEnd(k),delayLineDataOut(k)],...
                            ['delayLine',int2str(k-1)]);
                        else
                            pirelab.instantiateNetwork(net,delayLineNet,...
                            [delayLineDataIn(k),delayLineValidIn(k),wrAddr(k),rdAddrDelayLine(k)],...
                            [delayLineEnd(k),delayLineDataOut(k)],...
                            ['delayLine',int2str(k-1)]);

                        end
                    else
                        if dlyLineLen(k)<=3
                            pirelab.instantiateNetwork(net,shortDlyLineNet,...
                            [delayLineDataIn(k),delayLineValidIn(k),wrAddr(k),rdAddr(k),rdAddr(k)],...
                            [delayLineEnd(k),delayLineDataOut(k)],...
                            ['delayLine',int2str(k-1)]);
                        else
                            pirelab.instantiateNetwork(net,shortDlyLineNet,...
                            [delayLineDataIn(k),delayLineValidIn(k),wrAddr(k),rdAddrDelayLine(k),rdAddr(k)],...
                            [delayLineEnd(k),delayLineDataOut(k)],...
                            ['delayLine',int2str(k-1)]);
                        end
                    end
                end
            else
                if dlyLineLen(k)<=2
                    if size(usedCoeff,1)>1
                        pirelab.instantiateNetwork(net,delayLineNet,...
                        [delayLineDataIn(k),delayLineValidIn(k),wrAddr(k),rdAddrDelayLine(k)],...
                        [delayLineEnd(k),delayLineDataOut(k)],...
                        ['delayLine',int2str(k-1)]);
                    else
                        pirelab.instantiateNetwork(net,delayLineNet,...
                        [delayLineDataIn(k),delayLineValidIn(k),wrAddr(k),rdAddr(k)],...
                        [delayLineEnd(k),delayLineDataOut(k)],...
                        ['delayLine',int2str(k-1)]);
                    end
                else
                    pirelab.instantiateNetwork(net,delayLineNet,...
                    [delayLineDataIn(k),delayLineValidIn(k),wrAddr(k),rdAddrDelayLine(k)],...
                    [delayLineEnd(k),delayLineDataOut(k)],...
                    ['delayLine',int2str(k-1)]);

                end
            end
        end

    end


    for k=1:numDlyLine-1
        if isSymmetry&&k>ceil(numDlyLine/2)
            dly=0;
        elseif size(Numerator,1)>1
            dly=params.SharingFactor-1;
        else
            dly=1;
        end

        pirelab.getIntDelayEnabledResettableComp(net,delayLineEnd(k),delayLineDataIn(k+1),'',syncReset,dly,delayLineDataIn(k+1).name);


    end








    sumIn=net.addSignal(pirTypes.accumulatorType,'sumIn');
    sumIn.SimulinkRate=dataRate;
    sumOut=net.addSignal(pirTypes.accumulatorType,'sumOut');
    sumOut.SimulinkRate=dataRate;
    coeff=net.addSignal(pirTypes.coefficientsType,'coeff');
    coeff.SimulinkRate=dataRate;
    sumDT=pirgetdatatypeinfo(pirTypes.accumulatorType);
    dinDT=pirgetdatatypeinfo(pirTypes.inputType);
    coefDT=pirgetdatatypeinfo(pirTypes.coefficientsType);

    if dinDT.issigned
        DIN_WORDLENGTH=dinDT.wordsize;
        DIN_FRACTIONLENGTH=dinDT.binarypoint;
        DIN_SIGNED=1;
    else
        DIN_WORDLENGTH=dinDT.wordsize+1;
        DIN_FRACTIONLENGTH=dinDT.binarypoint;
        DIN_SIGNED=1;
    end


    if isSymmetry
        preAddIn=net.addSignal(pirTypes.inputType,'preAddIn');
        preAddIn.SimulinkRate=dataRate;
        firFilterTapSystolic=elabFilterTapSystolicPreAddS(this,net,params,dataRate,...
        dataIn,preAddIn,coeff,sumIn,syncReset,...
        sumOut,...
        DIN_SIGNED,DIN_WORDLENGTH,DIN_FRACTIONLENGTH,...
        coefDT.wordsize,coefDT.binarypoint,...
        sumDT.wordsize,sumDT.binarypoint,symmInfo.isSymmetric);
    else
        firFilterTapSystolic=elabFilterTapSystolicS(this,net,params,dataRate,...
        dataIn,coeff,sumIn,syncReset,sumOut,...
        DIN_SIGNED,DIN_WORDLENGTH,DIN_FRACTIONLENGTH,...
        coefDT.wordsize,coefDT.binarypoint,...
        sumDT.wordsize,sumDT.binarypoint);
    end


    if numMults==1
        k=1;
        nonzeroIndex=find(double(coeffTable(:,k)));
        if~any(coeffTable(:,k))
            pirelab.getIntDelayEnabledResettableComp(net,accSwitchOut,sumOut,'','',1,'filterDelay');
        elseif sum(double(coeffTable~=0))==1&&(floor(log2(double(coeffTable(nonzeroIndex))))==log2(double(coeffTable(nonzeroIndex))))
            coeffNonZero=pirelab.getCompareToZero(net,coeffTableReg(k),'~=','coeffNonZero');
            gainOut=net.addSignal(pirTypes.productType,'gainOut');
            gainOut.SimulinkRate=dataRate;
            gainOutDB=net.addSignal(pirTypes.productType,'gainOutDB');
            gainOutDB.SimulinkRate=dataRate;
            gainOutSwitch=net.addSignal(pirTypes.productType,'gainOutSwitch');
            gainOutSwitch.SimulinkRate=dataRate;
            gainOutREG=net.addSignal(pirTypes.productType,'gainOutREG');
            gainOutREG.SimulinkRate=dataRate;
            zeroOut=net.addSignal(pirTypes.productType,'zeroOut');
            zeroOut.SimulinkRate=dataRate;
            pirelab.getConstComp(net,zeroOut,0);
            nonzeroIndex=find(double(coeffTable(:,k)));
            pirelab.getGainComp(net,delayLineDataOut(k),gainOut,coeffTable(nonzeroIndex),1,1,'Floor','Wrap');

            if isSymmetry
                pirelab.getIntDelayEnabledResettableComp(net,gainOut,gainOutDB,'','',1,'filterDelay');
            else
                pirelab.getWireComp(net,gainOut,gainOutDB);
            end

            pirelab.getIntDelayEnabledResettableComp(net,gainOutDB,gainOutSwitch,coeffNonZero,'',1,'filterDelay');

            pirelab.getIntDelayEnabledResettableComp(net,gainOutSwitch,gainOutREG,'','',3,'filterDelay');

            pirelab.getDTCComp(net,gainOutREG,sumOut,'Floor','Wrap');

        elseif isSymmetry
            pirelab.instantiateNetwork(net,firFilterTapSystolic,[delayLineDataOut(k),delayLineDataOut(numDlyLine-k+1),coeffTableReg(k),accSwitchOut,syncReset],...
            sumOut,...
            ['filterTap',int2str(k-1)]);
        else
            pirelab.instantiateNetwork(net,firFilterTapSystolic,[delayLineDataOut(k),coeffTableReg(k),accSwitchOut,syncReset],...
            sumOut,...
            ['filterTap',int2str(k-1)]);
        end





        if isSymmetry
            pirelab.getIntDelayEnabledResettableComp(net,delayLineShiftEn(numMults+1),validOutLookAhead,'',syncReset,validDelayAmount,validOutLookAhead.name);
        else
            pirelab.getIntDelayEnabledResettableComp(net,delayLineShiftEn(end),validOutLookAhead,'',syncReset,validDelayAmount,validOutLookAhead.name);
        end

        if size(Numerator,1)>1
            pirelab.getIntDelayEnabledResettableComp(net,accumulateValid,validOut,'',syncReset,1,validOut.name);
        else
            pirelab.getIntDelayEnabledResettableComp(net,validOutLookAhead,validOut,'',syncReset,1,validOut.name);
        end


        if isSymmetry
            rdAddrEndNonZero=pirelab.getCompareToZero(net,rdAddr(numMults+1),'~=','rdAddrEndNonZero');
            pirelab.getRelOpComp(net,[rdAddrDelayLine(numMults+1),wrAddr(numMults+1)],rdCountReached,'==');
            pirelab.getLogicComp(net,[rdAddrEndNonZero,rdCountReached],lutCountReached,'and');
            pirelab.getIntDelayEnabledResettableComp(net,lutCountReached,accumulateValid,'',syncReset,accumulateDelayAmount+double(isSymmetry)+1,'finalSumValidPipe');
        else
            rdAddrEndNonZero=pirelab.getCompareToZero(net,rdAddr(end),'~=','rdAddrEndNonZero');
            pirelab.getRelOpComp(net,[rdAddrDelayLine(end),wrAddr(end)],rdCountReached,'==');
            pirelab.getLogicComp(net,[rdAddrEndNonZero,rdCountReached],lutCountReached,'and');
            pirelab.getIntDelayEnabledResettableComp(net,lutCountReached,accumulateValid,'',syncReset,accumulateDelayAmount+double(isSymmetry)+1,'finalSumValidPipe');
        end










        pirelab.getIntDelayEnabledResettableComp(net,rdAddrEndZero,accumulate,'',syncReset,accumulateDelayAmount+double(isSymmetry),'finalSumValidPipe');
        pirelab.getConstComp(net,accSwitchZeroIn,0);
        pirelab.getLogicComp(net,rdAddrEndNonZero,rdAddrEndZero,'not');

        if size(Numerator,1)>1
            pirelab.getLogicComp(net,[accumulateValid,accumulate],accumulateRST,'or');
        else
            pirelab.getWireComp(net,accumulate,accumulateRST);
        end

        pirelab.getSwitchComp(net,[sumOut,accSwitchZeroIn],accSwitchOut,accumulateRST);


        if FullPrecision
            pirelab.getWireComp(net,sumOut,converterOut);
        else
            pirelab.getDTCComp(net,sumOut,converterOut,params.RoundingMethod,params.OverflowAction);
        end
    else
        pirelab.getConstComp(net,sumIn,0);
        halfbandFilter=sum(sum(coeffTable(:,:)>0))==1;

        for k=1:numMults
            nonzeroIndex=find(double(coeffTable(:,k)));
            if~any(coeffTable(:,k))
                pirelab.getIntDelayEnabledResettableComp(net,sumIn,sumOut,'','',1,'filterDelay');
            elseif sum(double(coeffTable(:,k)~=0))==1&&halfbandFilter...
                &&(floor(log2(double(coeffTable(nonzeroIndex,k))))==log2(double(coeffTable(nonzeroIndex,k))))


                coeffNonZero=pirelab.getCompareToZero(net,coeffTableReg(k),'~=','coeffNonZero');
                gainOut=net.addSignal(pirTypes.productType,'gainOut');
                gainOut.SimulinkRate=dataRate;
                gainOutSwitch=net.addSignal(pirTypes.productType,'gainOutSwitch');
                gainOutSwitch.SimulinkRate=dataRate;
                gainOutDB=net.addSignal(pirTypes.productType,'gainOutDB');
                gainOutDB.SimulinkRate=dataRate;
                gainOutREG=net.addSignal(pirTypes.productType,'gainOutREG');
                gainOutREG.SimulinkRate=dataRate;
                zeroOut=net.addSignal(pirTypes.productType,'gainOut');
                zeroOut.SimulinkRate=dataRate;
                pirelab.getConstComp(net,zeroOut,0);
                nonzeroIndex=find(double(coeffTable(:,k)));
                pirelab.getGainComp(net,delayLineDataOut(k),gainOut,coeffTable(nonzeroIndex,k),1,1,'Floor','Wrap');

                if isSymmetry
                    pirelab.getIntDelayEnabledResettableComp(net,gainOut,gainOutDB,'','',1,'filterDelay');
                else
                    pirelab.getWireComp(net,gainOut,gainOutDB);
                end

                pirelab.getSwitchComp(net,[zeroOut,gainOutDB],gainOutSwitch,coeffNonZero);

                pirelab.getIntDelayEnabledResettableComp(net,gainOutSwitch,gainOutREG,'','',4,'filterDelay');
                pirelab.getDTCComp(net,gainOutREG,sumOut,'Floor','Wrap');

            elseif isSymmetry
                if oddSymm&&k==numMults&&numMults>1
                    pirelab.getConstComp(net,preAddIn,0);
                    pirelab.instantiateNetwork(net,firFilterTapSystolic,[delayLineDataOut(k),preAddIn,coeffTableReg(k),sumIn,syncReset],...
                    sumOut,...
                    ['filterTap',int2str(k-1)]);
                else
                    pirelab.instantiateNetwork(net,firFilterTapSystolic,[delayLineDataOut(k),delayLineDataOut(numDlyLine-k+1),coeffTableReg(k),sumIn,syncReset],...
                    sumOut,...
                    ['filterTap',int2str(k-1)]);
                end
            else
                pirelab.instantiateNetwork(net,firFilterTapSystolic,[delayLineDataOut(k),coeffTableReg(k),sumIn,syncReset],...
                sumOut,...
                ['filterTap',int2str(k-1)]);
            end
            sumIn=sumOut;
            sumOut=net.addSignal(pirTypes.accumulatorType,['sumOut_',int2str(k-1)]);
            sumOut.SimulinkRate=dataRate;
        end



        if params.inMode(2)



            syncResetREG=net.addSignal(pir_boolean_t,'syncResetREG');
            validReset=net.addSignal(pir_boolean_t,'validReset');
            pirelab.getIntDelayEnabledResettableComp(net,syncReset,syncResetREG,'','',1,syncResetREG.name);
            pirelab.getLogicComp(net,[syncReset,syncResetREG],validReset,'or');
        else
            validReset='';
        end

        if isSymmetry
            pirelab.getIntDelayEnabledResettableComp(net,delayLineShiftEn(numMults+1),validOutLookAhead,'',validReset,validDelayAmount,validOutLookAhead.name);
        else
            pirelab.getIntDelayEnabledResettableComp(net,delayLineShiftEn(end),validOutLookAhead,'',validReset,validDelayAmount,validOutLookAhead.name);
        end
        if size(Numerator,1)>1
            pirelab.getIntDelayEnabledResettableComp(net,accumulateValid,validOut,'',syncReset,1,validOut.name);
        else
            pirelab.getIntDelayEnabledResettableComp(net,validOutLookAhead,validOut,'',syncReset,1,validOut.name);
        end

        if isSymmetry
            rdAddrEndNonZero=pirelab.getCompareToZero(net,rdAddr(numMults+1),'~=','rdAddrEndNonZero');
            pirelab.getRelOpComp(net,[rdAddrDelayLine(numMults+1),wrAddr(numMults+1)],rdCountReached,'==');
            pirelab.getLogicComp(net,[rdAddrEndNonZero,rdCountReached],lutCountReached,'and');
            pirelab.getIntDelayEnabledResettableComp(net,lutCountReached,accumulateValid,'',syncReset,accumulateDelayAmount+double(isSymmetry)+1,'finalSumValidPipe');

        else
            rdAddrEndNonZero=pirelab.getCompareToZero(net,rdAddr(end),'~=','rdAddrEndNonZero');
            pirelab.getRelOpComp(net,[rdAddrDelayLine(end),wrAddr(end)],rdCountReached,'==');
            pirelab.getLogicComp(net,[rdAddrEndNonZero,rdCountReached],lutCountReached,'and');
            pirelab.getIntDelayEnabledResettableComp(net,lutCountReached,accumulateValid,'',syncReset,accumulateDelayAmount+double(isSymmetry)+1,'finalSumValidPipe');

        end














        pirelab.getLogicComp(net,rdAddrEndNonZero,rdAddrEndZero,'not');
        pirelab.getIntDelayEnabledResettableComp(net,rdAddrEndZero,accumulate,'',syncReset,accumulateDelayAmount+double(isSymmetry),'finalSumValidPipe');


        if size(Numerator,1)>1
            pirelab.getLogicComp(net,[accumulateValid,accumulate],accumulateRST,'or');
        else
            pirelab.getWireComp(net,accumulate,accumulateRST);
        end

        pirelab.getConstComp(net,accSwitchZeroIn,0);
        pirelab.getSwitchComp(net,[accDataOut,accSwitchZeroIn],accSwitchOut,accumulateRST);
        pirelab.getAddComp(net,[accSwitchOut,sumOutReg],accAdderOut);
        pirelab.getIntDelayEnabledResettableComp(net,accAdderOut,accDataOut,'',syncReset,1,accDataOut.name);

        pirelab.getIntDelayEnabledResettableComp(net,sumIn,sumOutReg,'',syncReset,1,sumOutReg.name);

        if FullPrecision
            pirelab.getWireComp(net,accDataOut,converterOut);
        else
            pirelab.getDTCComp(net,accDataOut,converterOut,params.RoundingMethod,params.OverflowAction);
        end
    end



    dataOutRegIn=net.addSignal(dataOut.Type,'dataOutRegIn');
    dataOutRegIn.SimulinkRate=dataRate;
    if strcmpi(params.synthesisTool,'Altera Quartus II')&&size(Numerator,1)==1
        pirelab.getIntDelayEnabledResettableComp(net,converterOut,dataOutRegIn,'',syncReset,1,'converterOutReg');
    else
        pirelab.getWireComp(net,converterOut,dataOutRegIn);
    end

    if size(Numerator,1)>1
        pirelab.getIntDelayEnabledResettableComp(net,dataOutRegIn,dataOut,accumulateValid,syncReset,1,dataOut.name);
    else
        pirelab.getIntDelayEnabledResettableComp(net,dataOutRegIn,dataOut,validOutLookAhead,syncReset,1,dataOut.name);
    end
end
























































































