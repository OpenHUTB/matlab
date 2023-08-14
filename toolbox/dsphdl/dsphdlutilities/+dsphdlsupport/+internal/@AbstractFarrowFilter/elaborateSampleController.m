function sampleControlNet=elaborateSampleController(this,topNet,blockInfo,sigInfo,dataRate)







    booleanT=sigInfo.booleanT;
    filterVecType=sigInfo.filterVecType;
    countType=pir_fixpt_t(0,4,0);

    if blockInfo.ResetInputPort
        if strcmpi(blockInfo.Mode,'Property')
            inPortNames={'dataIn','validIn','BufferCount','syncReset'};
            inPortTypes=[filterVecType,booleanT,countType,booleanT];
            inPortRates=[dataRate,dataRate,dataRate,dataRate];
        else
            inPortNames={'dataIn','validIn','BufferCount','rate','syncReset'};
            inPortTypes=[filterVecType,booleanT,countType,blockInfo.FractionalDelayDataType,booleanT];
            inPortRates=[dataRate,dataRate,dataRate,dataRate,dataRate];
        end
    else
        if strcmpi(blockInfo.Mode,'Property')
            inPortNames={'dataIn','validIn','BufferCount'};
            inPortTypes=[filterVecType,booleanT,countType];
            inPortRates=[dataRate,dataRate,dataRate];
        else
            inPortNames={'dataIn','validIn','BufferCount','rate'};
            inPortTypes=[filterVecType,booleanT,countType,blockInfo.FractionalDelayDataType];
            inPortRates=[dataRate,dataRate,dataRate,dataRate];
        end
    end
    outPortNames={'dataOut','fracDelayOut','validOut','ready','nextSample','interp','readyInternal'};
    outPortTypes=[filterVecType,blockInfo.FractionalDelayDataType,booleanT,booleanT,booleanT,booleanT,booleanT];

    sampleControlNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','SampleController',...
    'InportNames',inPortNames,...
    'InportTypes',inPortTypes,...
    'InportRates',inPortRates,...
    'OutportNames',outPortNames,...
    'OutportTypes',outPortTypes...
    );

    inSignals=sampleControlNet.PirInputSignals;
    dataIn=inSignals(1);
    validIn=inSignals(2);
    bufferCount=inSignals(3);

    if strcmpi(blockInfo.Mode,'Input port')
        rate=inSignals(4);
    end

    if blockInfo.ResetInputPort
        if strcmpi(blockInfo.Mode,'Property')
            syncReset=inSignals(4);
        else
            syncReset=inSignals(5);
        end
    else
        syncReset=sampleControlNet.addSignal2('Type',booleanT,'Name','syncReset');
        syncReset.SimulinkRate=dataRate;
        pirelab.getConstComp(sampleControlNet,syncReset,0);
    end

    outSignals=sampleControlNet.PirOutputSignals;
    dataOut=outSignals(1);
    fracDelayOut=outSignals(2);
    validOut=outSignals(3);
    ready=outSignals(4);
    nextSample=outSignals(5);
    interp=outSignals(6);
    readyInternal=outSignals(7);
    fracWL=blockInfo.FractionalDelayDataType.WordLength;
    fracFL=blockInfo.FractionalDelayDataType.FractionLength*-1;


    rateChange=sampleControlNet.addSignal2('Type',blockInfo.FractionalDelayDataType,'Name','RateChange');
    clearPhase=sampleControlNet.addSignal2('Type',booleanT,'Name','clearPhase');
    rateChange.SimulinkRate=dataRate;
    rateChangeREG=sampleControlNet.addSignal2('Type',blockInfo.FractionalDelayDataType,'Name','RateChangeREG');
    clearPhaseREG=sampleControlNet.addSignal2('Type',booleanT,'Name','clearPhaseREG');
    rateChangeRED.SimulinkRate=dataRate;


    if strcmpi(blockInfo.Mode,'Property')
        pirelab.getConstComp(sampleControlNet,rateChange,blockInfo.RateChange);
        pirelab.getConstComp(sampleControlNet,clearPhaseREG,false);
    else
        pirelab.getUnitDelayComp(sampleControlNet,rate,rateChange);
        pirelab.getUnitDelayComp(sampleControlNet,rateChange,rateChangeREG);
        pirelab.getRelOpComp(sampleControlNet,[rateChangeREG,rateChange],clearPhase,'~=');
        pirelab.getUnitDelayComp(sampleControlNet,clearPhase,clearPhaseREG);

    end




    fracIntegerBits=fracWL-fracFL;


    fracIntegerType=pir_fixpt_t(0,fracIntegerBits,0);
    fracBitSliceType=pir_fixpt_t(0,fracFL,0);
    fracBitSliceSIType=pir_fixpt_t(0,fracFL,fracFL*-1);
    fracFractionType=pir_fixpt_t(0,fracFL+1,fracFL*-1);
    accumType=pir_fixpt_t(1,fracFL+2,fracFL*-1);
    nextPhaseType=pir_fixpt_t(0,12,-11);

    rateChangeInteger=sampleControlNet.addSignal2('Type',fracIntegerType,'Name','RateChangeInteger');
    rateChangeFraction=sampleControlNet.addSignal2('Type',fracFractionType,'Name','RateChangeFraction');
    rateChangeFractionIn=sampleControlNet.addSignal2('Type',accumType,'Name','RateChangeFractionIn');
    nextPhase=sampleControlNet.addSignal2('Type',fracFractionType,'Name','nextPhase');

    fracFractionOut=sampleControlNet.addSignal2('Type',fracFractionType,'Name','fracFractionOut');
    rateChangeFracBitSlice=sampleControlNet.addSignal2('Type',fracBitSliceType,'Name','RateChangeFrac');
    rateChangeFracBitSliceSI=sampleControlNet.addSignal2('Type',fracBitSliceSIType,'Name','RateChangeFracSI');
    constantOne=sampleControlNet.addSignal2('Type',fracFractionType,'Name','ConstantOne');
    constantOne.SimulinkRate=dataRate;
    pirelab.getConstComp(sampleControlNet,constantOne,1);

    fracAccumBitClear=sampleControlNet.addSignal2('Type',fracFractionType,'Name','FracAccumBitClear');

    pirelab.getBitSliceComp(sampleControlNet,rateChange,rateChangeInteger,fracWL-1,fracWL-fracIntegerBits);
    pirelab.getBitSliceComp(sampleControlNet,rateChange,rateChangeFracBitSlice,fracFL-1,0);
    pirelab.getDTCComp(sampleControlNet,rateChangeFracBitSlice,rateChangeFracBitSliceSI,'Floor','Wrap','SI','ReinterpretCast');
    pirelab.getDTCComp(sampleControlNet,rateChangeFracBitSliceSI,rateChangeFraction,'Floor','Wrap');



    fracAccumREG=sampleControlNet.addSignal2('Type',fracFractionType,'Name','FracAccumREG');
    fracAccumREGFP=sampleControlNet.addSignal2('Type',accumType,'Name','FracAccumREGFP');
    fracAccumIn=sampleControlNet.addSignal2('Type',accumType,'Name','FracAccumIn');
    fracAccumREGS=sampleControlNet.addSignal2('Type',fracFractionType,'Name','FracAccumREGS');
    fracAccumREGZero=sampleControlNet.addSignal2('Type',fracFractionType,'Name','FracAccumREGZero');
    fracAccumREGBitSet=sampleControlNet.addSignal2('Type',fracFractionType,'Name','FracAccumREGBitSet');
    fracAccumREGSwitch=sampleControlNet.addSignal2('Type',fracFractionType,'Name','FracAccumREGSwitch');
    fracAccumREGOut=sampleControlNet.addSignal2('Type',fracFractionType,'Name','FracAccumREGOut');
    fracAccumREGEn=sampleControlNet.addSignal2('Type',booleanT,'Name','FracAccumREGEn');
    fracAccumREGRST=sampleControlNet.addSignal2('Type',booleanT,'Name','FracAccumREGRST');
    fracAccumREGRSTSR=sampleControlNet.addSignal2('Type',booleanT,'Name','FracAccumREGRSTSR');
    fracAccum=sampleControlNet.addSignal2('Type',fracFractionType,'Name','FracAccum');
    fracAccumS=sampleControlNet.addSignal2('Type',fracFractionType,'Name','FracAccumS');
    sampleCountRST=sampleControlNet.addSignal2('Type',booleanT,'Name','SampleCountRST');
    sampleCountRSTSR=sampleControlNet.addSignal2('Type',booleanT,'Name','SampleCountRSTSR');
    wrapOverPhase=sampleControlNet.addSignal2('Type',booleanT,'Name','wrapOverPhase');
    wrapOverPhaseClear=sampleControlNet.addSignal2('Type',booleanT,'Name','wrapOverPhaseClear');
    fracAccumREGZero.SimulinkRate=dataRate;
    accumValid=sampleControlNet.addSignal2('Type',booleanT,'Name','AccumValid');



    pirelab.getLogicComp(sampleControlNet,[fracAccumREGRST,syncReset],fracAccumREGRSTSR,'or');

    pirelab.getBitSetComp(sampleControlNet,fracAccumREG,fracAccumREGBitSet,false,fracFL+1);
    pirelab.getCompareToValueComp(sampleControlNet,fracAccumREGBitSet,wrapOverPhase,'>',fi(0.99999998,0,fracFL,fracFL,hdlfimath));
    pirelab.getConstComp(sampleControlNet,fracAccumREGZero,0);
    pirelab.getLogicComp(sampleControlNet,[wrapOverPhase,clearPhaseREG],wrapOverPhaseClear,'or');
    pirelab.getSwitchComp(sampleControlNet,[fracAccumREGBitSet,fracAccumREGZero],fracAccumREGSwitch,wrapOverPhaseClear);
    pirelab.getDTCComp(sampleControlNet,rateChangeFraction,rateChangeFractionIn);


    accumNet=elabAccumulator(this,sampleControlNet,blockInfo,dataRate,...
    rateChangeFractionIn,fracAccumIn,fracAccumREGEn,fracAccumREGFP,...
    fracFL+2,fracFL*-1,...
    fracFL+2,fracFL*-1,...
    fracFL+2,fracFL*-1);%#ok<*NASGU>


    if blockInfo.ResetInputPort
        pirelab.instantiateNetwork(sampleControlNet,accumNet,...
        [rateChangeFractionIn,fracAccumIn,fracAccumREGEn,syncReset],...
        [fracAccumREGFP],...
        'PhaseAccumulator');
    else
        pirelab.instantiateNetwork(sampleControlNet,accumNet,...
        [rateChangeFractionIn,fracAccumIn,fracAccumREGEn],...
        [fracAccumREGFP],...
        'PhaseAccumulator');
    end

    pirelab.getDTCComp(sampleControlNet,fracAccumREGFP,fracAccumREG,'floor','wrap');
    pirelab.getDTCComp(sampleControlNet,fracAccumREGSwitch,fracAccumIn,'floor','wrap');












    counterType=pir_fixpt_t(0,8,0);
    sampleCount=sampleControlNet.addSignal2('Type',counterType,'Name','SampleCount');
    sampleCount.SimulinkRate=dataRate;
    sampleCountEN=sampleControlNet.addSignal2('Type',booleanT,'Name','SampleCountEN');
    fracOverOne=sampleControlNet.addSignal2('Type',booleanT,'Name','fracOverOne');
    fracOverOneREG=sampleControlNet.addSignal2('Type',booleanT,'Name','fracOverOneREG');

    pirelab.getLogicComp(sampleControlNet,[sampleCountRST,syncReset,clearPhaseREG],sampleCountRSTSR,'or');

    pirelab.getCounterComp(sampleControlNet,[sampleCountRSTSR,sampleCountEN],sampleCount,'Free running',...
    1,1,[],true,false,true,false,'Sample Count',1);

    rateChangeIntegerNext=sampleControlNet.addSignal2('Type',fracIntegerType,'Name','RateChangeIntegerNext');
    constOne=sampleControlNet.addSignal2('Type',fracIntegerType,'Name','constOne');
    constOne.SimulinkRate=dataRate;
    readyREGD=sampleControlNet.addSignal2('Type',booleanT,'Name','readyREGD');
    CountNext=sampleControlNet.addSignal2('Type',booleanT,'Name','CountNext');
    fracDelayThreshold=sampleControlNet.addSignal2('Type',booleanT,'Name','FracDelayThreshold');
    fracDelayThreshold.SimulinkRate=dataRate;
    fracDelayThresholdReady=sampleControlNet.addSignal2('Type',booleanT,'Name','FracDelayThresholdReady');
    pirelab.getLogicComp(sampleControlNet,[fracDelayThreshold,readyREGD],fracDelayThresholdReady,'and');

    pirelab.getConstComp(sampleControlNet,constOne,1);
    pirelab.getAddComp(sampleControlNet,[rateChangeInteger,constOne],rateChangeIntegerNext,'Floor','Wrap');

    countCompareValue=sampleControlNet.addSignal2('Type',fracIntegerType,'Name','CountCompareValue');
    rateChangeOverOne=sampleControlNet.addSignal2('Type',booleanT,'Name','RateChangeOverOne');
    nextPhaseConst=sampleControlNet.addSignal2('Type',fracFractionType,'Name','nextPhaseConst');
    countReached=sampleControlNet.addSignal2('Type',booleanT,'Name','CountReached');

    pirelab.getAddComp(sampleControlNet,[rateChangeFraction,fracAccumREGSwitch],nextPhase,'floor','wrap');
    pirelab.getCompareToValueComp(sampleControlNet,fracAccumREG,fracDelayThreshold,'>',fi(0.99999998,0,fracFL,fracFL,hdlfimath));


    pirelab.getConstComp(sampleControlNet,nextPhaseConst,fi(0.99999998,0,fracFL+1,fracFL,hdlfimath));
    pirelab.getRelOpComp(sampleControlNet,[nextPhase,nextPhaseConst],CountNext,'>');

    pirelab.getSwitchComp(sampleControlNet,[rateChangeInteger,rateChangeIntegerNext],countCompareValue,CountNext);
    pirelab.getCompareToValueComp(sampleControlNet,countCompareValue,rateChangeOverOne,'>',1);
    pirelab.getLogicComp(sampleControlNet,[validIn,rateChangeOverOne],sampleCountEN,'and');
    pirelab.getRelOpComp(sampleControlNet,[sampleCount,countCompareValue],countReached,'==');
    pirelab.getLogicComp(sampleControlNet,[countReached,validIn],sampleCountRST,'and');


    readyREG=sampleControlNet.addSignal2('Type',booleanT,'Name','ReadyREG');
    NotReady=sampleControlNet.addSignal2('Type',booleanT,'Name','NotReady');
    readyREGRST=sampleControlNet.addSignal2('Type',booleanT,'Name','ReadyREGRST');
    readyREGRSTCP=sampleControlNet.addSignal2('Type',booleanT,'Name','ReadyREGRSTCP');
    readyREGRSTSR=sampleControlNet.addSignal2('Type',booleanT,'Name','ReadyREGRSTSR');
    readyREGRSTSN=sampleControlNet.addSignal2('Type',booleanT,'Name','ReadyREGRST');
    sampleNumR=sampleControlNet.addSignal2('Type',booleanT,'Name','sampleNumR');
    sampleNumRN=sampleControlNet.addSignal2('Type',booleanT,'Name','sampleNumRN');
    sampleNumRnotready=sampleControlNet.addSignal2('Type',booleanT,'Name','sampleNumRnotready');
    pirelab.getCompareToValueComp(sampleControlNet,bufferCount,sampleNumR,'>',1);
    pirelab.getLogicComp(sampleControlNet,sampleNumR,sampleNumRN,'not');
    pirelab.getLogicComp(sampleControlNet,[sampleNumRN,readyREGRST],readyREGRSTSN,'and');
    pirelab.getLogicComp(sampleControlNet,[readyREGRSTSN,syncReset,clearPhaseREG],readyREGRSTSR,'or');
    pirelab.getLogicComp(sampleControlNet,[sampleNumR,NotReady],sampleNumRnotready,'and');
    pirelab.getUnitDelayEnabledResettableComp(sampleControlNet,sampleNumRnotready,readyREG,sampleNumRnotready,readyREGRSTSR,'ReadyREG',0,'',true,'',-1,true);


    validREG=sampleControlNet.addSignal2('Type',booleanT,'Name','ValidREG');
    validREGRST=sampleControlNet.addSignal2('Type',booleanT,'Name','ValidREGRST');
    validREGRSTSR=sampleControlNet.addSignal2('Type',booleanT,'Name','ValidREGRSTSR');
    pirelab.getLogicComp(sampleControlNet,[validREGRST,syncReset,clearPhaseREG],validREGRSTSR,'or');
    pirelab.getUnitDelayEnabledResettableComp(sampleControlNet,sampleCountRST,validREG,sampleCountRST,validREGRSTSR,'validREG',0,'',true','',-1,true);

    CountNOTReached=sampleControlNet.addSignal2('Type',booleanT,'Name','CountNOTReached');
    decimValidOut=sampleControlNet.addSignal2('Type',booleanT,'Name','DecimValidOut');

    pirelab.getLogicComp(sampleControlNet,sampleCountRST,CountNOTReached,'not');
    pirelab.getLogicComp(sampleControlNet,[CountNOTReached,validIn],validREGRST,'and');
    pirelab.getLogicComp(sampleControlNet,[validREG,validIn],decimValidOut,'and');

    interpValidOut=sampleControlNet.addSignal2('Type',booleanT,'Name','InterpValidOut');
    interpValidOutREG=sampleControlNet.addSignal2('Type',booleanT,'Name','InterpValidOutREG');
    notReadyRST=sampleControlNet.addSignal2('Type',booleanT,'Name','notReadyRST');
    bufferReady=sampleControlNet.addSignal2('Type',booleanT,'Name','bufferReady');
    interpReady=sampleControlNet.addSignal2('Type',booleanT,'Name','interpReady');
    pirelab.getLogicComp(sampleControlNet,readyREGRST,notReadyRST,'not');
    interpMode=sampleControlNet.addSignal2('Type',booleanT,'Name','InterMode');
    pirelab.getCompareToValueComp(sampleControlNet,rateChangeInteger,interpMode,'==',0);
    pirelab.getLogicComp(sampleControlNet,[readyREG,interpMode,notReadyRST],interpValidOut,'and');

    pirelab.getUnitDelayComp(sampleControlNet,interpValidOut,interpValidOutREG);

    pirelab.getSwitchComp(sampleControlNet,[decimValidOut,interpValidOut],validOut,interpMode);

    constTrue=sampleControlNet.addSignal2('Type',booleanT,'Name','constFalse');
    constTrue.SimulinkRate=dataRate;
    pirelab.getConstComp(sampleControlNet,constTrue,1);

    pirelab.getLogicComp(sampleControlNet,readyREG,NotReady,'not');
    pirelab.getWireComp(sampleControlNet,NotReady,readyInternal);
    pirelab.getCompareToValueComp(sampleControlNet,bufferCount,bufferReady,'<=',12);
    pirelab.getLogicComp(sampleControlNet,[bufferReady,NotReady],interpReady,'and');
    pirelab.getSwitchComp(sampleControlNet,[constTrue,interpReady],ready,interpMode);


    fracDelayThresholdREG=sampleControlNet.addSignal2('Type',booleanT,'Name','FracDelayThresholdREG');
    risingEdgeReady=sampleControlNet.addSignal2('Type',booleanT,'Name','risingEdgeReady');
    risingEdgeReadyThresh=sampleControlNet.addSignal2('Type',booleanT,'Name','RisingEdgeReadyThresh');
    fracDelayThresholdSwitch=sampleControlNet.addSignal2('Type',booleanT,'Name','FracDelayThresholdSwitch');
    nextSampleClear=sampleControlNet.addSignal2('Type',booleanT,'Name','nextSampleClear');
    sampleAvailable=sampleControlNet.addSignal2('Type',booleanT,'Name','sampleAvailable');


    pirelab.getCompareToValueComp(sampleControlNet,bufferCount,sampleAvailable,'>',0);
    pirelab.getLogicComp(sampleControlNet,[sampleAvailable,clearPhaseREG],nextSampleClear,'and');

    constFalse=sampleControlNet.addSignal2('Type',booleanT,'Name','constFalse');
    constFalse.SimulinkRate=dataRate;
    pirelab.getConstComp(sampleControlNet,constFalse,0);

    pirelab.getUnitDelayComp(sampleControlNet,readyREG,readyREGD);

    pirelab.getSwitchComp(sampleControlNet,[fracDelayThresholdReady,constFalse],fracDelayThresholdSwitch,validIn);
    pirelab.getUnitDelayComp(sampleControlNet,fracDelayThresholdSwitch,fracDelayThresholdREG);
    pirelab.getLogicComp(sampleControlNet,fracDelayThresholdREG,risingEdgeReady,'not');

    pirelab.getLogicComp(sampleControlNet,[fracDelayThresholdReady,risingEdgeReady],risingEdgeReadyThresh,'and');
    pirelab.getLogicComp(sampleControlNet,[readyREGD,risingEdgeReadyThresh],readyREGRST,'and');

    pirelab.getLogicComp(sampleControlNet,[readyREGRST,nextSampleClear],readyREGRSTCP,'or');

    DecimEn=sampleControlNet.addSignal2('Type',booleanT,'Name','DecimEn');
    notInterp=sampleControlNet.addSignal2('Type',booleanT,'Name','notInterp');

    pirelab.getLogicComp(sampleControlNet,interpMode,notInterp,'not');
    pirelab.getLogicComp(sampleControlNet,[sampleCountRST,notInterp],DecimEn,'and');
    pirelab.getLogicComp(sampleControlNet,[interpValidOut,DecimEn],fracAccumREGEn,'or');




    ConstOneOutput=sampleControlNet.addSignal2('Type',blockInfo.FractionalDelayDataType,'Name','ConstOneOutput');
    ConstOneOutput.SimulinkRate=dataRate;
    pirelab.getConstComp(sampleControlNet,ConstOneOutput,1);

    pirelab.getSubComp(sampleControlNet,[ConstOneOutput,fracAccumREGSwitch],fracDelayOut,'Floor','Wrap','FracDelaySubtract');

    dataREG=sampleControlNet.addSignal2('Type',filterVecType,'Name','dataREG');

    pirelab.getUnitDelayComp(sampleControlNet,dataIn,dataREG);
    pirelab.getSwitchComp(sampleControlNet,[dataIn,dataREG],dataOut,notInterp);

    pirelab.getWireComp(sampleControlNet,interpMode,interp);
    pirelab.getWireComp(sampleControlNet,readyREGRSTCP,nextSample);
