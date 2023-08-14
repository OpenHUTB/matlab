function elaborateDVBS2SymbolDemodulatorNetwork(this,topNet,blockInfo,insignals,outsignals)







    dataIn=insignals(1);
    if(strcmpi(blockInfo.OutputType,'Vector'))
        startInput=insignals(2);
        endInput=insignals(3);
        validInput=insignals(4);
        if(strcmpi(blockInfo.ModulationSourceParams,'Input port'))
            modIndx=insignals(5);
            codeRateIndx=insignals(6);
            if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')&&blockInfo.EnbNoiseVar
                nVarInput=insignals(7);
            end
        else
            if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')&&blockInfo.EnbNoiseVar
                nVarInput=insignals(5);
            end
        end
    else
        validInput=insignals(2);
        if(strcmpi(blockInfo.ModulationSourceParams,'Input port'))
            modIndx=insignals(3);
            codeRateIndx=insignals(4);
            if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')&&blockInfo.EnbNoiseVar
                nVarInput=insignals(5);
            end
        else
            if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')&&blockInfo.EnbNoiseVar
                nVarInput=insignals(3);
            end
        end
    end


    dataOut=outsignals(1);
    if(strcmpi(blockInfo.OutputType,'Vector'))
        startOut=outsignals(2);
        endOut=outsignals(3);
        validOut=outsignals(4);
    else
        validOut=outsignals(2);
        readyOut=outsignals(3);
    end

    rate=dataIn.SimulinkRate;
    if(strcmpi(blockInfo.OutputType,'Vector'))
        dataOut.SimulinkRate=rate;
        startOut.SimulinkRate=rate;
        endOut.SimulinkRate=rate;
        validOut.SimulinkRate=rate;
    else
        validOut.SimulinkRate=rate;
        readyOut.SimulinkRate=rate;
    end
    inWL=dataIn.Type.BaseType.WordLength;
    inFL=dataIn.Type.BaseType.FractionLength;
    inComplexType=pir_complex_t(pir_sfixpt_t(inWL,inFL));

    if(strcmpi(blockInfo.OutputType,'Vector'))
        if(strcmpi(blockInfo.DecisionType,'Approximate log-likelihood ratio'))
            if blockInfo.EnbNoiseVar
                vecDT=pirelab.createPirArrayType(pir_sfixpt_t(inWL+14,inFL),[8,0]);
            else
                vecDT=pirelab.createPirArrayType(pir_sfixpt_t(inWL+3,inFL),[8,0]);
            end
        else
            vecDT=pirelab.createPirArrayType(pir_ufixpt_t(1,0),[8,0]);
        end
    else
        if(strcmpi(blockInfo.DecisionType,'Approximate log-likelihood ratio'))
            if blockInfo.EnbNoiseVar
                vecDT=pir_sfixpt_t(inWL+14,inFL);
            else
                vecDT=pir_sfixpt_t(inWL+3,inFL);
            end
        else
            vecDT=pir_ufixpt_t(1,0);
        end
    end


    modIndxSigDelay=newDataSignal(topNet,pir_ufixpt_t(3,0),'modIndxSigDelay',rate);
    codeRateIndxSigDelay=newDataSignal(topNet,pir_ufixpt_t(3,0),'codeRateIndxSigDelay',rate);

    if strcmp(blockInfo.ModulationSourceParams,'Property')

        switch(blockInfo.ModulationScheme)
        case 'pi/2-BPSK'
            numBitPerSym=1;
        case 'QPSK'
            numBitPerSym=2;
        case '8-PSK'
            numBitPerSym=3;
        case '16-APSK'
            numBitPerSym=4;
        case '32-APSK'
            numBitPerSym=5;
        otherwise
            numBitPerSym=2;
        end
        pirelab.getConstComp(topNet,modIndxSigDelay,numBitPerSym);

        if strcmp(blockInfo.ModulationScheme,'16-APSK')
            switch(blockInfo.CodeRateAPSK)
            case '2/3'
                codeRateIndex=0;
            case '3/4'
                codeRateIndex=1;
            case '4/5'
                codeRateIndex=2;
            case '5/6'
                codeRateIndex=3;
            case '8/9'
                codeRateIndex=4;
            case '9/10'
                codeRateIndex=5;
            otherwise
                codeRateIndex=1;
            end
        else
            switch(blockInfo.CodeRateAPSK)
            case '3/4'
                codeRateIndex=0;
            case '4/5'
                codeRateIndex=1;
            case '5/6'
                codeRateIndex=2;
            case '8/9'
                codeRateIndex=3;
            case '9/10'
                codeRateIndex=4;
            otherwise
                codeRateIndex=0;
            end
        end
        pirelab.getConstComp(topNet,codeRateIndxSigDelay,codeRateIndex);
    end


    fiMath1Reset=fimath('RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision','SumMode','FullPrecision');
    nt2Reset=numerictype(0,1,0);
    resetIn=newControlSignal(topNet,'resetIn',rate);
    resetIn1=newControlSignal(topNet,'resetIn1',rate);
    ConstantZeroForScReset=newControlSignal(topNet,'ConstantZeroForScReset',rate);

    vectorInpFlag=newControlSignal(topNet,'vectorInpFlag',rate);
    pirelab.getConstComp(topNet,vectorInpFlag,strcmpi(blockInfo.OutputType,'Vector'),'vectorInputFlag');

    pirelab.getConstComp(topNet,...
    ConstantZeroForScReset,...
    fi(0,nt2Reset,fiMath1Reset,'hex','0'),...
    'ConstantReset','on',1,'','','');

    pirelab.getSwitchComp(topNet,...
    [resetIn1,ConstantZeroForScReset],...
    resetIn,...
    vectorInpFlag,'SwitchReset',...
    '>',0,'Floor','Wrap');

    if(strcmpi(blockInfo.OutputType,'Vector'))
        startInDelay=newControlSignal(topNet,'startInDelay',rate);
        endInDelay=newControlSignal(topNet,'endInDelay',rate);
        validInDelay=newControlSignal(topNet,'validInDelay',rate);
        startInFlag=newControlSignal(topNet,'startInFlag',rate);

        sampleControlNet=this.elabSampleControl(topNet,blockInfo,rate);
        sampleControlNet.addComment('Sample control for valid start and end');

        inports(1)=startInput;
        inports(2)=endInput;
        inports(3)=validInput;

        outports(1)=startInDelay;
        outports(2)=endInDelay;
        outports(3)=validInDelay;
        outports(4)=startInFlag;
        outports(5)=resetIn1;
        pirelab.instantiateNetwork(topNet,sampleControlNet,inports,outports,'sampleControlNet_inst');



        if~strcmp(blockInfo.ModulationSourceParams,'Property')
            sampleModCodeRateIdxNet=this.elabSampleModIdxCodeRateIdx(topNet,blockInfo,rate);
            sampleModCodeRateIdxNet.addComment('Sample modIdx and codeRateIdx');


            inports_sampModCod(1)=startInDelay;
            inports_sampModCod(2)=modIndx;
            inports_sampModCod(3)=codeRateIndx;

            outports_sampModCod(1)=modIndxSigDelay;
            outports_sampModCod(2)=codeRateIndxSigDelay;
            pirelab.instantiateNetwork(topNet,sampleModCodeRateIdxNet,inports_sampModCod,outports_sampModCod,'sampleModCodeRateIdxNet_inst');
        end

    else

        scalarValidIn=newControlSignal(topNet,'scalarValidIn',rate);
        inpRecvFlag=newControlSignal(topNet,'inpRecvFlag',rate);
        readyOutReg=newControlSignal(topNet,'readyOutReg',rate);

        sclSampleControlNet=this.elabSclSampCtrl(topNet,blockInfo,rate);
        sclSampleControlNet.addComment('Sample control for scalar valid ');

        inportsSclSampCtrl(1)=validInput;
        inportsSclSampCtrl(2)=readyOutReg;

        outportsSclSampCtrl(1)=scalarValidIn;
        outportsSclSampCtrl(2)=inpRecvFlag;

        pirelab.instantiateNetwork(topNet,sclSampleControlNet,inportsSclSampCtrl,outportsSclSampCtrl,'sampleSclControlNet_inst');

        if~strcmp(blockInfo.ModulationSourceParams,'Property')



            sampScModCodeRateIdxNet=this.elabSampleModIdxCodeRateIdx(topNet,blockInfo,rate);
            sampScModCodeRateIdxNet.addComment('Sample modIdx and codeRateIdx for scalar');

            inports_sampScModCod(1)=scalarValidIn;
            inports_sampScModCod(2)=modIndx;
            inports_sampScModCod(3)=codeRateIndx;

            outports_sampScModCod(1)=modIndxSigDelay;
            outports_sampScModCod(2)=codeRateIndxSigDelay;

            pirelab.instantiateNetwork(topNet,sampScModCodeRateIdxNet,inports_sampScModCod,outports_sampScModCod,'sampScModCodeRateIdxNet_inst');

        end


        readyControlNet=this.elabReadyCtrl(topNet,blockInfo,rate);
        readyControlNet.addComment('Ready signal control for scalar valid ');

        inportsReadyControl(1)=scalarValidIn;
        inportsReadyControl(2)=inpRecvFlag;
        inportsReadyControl(3)=modIndxSigDelay;

        outportsReadyCtrl(1)=readyOut;

        pirelab.instantiateNetwork(topNet,readyControlNet,inportsReadyControl,outportsReadyCtrl,'readyControlNet_inst');

        pirelab.getIntDelayComp(topNet,readyOut,readyOutReg,1,'readyOutdelay',1);
    end



    dataInDelay=newDataSignal(topNet,inComplexType,'dataInDelay',rate);
    pirelab.getDTCComp(topNet,dataIn,dataInDelay);



    bpskEnable=newControlSignal(topNet,'bpskEnable',rate);
    qpskEnable=newControlSignal(topNet,'qpskEnable',rate);
    psk8Enable=newControlSignal(topNet,'psk8Enable',rate);
    apsk16Enable=newControlSignal(topNet,'apsk16Enable',rate);
    apsk32Enable=newControlSignal(topNet,'apsk32Enable',rate);

    pirelab.getCompareToValueComp(topNet,modIndxSigDelay,bpskEnable,'==',1);
    pirelab.getCompareToValueComp(topNet,modIndxSigDelay,qpskEnable,'==',2);
    pirelab.getCompareToValueComp(topNet,modIndxSigDelay,psk8Enable,'==',3);
    pirelab.getCompareToValueComp(topNet,modIndxSigDelay,apsk16Enable,'==',4);
    pirelab.getCompareToValueComp(topNet,modIndxSigDelay,apsk32Enable,'==',5);

    bpskValidIn=newControlSignal(topNet,'bpskValidIn',rate);
    qpskValidIn=newControlSignal(topNet,'qpskValidIn',rate);
    psk8ValidIn=newControlSignal(topNet,'psk8ValidIn',rate);
    apsk16ValidIn=newControlSignal(topNet,'apsk16ValidIn',rate);
    apsk32ValidIn=newControlSignal(topNet,'apsk32ValidIn',rate);

    if(strcmpi(blockInfo.OutputType,'Vector'))

        bpskValidInStart=newControlSignal(topNet,'bpskValidInStart',rate);
        qpskValidInStart=newControlSignal(topNet,'qpskValidInStart',rate);
        psk8ValidInStart=newControlSignal(topNet,'psk8ValidInStart',rate);
        apsk16ValidInStart=newControlSignal(topNet,'apsk16ValidInStart',rate);
        apsk32ValidInStart=newControlSignal(topNet,'apsk32ValidInStart',rate);

        pirelab.getBitwiseOpComp(topNet,[startInFlag,bpskEnable],bpskValidInStart,'AND');
        pirelab.getBitwiseOpComp(topNet,[startInFlag,qpskEnable],qpskValidInStart,'AND');
        pirelab.getBitwiseOpComp(topNet,[startInFlag,psk8Enable],psk8ValidInStart,'AND');
        pirelab.getBitwiseOpComp(topNet,[startInFlag,apsk16Enable],apsk16ValidInStart,'AND');
        pirelab.getBitwiseOpComp(topNet,[startInFlag,apsk32Enable],apsk32ValidInStart,'AND');

        pirelab.getBitwiseOpComp(topNet,[validInput,bpskValidInStart],bpskValidIn,'AND');
        pirelab.getBitwiseOpComp(topNet,[validInput,qpskValidInStart],qpskValidIn,'AND');
        pirelab.getBitwiseOpComp(topNet,[validInput,psk8ValidInStart],psk8ValidIn,'AND');
        pirelab.getBitwiseOpComp(topNet,[validInput,apsk16ValidInStart],apsk16ValidIn,'AND');
        pirelab.getBitwiseOpComp(topNet,[validInput,apsk32ValidInStart],apsk32ValidIn,'AND');

    else
        pirelab.getBitwiseOpComp(topNet,[scalarValidIn,bpskEnable],bpskValidIn,'AND');
        pirelab.getBitwiseOpComp(topNet,[scalarValidIn,qpskEnable],qpskValidIn,'AND');
        pirelab.getBitwiseOpComp(topNet,[scalarValidIn,psk8Enable],psk8ValidIn,'AND');
        pirelab.getBitwiseOpComp(topNet,[scalarValidIn,apsk16Enable],apsk16ValidIn,'AND');
        pirelab.getBitwiseOpComp(topNet,[scalarValidIn,apsk32Enable],apsk32ValidIn,'AND');

    end


    bpskValidInDelay=newControlSignal(topNet,'bpskValidInDelay',rate);
    qpskValidInDelay=newControlSignal(topNet,'qpskValidInDelay',rate);
    psk8ValidInDelay=newControlSignal(topNet,'psk8ValidInDelay',rate);
    apsk16ValidInDelay=newControlSignal(topNet,'apsk16ValidInDelay',rate);
    apsk32ValidInDelay=newControlSignal(topNet,'apsk32ValidInDelay',rate);

    pirelab.getUnitDelayComp(topNet,bpskValidIn,bpskValidInDelay);
    pirelab.getUnitDelayComp(topNet,qpskValidIn,qpskValidInDelay);
    pirelab.getUnitDelayComp(topNet,psk8ValidIn,psk8ValidInDelay);
    pirelab.getUnitDelayComp(topNet,apsk16ValidIn,apsk16ValidInDelay);
    pirelab.getUnitDelayComp(topNet,apsk32ValidIn,apsk32ValidInDelay);



    dataInDelay1=newDataSignal(topNet,inComplexType,'dataInDelay1',rate);
    pirelab.getUnitDelayComp(topNet,dataInDelay,dataInDelay1);

    if(strcmpi(blockInfo.OutputType,'Vector'))
        endInDelay1=newControlSignal(topNet,'endInDelay1',rate);
        pirelab.getUnitDelayComp(topNet,endInDelay,endInDelay1);
    end

    codeRateIndxSigDelay1=newDataSignal(topNet,pir_ufixpt_t(3,0),'codeRateIndxSigDelay1',rate);
    pirelab.getUnitDelayComp(topNet,codeRateIndxSigDelay,codeRateIndxSigDelay1);

    unitAvgPowerFlagIn=newControlSignal(topNet,'unitAvgPowerFlagIn',rate);
    pirelab.getConstComp(topNet,unitAvgPowerFlagIn,blockInfo.UnitAveragePower,'constBlkwithUnitAvgpowerFlag');

    if(strcmpi(blockInfo.DecisionType,'Approximate log-likelihood ratio'))
        if(strcmpi(blockInfo.OutputType,'Vector'))
            vecDTLLR=pirelab.createPirArrayType(pir_sfixpt_t(inWL+3,inFL),[8,0]);
        else
            vecDTLLR=pir_sfixpt_t(inWL+3,inFL);
        end
    else
        vecDTLLR=vecDT;
    end


    bpskDataOut=newDataSignal(topNet,vecDTLLR,'bpskDataOut',rate);
    bpskValidOut=newControlSignal(topNet,'bpskValidOut',rate);


    bpskDataOutDelay=newDataSignal(topNet,vecDTLLR,'bpskDataOutDelay',rate);
    bpskValidOutDelay=newControlSignal(topNet,'bpskValidOutDelay',rate);
    bpskValidOutBefRst=newControlSignal(topNet,'bpskValidOutBefRst',rate);


    qpskDataOut=newDataSignal(topNet,vecDTLLR,'qpskDataOut',rate);
    qpskValidOut=newControlSignal(topNet,'qpskValidOut',rate);


    qpskDataOutDelay=newDataSignal(topNet,vecDTLLR,'qpskDataOutDelay',rate);
    qpskValidOutDelay=newControlSignal(topNet,'qpskValidOutDelay',rate);


    psk8DataOut=newDataSignal(topNet,vecDTLLR,'psk8DataOut',rate);
    psk8ValidOut=newControlSignal(topNet,'psk8ValidOut',rate);


    psk8DataOutDelay=newDataSignal(topNet,vecDTLLR,'psk8DataOutDelay',rate);
    psk8ValidOutDelay=newControlSignal(topNet,'psk8ValidOutDelay',rate);



    apsk16DataOut=newDataSignal(topNet,vecDTLLR,'apsk16DataOut',rate);
    apsk16ValidOut=newControlSignal(topNet,'apsk16ValidOut',rate);


    apsk16DataOutDelay=newDataSignal(topNet,vecDTLLR,'apsk16DataOutDelay',rate);
    apsk16ValidOutDelay=newControlSignal(topNet,'apsk16ValidOutDelay',rate);


    apsk32DataOut=newDataSignal(topNet,vecDTLLR,'apsk32DataOut',rate);
    apsk32ValidOut=newControlSignal(topNet,'apsk32ValidOut',rate);

    if(strcmpi(blockInfo.OutputType,'Vector'))
        bpskNonMul8FlagOut=newControlSignal(topNet,'bpskNonMul8FlagOut',rate);
        bpskNonMul8FlagOutDelay=newControlSignal(topNet,'bpskNonMul8FlagOutDelay',rate);

        qpskNonMul8FlagOut=newControlSignal(topNet,'qpskNonMul8FlagOut',rate);
        qpskNonMul8FlagOutDelay=newControlSignal(topNet,'qpskNonMul8FlagOutDelay',rate);

        psk8NonMul8FlagOut=newControlSignal(topNet,'psk8NonMul8FlagOut',rate);
        psk8NonMul8FlagOutDelay=newControlSignal(topNet,'psk8NonMul8FlagOutDelay',rate);

        apsk16NonMul8FlagOut=newControlSignal(topNet,'apsk16NonMul8FlagOut',rate);
        apsk16NonMul8FlagOutDelay=newControlSignal(topNet,'apsk16NonMul8FlagOutDelay',rate);

        apsk32NonMul8FlagOut=newControlSignal(topNet,'apsk32NonMul8FlagOut',rate);
    end


    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')&&blockInfo.EnbNoiseVar
        dataOutDelay=newDataSignal(topNet,vecDTLLR,'dataOutDelayLLR',rate);
        dataOutDivDelay=newDataSignal(topNet,vecDTLLR,'dataOutDivDelay',rate);
        validOutDivDelay=newControlSignal(topNet,'validOutDivDelay',rate);
        NonMul8FlagOutDivDelay=newControlSignal(topNet,'NonMul8FlagOutDivDelay',rate);


        numeratorOne=newUnitControlSignal(topNet,'numeratorOneIn',rate);
        pirelab.getConstComp(topNet,numeratorOne,1,'constBlkwithNumeratorOne');



        inNVarWL=nVarInput.Type.BaseType.WordLength;
        inNVarFL=nVarInput.Type.BaseType.FractionLength;
        vecDTNVar=pirelab.createPirArrayType(pir_ufixpt_t(inNVarWL,inNVarFL),[8,0]);




        fracLenNVar=newDataSignal(topNet,pir_ufixpt_t(5,0),'fracLenNVar',rate);
        pirelab.getConstComp(topNet,fracLenNVar,-inNVarFL,'constfracLenNVar');
        nonZeroNVar=newDataSignal(topNet,pir_ufixpt_t(inNVarWL,inNVarFL),'nonZeroNVar',rate);
        nVarVecOut=newDataSignal(topNet,vecDTNVar,'nVarVecOut',rate);

        inpHandleZeroNVar(1)=nVarInput;
        inpHandleZeroNVar(2)=fracLenNVar;

        outHandleZeroNVar(1)=nonZeroNVar;

        handleZeroNVarNet=this.elabhandleZeroNVarNet(topNet,blockInfo,rate,inNVarWL,inNVarFL);
        handleZeroNVarNet.addComment('outputs non zero noise variance value');

        pirelab.instantiateNetwork(topNet,handleZeroNVarNet,inpHandleZeroNVar,outHandleZeroNVar,'handleZeroNVar_inst');

        nonZeroNVarDelay=newDataSignal(topNet,pir_ufixpt_t(inNVarWL,inNVarFL),'nonZeroNVarDelay',rate);
        pirelab.getIntDelayComp(topNet,nonZeroNVar,nonZeroNVarDelay,1,'delay_nVarInput',2^(inNVarFL));


    else
        dataOutDelay=newDataSignal(topNet,vecDT,'dataOutDelay',rate);
    end


    if(strcmpi(blockInfo.DecisionType,'Approximate log-likelihood ratio'))


        if(strcmpi(blockInfo.OutputType,'Vector'))

            symbBPSKDemodNet=this.elabPiBy2BPSKSymDemodNet(topNet,blockInfo,rate,inWL,inFL);
            symbBPSKDemodNet.addComment('Pi/2 BPSK Demodulation');

            inports_bpsk(1)=dataInDelay1;
            inports_bpsk(2)=bpskValidInDelay;
            inports_bpsk(3)=resetIn;
            inports_bpsk(4)=endInDelay1;

            outports_bpsk(1)=bpskDataOut;
            outports_bpsk(2)=bpskValidOut;
            outports_bpsk(3)=bpskNonMul8FlagOut;

            pirelab.instantiateNetwork(topNet,symbBPSKDemodNet,inports_bpsk,outports_bpsk,'symbBPSKDemodNet_inst');

            pirelab.getIntDelayComp(topNet,bpskDataOut,bpskDataOutDelay,11,'delay_bpskDataOut');
            pirelab.getIntDelayComp(topNet,bpskNonMul8FlagOut,bpskNonMul8FlagOutDelay,11,'delay_bpskNonMul8FlagOut');
            bpskVecLLRDelay=newDataSignal(topNet,pir_ufixpt_t(6,0),'bpskVecLLRDelay',rate);
            pirelab.getConstComp(topNet,bpskVecLLRDelay,11,'constbpskVecLLRDelay');
            pirelab.getIntDelayComp(topNet,bpskValidOut,bpskValidOutBefRst,11,'delay_bpskValidOut');

            validRstBPSKNet=this.elabValidWithRstNet(topNet,blockInfo,rate);
            validRstBPSKNet.addComment('pi/2-BPSK valid along With reset');

            inports_valRstBPSK(1)=bpskValidOutBefRst;
            inports_valRstBPSK(2)=resetIn;
            inports_valRstBPSK(3)=bpskVecLLRDelay;

            outports_valRstBPSK(1)=bpskValidOutDelay;

            pirelab.instantiateNetwork(topNet,validRstBPSKNet,inports_valRstBPSK,outports_valRstBPSK,'ValRstBPSKVecLLR_inst');

            if blockInfo.EnbNoiseVar
                nVarVecBPSK=newDataSignal(topNet,vecDTNVar,'nVarVecBPSK',rate);
                nVarVecBPSKDelay=newDataSignal(topNet,vecDTNVar,'nVarVecBPSKDelay',rate);
                symbBPSKNVarNet=this.elabPiBy2BPSKnVarVecNet(topNet,blockInfo,rate,inNVarWL,inNVarFL);
                symbBPSKNVarNet.addComment('Pi/2 BPSK noise variance vector formation');

                inports_bpskNVar(1)=nonZeroNVarDelay;
                inports_bpskNVar(2)=bpskValidInDelay;
                inports_bpskNVar(3)=resetIn;
                inports_bpskNVar(4)=endInDelay1;

                outports_bpskNVar(1)=nVarVecBPSK;

                pirelab.instantiateNetwork(topNet,symbBPSKNVarNet,inports_bpskNVar,outports_bpskNVar,'nVarBPSKNet_inst');

                pirelab.getIntDelayComp(topNet,nVarVecBPSK,nVarVecBPSKDelay,16,'delay_nVarVecBPSK',2^(inNVarFL));
            end


            symbQPSKDemodNet=this.elabQPSKSymDemodNet(topNet,blockInfo,rate,inWL,inFL);
            symbQPSKDemodNet.addComment('QPSK Demodulation');

            inports_qpsk(1)=dataInDelay1;
            inports_qpsk(2)=qpskValidInDelay;
            inports_qpsk(3)=resetIn;
            inports_qpsk(4)=endInDelay1;

            outports_qpsk(1)=qpskDataOut;
            outports_qpsk(2)=qpskValidOut;
            outports_qpsk(3)=qpskNonMul8FlagOut;

            pirelab.instantiateNetwork(topNet,symbQPSKDemodNet,inports_qpsk,outports_qpsk,'symbQPSKDemodNet_inst');

            pirelab.getIntDelayComp(topNet,qpskDataOut,qpskDataOutDelay,11,'delay_qpskDataOut');
            pirelab.getIntDelayEnabledResettableComp(topNet,qpskValidOut,qpskValidOutDelay,1,resetIn,11,'delay_qpskValidOut',0);
            pirelab.getIntDelayComp(topNet,qpskNonMul8FlagOut,qpskNonMul8FlagOutDelay,11,'delay_qpskNonMul8FlagOut');


            if blockInfo.EnbNoiseVar
                nVarVecQPSK=newDataSignal(topNet,vecDTNVar,'nVarVecQPSK',rate);
                nVarVecQPSKDelay=newDataSignal(topNet,vecDTNVar,'nVarVecQPSKDelay',rate);
                symbQPSKNVarNet=this.elabQPSKnVarVecNet(topNet,blockInfo,rate,inNVarWL,inNVarFL);
                symbQPSKNVarNet.addComment('QPSK noise variance vector formation');

                inports_qpskNVar(1)=nonZeroNVarDelay;
                inports_qpskNVar(2)=qpskValidInDelay;
                inports_qpskNVar(3)=resetIn;
                inports_qpskNVar(4)=endInDelay1;

                outports_qpskNVar(1)=nVarVecQPSK;

                pirelab.instantiateNetwork(topNet,symbQPSKNVarNet,inports_qpskNVar,outports_qpskNVar,'nVarQPSKNet_inst');

                pirelab.getIntDelayComp(topNet,nVarVecQPSK,nVarVecQPSKDelay,16,'delay_nVarVecQPSK',2^(inNVarFL));
            end


            symbPSK8DemodNet=this.elab8PSKSymDemodNet(topNet,blockInfo,rate,inWL,inFL);
            symbPSK8DemodNet.addComment('8-PSK Demodulation');

            inports_8psk(1)=dataInDelay1;
            inports_8psk(2)=psk8ValidInDelay;
            inports_8psk(3)=resetIn;
            inports_8psk(4)=endInDelay1;

            outports_8psk(1)=psk8DataOut;
            outports_8psk(2)=psk8ValidOut;
            outports_8psk(3)=psk8NonMul8FlagOut;

            pirelab.instantiateNetwork(topNet,symbPSK8DemodNet,inports_8psk,outports_8psk,'symbPSK8DemodNet_inst');

            pirelab.getIntDelayComp(topNet,psk8DataOut,psk8DataOutDelay,10,'delay_8pskDataOut');
            pirelab.getIntDelayEnabledResettableComp(topNet,psk8ValidOut,psk8ValidOutDelay,1,resetIn,10,'delay_8pskValidOut',0);
            pirelab.getIntDelayComp(topNet,psk8NonMul8FlagOut,psk8NonMul8FlagOutDelay,10,'delay_8pskNonMul8FlagOut');

            if blockInfo.EnbNoiseVar
                vecDTNVar=pirelab.createPirArrayType(pir_ufixpt_t(inNVarWL,inNVarFL),[8,0]);
                nVarVec8PSK=newDataSignal(topNet,vecDTNVar,'nVarVec8PSK',rate);
                nVarVec8PSKDelay=newDataSignal(topNet,vecDTNVar,'nVarVec8PSKDelay',rate);
                symb8PSKNVarNet=this.ela8PSKnVarVecNet(topNet,blockInfo,rate,inNVarWL,inNVarFL);
                symb8PSKNVarNet.addComment('8-PSK noise variance vector formation');

                inports_8pskNVar(1)=nonZeroNVarDelay;
                inports_8pskNVar(2)=psk8ValidInDelay;
                inports_8pskNVar(3)=resetIn;
                inports_8pskNVar(4)=endInDelay1;

                outports_8pskNVar(1)=nVarVec8PSK;

                pirelab.instantiateNetwork(topNet,symb8PSKNVarNet,inports_8pskNVar,outports_8pskNVar,'nVar8PSKNet_inst');

                pirelab.getIntDelayComp(topNet,nVarVec8PSK,nVarVec8PSKDelay,15,'delay_nVarVec8PSK',2^(inNVarFL));
            end


            symb16APSKDemodNet=this.elab16APSKSymDemodNet(topNet,blockInfo,rate,inWL,inFL);
            symb16APSKDemodNet.addComment('16-APSK Demodulation');

            inports_16apsk(1)=dataInDelay1;
            inports_16apsk(2)=apsk16ValidInDelay;
            inports_16apsk(3)=codeRateIndxSigDelay1;
            inports_16apsk(4)=unitAvgPowerFlagIn;
            inports_16apsk(5)=resetIn;
            inports_16apsk(6)=endInDelay1;

            outports_16apsk(1)=apsk16DataOut;
            outports_16apsk(2)=apsk16ValidOut;
            outports_16apsk(3)=apsk16NonMul8FlagOut;

            pirelab.instantiateNetwork(topNet,symb16APSKDemodNet,inports_16apsk,outports_16apsk,'symb16APSKDemodNet_inst');

            pirelab.getIntDelayComp(topNet,apsk16DataOut,apsk16DataOutDelay,1,'delay_16apskDataOut');
            pirelab.getIntDelayEnabledResettableComp(topNet,apsk16ValidOut,apsk16ValidOutDelay,1,resetIn,1,'delay_16apskValidOut',0);
            pirelab.getIntDelayComp(topNet,apsk16NonMul8FlagOut,apsk16NonMul8FlagOutDelay,1,'delay_apsk16NonMul8FlagOutDelay');

            if blockInfo.EnbNoiseVar
                vecDTNVar=pirelab.createPirArrayType(pir_ufixpt_t(inNVarWL,inNVarFL),[8,0]);
                nVarVec16APSK=newDataSignal(topNet,vecDTNVar,'nVarVec16APSK',rate);
                nVarVec16APSKDelay=newDataSignal(topNet,vecDTNVar,'nVarVec16APSKDelay',rate);
                symb16APSKNVarNet=this.elab16APSKnVarVecNet(topNet,blockInfo,rate,inNVarWL,inNVarFL);
                symb16APSKNVarNet.addComment('16-APSK noise variance vector formation');

                inports_16apskNVar(1)=nonZeroNVarDelay;
                inports_16apskNVar(2)=apsk16ValidInDelay;
                inports_16apskNVar(3)=resetIn;
                inports_16apskNVar(4)=endInDelay1;

                outports_16apskNVar(1)=nVarVec16APSK;

                pirelab.instantiateNetwork(topNet,symb16APSKNVarNet,inports_16apskNVar,outports_16apskNVar,'nVar16APSKNet_inst');

                pirelab.getIntDelayComp(topNet,nVarVec16APSK,nVarVec16APSKDelay,16,'delay_nVarVec16APSK',2^(inNVarFL));
            end


            symb32APSKDemodNet=this.elab32APSKSymDemodNet(topNet,blockInfo,rate,inWL,inFL);
            symb32APSKDemodNet.addComment('32-APSK Demodulation');

            inports_32apsk(1)=dataInDelay1;
            inports_32apsk(2)=apsk32ValidInDelay;
            inports_32apsk(3)=codeRateIndxSigDelay1;
            inports_32apsk(4)=unitAvgPowerFlagIn;
            inports_32apsk(5)=resetIn;
            inports_32apsk(6)=endInDelay1;

            outports_32apsk(1)=apsk32DataOut;
            outports_32apsk(2)=apsk32ValidOut;
            outports_32apsk(3)=apsk32NonMul8FlagOut;

            pirelab.instantiateNetwork(topNet,symb32APSKDemodNet,inports_32apsk,outports_32apsk,'symb32APSKDemodNet_inst');

            if blockInfo.EnbNoiseVar
                vecDTNVar=pirelab.createPirArrayType(pir_ufixpt_t(inNVarWL,inNVarFL),[8,0]);
                nVarVec32APSK=newDataSignal(topNet,vecDTNVar,'nVarVec32APSK',rate);
                nVarVec32APSKDelay=newDataSignal(topNet,vecDTNVar,'nVarVec32APSKDelay',rate);
                symb32APSKNVarNet=this.elab32APSKnVarVecNet(topNet,blockInfo,rate,inNVarWL,inNVarFL);
                symb32APSKNVarNet.addComment('32-APSK noise variance vector formation');

                inports_32apskNVar(1)=nonZeroNVarDelay;
                inports_32apskNVar(2)=apsk32ValidInDelay;
                inports_32apskNVar(3)=resetIn;
                inports_32apskNVar(4)=endInDelay1;

                outports_32apskNVar(1)=nVarVec32APSK;

                pirelab.instantiateNetwork(topNet,symb32APSKNVarNet,inports_32apskNVar,outports_32apskNVar,'nVar32APSKNet_inst');

                pirelab.getIntDelayComp(topNet,nVarVec32APSK,nVarVec32APSKDelay,15,'delay_nVarVec32APSK',2^(inNVarFL));
            end

        else
            symbScBPSKDemodNet=this.elabScPiBy2BPSKSymDemodNet(topNet,blockInfo,rate,inWL,inFL);
            symbScBPSKDemodNet.addComment('Pi/2 BPSK scalar Demodulation');

            inports_bpskSc(1)=dataInDelay1;
            inports_bpskSc(2)=bpskValidInDelay;

            outports_bpskSc(1)=bpskDataOut;
            outports_bpskSc(2)=bpskValidOut;

            pirelab.instantiateNetwork(topNet,symbScBPSKDemodNet,inports_bpskSc,outports_bpskSc,'symbBPSKScDemodNet_inst');

            bpskScLLRDelay=3+9+1;
            pirelab.getIntDelayComp(topNet,bpskDataOut,bpskDataOutDelay,bpskScLLRDelay,'delay_bpskScDataOut');
            pirelab.getIntDelayComp(topNet,bpskValidOut,bpskValidOutDelay,bpskScLLRDelay,'delay_bpskScValidOut');



            symbQPSKScDemodNet=this.elabQPSKScSymDemodNet(topNet,blockInfo,rate,inWL,inFL);
            symbQPSKScDemodNet.addComment('QPSK Scalar Demodulation');

            inports_qpskSc(1)=dataInDelay1;
            inports_qpskSc(2)=qpskValidInDelay;

            outports_qpskSc(1)=qpskDataOut;
            outports_qpskSc(2)=qpskValidOut;

            pirelab.instantiateNetwork(topNet,symbQPSKScDemodNet,inports_qpskSc,outports_qpskSc,'symbQPSKScDemodNet_inst');

            qpskScLLRDelay=3+9+1;
            pirelab.getIntDelayComp(topNet,qpskDataOut,qpskDataOutDelay,qpskScLLRDelay,'delay_qpskScDataOut');
            pirelab.getIntDelayComp(topNet,qpskValidOut,qpskValidOutDelay,qpskScLLRDelay,'delay_qpskScValidOut');



            symbpsk8ScDemodNet=this.elabpsk8ScSymDemodNet(topNet,blockInfo,rate,inWL,inFL);
            symbpsk8ScDemodNet.addComment('psk8 Scalar Demodulation');

            inports_psk8Sc(1)=dataInDelay1;
            inports_psk8Sc(2)=psk8ValidInDelay;

            outports_psk8Sc(1)=psk8DataOut;
            outports_psk8Sc(2)=psk8ValidOut;

            pirelab.instantiateNetwork(topNet,symbpsk8ScDemodNet,inports_psk8Sc,outports_psk8Sc,'symbpsk8ScDemodNet_inst');

            psk8ScLLRDelay=9+1;
            pirelab.getIntDelayComp(topNet,psk8DataOut,psk8DataOutDelay,psk8ScLLRDelay,'delay_psk8ScDataOut');
            pirelab.getIntDelayComp(topNet,psk8ValidOut,psk8ValidOutDelay,psk8ScLLRDelay,'delay_psk8ScValidOut');


            symbapsk16ScDemodNet=this.elabapsk16ScSymDemodNet(topNet,blockInfo,rate,inWL,inFL);
            symbapsk16ScDemodNet.addComment('apsk16 Scalar Demodulation');

            inports_apsk16Sc(1)=dataInDelay1;
            inports_apsk16Sc(2)=apsk16ValidInDelay;
            inports_apsk16Sc(3)=codeRateIndxSigDelay1;
            inports_apsk16Sc(4)=unitAvgPowerFlagIn;

            outports_apsk16Sc(1)=apsk16DataOut;
            outports_apsk16Sc(2)=apsk16ValidOut;

            pirelab.instantiateNetwork(topNet,symbapsk16ScDemodNet,inports_apsk16Sc,outports_apsk16Sc,'symbapsk16ScDemodNet_inst');
            apsk16ScLLRDelay=1;
            pirelab.getIntDelayComp(topNet,apsk16DataOut,apsk16DataOutDelay,apsk16ScLLRDelay,'delay_apsk16ScDataOut');
            pirelab.getIntDelayComp(topNet,apsk16ValidOut,apsk16ValidOutDelay,apsk16ScLLRDelay,'delay_apsk16ScValidOut');


            symbapsk32ScDemodNet=this.elabapsk32ScSymDemodNet(topNet,blockInfo,rate,inWL,inFL);
            symbapsk32ScDemodNet.addComment('apsk32 Scalar Demodulation');

            inports_apsk32Sc(1)=dataInDelay1;
            inports_apsk32Sc(2)=apsk32ValidInDelay;
            inports_apsk32Sc(3)=codeRateIndxSigDelay1;
            inports_apsk32Sc(4)=unitAvgPowerFlagIn;

            outports_apsk32Sc(1)=apsk32DataOut;
            outports_apsk32Sc(2)=apsk32ValidOut;

            pirelab.instantiateNetwork(topNet,symbapsk32ScDemodNet,inports_apsk32Sc,outports_apsk32Sc,'symbapsk32ScDemodNet_inst');

        end

    else

        LutNAPSKWL=15;
        LutNAPSKFL=14;
        bGAng=7;
        inWLBefAng=inWL+bGAng;
        inFLBefAng=inFL-bGAng;
        UAPWLDelay=inWLBefAng+LutNAPSKWL;
        UAPFLDelay=inFLBefAng-LutNAPSKFL;
        angMagBlkDelayFac=7;

        inComplexTypeHD=pir_complex_t(pir_sfixpt_t(inWLBefAng,inFLBefAng));
        dataInDelayHD=newDataSignal(topNet,inComplexTypeHD,'dataInDelayHD',rate);
        pirelab.getDTCComp(topNet,dataInDelay1,dataInDelayHD);

        if(strcmpi(blockInfo.OutputType,'Vector'))
            endInDelay1ComplxToMagAng=newControlSignal(topNet,'endInDelay1ComplxToMagAng',rate);
            pirelab.getIntDelayComp(topNet,endInDelay1,endInDelay1ComplxToMagAng,inWL+10,'delay_endInDelay1ComplxToMagAng');

            endInDelay2ComplxToMagAng=newControlSignal(topNet,'endInDelay2ComplxToMagAng',rate);
            pirelab.getIntDelayComp(topNet,endInDelay1,endInDelay2ComplxToMagAng,inWL+10+15+4+2,'delay_endInDelay2ComplxToMagAng');
        end

        codeRateIndxSigDelayMagAng=newDataSignal(topNet,pir_ufixpt_t(3,0),'codeRateIndxSigDelayMagAng',rate);
        pirelab.getIntDelayComp(topNet,codeRateIndxSigDelay1,codeRateIndxSigDelayMagAng,inWL+10+15+4+2,'delay_codeRateIndxSigDelayMagAng');



        bpskAngleOut=newDataSignal(topNet,pir_sfixpt_t(inWLBefAng+3,-inWLBefAng),'bpskAngleOut',rate);
        bpskAngleValidOut=newControlSignal(topNet,'bpskAngleValidOut',rate);

        bpskComplxToAngleNet=this.elabComplxToAngleNet(topNet,blockInfo,rate,inWLBefAng,inFLBefAng);
        bpskComplxToAngleNet.addComment('complex to angle BPSK');

        inports_bpskcomplxToAng(1)=dataInDelayHD;
        inports_bpskcomplxToAng(2)=bpskValidInDelay;

        outports_bpskcomplxToAng(1)=bpskAngleOut;
        outports_bpskcomplxToAng(2)=bpskAngleValidOut;

        pirelab.instantiateNetwork(topNet,bpskComplxToAngleNet,inports_bpskcomplxToAng,outports_bpskcomplxToAng,'ComplxToAngBPSKNet_inst');

        if(strcmpi(blockInfo.OutputType,'Vector'))
            symbBPSKHDDemodNet=this.elabPiBy2BPSKHDSymDemodNet(topNet,blockInfo,rate,inWLBefAng);
            symbBPSKHDDemodNet.addComment('Pi/2 BPSK HD Demodulation');

            inports_bpskHD(1)=bpskAngleOut;
            inports_bpskHD(2)=bpskAngleValidOut;
            inports_bpskHD(3)=resetIn;
            inports_bpskHD(4)=endInDelay1ComplxToMagAng;

            outports_bpskHD(1)=bpskDataOut;
            outports_bpskHD(2)=bpskValidOut;
            outports_bpskHD(3)=bpskNonMul8FlagOut;

            pirelab.instantiateNetwork(topNet,symbBPSKHDDemodNet,inports_bpskHD,outports_bpskHD,'symbBPSKHDDemodNet_inst');

            delayBPSKHD=1+LutNAPSKWL+2+angMagBlkDelayFac-3;
            pirelab.getIntDelayComp(topNet,bpskNonMul8FlagOut,bpskNonMul8FlagOutDelay,delayBPSKHD,'delay_bpskHDNonMul8FlagOut');

        else
            symbScBPSKHDDemodNet=this.elabScPiBy2BPSKHDSymDemodNet(topNet,blockInfo,rate,inWLBefAng);
            symbScBPSKHDDemodNet.addComment('Pi/2 BPSK Scalar HD Demodulation');

            inports_bpskHDSc(1)=bpskAngleOut;
            inports_bpskHDSc(2)=bpskAngleValidOut;

            outports_bpskHDSc(1)=bpskDataOut;
            outports_bpskHDSc(2)=bpskValidOut;

            pirelab.instantiateNetwork(topNet,symbScBPSKHDDemodNet,inports_bpskHDSc,outports_bpskHDSc,'symbScBPSKHDDemodNet_inst');

            delayBPSKHD=0+3+LutNAPSKWL+2+angMagBlkDelayFac-3;
        end
        pirelab.getIntDelayComp(topNet,bpskDataOut,bpskDataOutDelay,delayBPSKHD,'delay_bpskHDDataOut');
        pirelab.getIntDelayEnabledResettableComp(topNet,bpskValidOut,bpskValidOutDelay,1,resetIn,delayBPSKHD,'delay_bpskHDValidOut',0);



        qpskAngleOut=newDataSignal(topNet,pir_sfixpt_t(inWLBefAng+3,-inWLBefAng),'qpskAngleOut',rate);
        qpskAngleValidOut=newControlSignal(topNet,'qpskAngleValidOut',rate);

        qpskComplxToAngleNet=this.elabComplxToAngleNet(topNet,blockInfo,rate,inWLBefAng,inFLBefAng);
        qpskComplxToAngleNet.addComment('complex to angle QPSK');

        inports_qpskcomplxToAng(1)=dataInDelayHD;
        inports_qpskcomplxToAng(2)=qpskValidInDelay;

        outports_qpskcomplxToAng(1)=qpskAngleOut;
        outports_qpskcomplxToAng(2)=qpskAngleValidOut;

        pirelab.instantiateNetwork(topNet,qpskComplxToAngleNet,inports_qpskcomplxToAng,outports_qpskcomplxToAng,'ComplxToAngQPSKHDNet_inst');

        if(strcmpi(blockInfo.OutputType,'Vector'))
            symbQPSKHDDemodNet=this.elabQPSKHDSymDemodNet(topNet,blockInfo,rate,inWLBefAng);
            symbQPSKHDDemodNet.addComment('QPSK HD Demodulation');

            inports_qpskHD(1)=qpskAngleOut;
            inports_qpskHD(2)=qpskAngleValidOut;
            inports_qpskHD(3)=resetIn;
            inports_qpskHD(4)=endInDelay1ComplxToMagAng;

            outports_qpskHD(1)=qpskDataOut;
            outports_qpskHD(2)=qpskValidOut;
            outports_qpskHD(3)=qpskNonMul8FlagOut;

            pirelab.instantiateNetwork(topNet,symbQPSKHDDemodNet,inports_qpskHD,outports_qpskHD,'symbQPSKHDDemodNet_inst');

            delayQPSKHD=1+LutNAPSKWL+2+angMagBlkDelayFac-3;
            pirelab.getIntDelayComp(topNet,qpskNonMul8FlagOut,qpskNonMul8FlagOutDelay,delayQPSKHD,'delay_qpskHDNonMul8FlagOut');
        else
            symbScQPSKHDDemodNet=this.elabScQPSKHDSymDemodNet(topNet,blockInfo,rate,inWLBefAng);
            symbScQPSKHDDemodNet.addComment('QPSK Scalar HD Demodulation');

            inports_qpskHDSc(1)=qpskAngleOut;
            inports_qpskHDSc(2)=qpskAngleValidOut;

            outports_qpskHDSc(1)=qpskDataOut;
            outports_qpskHDSc(2)=qpskValidOut;

            pirelab.instantiateNetwork(topNet,symbScQPSKHDDemodNet,inports_qpskHDSc,outports_qpskHDSc,'symbScQPSKHDDemodNet_inst');

            delayQPSKHD=0+3+LutNAPSKWL+2+angMagBlkDelayFac-3;
        end
        pirelab.getIntDelayComp(topNet,qpskDataOut,qpskDataOutDelay,delayQPSKHD,'delay_qpskHDDataOut');
        pirelab.getIntDelayEnabledResettableComp(topNet,qpskValidOut,qpskValidOutDelay,1,resetIn,delayQPSKHD,'delay_qpskHDValidOut',0);



        psk8AngleOut=newDataSignal(topNet,pir_sfixpt_t(inWLBefAng+3,-inWLBefAng),'psk8AngleOut',rate);
        psk8AngleValidOut=newControlSignal(topNet,'psk8AngleValidOut',rate);

        psk8ComplxToAngleNet=this.elabComplxToAngleNet(topNet,blockInfo,rate,inWLBefAng,inFLBefAng);
        psk8ComplxToAngleNet.addComment('complex to angle 8-PSK');

        inports_psk8complxToAng(1)=dataInDelayHD;
        inports_psk8complxToAng(2)=psk8ValidInDelay;

        outports_psk8complxToAng(1)=psk8AngleOut;
        outports_psk8complxToAng(2)=psk8AngleValidOut;

        pirelab.instantiateNetwork(topNet,psk8ComplxToAngleNet,inports_psk8complxToAng,outports_psk8complxToAng,'ComplxToAngpsk8Net_inst');

        if(strcmpi(blockInfo.OutputType,'Vector'))
            symbpsk8HDDemodNet=this.elabPSK8HDSymDemodNet(topNet,blockInfo,rate,inWLBefAng);
            symbpsk8HDDemodNet.addComment('8-PSK HD Demodulation');

            inports_psk8HD(1)=psk8AngleOut;
            inports_psk8HD(2)=psk8AngleValidOut;
            inports_psk8HD(3)=resetIn;
            inports_psk8HD(4)=endInDelay1ComplxToMagAng;

            outports_psk8HD(1)=psk8DataOut;
            outports_psk8HD(2)=psk8ValidOut;
            outports_psk8HD(3)=psk8NonMul8FlagOut;

            pirelab.instantiateNetwork(topNet,symbpsk8HDDemodNet,inports_psk8HD,outports_psk8HD,'symbpsk8HDDemodNet_inst');

            delay8PSKHD=0+LutNAPSKWL+2+angMagBlkDelayFac-3;
            pirelab.getIntDelayComp(topNet,psk8NonMul8FlagOut,psk8NonMul8FlagOutDelay,delay8PSKHD,'delay_8pskHDNonMul8FlagOut');
        else
            symbSc8PSKHDDemodNet=this.elabSc8PSKHDSymDemodNet(topNet,blockInfo,rate,inWLBefAng);
            symbSc8PSKHDDemodNet.addComment('8PSK Scalar HD Demodulation');

            inports_8PskHDSc(1)=psk8AngleOut;
            inports_8PskHDSc(2)=psk8AngleValidOut;

            outports_8PskHDSc(1)=psk8DataOut;
            outports_8PskHDSc(2)=psk8ValidOut;

            pirelab.instantiateNetwork(topNet,symbSc8PSKHDDemodNet,inports_8PskHDSc,outports_8PskHDSc,'symbSc8PSKHDDemodNet_inst');

            delay8PSKHD=0+LutNAPSKWL+2+angMagBlkDelayFac-3;
        end
        pirelab.getIntDelayComp(topNet,psk8DataOut,psk8DataOutDelay,delay8PSKHD,'delay_8pskHDDataOut');
        pirelab.getIntDelayEnabledResettableComp(topNet,psk8ValidOut,psk8ValidOutDelay,1,resetIn,delay8PSKHD,'delay_8pskHDValidOut',0);


        pirTyp2=pir_ufixpt_t(1,0);
        pirTyp1=pir_sfixpt_t(inWLBefAng,inFLBefAng);
        pirTyp4=pir_sfixpt_t(inWLBefAng+LutNAPSKWL,inFLBefAng-LutNAPSKFL);
        pirTyp5=pir_ufixpt_t(LutNAPSKWL,-LutNAPSKFL);

        fiMath1=fimath('RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision','SumMode','FullPrecision');

        nt1=numerictype(0,LutNAPSKWL,LutNAPSKFL);
        nt2=numerictype(1,inWLBefAng,-inFLBefAng);
        nt3=numerictype(1,inWLBefAng+LutNAPSKWL,-(inFLBefAng-LutNAPSKFL));

        slRate1=rate;

        Real_ImagToComplex_out1_s16=addSignal(topNet,'Real-Imag to Complex_out1',pir_complex_t(pirTyp4),slRate1);

        LogicalOperator1_out1_s13=addSignal(topNet,sprintf('Logical\nOperator1_out1'),pirTyp2,slRate1);

        ComplexToReal_Imag_out1_s5=addSignal(topNet,'Complex to Real-Imag_out1',pirTyp1,slRate1);
        ComplexToReal_Imag_out2_s6=addSignal(topNet,'Complex to Real-Imag_out2',pirTyp1,slRate1);
        HwModeRegister_out1_s7=addSignal(topNet,'HwModeRegister_out1',pirTyp5,slRate1);
        HwModeRegister1_out1_s8=addSignal(topNet,'HwModeRegister1_out1',pirTyp1,slRate1);
        HwModeRegister2_out1_s9=addSignal(topNet,'HwModeRegister2_out1',pirTyp5,slRate1);
        HwModeRegister3_out1_s10=addSignal(topNet,'HwModeRegister3_out1',pirTyp1,slRate1);
        LUTN16_0Plus_out1_s11=addSignal(topNet,'LUTN16_0Plus_out1',pirTyp5,slRate1);
        LogicalOperator_out1_s12=addSignal(topNet,sprintf('Logical\nOperator_out1'),pirTyp2,slRate1);
        PipelineRegister_out1_s14=addSignal(topNet,'PipelineRegister_out1',pirTyp4,slRate1);
        PipelineRegister1_out1_s15=addSignal(topNet,'PipelineRegister1_out1',pirTyp4,slRate1);
        Switch_out1_s17=addSignal(topNet,'Switch_out1',pirTyp4,slRate1);
        Switch5_out1_s18=addSignal(topNet,'Switch5_out1',pirTyp4,slRate1);
        delayMatch_out1_s19=addSignal(topNet,'delayMatch_out1',pirTyp2,slRate1);
        delayMatch1_out1_s20=addSignal(topNet,'delayMatch1_out1',pirTyp1,slRate1);
        delayMatch2_out1_s21=addSignal(topNet,'delayMatch2_out1',pirTyp2,slRate1);
        delayMatch3_out1_s22=addSignal(topNet,'delayMatch3_out1',pirTyp1,slRate1);
        delayMatch4_out1_s23=addSignal(topNet,'delayMatch4_out1',pirTyp2,slRate1);
        delayMatch7_out1_s24=addSignal(topNet,'delayMatch7_out1',pirTyp2,slRate1);
        delayMatch8_out1_s25=addSignal(topNet,'delayMatch8_out1',pirTyp2,slRate1);
        mulNLUT0PlusImag_out1_s26=addSignal(topNet,'mulNLUT0PlusImag_out1',pirTyp4,slRate1);
        mulNLUT0PlusReal_out1_s27=addSignal(topNet,'mulNLUT0PlusReal_out1',pirTyp4,slRate1);
        MultiPortSwitch_out1_s29=addSignal(topNet,'MultiPortSwitch_out1',pirTyp5,slRate1);
        VectorConcat_out1_s30=addSignal(topNet,'VectorConcat_out1',pirelab.createPirArrayType(pirTyp5,[6,0]),slRate1);
        const0NLUt16_out1_s31=addSignal(topNet,'const0NLUt16_out1',pirTyp5,slRate1);
        const1NLUt16_out1_s32=addSignal(topNet,'const1NLUt16_out1',pirTyp5,slRate1);
        const2NLUt16_out1_s33=addSignal(topNet,'const2NLUt16_out1',pirTyp5,slRate1);
        const3NLUt16_out1_s34=addSignal(topNet,'const3NLUt16_out1',pirTyp5,slRate1);
        const4NLUt16_out1_s35=addSignal(topNet,'const4NLUt16_out1',pirTyp5,slRate1);
        const5NLUt16_out1_s36=addSignal(topNet,'const5NLUt16_out1',pirTyp5,slRate1);


        pirelab.getConstComp(topNet,...
        const0NLUt16_out1_s31,...
        fi(0,nt1,fiMath1,'hex','3859'),...
        'const0NLUt16','on',0,'','','');


        pirelab.getConstComp(topNet,...
        const1NLUt16_out1_s32,...
        fi(0,nt1,fiMath1,'hex','388d'),...
        'const1NLUt16','on',0,'','','');


        pirelab.getConstComp(topNet,...
        const2NLUt16_out1_s33,...
        fi(0,nt1,fiMath1,'hex','38a2'),...
        'const2NLUt16','on',0,'','','');


        pirelab.getConstComp(topNet,...
        const3NLUt16_out1_s34,...
        fi(0,nt1,fiMath1,'hex','38ad'),...
        'const3NLUt16','on',0,'','','');


        pirelab.getConstComp(topNet,...
        const4NLUt16_out1_s35,...
        fi(0,nt1,fiMath1,'hex','38c6'),...
        'const4NLUt16','on',0,'','','');


        pirelab.getConstComp(topNet,...
        const5NLUt16_out1_s36,...
        fi(0,nt1,fiMath1,'hex','38ce'),...
        'const5NLUt16','on',0,'','','');


        pirelab.getIntDelayComp(topNet,...
        LUTN16_0Plus_out1_s11,...
        HwModeRegister_out1_s7,...
        1,'HwModeRegister',...
        fi(0,nt1,fiMath1,'hex','0000'),...
        0,0,[],0,0);


        pirelab.getIntDelayComp(topNet,...
        ComplexToReal_Imag_out2_s6,...
        HwModeRegister1_out1_s8,...
        1,'HwModeRegister1',...
        fi(0,nt2,fiMath1,'hex','0000'),...
        0,0,[],0,0);


        pirelab.getIntDelayComp(topNet,...
        LUTN16_0Plus_out1_s11,...
        HwModeRegister2_out1_s9,...
        1,'HwModeRegister2',...
        fi(0,nt1,fiMath1,'hex','0000'),...
        0,0,[],0,0);


        pirelab.getIntDelayComp(topNet,...
        ComplexToReal_Imag_out1_s5,...
        HwModeRegister3_out1_s10,...
        1,'HwModeRegister3',...
        fi(0,nt2,fiMath1,'hex','0000'),...
        0,0,[],0,0);


        pirelab.getIntDelayComp(topNet,...
        mulNLUT0PlusImag_out1_s26,...
        PipelineRegister_out1_s14,...
        1,'PipelineRegister',...
        fi(0,nt3,fiMath1,'hex','00000000'),...
        0,0,[],0,0);


        pirelab.getIntDelayComp(topNet,...
        mulNLUT0PlusReal_out1_s27,...
        PipelineRegister1_out1_s15,...
        1,'PipelineRegister1',...
        fi(0,nt3,fiMath1,'hex','00000000'),...
        0,0,[],0,0);


        pirelab.getIntDelayComp(topNet,...
        unitAvgPowerFlagIn,...
        delayMatch_out1_s19,...
        2,'delayMatch',...
        false,...
        0,0,[],0,0);


        pirelab.getIntDelayComp(topNet,...
        ComplexToReal_Imag_out1_s5,...
        delayMatch1_out1_s20,...
        2,'delayMatch1',...
        fi(0,nt2,fiMath1,'hex','0000'),...
        0,0,[],0,0);


        pirelab.getIntDelayComp(topNet,...
        unitAvgPowerFlagIn,...
        delayMatch2_out1_s21,...
        2,'delayMatch2',...
        false,...
        0,0,[],0,0);


        pirelab.getIntDelayComp(topNet,...
        ComplexToReal_Imag_out2_s6,...
        delayMatch3_out1_s22,...
        2,'delayMatch3',...
        fi(0,nt2,fiMath1,'hex','0000'),...
        0,0,[],0,0);


        pirelab.getIntDelayComp(topNet,...
        apsk16ValidInDelay,...
        delayMatch4_out1_s23,...
        2,'delayMatch4',...
        false,...
        0,0,[],0,0);


        pirelab.getIntDelayComp(topNet,...
        LogicalOperator_out1_s12,...
        delayMatch7_out1_s24,...
        1,'delayMatch7',...
        false,...
        0,0,[],0,0);


        pirelab.getIntDelayComp(topNet,...
        LogicalOperator_out1_s12,...
        delayMatch8_out1_s25,...
        2,'delayMatch8',...
        false,...
        0,0,[],0,0);

        pirelab.getWireComp(topNet,...
        MultiPortSwitch_out1_s29,...
        LUTN16_0Plus_out1_s11,...
        'LUTN16_0Plus_out1');


        pirelab.getComplex2RealImag(topNet,...
        dataInDelayHD,...
        [ComplexToReal_Imag_out1_s5,ComplexToReal_Imag_out2_s6],...
        'Real and imag',...
        'Complex to Real-Imag');


        pirelab.getMultiPortSwitchComp(topNet,...
        [codeRateIndxSigDelay1,VectorConcat_out1_s30],...
        MultiPortSwitch_out1_s29,...
        0,'Zero-based contiguous','Floor','Wrap','MultiPortSwitch',[]);


        pirelab.getMuxComp(topNet,...
        [const0NLUt16_out1_s31,const1NLUt16_out1_s32,const2NLUt16_out1_s33,const3NLUt16_out1_s34,const4NLUt16_out1_s35,const5NLUt16_out1_s36],...
        VectorConcat_out1_s30,...
        'concatenate');


        pirelab.getLogicComp(topNet,...
        resetIn,...
        LogicalOperator_out1_s12,...
        'not',sprintf('Logical\nOperator'));


        pirelab.getLogicComp(topNet,...
        [delayMatch4_out1_s23,delayMatch7_out1_s24,delayMatch8_out1_s25],...
        LogicalOperator1_out1_s13,...
        'and',sprintf('Logical\nOperator1'));


        pirelab.getRealImag2Complex(topNet,...
        [Switch_out1_s17,Switch5_out1_s18],...
        Real_ImagToComplex_out1_s16,...
        'Real and imag',...
        0,...
        'Real-Imag to Complex');


        pirelab.getSwitchComp(topNet,...
        [PipelineRegister1_out1_s15,delayMatch1_out1_s20],...
        Switch_out1_s17,...
        delayMatch_out1_s19,'Switch',...
        '>',0,'Floor','Wrap');


        pirelab.getSwitchComp(topNet,...
        [PipelineRegister_out1_s14,delayMatch3_out1_s22],...
        Switch5_out1_s18,...
        delayMatch2_out1_s21,'Switch5',...
        '>',0,'Floor','Wrap');


        pirelab.getMulComp(topNet,...
        [HwModeRegister_out1_s7,HwModeRegister1_out1_s8],...
        mulNLUT0PlusImag_out1_s26,...
        'Floor','Wrap','mulNLUT0PlusImag','**','',-1,0);


        pirelab.getMulComp(topNet,...
        [HwModeRegister2_out1_s9,HwModeRegister3_out1_s10],...
        mulNLUT0PlusReal_out1_s27,...
        'Floor','Wrap','mulNLUT0PlusReal','**','',-1,0);


        apsk16MagOut=newDataSignal(topNet,pir_sfixpt_t(UAPWLDelay+1,UAPFLDelay),'apsk16MagOut',rate);
        apsk16AngleOut=newDataSignal(topNet,pir_sfixpt_t(UAPWLDelay+3,-inWLBefAng-LutNAPSKFL),'apsk16AngleOut',rate);
        apsk16MagAngleValidOut=newControlSignal(topNet,'apsk16AngleValidOut',rate);

        apsk16ComplxToMagAngleNet=this.elabComplxToMagAngleNet(topNet,blockInfo,rate,UAPWLDelay,UAPFLDelay);
        apsk16ComplxToMagAngleNet.addComment('complex to mag and angle 16-APSK');

        inports_apsk16complxToMagAng(1)=Real_ImagToComplex_out1_s16;
        inports_apsk16complxToMagAng(2)=LogicalOperator1_out1_s13;

        outports_apsk16complxToMagAng(1)=apsk16MagOut;
        outports_apsk16complxToMagAng(2)=apsk16AngleOut;
        outports_apsk16complxToMagAng(3)=apsk16MagAngleValidOut;

        pirelab.instantiateNetwork(topNet,apsk16ComplxToMagAngleNet,inports_apsk16complxToMagAng,outports_apsk16complxToMagAng,'ComplxToMagAngapsk16Net_inst');

        if(strcmpi(blockInfo.OutputType,'Vector'))
            symbapsk16HDDemodNet=this.elabAPSK16HDSymDemodNet(topNet,blockInfo,rate,UAPWLDelay,UAPFLDelay);
            symbapsk16HDDemodNet.addComment('16-APSK HD Demodulation');

            inports_apsk16HD(1)=apsk16MagOut;
            inports_apsk16HD(2)=apsk16AngleOut;
            inports_apsk16HD(3)=apsk16MagAngleValidOut;
            inports_apsk16HD(4)=codeRateIndxSigDelayMagAng;
            inports_apsk16HD(5)=resetIn;
            inports_apsk16HD(6)=endInDelay2ComplxToMagAng;

            outports_apsk16HD(1)=apsk16DataOut;
            outports_apsk16HD(2)=apsk16ValidOut;
            outports_apsk16HD(3)=apsk16NonMul8FlagOut;

            pirelab.instantiateNetwork(topNet,symbapsk16HDDemodNet,inports_apsk16HD,outports_apsk16HD,'symbapsk16HDDemodNet_inst');
            pirelab.getIntDelayComp(topNet,apsk16NonMul8FlagOut,apsk16NonMul8FlagOutDelay,0,'delay_apsk16HDNonMul8FlagOutDelay');
        else
            symbScAPSK16HDDemodNet=this.elabScAPSK16HDSymDemodNet(topNet,blockInfo,rate,UAPWLDelay,UAPFLDelay);
            symbScAPSK16HDDemodNet.addComment('16-APSK Scalar HD Demodulation');

            inports_ScAPSK16HD(1)=apsk16MagOut;
            inports_ScAPSK16HD(2)=apsk16AngleOut;
            inports_ScAPSK16HD(3)=apsk16MagAngleValidOut;
            inports_ScAPSK16HD(4)=codeRateIndxSigDelayMagAng;

            outports_ScAPSK16HD(1)=apsk16DataOut;
            outports_ScAPSK16HD(2)=apsk16ValidOut;

            pirelab.instantiateNetwork(topNet,symbScAPSK16HDDemodNet,inports_ScAPSK16HD,outports_ScAPSK16HD,'symbScAPSK16HDDemodNet_inst');
        end
        pirelab.getIntDelayComp(topNet,apsk16DataOut,apsk16DataOutDelay,0,'delay_16apskHDDataOut');
        pirelab.getIntDelayComp(topNet,apsk16ValidOut,apsk16ValidOutDelay,0,'delay_16apskHDValidOut');




        pirTyp2A32=pir_boolean_t;
        pirTyp1A32=pir_sfixpt_t(inWLBefAng,inFLBefAng);
        pirTyp4A32=pir_sfixpt_t(inWLBefAng+LutNAPSKWL,inFLBefAng-LutNAPSKFL);
        pirTyp5A32=pir_ufixpt_t(LutNAPSKWL,-LutNAPSKFL);

        fiMath1A32=fimath('RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision','SumMode','FullPrecision');

        nt2A32=numerictype(0,LutNAPSKWL,LutNAPSKFL);
        nt1A32=numerictype(1,inWLBefAng,-inFLBefAng);
        nt3A32=numerictype(1,inWLBefAng+LutNAPSKWL,-(inFLBefAng-LutNAPSKFL));

        RealImag2Comp32A_out1_s16=addSignal(topNet,'RealImag2Comp32A_out1',pir_complex_t(pirTyp4A32),slRate1);
        ANDGate32A_out1_s5=addSignal(topNet,'ANDGate32A_out1',pirTyp2A32,slRate1);

        Comp2RealImag32A_out1_s6=addSignal(topNet,'Comp2RealImag32A_out1',pirTyp1A32,slRate1);
        Comp2RealImag32A_out2_s7=addSignal(topNet,'Comp2RealImag32A_out2',pirTyp1A32,slRate1);
        HwMode32ARegister1_out1_s8=addSignal(topNet,'HwMode32ARegister1_out1',pirTyp1A32,slRate1);
        HwMode32ARegister2_out1_s9=addSignal(topNet,'HwMode32ARegister2_out1',pirTyp5A32,slRate1);
        HwMode32Register_out1_s10=addSignal(topNet,'HwMode32Register_out1',pirTyp5A32,slRate1);
        HwMode32Register3_out1_s11=addSignal(topNet,'HwMode32Register3_out1',pirTyp1A32,slRate1);
        MultiPortSwitch32A_out1_s12=addSignal(topNet,'MultiPortSwitch32A_out1',pirTyp5A32,slRate1);
        NOT32A_out1_s13=addSignal(topNet,'NOT32A_out1',pirTyp2A32,slRate1);
        Pipeline32ARegister_out1_s14=addSignal(topNet,'Pipeline32ARegister_out1',pirTyp4A32,slRate1);
        Pipeline32ARegister1_out1_s15=addSignal(topNet,'Pipeline32ARegister1_out1',pirTyp4A32,slRate1);
        Switch5_32A_out1_s17=addSignal(topNet,'Switch5_32A_out1',pirTyp4A32,slRate1);
        Switch_32A_out1_s18=addSignal(topNet,'Switch_32A_out1',pirTyp4A32,slRate1);
        VectorConcat32A_out1_s19=addSignal(topNet,'VectorConcat32A_out1',pirelab.createPirArrayType(pirTyp5A32,[5,0]),slRate1);
        const0NLUt32_out1_s20=addSignal(topNet,'const0NLUt32_out1',pirTyp5A32,slRate1);
        const1NLUt32_out1_s21=addSignal(topNet,'const1NLUt32_out1',pirTyp5A32,slRate1);
        const2NLUt32_out1_s22=addSignal(topNet,'const2NLUt32_out1',pirTyp5A32,slRate1);
        const3NLUt32_out1_s23=addSignal(topNet,'const3NLUt32_out1',pirTyp5A32,slRate1);
        const4NLUt32_out1_s24=addSignal(topNet,'const4NLUt32_out1',pirTyp5A32,slRate1);
        delay32AMatch_out1_s25=addSignal(topNet,'delay32AMatch_out1',pirTyp2A32,slRate1);
        delay32AMatch2_out1_s26=addSignal(topNet,'delay32AMatch2_out1',pirTyp2A32,slRate1);
        delay32AMatch3_out1_s27=addSignal(topNet,'delay32AMatch3_out1',pirTyp1A32,slRate1);
        delay32AMatch4_out1_s28=addSignal(topNet,'delay32AMatch4_out1',pirTyp2A32,slRate1);
        delay32AMatch5_out1_s29=addSignal(topNet,'delay32AMatch5_out1',pirTyp1A32,slRate1);
        delay32AMatch7_out1_s30=addSignal(topNet,'delay32AMatch7_out1',pirTyp2A32,slRate1);
        delay32AMatch8_out1_s31=addSignal(topNet,'delay32AMatch8_out1',pirTyp2A32,slRate1);
        mul32NLUT0PlusImag_out1_s32=addSignal(topNet,'mul32NLUT0PlusImag_out1',pirTyp4A32,slRate1);
        mul32NLUT0PlusReal_out1_s33=addSignal(topNet,'mul32NLUT0PlusReal_out1',pirTyp4A32,slRate1);


        pirelab.getIntDelayComp(topNet,...
        Comp2RealImag32A_out2_s7,...
        HwMode32ARegister1_out1_s8,...
        1,'HwMode32ARegister1',...
        fi(0,nt1A32,fiMath1A32,'hex','0000'),...
        0,0,[],0,0);


        pirelab.getIntDelayComp(topNet,...
        MultiPortSwitch32A_out1_s12,...
        HwMode32ARegister2_out1_s9,...
        1,'HwMode32ARegister2',...
        fi(0,nt2A32,fiMath1A32,'hex','0000'),...
        0,0,[],0,0);


        pirelab.getIntDelayComp(topNet,...
        MultiPortSwitch32A_out1_s12,...
        HwMode32Register_out1_s10,...
        1,'HwMode32Register',...
        fi(0,nt2A32,fiMath1A32,'hex','0000'),...
        0,0,[],0,0);


        pirelab.getIntDelayComp(topNet,...
        Comp2RealImag32A_out1_s6,...
        HwMode32Register3_out1_s11,...
        1,'HwMode32Register3',...
        fi(0,nt1A32,fiMath1A32,'hex','0000'),...
        0,0,[],0,0);


        pirelab.getIntDelayComp(topNet,...
        mul32NLUT0PlusImag_out1_s32,...
        Pipeline32ARegister_out1_s14,...
        1,'Pipeline32ARegister',...
        fi(0,nt3A32,fiMath1A32,'hex','00000000'),...
        0,0,[],0,0);


        pirelab.getIntDelayComp(topNet,...
        mul32NLUT0PlusReal_out1_s33,...
        Pipeline32ARegister1_out1_s15,...
        1,'Pipeline32ARegister1',...
        fi(0,nt3A32,fiMath1A32,'hex','00000000'),...
        0,0,[],0,0);


        pirelab.getConstComp(topNet,...
        const0NLUt32_out1_s20,...
        fi(0,nt2A32,fiMath1A32,'hex','321f'),...
        'const0NLUt32','on',0,'','','');


        pirelab.getConstComp(topNet,...
        const1NLUt32_out1_s21,...
        fi(0,nt2A32,fiMath1A32,'hex','327c'),...
        'const1NLUt32','on',0,'','','');


        pirelab.getConstComp(topNet,...
        const2NLUt32_out1_s22,...
        fi(0,nt2A32,fiMath1A32,'hex','32af'),...
        'const2NLUt32','on',0,'','','');


        pirelab.getConstComp(topNet,...
        const3NLUt32_out1_s23,...
        fi(0,nt2A32,fiMath1A32,'hex','3307'),...
        'const3NLUt32','on',0,'','','');


        pirelab.getConstComp(topNet,...
        const4NLUt32_out1_s24,...
        fi(0,nt2A32,fiMath1A32,'hex','3310'),...
        'const4NLUt32','on',0,'','','');


        pirelab.getIntDelayComp(topNet,...
        unitAvgPowerFlagIn,...
        delay32AMatch_out1_s25,...
        2,'delay32AMatch',...
        false,...
        0,0,[],0,0);


        pirelab.getIntDelayComp(topNet,...
        unitAvgPowerFlagIn,...
        delay32AMatch2_out1_s26,...
        2,'delay32AMatch2',...
        false,...
        0,0,[],0,0);


        pirelab.getIntDelayComp(topNet,...
        Comp2RealImag32A_out2_s7,...
        delay32AMatch3_out1_s27,...
        2,'delay32AMatch3',...
        fi(0,nt1A32,fiMath1A32,'hex','0000'),...
        0,0,[],0,0);


        pirelab.getIntDelayComp(topNet,...
        apsk32ValidInDelay,...
        delay32AMatch4_out1_s28,...
        2,'delay32AMatch4',...
        false,...
        0,0,[],0,0);


        pirelab.getIntDelayComp(topNet,...
        Comp2RealImag32A_out1_s6,...
        delay32AMatch5_out1_s29,...
        2,'delay32AMatch5',...
        fi(0,nt1A32,fiMath1A32,'hex','0000'),...
        0,0,[],0,0);


        pirelab.getIntDelayComp(topNet,...
        NOT32A_out1_s13,...
        delay32AMatch7_out1_s30,...
        1,'delay32AMatch7',...
        false,...
        0,0,[],0,0);


        pirelab.getIntDelayComp(topNet,...
        NOT32A_out1_s13,...
        delay32AMatch8_out1_s31,...
        2,'delay32AMatch8',...
        false,...
        0,0,[],0,0);


        pirelab.getLogicComp(topNet,...
        [delay32AMatch4_out1_s28,delay32AMatch8_out1_s31,delay32AMatch7_out1_s30],...
        ANDGate32A_out1_s5,...
        'and','ANDGate32A');


        pirelab.getComplex2RealImag(topNet,...
        dataInDelayHD,...
        [Comp2RealImag32A_out1_s6,Comp2RealImag32A_out2_s7],...
        'Real and imag',...
        'Comp2RealImag32A');


        pirelab.getMultiPortSwitchComp(topNet,...
        [codeRateIndxSigDelay1,VectorConcat32A_out1_s19],...
        MultiPortSwitch32A_out1_s12,...
        0,'Zero-based contiguous','Floor','Wrap','MultiPortSwitch32A',[]);


        pirelab.getLogicComp(topNet,...
        resetIn,...
        NOT32A_out1_s13,...
        'not','NOT32A');


        pirelab.getRealImag2Complex(topNet,...
        [Switch_32A_out1_s18,Switch5_32A_out1_s17],...
        RealImag2Comp32A_out1_s16,...
        'Real and imag',...
        0,...
        'RealImag2Comp32A');


        pirelab.getSwitchComp(topNet,...
        [Pipeline32ARegister_out1_s14,delay32AMatch3_out1_s27],...
        Switch5_32A_out1_s17,...
        delay32AMatch2_out1_s26,'Switch5_32A',...
        '>',0,'Floor','Wrap');


        pirelab.getSwitchComp(topNet,...
        [Pipeline32ARegister1_out1_s15,delay32AMatch5_out1_s29],...
        Switch_32A_out1_s18,...
        delay32AMatch_out1_s25,'Switch_32A',...
        '>',0,'Floor','Wrap');


        pirelab.getMuxComp(topNet,...
        [const0NLUt32_out1_s20,const1NLUt32_out1_s21,const2NLUt32_out1_s22,const3NLUt32_out1_s23,const4NLUt32_out1_s24],...
        VectorConcat32A_out1_s19,...
        'concatenate');


        pirelab.getMulComp(topNet,...
        [HwMode32Register_out1_s10,HwMode32ARegister1_out1_s8],...
        mul32NLUT0PlusImag_out1_s32,...
        'Floor','Wrap','mul32NLUT0PlusImag','**','',-1,0);


        pirelab.getMulComp(topNet,...
        [HwMode32ARegister2_out1_s9,HwMode32Register3_out1_s11],...
        mul32NLUT0PlusReal_out1_s33,...
        'Floor','Wrap','mul32NLUT0PlusReal','**','',-1,0);




        apsk32MagOut=newDataSignal(topNet,pir_sfixpt_t(UAPWLDelay+1,UAPFLDelay),'apsk32MagOut',rate);
        apsk32AngleOut=newDataSignal(topNet,pir_sfixpt_t(UAPWLDelay+3,-inWLBefAng-LutNAPSKFL),'apsk32AngleOut',rate);
        apsk32MagAngleValidOut=newControlSignal(topNet,'apsk32AngleValidOut',rate);

        apsk32ComplxToMagAngleNet=this.elabComplxToMagAngleNet(topNet,blockInfo,rate,UAPWLDelay,UAPFLDelay);
        apsk32ComplxToMagAngleNet.addComment('complex to mag and angle 32-APSK');

        inports_apsk32complxToMagAng(1)=RealImag2Comp32A_out1_s16;
        inports_apsk32complxToMagAng(2)=ANDGate32A_out1_s5;

        outports_apsk32complxToMagAng(1)=apsk32MagOut;
        outports_apsk32complxToMagAng(2)=apsk32AngleOut;
        outports_apsk32complxToMagAng(3)=apsk32MagAngleValidOut;

        pirelab.instantiateNetwork(topNet,apsk32ComplxToMagAngleNet,inports_apsk32complxToMagAng,outports_apsk32complxToMagAng,'ComplxToMagAngapsk32Net_inst');

        if(strcmpi(blockInfo.OutputType,'Vector'))
            symbapsk32HDDemodNet=this.elabAPSK32HDSymDemodNet(topNet,blockInfo,rate,UAPWLDelay,UAPFLDelay);
            symbapsk32HDDemodNet.addComment('32-APSK HD Demodulation');

            inports_apsk32HD(1)=apsk32MagOut;
            inports_apsk32HD(2)=apsk32AngleOut;
            inports_apsk32HD(3)=apsk32MagAngleValidOut;
            inports_apsk32HD(4)=codeRateIndxSigDelayMagAng;
            inports_apsk32HD(5)=resetIn;
            inports_apsk32HD(6)=endInDelay2ComplxToMagAng;

            outports_apsk32HD(1)=apsk32DataOut;
            outports_apsk32HD(2)=apsk32ValidOut;
            outports_apsk32HD(3)=apsk32NonMul8FlagOut;

            pirelab.instantiateNetwork(topNet,symbapsk32HDDemodNet,inports_apsk32HD,outports_apsk32HD,'symbapsk32HDDemodNet_inst');
        else
            symbapsk32ScHDDemodNet=this.elabScAPSK32HDSymDemodNet(topNet,blockInfo,rate,UAPWLDelay,UAPFLDelay);
            symbapsk32ScHDDemodNet.addComment('32-APSK Scalar HD Demodulation');

            inports_apsk32HDSc(1)=apsk32MagOut;
            inports_apsk32HDSc(2)=apsk32AngleOut;
            inports_apsk32HDSc(3)=apsk32MagAngleValidOut;
            inports_apsk32HDSc(4)=codeRateIndxSigDelayMagAng;

            outports_apsk32HDSc(1)=apsk32DataOut;
            outports_apsk32HDSc(2)=apsk32ValidOut;

            pirelab.instantiateNetwork(topNet,symbapsk32ScHDDemodNet,inports_apsk32HDSc,outports_apsk32HDSc,'symbapsk32ScHDDemodNet_inst');
        end
    end




    dataMulOut=newDataSignal(topNet,vecDT,'dataMulOut',rate);
    validMulOut=newControlSignal(topNet,'validMulOut',rate);
    validOutDelay=newControlSignal(topNet,'validOutDelay',rate);
    modIndxSigDelay1=newDataSignal(topNet,pir_ufixpt_t(3,0),'modIndxSigDelay1',rate);

    if(strcmpi(blockInfo.OutputType,'Vector'))
        NonMul8FlagOutDelay=newControlSignal(topNet,'NonMul8FlagOutDelay',rate);
        if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
            pirelab.getIntDelayComp(topNet,modIndxSigDelay,modIndxSigDelay1,19,'delay_modIndxSigDelay');
        else
            pirelab.getIntDelayComp(topNet,modIndxSigDelay,modIndxSigDelay1,inWL+41,'delay_modIndxSigDelayHD');
        end
    else
        if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
            pirelab.getIntDelayComp(topNet,modIndxSigDelay,modIndxSigDelay1,16,'delay_modIndxSigDelaySc');
        else
            pirelab.getIntDelayComp(topNet,modIndxSigDelay,modIndxSigDelay1,inWL+38,'delay_modIndxSigDelayScHD');
        end
    end

    pirelab.getMultiPortSwitchComp(topNet,[modIndxSigDelay1,bpskDataOutDelay,qpskDataOutDelay,psk8DataOutDelay,apsk16DataOutDelay,apsk32DataOut],dataOutDelay,...
    1,2,'floor','Wrap','dataOutMux');
    pirelab.getMultiPortSwitchComp(topNet,[modIndxSigDelay1,bpskValidOutDelay,qpskValidOutDelay,psk8ValidOutDelay,apsk16ValidOutDelay,apsk32ValidOut],validOutDelay,...
    1,2,'floor','Wrap','validOutMux');


    if(strcmpi(blockInfo.OutputType,'Vector'))
        dataOutBefSwitch=newDataSignal(topNet,vecDT,'dataOutBefSwitch',rate);
        dataZeroVec=newDataSignal(topNet,vecDT,'dataZeroVec',rate);
        pirelab.getConstComp(topNet,dataZeroVec,zeros(8,1),'constZeroVec');
        validOutWire=newControlSignal(topNet,'validOutWire',rate);

        if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')&&blockInfo.EnbNoiseVar

            validOutDivBefRst=newControlSignal(topNet,'validOutDivBefRst',rate);

            pirelab.getMultiPortSwitchComp(topNet,[modIndxSigDelay1,bpskNonMul8FlagOutDelay,qpskNonMul8FlagOutDelay,psk8NonMul8FlagOutDelay,apsk16NonMul8FlagOutDelay,apsk32NonMul8FlagOut],NonMul8FlagOutDelay,...
            1,2,'floor','Wrap','nonMul8FlagOutMux');
            pirelab.getMultiPortSwitchComp(topNet,[modIndxSigDelay1,nVarVecBPSKDelay,nVarVecQPSKDelay,nVarVec8PSKDelay,nVarVec16APSKDelay,nVarVec32APSKDelay],nVarVecOut,...
            1,2,'floor','Wrap','nVarVecOutMux');

            divideInfo.numeratorTypeInfo.zType=numeratorOne.Type;
            divideInfo.OutType='Inherit: Inherit via internal rule';
            divideInfo.ovMode='Saturate';
            divideInfo.rndMode='Zero';
            divideInfo.inputSigns='*/';
            divideInfo.firstInputSignDivide=false;
            divideInfo.networkName='Divide';
            divideInfo.pipeline='on';
            divideInfo.customLatency=0;
            divideInfo.latencyStrategy='MAX';
            divideInfo.numeratorTypeInfo.zWL=32;
            divideInfo.numeratorTypeInfo.zSign=false;
            divideInfo.denominatorTypeInfo.dWL=inNVarWL;
            divideInfo.denominatorTypeInfo.dSign=false;
            divideInfo.quotientTypeInfo.QWL=32;
            divideInfo.quotientTypeInfo.QFL=-(31+inNVarFL);
            divideInfo.fractiondiff=0;
            divideInfo.maxWl=32;

            nVarVecDemuxOut=[];
            for vecElemCount=1:8
                noiseVarVec(vecElemCount)=newDataSignal(topNet,pir_ufixpt_t(inNVarWL,inNVarFL),['noiseVecElem',num2str(vecElemCount)],rate);%#ok<*AGROW>
                divideOut(vecElemCount)=newDataSignal(topNet,pir_ufixpt_t(32,-(31+inNVarFL)),['divideElem',num2str(vecElemCount)],rate);%#ok<*AGROW>
                divideInfo.denominatorTypeInfo.dType=noiseVarVec(vecElemCount).Type;
                divideInfo.quotientTypeInfo.QType=divideOut(vecElemCount).Type;
                nVarVecDemuxOut=[nVarVecDemuxOut,noiseVarVec(vecElemCount)];
            end

            pirelab.getDemuxComp(topNet,nVarVecOut,nVarVecDemuxOut,'demuxNVarVec');

            for vecElemCount=1:8
                divideInfo.denominatorTypeInfo.dType=noiseVarVec(vecElemCount).Type;
                divideInfo.quotientTypeInfo.QType=divideOut(vecElemCount).Type;
                pirelab.getNonRestoreDivideComp(topNet,[numeratorOne;nVarVecDemuxOut(vecElemCount)],divideOut(vecElemCount),divideInfo);
            end

            nonRestoreDivideCompLatency=calNonRestoreDivideCompLatency(numeratorOne,nVarVecDemuxOut(1),divideOut(1));

            divideOutMuxed=newDataSignal(topNet,pirelab.createPirArrayType(pir_ufixpt_t(32,-(31+inNVarFL)),[8,0]),'divideOutMuxed',rate);
            pirelab.getMuxComp(topNet,divideOut,divideOutMuxed,'muxDivideOut');

            nonMulti8FlagOut=newControlSignal(topNet,'nonMulti8FlagOut',rate);


            pirelab.getIntDelayComp(topNet,dataOutDelay,dataOutDivDelay,nonRestoreDivideCompLatency,'delay_dataOutDivDelayNVarVec');
            pirelab.getIntDelayComp(topNet,validOutDelay,validOutDivBefRst,nonRestoreDivideCompLatency,'delay_validOutDivDelayNVarVec');

            validRstNVarNet=this.elabValidWithRstNet(topNet,blockInfo,rate);
            validRstNVarNet.addComment('NVar Div valid along With reset');
            nVarVecLLRDelay=newDataSignal(topNet,pir_ufixpt_t(6,0),'bpskVecLLRDelay',rate);
            pirelab.getConstComp(topNet,nVarVecLLRDelay,nonRestoreDivideCompLatency,'constDivNVarVecLLRDelay');

            inports_valRstNVar(1)=validOutDivBefRst;
            inports_valRstNVar(2)=resetIn;
            inports_valRstNVar(3)=nVarVecLLRDelay;

            outports_valRstNVar(1)=validOutDivDelay;

            pirelab.instantiateNetwork(topNet,validRstNVarNet,inports_valRstNVar,outports_valRstNVar,'ValRstNVarVecLLR_inst');

            pirelab.getIntDelayComp(topNet,NonMul8FlagOutDelay,NonMul8FlagOutDivDelay,nonRestoreDivideCompLatency,'delay_NonMul8FlagOutDivNVarVec');


            pirelab.getIntDelayComp(topNet,NonMul8FlagOutDivDelay,nonMulti8FlagOut,3,'delay_NonMul8FlagOutMUL');



            pirTyp2=pir_boolean_t;
            pirTyp1=pir_sfixpt_t(inWL+3,inFL);
            pirTyp4=pir_sfixpt_t(inWL+14,inFL);
            pirTyp5=pir_sfixpt_t(inWL+3+32,-(31+inNVarFL)+inFL);
            pirTyp3=pir_ufixpt_t(32,-(31+inNVarFL));

            fiMath1=fimath('RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision','SumMode','FullPrecision');

            nt2=numerictype(0,32,(31+inNVarFL));
            nt1=numerictype(1,inWL+3,-inFL);
            nt3=numerictype(1,inWL+14,-inFL);
            nt4=numerictype(1,inWL+3+32,(31+inNVarFL)-inFL);

            slRate1=rate;

            SwitchLLRVecNVar_out1_s57=addSignal(topNet,'SwitchLLRVecNVar_out1',pirelab.createPirArrayType(pirTyp4,[8,0]),slRate1);
            LogicalAND1VecNVar_out1_s38=addSignal(topNet,sprintf('Logical\nAND1VecNVar_out1'),pirTyp2,slRate1);

            DTCVecNVar_out1_s4=addSignal(topNet,'DTCVecNVar_out1',pirelab.createPirArrayType(pirTyp4,[8,0]),slRate1);
            Demux_out1_s5=addSignal(topNet,'Demux_out1',pirTyp3,slRate1);
            Demux_out2_s6=addSignal(topNet,'Demux_out2',pirTyp3,slRate1);
            Demux_out3_s7=addSignal(topNet,'Demux_out3',pirTyp3,slRate1);
            Demux_out4_s8=addSignal(topNet,'Demux_out4',pirTyp3,slRate1);
            Demux_out5_s9=addSignal(topNet,'Demux_out5',pirTyp3,slRate1);
            Demux_out6_s10=addSignal(topNet,'Demux_out6',pirTyp3,slRate1);
            Demux_out7_s11=addSignal(topNet,'Demux_out7',pirTyp3,slRate1);
            Demux_out8_s12=addSignal(topNet,'Demux_out8',pirTyp3,slRate1);
            Demux1_out1_s13=addSignal(topNet,'Demux1_out1',pirTyp1,slRate1);
            Demux1_out2_s14=addSignal(topNet,'Demux1_out2',pirTyp1,slRate1);
            Demux1_out3_s15=addSignal(topNet,'Demux1_out3',pirTyp1,slRate1);
            Demux1_out4_s16=addSignal(topNet,'Demux1_out4',pirTyp1,slRate1);
            Demux1_out5_s17=addSignal(topNet,'Demux1_out5',pirTyp1,slRate1);
            Demux1_out6_s18=addSignal(topNet,'Demux1_out6',pirTyp1,slRate1);
            Demux1_out7_s19=addSignal(topNet,'Demux1_out7',pirTyp1,slRate1);
            Demux1_out8_s20=addSignal(topNet,'Demux1_out8',pirTyp1,slRate1);
            HwModeRegister1VecNVar_out1_s21=addSignal(topNet,'HwModeRegister1VecNVar_out1',pirTyp1,slRate1);
            HwModeRegister1VecNVar1_out1_s22=addSignal(topNet,'HwModeRegister1VecNVar1_out1',pirTyp1,slRate1);
            HwModeRegister1VecNVar2_out1_s23=addSignal(topNet,'HwModeRegister1VecNVar2_out1',pirTyp1,slRate1);
            HwModeRegister1VecNVar3_out1_s24=addSignal(topNet,'HwModeRegister1VecNVar3_out1',pirTyp1,slRate1);
            HwModeRegister1VecNVar4_out1_s25=addSignal(topNet,'HwModeRegister1VecNVar4_out1',pirTyp1,slRate1);
            HwModeRegister1VecNVar5_out1_s26=addSignal(topNet,'HwModeRegister1VecNVar5_out1',pirTyp1,slRate1);
            HwModeRegister1VecNVar6_out1_s27=addSignal(topNet,'HwModeRegister1VecNVar6_out1',pirTyp1,slRate1);
            HwModeRegister1VecNVar7_out1_s28=addSignal(topNet,'HwModeRegister1VecNVar7_out1',pirTyp1,slRate1);
            HwModeRegisterVecNVar_out1_s29=addSignal(topNet,'HwModeRegisterVecNVar_out1',pirTyp3,slRate1);
            HwModeRegisterVecNVar1_out1_s30=addSignal(topNet,'HwModeRegisterVecNVar1_out1',pirTyp3,slRate1);
            HwModeRegisterVecNVar2_out1_s31=addSignal(topNet,'HwModeRegisterVecNVar2_out1',pirTyp3,slRate1);
            HwModeRegisterVecNVar3_out1_s32=addSignal(topNet,'HwModeRegisterVecNVar3_out1',pirTyp3,slRate1);
            HwModeRegisterVecNVar4_out1_s33=addSignal(topNet,'HwModeRegisterVecNVar4_out1',pirTyp3,slRate1);
            HwModeRegisterVecNVar5_out1_s34=addSignal(topNet,'HwModeRegisterVecNVar5_out1',pirTyp3,slRate1);
            HwModeRegisterVecNVar6_out1_s35=addSignal(topNet,'HwModeRegisterVecNVar6_out1',pirTyp3,slRate1);
            HwModeRegisterVecNVar7_out1_s36=addSignal(topNet,'HwModeRegisterVecNVar7_out1',pirTyp3,slRate1);
            LLRWithNVarConstVecNVar_out1_s37=addSignal(topNet,'LLRWithNVarConstVecNVar_out1',pirTyp4,slRate1);
            LogicalOperatorVecNVar_out1_s39=addSignal(topNet,sprintf('Logical\nOperatorVecNVar_out1'),pirTyp2,slRate1);
            Mux_out1_s40=addSignal(topNet,'Mux_out1',pirelab.createPirArrayType(pirTyp5,[8,0]),slRate1);
            PipelineRegisterVecNVar_out1_s41=addSignal(topNet,'PipelineRegisterVecNVar_out1',pirTyp5,slRate1);
            PipelineRegisterVecNVar1_out1_s42=addSignal(topNet,'PipelineRegisterVecNVar1_out1',pirTyp5,slRate1);
            PipelineRegisterVecNVar2_out1_s43=addSignal(topNet,'PipelineRegisterVecNVar2_out1',pirTyp5,slRate1);
            PipelineRegisterVecNVar3_out1_s44=addSignal(topNet,'PipelineRegisterVecNVar3_out1',pirTyp5,slRate1);
            PipelineRegisterVecNVar4_out1_s45=addSignal(topNet,'PipelineRegisterVecNVar4_out1',pirTyp5,slRate1);
            PipelineRegisterVecNVar5_out1_s46=addSignal(topNet,'PipelineRegisterVecNVar5_out1',pirTyp5,slRate1);
            PipelineRegisterVecNVar6_out1_s47=addSignal(topNet,'PipelineRegisterVecNVar6_out1',pirTyp5,slRate1);
            PipelineRegisterVecNVar7_out1_s48=addSignal(topNet,'PipelineRegisterVecNVar7_out1',pirTyp5,slRate1);
            ProductVecNVar_out1_s49=addSignal(topNet,'ProductVecNVar_out1',pirTyp5,slRate1);
            ProductVecNVar1_out1_s50=addSignal(topNet,'ProductVecNVar1_out1',pirTyp5,slRate1);
            ProductVecNVar2_out1_s51=addSignal(topNet,'ProductVecNVar2_out1',pirTyp5,slRate1);
            ProductVecNVar3_out1_s52=addSignal(topNet,'ProductVecNVar3_out1',pirTyp5,slRate1);
            ProductVecNVar4_out1_s53=addSignal(topNet,'ProductVecNVar4_out1',pirTyp5,slRate1);
            ProductVecNVar5_out1_s54=addSignal(topNet,'ProductVecNVar5_out1',pirTyp5,slRate1);
            ProductVecNVar6_out1_s55=addSignal(topNet,'ProductVecNVar6_out1',pirTyp5,slRate1);
            ProductVecNVar7_out1_s56=addSignal(topNet,'ProductVecNVar7_out1',pirTyp5,slRate1);
            delayMatch1VecNVar_out1_s58=addSignal(topNet,'delayMatch1VecNVar_out1',pirTyp2,slRate1);
            delayMatch3VecNVar_out1_s59=addSignal(topNet,'delayMatch3VecNVar_out1',pirTyp2,slRate1);
            delayMatch4VecNVar_out1_s60=addSignal(topNet,'delayMatch4VecNVar_out1',pirTyp2,slRate1);
            delayMatch5VecNVar_out1_s61=addSignal(topNet,'delayMatch5VecNVar_out1',pirTyp2,slRate1);
            delayMatchVecNVar_out1_s62=addSignal(topNet,'delayMatchVecNVar_out1',pirTyp2,slRate1);
            oneByNvarIn_0_s63=addSignal(topNet,'oneByNvarIn_0',pirTyp3,slRate1);
            oneByNvarIn_1_s64=addSignal(topNet,'oneByNvarIn_1',pirTyp3,slRate1);
            oneByNvarIn_2_s65=addSignal(topNet,'oneByNvarIn_2',pirTyp3,slRate1);
            oneByNvarIn_3_s66=addSignal(topNet,'oneByNvarIn_3',pirTyp3,slRate1);
            oneByNvarIn_4_s67=addSignal(topNet,'oneByNvarIn_4',pirTyp3,slRate1);
            oneByNvarIn_5_s68=addSignal(topNet,'oneByNvarIn_5',pirTyp3,slRate1);
            oneByNvarIn_6_s69=addSignal(topNet,'oneByNvarIn_6',pirTyp3,slRate1);
            oneByNvarIn_7_s70=addSignal(topNet,'oneByNvarIn_7',pirTyp3,slRate1);
            dataLLROut_0_s71=addSignal(topNet,'dataLLROut_0',pirTyp1,slRate1);
            dataLLROut_1_s72=addSignal(topNet,'dataLLROut_1',pirTyp1,slRate1);
            dataLLROut_2_s73=addSignal(topNet,'dataLLROut_2',pirTyp1,slRate1);
            dataLLROut_3_s74=addSignal(topNet,'dataLLROut_3',pirTyp1,slRate1);
            dataLLROut_4_s75=addSignal(topNet,'dataLLROut_4',pirTyp1,slRate1);
            dataLLROut_5_s76=addSignal(topNet,'dataLLROut_5',pirTyp1,slRate1);
            dataLLROut_6_s77=addSignal(topNet,'dataLLROut_6',pirTyp1,slRate1);
            dataLLROut_7_s78=addSignal(topNet,'dataLLROut_7',pirTyp1,slRate1);

            pirelab.getAnnotationComp(topNet,...
            'DTDVecNVar');


            pirelab.getIntDelayComp(topNet,...
            Demux1_out1_s13,...
            HwModeRegister1VecNVar_out1_s21,...
            1,'HwModeRegister1VecNVar',...
            fi(0,nt1,fiMath1,'hex','00000'),...
            0,0,[],0,0);


            pirelab.getIntDelayComp(topNet,...
            Demux1_out2_s14,...
            HwModeRegister1VecNVar1_out1_s22,...
            1,'HwModeRegister1VecNVar1',...
            fi(0,nt1,fiMath1,'hex','00000'),...
            0,0,[],0,0);


            pirelab.getIntDelayComp(topNet,...
            Demux1_out3_s15,...
            HwModeRegister1VecNVar2_out1_s23,...
            1,'HwModeRegister1VecNVar2',...
            fi(0,nt1,fiMath1,'hex','00000'),...
            0,0,[],0,0);


            pirelab.getIntDelayComp(topNet,...
            Demux1_out4_s16,...
            HwModeRegister1VecNVar3_out1_s24,...
            1,'HwModeRegister1VecNVar3',...
            fi(0,nt1,fiMath1,'hex','00000'),...
            0,0,[],0,0);


            pirelab.getIntDelayComp(topNet,...
            Demux1_out5_s17,...
            HwModeRegister1VecNVar4_out1_s25,...
            1,'HwModeRegister1VecNVar4',...
            fi(0,nt1,fiMath1,'hex','00000'),...
            0,0,[],0,0);


            pirelab.getIntDelayComp(topNet,...
            Demux1_out6_s18,...
            HwModeRegister1VecNVar5_out1_s26,...
            1,'HwModeRegister1VecNVar5',...
            fi(0,nt1,fiMath1,'hex','00000'),...
            0,0,[],0,0);


            pirelab.getIntDelayComp(topNet,...
            Demux1_out7_s19,...
            HwModeRegister1VecNVar6_out1_s27,...
            1,'HwModeRegister1VecNVar6',...
            fi(0,nt1,fiMath1,'hex','00000'),...
            0,0,[],0,0);


            pirelab.getIntDelayComp(topNet,...
            Demux1_out8_s20,...
            HwModeRegister1VecNVar7_out1_s28,...
            1,'HwModeRegister1VecNVar7',...
            fi(0,nt1,fiMath1,'hex','00000'),...
            0,0,[],0,0);


            pirelab.getIntDelayComp(topNet,...
            Demux_out1_s5,...
            HwModeRegisterVecNVar_out1_s29,...
            1,'HwModeRegisterVecNVar',...
            fi(0,nt2,fiMath1,'hex','00000000'),...
            0,0,[],0,0);


            pirelab.getIntDelayComp(topNet,...
            Demux_out2_s6,...
            HwModeRegisterVecNVar1_out1_s30,...
            1,'HwModeRegisterVecNVar1',...
            fi(0,nt2,fiMath1,'hex','00000000'),...
            0,0,[],0,0);


            pirelab.getIntDelayComp(topNet,...
            Demux_out3_s7,...
            HwModeRegisterVecNVar2_out1_s31,...
            1,'HwModeRegisterVecNVar2',...
            fi(0,nt2,fiMath1,'hex','00000000'),...
            0,0,[],0,0);


            pirelab.getIntDelayComp(topNet,...
            Demux_out4_s8,...
            HwModeRegisterVecNVar3_out1_s32,...
            1,'HwModeRegisterVecNVar3',...
            fi(0,nt2,fiMath1,'hex','00000000'),...
            0,0,[],0,0);


            pirelab.getIntDelayComp(topNet,...
            Demux_out5_s9,...
            HwModeRegisterVecNVar4_out1_s33,...
            1,'HwModeRegisterVecNVar4',...
            fi(0,nt2,fiMath1,'hex','00000000'),...
            0,0,[],0,0);


            pirelab.getIntDelayComp(topNet,...
            Demux_out6_s10,...
            HwModeRegisterVecNVar5_out1_s34,...
            1,'HwModeRegisterVecNVar5',...
            fi(0,nt2,fiMath1,'hex','00000000'),...
            0,0,[],0,0);


            pirelab.getIntDelayComp(topNet,...
            Demux_out7_s11,...
            HwModeRegisterVecNVar6_out1_s35,...
            1,'HwModeRegisterVecNVar6',...
            fi(0,nt2,fiMath1,'hex','00000000'),...
            0,0,[],0,0);


            pirelab.getIntDelayComp(topNet,...
            Demux_out8_s12,...
            HwModeRegisterVecNVar7_out1_s36,...
            1,'HwModeRegisterVecNVar7',...
            fi(0,nt2,fiMath1,'hex','00000000'),...
            0,0,[],0,0);


            pirelab.getConstComp(topNet,...
            LLRWithNVarConstVecNVar_out1_s37,...
            fi(0,nt3,fiMath1,'hex','00000000'),...
            'LLRWithNVarConstVecNVar','on',1,'','','');


            pirelab.getIntDelayComp(topNet,...
            ProductVecNVar_out1_s49,...
            PipelineRegisterVecNVar_out1_s41,...
            2,'PipelineRegisterVecNVar',...
            fi(0,nt4,fiMath1,'hex','0000000000000'),...
            0,0,[],0,0);


            pirelab.getIntDelayComp(topNet,...
            ProductVecNVar1_out1_s50,...
            PipelineRegisterVecNVar1_out1_s42,...
            2,'PipelineRegisterVecNVar1',...
            fi(0,nt4,fiMath1,'hex','0000000000000'),...
            0,0,[],0,0);


            pirelab.getIntDelayComp(topNet,...
            ProductVecNVar2_out1_s51,...
            PipelineRegisterVecNVar2_out1_s43,...
            2,'PipelineRegisterVecNVar2',...
            fi(0,nt4,fiMath1,'hex','0000000000000'),...
            0,0,[],0,0);


            pirelab.getIntDelayComp(topNet,...
            ProductVecNVar3_out1_s52,...
            PipelineRegisterVecNVar3_out1_s44,...
            2,'PipelineRegisterVecNVar3',...
            fi(0,nt4,fiMath1,'hex','0000000000000'),...
            0,0,[],0,0);


            pirelab.getIntDelayComp(topNet,...
            ProductVecNVar4_out1_s53,...
            PipelineRegisterVecNVar4_out1_s45,...
            2,'PipelineRegisterVecNVar4',...
            fi(0,nt4,fiMath1,'hex','0000000000000'),...
            0,0,[],0,0);


            pirelab.getIntDelayComp(topNet,...
            ProductVecNVar5_out1_s54,...
            PipelineRegisterVecNVar5_out1_s46,...
            2,'PipelineRegisterVecNVar5',...
            fi(0,nt4,fiMath1,'hex','0000000000000'),...
            0,0,[],0,0);


            pirelab.getIntDelayComp(topNet,...
            ProductVecNVar6_out1_s55,...
            PipelineRegisterVecNVar6_out1_s47,...
            2,'PipelineRegisterVecNVar6',...
            fi(0,nt4,fiMath1,'hex','0000000000000'),...
            0,0,[],0,0);


            pirelab.getIntDelayComp(topNet,...
            ProductVecNVar7_out1_s56,...
            PipelineRegisterVecNVar7_out1_s48,...
            2,'PipelineRegisterVecNVar7',...
            fi(0,nt4,fiMath1,'hex','0000000000000'),...
            0,0,[],0,0);


            pirelab.getIntDelayComp(topNet,...
            validOutDivDelay,...
            delayMatch1VecNVar_out1_s58,...
            3,'delayMatch1VecNVar',...
            false,...
            0,0,[],0,0);


            pirelab.getIntDelayComp(topNet,...
            LogicalOperatorVecNVar_out1_s39,...
            delayMatch3VecNVar_out1_s59,...
            1,'delayMatch3VecNVar',...
            false,...
            0,0,[],0,0);


            pirelab.getIntDelayComp(topNet,...
            LogicalOperatorVecNVar_out1_s39,...
            delayMatch4VecNVar_out1_s60,...
            2,'delayMatch4VecNVar',...
            false,...
            0,0,[],0,0);


            pirelab.getIntDelayComp(topNet,...
            LogicalOperatorVecNVar_out1_s39,...
            delayMatch5VecNVar_out1_s61,...
            3,'delayMatch5VecNVar',...
            false,...
            0,0,[],0,0);


            pirelab.getIntDelayComp(topNet,...
            validOutDivDelay,...
            delayMatchVecNVar_out1_s62,...
            3,'delayMatchVecNVar',...
            false,...
            0,0,[],0,0);


            pirelab.getDTCComp(topNet,...
            Mux_out1_s40,...
            DTCVecNVar_out1_s4,...
            'Floor','Wrap','RWV','DTCVecNVar');

            oneByNvarVecDemuxed=[oneByNvarIn_0_s63,oneByNvarIn_1_s64,oneByNvarIn_2_s65,oneByNvarIn_3_s66,oneByNvarIn_4_s67,oneByNvarIn_5_s68,oneByNvarIn_6_s69,oneByNvarIn_7_s70];

            pirelab.getDemuxComp(topNet,...
            divideOutMuxed,...
            oneByNvarVecDemuxed,...
            'demuxOneByNVarVec');

            pirelab.getWireComp(topNet,...
            oneByNvarIn_0_s63,...
            Demux_out1_s5,...
            'oneByNvarIn_0_wire');

            pirelab.getWireComp(topNet,...
            oneByNvarIn_1_s64,...
            Demux_out2_s6,...
            'oneByNvarIn_1_wire');

            pirelab.getWireComp(topNet,...
            oneByNvarIn_2_s65,...
            Demux_out3_s7,...
            'oneByNvarIn_2_wire');

            pirelab.getWireComp(topNet,...
            oneByNvarIn_3_s66,...
            Demux_out4_s8,...
            'oneByNvarIn_3_wire');

            pirelab.getWireComp(topNet,...
            oneByNvarIn_4_s67,...
            Demux_out5_s9,...
            'oneByNvarIn_4_wire');

            pirelab.getWireComp(topNet,...
            oneByNvarIn_5_s68,...
            Demux_out6_s10,...
            'oneByNvarIn_5_wire');

            pirelab.getWireComp(topNet,...
            oneByNvarIn_6_s69,...
            Demux_out7_s11,...
            'oneByNvarIn_6_wire');

            pirelab.getWireComp(topNet,...
            oneByNvarIn_7_s70,...
            Demux_out8_s12,...
            'oneByNvarIn_7_wire');


            pirelab.getDemuxComp(topNet,...
            dataOutDivDelay,...
            [dataLLROut_0_s71,dataLLROut_1_s72,dataLLROut_2_s73,dataLLROut_3_s74,dataLLROut_4_s75,dataLLROut_5_s76...
            ,dataLLROut_6_s77,dataLLROut_7_s78],...
            'demuxDataLLRVec');

            pirelab.getWireComp(topNet,...
            dataLLROut_0_s71,...
            Demux1_out1_s13,...
            'dataLLROut_0_wire');

            pirelab.getWireComp(topNet,...
            dataLLROut_1_s72,...
            Demux1_out2_s14,...
            'dataLLROut_1_wire');

            pirelab.getWireComp(topNet,...
            dataLLROut_2_s73,...
            Demux1_out3_s15,...
            'dataLLROut_2_wire');

            pirelab.getWireComp(topNet,...
            dataLLROut_3_s74,...
            Demux1_out4_s16,...
            'dataLLROut_3_wire');

            pirelab.getWireComp(topNet,...
            dataLLROut_4_s75,...
            Demux1_out5_s17,...
            'dataLLROut_4_wire');

            pirelab.getWireComp(topNet,...
            dataLLROut_5_s76,...
            Demux1_out6_s18,...
            'dataLLROut_5_wire');

            pirelab.getWireComp(topNet,...
            dataLLROut_6_s77,...
            Demux1_out7_s19,...
            'dataLLROut_6_wire');

            pirelab.getWireComp(topNet,...
            dataLLROut_7_s78,...
            Demux1_out8_s20,...
            'dataLLROut_7_wire');


            pirelab.getLogicComp(topNet,...
            [delayMatch3VecNVar_out1_s59,delayMatch4VecNVar_out1_s60,delayMatch5VecNVar_out1_s61,delayMatch1VecNVar_out1_s58],...
            LogicalAND1VecNVar_out1_s38,...
            'and',sprintf('Logical\nAND1VecNVar'));


            pirelab.getLogicComp(topNet,...
            resetIn,...
            LogicalOperatorVecNVar_out1_s39,...
            'not',sprintf('Logical\nOperatorVecNVar'));


            pirelab.getMuxComp(topNet,...
            [PipelineRegisterVecNVar_out1_s41,PipelineRegisterVecNVar1_out1_s42,PipelineRegisterVecNVar2_out1_s43,PipelineRegisterVecNVar3_out1_s44,PipelineRegisterVecNVar4_out1_s45,PipelineRegisterVecNVar5_out1_s46,...
            PipelineRegisterVecNVar6_out1_s47,PipelineRegisterVecNVar7_out1_s48],...
            Mux_out1_s40,...
            'mux');


            pirelab.getMulComp(topNet,...
            [HwModeRegisterVecNVar_out1_s29,HwModeRegister1VecNVar_out1_s21],...
            ProductVecNVar_out1_s49,...
            'Floor','Wrap','ProductVecNVar','**','',-1,0);


            pirelab.getMulComp(topNet,...
            [HwModeRegisterVecNVar1_out1_s30,HwModeRegister1VecNVar1_out1_s22],...
            ProductVecNVar1_out1_s50,...
            'Floor','Wrap','ProductVecNVar1','**','',-1,0);


            pirelab.getMulComp(topNet,...
            [HwModeRegisterVecNVar2_out1_s31,HwModeRegister1VecNVar2_out1_s23],...
            ProductVecNVar2_out1_s51,...
            'Floor','Wrap','ProductVecNVar2','**','',-1,0);


            pirelab.getMulComp(topNet,...
            [HwModeRegisterVecNVar3_out1_s32,HwModeRegister1VecNVar3_out1_s24],...
            ProductVecNVar3_out1_s52,...
            'Floor','Wrap','ProductVecNVar3','**','',-1,0);


            pirelab.getMulComp(topNet,...
            [HwModeRegisterVecNVar4_out1_s33,HwModeRegister1VecNVar4_out1_s25],...
            ProductVecNVar4_out1_s53,...
            'Floor','Wrap','ProductVecNVar4','**','',-1,0);


            pirelab.getMulComp(topNet,...
            [HwModeRegisterVecNVar5_out1_s34,HwModeRegister1VecNVar5_out1_s26],...
            ProductVecNVar5_out1_s54,...
            'Floor','Wrap','ProductVecNVar5','**','',-1,0);


            pirelab.getMulComp(topNet,...
            [HwModeRegisterVecNVar6_out1_s35,HwModeRegister1VecNVar6_out1_s27],...
            ProductVecNVar6_out1_s55,...
            'Floor','Wrap','ProductVecNVar6','**','',-1,0);


            pirelab.getMulComp(topNet,...
            [HwModeRegisterVecNVar7_out1_s36,HwModeRegister1VecNVar7_out1_s28],...
            ProductVecNVar7_out1_s56,...
            'Floor','Wrap','ProductVecNVar7','**','',-1,0);


            pirelab.getSwitchComp(topNet,...
            [DTCVecNVar_out1_s4,LLRWithNVarConstVecNVar_out1_s37],...
            SwitchLLRVecNVar_out1_s57,...
            delayMatchVecNVar_out1_s62,'SwitchLLRVecNVar',...
            '~=',0,'Floor','Wrap');



            pirelab.getWireComp(topNet,SwitchLLRVecNVar_out1_s57,dataMulOut);
            pirelab.getWireComp(topNet,LogicalAND1VecNVar_out1_s38,validMulOut);




            startOutDelay1=newControlSignal(topNet,'startOutDelay1',rate);
            endInDelay2=newControlSignal(topNet,'endInDelay2',rate);
            endInDelay3=newControlSignal(topNet,'endInDelay3',rate);

            pirelab.getIntDelayComp(topNet,endInDelay1,endInDelay2,18+nonRestoreDivideCompLatency+3,'delay_endInNvar');


            inports_sampNVar(1)=endInDelay2;
            inports_sampNVar(2)=validMulOut;
            inports_sampNVar(3)=resetIn;
            inports_sampNVar(4)=nonMulti8FlagOut;

            outports_sampNVar(1)=startOutDelay1;
            outports_sampNVar(2)=endInDelay3;

            outsampleNVarControlNet=this.elabOutSampleControlNet(topNet,blockInfo,rate);
            outsampleNVarControlNet.addComment('output control Net');

            pirelab.instantiateNetwork(topNet,outsampleNVarControlNet,inports_sampNVar,outports_sampNVar,'outsampleNVarControlNet_inst');

            resetInNOT=newControlSignal(topNet,'resetInNOT',rate);
            pirelab.getBitwiseOpComp(topNet,resetIn,resetInNOT,'NOT');

            resetInNOTDelay1=newControlSignal(topNet,'resetInNOTDelay1',rate);
            pirelab.getUnitDelayComp(topNet,resetInNOT,resetInNOTDelay1);

            startOutDelay2=newControlSignal(topNet,'startOutDelay2',rate);
            endInDelay4=newControlSignal(topNet,'endInDelay4',rate);
            validOutDelay1=newControlSignal(topNet,'validOutDelay1',rate);

            pirelab.getIntDelayComp(topNet,startOutDelay1,startOutDelay2,1,'delay_startOut');
            pirelab.getIntDelayComp(topNet,endInDelay3,endInDelay4,1,'delay_endOut');
            pirelab.getIntDelayComp(topNet,validMulOut,validOutDelay1,1,'delay_validOut');

            pirelab.getBitwiseOpComp(topNet,[startOutDelay2,resetInNOTDelay1],startOut,'AND');
            pirelab.getBitwiseOpComp(topNet,[endInDelay4,resetInNOTDelay1],endOut,'AND');
            pirelab.getBitwiseOpComp(topNet,[validOutDelay1,resetInNOTDelay1],validOutWire,'AND');

            pirelab.getIntDelayComp(topNet,dataMulOut,dataOutBefSwitch,1,'delay_dataOutVecNvar');

            pirelab.getWireComp(topNet,validOutWire,validOut);
            pirelab.getSwitchComp(topNet,[dataOutBefSwitch,dataZeroVec],dataOut,validOutWire,'finDataOutNVarSwitch','>',0,'Floor','Wrap');

        else
            pirelab.getMultiPortSwitchComp(topNet,[modIndxSigDelay1,bpskNonMul8FlagOutDelay,qpskNonMul8FlagOutDelay,psk8NonMul8FlagOutDelay,apsk16NonMul8FlagOutDelay,apsk32NonMul8FlagOut],NonMul8FlagOutDelay,...
            1,2,'floor','Wrap','nonMul8FlagOutMux');
            startOutDelay1=newControlSignal(topNet,'startOutDelay1',rate);
            endInDelay2=newControlSignal(topNet,'endInDelay2',rate);
            endInDelay3=newControlSignal(topNet,'endInDelay3',rate);
            if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                pirelab.getIntDelayComp(topNet,endInDelay1,endInDelay2,18,'delay_endIn');
            else
                pirelab.getIntDelayComp(topNet,endInDelay1,endInDelay2,inWL+40,'delay_endInHD');
            end

            inports_samp(1)=endInDelay2;
            inports_samp(2)=validOutDelay;
            inports_samp(3)=resetIn;
            inports_samp(4)=NonMul8FlagOutDelay;

            outports_samp(1)=startOutDelay1;
            outports_samp(2)=endInDelay3;

            outSampleControlNet=this.elabOutSampleControlNet(topNet,blockInfo,rate);
            outSampleControlNet.addComment('output control Net');

            pirelab.instantiateNetwork(topNet,outSampleControlNet,inports_samp,outports_samp,'outSampleControlNet_inst');

            resetInNOT=newControlSignal(topNet,'resetInNOT',rate);
            pirelab.getBitwiseOpComp(topNet,resetIn,resetInNOT,'NOT');

            resetInNOTDelay1=newControlSignal(topNet,'resetInNOTDelay1',rate);
            pirelab.getUnitDelayComp(topNet,resetInNOT,resetInNOTDelay1);

            startOutDelay2=newControlSignal(topNet,'startOutDelay2',rate);
            endInDelay4=newControlSignal(topNet,'endInDelay4',rate);
            validOutDelay1=newControlSignal(topNet,'validOutDelay1',rate);

            pirelab.getIntDelayComp(topNet,startOutDelay1,startOutDelay2,1,'delay_startOut');
            pirelab.getIntDelayComp(topNet,endInDelay3,endInDelay4,1,'delay_endOut');
            pirelab.getIntDelayComp(topNet,validOutDelay,validOutDelay1,1,'delay_validOut');

            pirelab.getBitwiseOpComp(topNet,[startOutDelay2,resetInNOTDelay1],startOut,'AND');
            pirelab.getBitwiseOpComp(topNet,[endInDelay4,resetInNOTDelay1],endOut,'AND');
            pirelab.getBitwiseOpComp(topNet,[validOutDelay1,resetInNOTDelay1],validOutWire,'AND');

            pirelab.getWireComp(topNet,validOutWire,validOut);

            pirelab.getIntDelayComp(topNet,dataOutDelay,dataOutBefSwitch,1,'delay_dataOutVecNoNvar');
            pirelab.getSwitchComp(topNet,[dataOutBefSwitch,dataZeroVec],dataOut,validOutWire,'finDataOutSwitch','>',0,'Floor','Wrap');

        end
    else
        if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')&&blockInfo.EnbNoiseVar

            serialSCNVar=newDataSignal(topNet,pir_ufixpt_t(inNVarWL,inNVarFL),'serialSCNVar',rate);

            inpSerialNVarSc(1)=nonZeroNVar;
            inpSerialNVarSc(2)=scalarValidIn;
            inpSerialNVarSc(3)=modIndxSigDelay;

            outSerialNVarSc(1)=serialSCNVar;

            serialNVarScNet=this.elabSerialNVarScNet(topNet,blockInfo,rate,inNVarWL,inNVarFL);
            serialNVarScNet.addComment('serialize the noise variance Network');

            pirelab.instantiateNetwork(topNet,serialNVarScNet,inpSerialNVarSc,outSerialNVarSc,'SerialNVarSc_inst');

            divideOut=newDataSignal(topNet,pir_ufixpt_t(32,-(31+inNVarFL)),'divideOut',rate);
            divideInfo.OutType='Inherit: Inherit via internal rule';
            divideInfo.ovMode='Saturate';
            divideInfo.rndMode='Zero';
            divideInfo.inputSigns='*/';
            divideInfo.firstInputSignDivide=false;
            divideInfo.networkName='Divide';
            divideInfo.pipeline='on';
            divideInfo.customLatency=0;
            divideInfo.latencyStrategy='MAX';
            divideInfo.numeratorTypeInfo.zType=numeratorOne.Type;
            divideInfo.numeratorTypeInfo.zWL=32;
            divideInfo.numeratorTypeInfo.zSign=false;
            divideInfo.denominatorTypeInfo.dType=nVarInput.Type;
            divideInfo.denominatorTypeInfo.dWL=inNVarWL;
            divideInfo.denominatorTypeInfo.dSign=false;
            divideInfo.quotientTypeInfo.QType=divideOut.Type;
            divideInfo.quotientTypeInfo.QWL=32;
            divideInfo.quotientTypeInfo.QFL=-(31+inNVarFL);
            divideInfo.fractiondiff=0;
            divideInfo.maxWl=32;

            pirelab.getNonRestoreDivideComp(topNet,[numeratorOne;serialSCNVar],divideOut,divideInfo);
            nonRestoreDivideCompLatency=calNonRestoreDivideCompLatency(numeratorOne,nVarInput,divideOut);


            pirelab.getIntDelayComp(topNet,dataOutDelay,dataOutDivDelay,nonRestoreDivideCompLatency-15,'delay_dataOutDivDelay');
            pirelab.getIntDelayComp(topNet,validOutDelay,validOutDivDelay,nonRestoreDivideCompLatency-15,'delay_validOutDivDelay');

            inpLLRNVarSc(1)=dataOutDivDelay;
            inpLLRNVarSc(2)=validOutDivDelay;
            inpLLRNVarSc(3)=divideOut;

            outLLRNVarSc(1)=dataMulOut;
            outLLRNVarSc(2)=validMulOut;

            outLLRNVarScNet=this.elabOneByNVarMulLLRScNet(topNet,blockInfo,rate,inWL,inFL,inNVarFL);
            outLLRNVarScNet.addComment('one by scalar noise variance multiply by LLR Net');

            pirelab.instantiateNetwork(topNet,outLLRNVarScNet,inpLLRNVarSc,outLLRNVarSc,'OneByNVarMulLLRSc_inst');

            dataZeroSc=newDataSignal(topNet,vecDT,'dataZeroSc',rate);
            pirelab.getConstComp(topNet,dataZeroSc,zeros(1,1),'constdataZeroSc');
            dataMulOutD1=newDataSignal(topNet,vecDT,'dataMulOutD1',rate);
            pirelab.getIntDelayComp(topNet,dataMulOut,dataMulOutD1,1,'delay_dataMulOutSc');
            pirelab.getIntDelayComp(topNet,validMulOut,validOut,1,'delayScNvarvalidOut');
            pirelab.getSwitchComp(topNet,[dataMulOutD1,dataZeroSc],dataOut,validOut,'finMulDataOutSwitchSc','>',0,'Floor','Wrap');
        else
            pirelab.getIntDelayComp(topNet,validOutDelay,validOut,1,'delay_ScvalidOut');
            dataZeroScNoNvar=newDataSignal(topNet,vecDT,'dataZeroScNoNvar',rate);
            pirelab.getConstComp(topNet,dataZeroScNoNvar,zeros(1,1),'constdataZeroScNoNvar');
            dataOutDelay1NoNVar=newDataSignal(topNet,vecDT,'dataOutDelay1NoNVar',rate);
            pirelab.getIntDelayComp(topNet,dataOutDelay,dataOutDelay1NoNVar,1,'delay_dataOutDelay1NoNVar');
            pirelab.getSwitchComp(topNet,[dataOutDelay1NoNVar,dataZeroScNoNvar],dataOut,validOut,'finnoNvarDataOutSwitchSc','>',0,'Floor','Wrap');
        end
    end
end

function latency=calNonRestoreDivideCompLatency(dataIn1RegDelay1,dataIn2RegDelay1,divideOut)

    sig1Signedness=dataIn1RegDelay1.Type.BaseType.Signed;
    sig2Signedness=dataIn2RegDelay1.Type.BaseType.Signed;

    latency=divideOut.Type.BaseType.Wordlength;

    if((sig1Signedness==1&&sig2Signedness==0)||(sig1Signedness==0&&sig2Signedness==1))
        latency=latency+1;
    end
    latency=latency+4;
end

function signal=newUnitControlSignal(topNet,name,rate)
    UnitControlType=pir_ufixpt_t(32,-31);
    signal=topNet.addSignal(UnitControlType,name);
    signal.SimulinkRate=rate;
end

function signal=newControlSignal(topNet,name,rate)
    controlType=pir_ufixpt_t(1,0);
    signal=topNet.addSignal(controlType,name);
    signal.SimulinkRate=rate;
end

function signal=newDataSignal(topNet,inType,name,rate)
    signal=topNet.addSignal(inType,name);
    signal.SimulinkRate=rate;
end

function hS=addSignal(topNet,sigName,pirTyp,simulinkRate)
    hS=topNet.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=0;
    hS.SimulinkRate=simulinkRate;
end
