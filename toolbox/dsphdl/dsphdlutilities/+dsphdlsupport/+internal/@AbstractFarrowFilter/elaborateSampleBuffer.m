function sampleBufferNet=elaborateSampleBuffer(this,topNet,blockInfo,sigInfo,dataRate)







    booleanT=sigInfo.booleanT;
    filterVecType=sigInfo.filterVecType;
    countType=pir_fixpt_t(0,4,0);



    if blockInfo.ResetInputPort
        inPortNames={'dataIn','validIn','nextSample','ready','interp','syncReset'};
        inPortTypes=[filterVecType,booleanT,booleanT,booleanT,booleanT,booleanT];
        inPortRates=[dataRate,dataRate,dataRate,dataRate,dataRate,dataRate];
    else
        inPortNames={'dataIn','validIn','nextSample','ready','interp'};
        inPortTypes=[filterVecType,booleanT,booleanT,booleanT,booleanT];
        inPortRates=[dataRate,dataRate,dataRate,dataRate,dataRate];
    end
    outPortNames={'dataOut','validOut','SampleCount'};
    outPortTypes=[filterVecType,booleanT,countType];

    sampleBufferNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','SampleBuffer',...
    'InportNames',inPortNames,...
    'InportTypes',inPortTypes,...
    'InportRates',inPortRates,...
    'OutportNames',outPortNames,...
    'OutportTypes',outPortTypes...
    );

    inSignals=sampleBufferNet.PirInputSignals;
    dataIn=inSignals(1);
    validIn=inSignals(2);
    nextSample=inSignals(3);
    ready=inSignals(4);
    interp=inSignals(5);

    outSignals=sampleBufferNet.PirOutputSignals;
    dataOut=outSignals(1);
    validOut=outSignals(2);
    SampleCount=outSignals(3);

    if blockInfo.ResetInputPort
        syncReset=inSignals(6);
    else
        syncReset=sampleBufferNet.addSignal2('Type',booleanT,'Name','syncRST');
        syncReset.SimulinkRate=dataRate;
        pirelab.getConstComp(sampleBufferNet,syncReset,0);
    end



    sampleInAddr=sampleBufferNet.addSignal2('Type',countType,'Name','SampleInAddr');
    sampleOutAddr=sampleBufferNet.addSignal2('Type',countType,'Name','SampleOutAddr');
    sampleNum=sampleBufferNet.addSignal2('Type',countType,'Name','SampleNum');
    validInterp=sampleBufferNet.addSignal2('Type',booleanT,'Name','ValidInterp');
    sampleNumEn=sampleBufferNet.addSignal2('Type',booleanT,'Name','SampleNumEn');
    sampleNumDir=sampleBufferNet.addSignal2('Type',booleanT,'Name','SampleNumDir');
    nextSampleEn=sampleBufferNet.addSignal2('Type',booleanT,'Name','NextSampleEn');
    SampleAvailable=sampleBufferNet.addSignal2('Type',booleanT,'Name','SampleAvailable');


    pirelab.getLogicComp(sampleBufferNet,[validIn,interp],validInterp,'and');
    pirelab.getCounterComp(sampleBufferNet,[syncReset,validInterp],sampleInAddr,'Free running',...
    0,1,[],true,false,true,false,'SampleInAddr',0.0);

    pirelab.getLogicComp(sampleBufferNet,[SampleAvailable,nextSample],nextSampleEn,'and');
    pirelab.getLogicComp(sampleBufferNet,[validInterp,nextSampleEn],sampleNumEn,'xor');
    pirelab.getLogicComp(sampleBufferNet,nextSampleEn,sampleNumDir,'not');
    pirelab.getCounterComp(sampleBufferNet,[syncReset,sampleNumEn,sampleNumDir],sampleNum,'Free running',...
    0,1,[],true,false,true,true,'SampleNum',0.0);

    pirelab.getCounterComp(sampleBufferNet,[syncReset,nextSampleEn],sampleOutAddr,'Free running',...
    0,1,[],true,false,true,false,'SampleOutAddr',0.0);



    for ii=1:1:16
        dataBuffer(ii)=sampleBufferNet.addSignal2('Type',filterVecType,'Name',['DataBuffer',num2str(ii)]);
        bufferEn(ii)=sampleBufferNet.addSignal2('Type',booleanT,'Name',['BufferEn',num2str(ii)]);
        pirelab.getCompareToValueComp(sampleBufferNet,sampleInAddr,bufferEn(ii),'==',ii-1);
        pirelab.getUnitDelayEnabledComp(sampleBufferNet,dataIn,dataBuffer(ii),bufferEn(ii));

    end

    NewSampleInterp=sampleBufferNet.addSignal2('Type',filterVecType,'Name','NewSampleInterp');
    pirelab.getSwitchComp(sampleBufferNet,dataBuffer,NewSampleInterp,sampleOutAddr);
    InterpValidOut=sampleBufferNet.addSignal2('Type',booleanT,'Name','InterpValidOut');

    pirelab.getCompareToValueComp(sampleBufferNet,sampleNum,SampleAvailable,'>',0);
    pirelab.getWireComp(sampleBufferNet,nextSample,InterpValidOut,'and');



    NewSampleDecim=sampleBufferNet.addSignal2('Type',filterVecType,'Name','NewSampleDecim');
    DecimValidOut=sampleBufferNet.addSignal2('Type',booleanT,'Name','InterpValidOut');
    pirelab.getWireComp(sampleBufferNet,dataIn,NewSampleDecim);
    pirelab.getWireComp(sampleBufferNet,validIn,DecimValidOut);




    pirelab.getSwitchComp(sampleBufferNet,[NewSampleDecim,NewSampleInterp],dataOut,interp);
    pirelab.getSwitchComp(sampleBufferNet,[DecimValidOut,InterpValidOut],validOut,interp);
    pirelab.getWireComp(sampleBufferNet,sampleNum,SampleCount);




