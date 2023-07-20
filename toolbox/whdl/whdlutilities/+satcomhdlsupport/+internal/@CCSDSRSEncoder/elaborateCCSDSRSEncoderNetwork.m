function elaborateCCSDSRSEncoderNetwork(this,topNet,blockInfo,insignals,outsignals)








    dataIn=insignals(1);
    startIn=insignals(2);
    endIn=insignals(3);
    validIn=insignals(4);



    dataOut=outsignals(1);
    startOut=outsignals(2);
    endOut=outsignals(3);
    validOut=outsignals(4);
    nextFrame=outsignals(5);


    rate=dataIn.SimulinkRate;
    dataOut.SimulinkRate=rate;
    startOut.SimulinkRate=rate;
    endOut.SimulinkRate=rate;
    validOut.SimulinkRate=rate;
    nextFrame.SimulinkRate=rate;


    messageLength=double(blockInfo.MessageLength);
    codewordLength=255;
    k=messageLength;
    n=codewordLength;
    I=double(blockInfo.InterleavingDepth);

    if(messageLength==239)
        corr=8;
    else
        corr=16;
    end

    [tgenPolyBeta,tbetaPow8]=HDLCCSDSRSCodeTables(messageLength);


    genPolyMSBLeft=tgenPolyBeta(2:(corr+1));
    genPolyMSBLeftBool=int2bit(genPolyMSBLeft',8,true);
    genPoly=bit2int(genPolyMSBLeftBool,8,false)';

    betaPow8MSBLeft=tbetaPow8;
    betaPow8MSBLeftBool=int2bit(betaPow8MSBLeft,8,true);
    betaPow8=bit2int(betaPow8MSBLeftBool,8,false);

    numPackets=2;


    latency_Act=3;
    latency=latency_Act-1;
    regLatency=latency-1;


    controlType=pir_ufixpt_t(1,0);



    dataInDelay=newDataSignal(topNet,'dataInDelay',pir_ufixpt_t(8,0),rate);
    startIn2=newControlSignal(topNet,'startIn2',rate);
    endIn2=newControlSignal(topNet,'endIn2',rate);
    validIn2=newControlSignal(topNet,'validIn2',rate);
    validIn2Delay=newControlSignal(topNet,'validIn2Delay',rate);
    startIn2Delay=newControlSignal(topNet,'startIn2Delay',rate);
    endIn2Delay=newControlSignal(topNet,'endIn2Delay',rate);
    packetWrAddrEnb=newControlSignal(topNet,'packetWrAddrEnb',rate);
    pirelab.getUnitDelayComp(topNet,dataIn,dataInDelay,'dataDelay',0);
    pirelab.getUnitDelayComp(topNet,validIn2,validIn2Delay,'validIn2Delay',0);
    pirelab.getUnitDelayComp(topNet,startIn2,startIn2Delay,'startIn2Delay',0);
    pirelab.getUnitDelayComp(topNet,endIn2,endIn2Delay,'endIn2Delay',0);

    sampleCountVal=newDataSignal(topNet,'sampleCountVal',pir_ufixpt_t(nextpow2(k*I+1),0),rate);
    endInOr=newControlSignal(topNet,'endInOr',rate);
    noNextFrame=newControlSignal(topNet,'noNextFrame',rate);
    startNoNextFrame=newControlSignal(topNet,'startNoNextFrame',rate);
    startNoNextFrameDelay=newControlSignal(topNet,'startNoNextFrameDelay',rate);
    pirelab.getBitwiseOpComp(topNet,nextFrame,noNextFrame,'NOT','noNextFrame');
    pirelab.getBitwiseOpComp(topNet,[startIn2,noNextFrame],startNoNextFrame,'AND','startNoNextFrame');
    pirelab.getUnitDelayComp(topNet,startNoNextFrame,startNoNextFrameDelay);



    wrIntrlvInd=newDataSignal(topNet,'wrIntrlvInd',pir_ufixpt_t(max(nextpow2(I),1),0),rate);
    wrIntrlvInd1=newDataSignal(topNet,'wrIntrlvInd1',pir_ufixpt_t(max(nextpow2(I),1),0),rate);
    nonMultLen1=newControlSignal(topNet,'nonMultLen1',rate);
    nonMultLen2=newControlSignal(topNet,'nonMultLen2',rate);
    nonMultLen=newControlSignal(topNet,'nonMultLen',rate);
    invalidInpFrame1=newControlSignal(topNet,'invalidInpFrame1',rate);
    invalidInpFrame=newControlSignal(topNet,'invalidInpFrame',rate);
    zeroConstIntrlv=newDataSignal(topNet,'zeroConstIntrlv',pir_ufixpt_t(max(nextpow2(I),1),0),rate);
    nextFrameCount=newDataSignal(topNet,'nextFrameCount',pir_ufixpt_t(nextpow2(2*corr*I+1),0),rate);
    nextFrameCountEnb=newControlSignal(topNet,'nextFrameCountEnb',rate);
    nextFrameLoad=newControlSignal(topNet,'nextFrameLoad',rate);
    oneConstNxtFrame=newDataSignal(topNet,'oneConstNxtFrame',pir_ufixpt_t(nextpow2(2*corr*I+1),0),rate);
    outputCountRst=newControlSignal(topNet,'outputCountRst',rate);
    validInDelay=topNet.addSignal(controlType,'validInDelay');
    notValidInDelay=topNet.addSignal(controlType,'notValidInDelay');
    nonMultLen2Valid=topNet.addSignal(controlType,'nonMultLen2Valid');
    nonMultLen1NotValid=topNet.addSignal(controlType,'nonMultLen1NotValid');



    if(I==1)
        pirelab.getConstComp(topNet,wrIntrlvInd,0);
        pirelab.getConstComp(topNet,invalidInpFrame1,false);
        pirelab.getConstComp(topNet,invalidInpFrame,false);
    else
        pirelab.getCounterComp(topNet,[startIn2,validIn2Delay],wrIntrlvInd,...
        'Count limited',...
        0.0,...
        1.0,...
        I-1,...
        true,...
        false,...
        true,...
        false,...
        'wrIntrlvIndCounter');
        pirelab.getConstComp(topNet,zeroConstIntrlv,0);
        pirelab.getSwitchComp(topNet,[wrIntrlvInd,zeroConstIntrlv],wrIntrlvInd1,startIn2);
        pirelab.getCompareToValueComp(topNet,wrIntrlvInd1,nonMultLen2,'~=',I-2);
        pirelab.getCompareToValueComp(topNet,wrIntrlvInd1,nonMultLen1,'~=',I-1);
        pirelab.getBitwiseOpComp(topNet,[nonMultLen2,validInDelay],nonMultLen2Valid,'AND');
        pirelab.getBitwiseOpComp(topNet,[nonMultLen1,notValidInDelay],nonMultLen1NotValid,'AND');
        pirelab.getBitwiseOpComp(topNet,[nonMultLen2Valid,nonMultLen1NotValid],nonMultLen,'OR');
        if(I==2)
            sampleCountZero=newControlSignal(topNet,'sampleCountZero',rate);
            invalidInpFrame2=newControlSignal(topNet,'invalidInpFrame2',rate);
            pirelab.getCompareToValueComp(topNet,sampleCountVal,sampleCountZero,'==',0);
            pirelab.getBitwiseOpComp(topNet,[sampleCountZero,startIn2],invalidInpFrame2,'AND');
            pirelab.getBitwiseOpComp(topNet,[nonMultLen,invalidInpFrame2],invalidInpFrame1,'OR');
            pirelab.getBitwiseOpComp(topNet,[invalidInpFrame1,endIn2],invalidInpFrame,'AND');
        else
            lessThanIntrlv1=newControlSignal(topNet,'lessThanIntrlv',rate);
            lessThanIntrlv2=newControlSignal(topNet,'lessThanIntrlv',rate);
            lessThanIntrlv1NotValid=newControlSignal(topNet,'lessThanIntrlv1NotValid',rate);
            lessThanIntrlv2Valid=newControlSignal(topNet,'lessThanIntrlv2Valid',rate);
            lessThanIntrlv=newControlSignal(topNet,'lessThanIntrlv',rate);
            pirelab.getCompareToValueComp(topNet,sampleCountVal,lessThanIntrlv2,'<',I-2);
            pirelab.getCompareToValueComp(topNet,sampleCountVal,lessThanIntrlv1,'<',I-1);
            pirelab.getBitwiseOpComp(topNet,[lessThanIntrlv2,validInDelay],lessThanIntrlv2Valid,'AND');
            pirelab.getBitwiseOpComp(topNet,[lessThanIntrlv1,notValidInDelay],lessThanIntrlv1NotValid,'AND');
            pirelab.getBitwiseOpComp(topNet,[lessThanIntrlv2Valid,lessThanIntrlv1NotValid],lessThanIntrlv,'OR');
            pirelab.getBitwiseOpComp(topNet,[nonMultLen,lessThanIntrlv],invalidInpFrame1,'OR');
            pirelab.getBitwiseOpComp(topNet,[invalidInpFrame1,endIn2],invalidInpFrame,'AND');
        end
    end



    maxValid1=topNet.addSignal(controlType,'maxValid1');
    maxValid2=topNet.addSignal(controlType,'maxValid2');
    maxValid=topNet.addSignal(controlType,'maxValid');
    sampleCountMax1=newControlSignal(topNet,'sampleCountMax1',rate);
    sampleCountMax2=newControlSignal(topNet,'sampleCountMax2',rate);
    falseConst=newControlSignal(topNet,'falseConst',rate);
    validInpFrame=newControlSignal(topNet,'validInpFrame',rate);
    notNextFrameLoad=newControlSignal(topNet,'notNextFrameLoad',rate);
    nxtFrameCountRst=newControlSignal(topNet,'nxtFrameCountRst',rate);
    nextFrameEnb=newControlSignal(topNet,'nextFrameEnb',rate);
    pirelab.getUnitDelayComp(topNet,validIn,validInDelay);
    pirelab.getBitwiseOpComp(topNet,validInDelay,notValidInDelay,'NOT');
    pirelab.getCompareToValueComp(topNet,sampleCountVal,sampleCountMax1,'==',k*I-1,'counterEnbComp');
    pirelab.getCompareToValueComp(topNet,sampleCountVal,sampleCountMax2,'==',k*I-2,'counterEnbComp');
    pirelab.getBitwiseOpComp(topNet,[sampleCountMax2,validIn,validInDelay],maxValid1,'AND');
    pirelab.getBitwiseOpComp(topNet,[sampleCountMax1,validIn,notValidInDelay],maxValid2,'AND');
    pirelab.getBitwiseOpComp(topNet,[maxValid1,maxValid2],maxValid,'OR');
    pirelab.getBitwiseOpComp(topNet,[maxValid,endIn],endInOr,'OR');
    inports(1)=startIn;
    inports(2)=endInOr;
    inports(3)=validIn;
    outports(1)=startIn2;
    outports(2)=endIn2;
    outports(3)=validIn2;
    sampleControlNet=this.elabSampleControl(topNet,blockInfo,rate);
    sampleControlNet.addComment('Sample control for valid start and end');
    pirelab.instantiateNetwork(topNet,sampleControlNet,inports,outports,'sampleControlNet_inst');



    trueConst=newControlSignal(topNet,'trueConst',rate);
    nextFrame1=newControlSignal(topNet,'nextFrame1',rate);
    nextFrame2=newControlSignal(topNet,'nextFrame2',rate);
    inpacket=newControlSignal(topNet,'inpacket',rate);
    notinpacket=newControlSignal(topNet,'notinpacket',rate);
    nextFrameEnbDelay=newControlSignal(topNet,'nextFrameEnbDelay',rate);
    pirelab.getConstComp(topNet,oneConstNxtFrame,1);
    pirelab.getBitwiseOpComp(topNet,invalidInpFrame1,validInpFrame,'NOT');
    pirelab.getBitwiseOpComp(topNet,[endIn2,validInpFrame],nextFrameLoad,'AND');
    pirelab.getBitwiseOpComp(topNet,nextFrameLoad,notNextFrameLoad,'NOT');
    pirelab.getBitwiseOpComp(topNet,[startNoNextFrame,notNextFrameLoad],nxtFrameCountRst,'AND');
    pirelab.getCounterComp(topNet,[nxtFrameCountRst,nextFrameLoad,oneConstNxtFrame,nextFrameCountEnb],nextFrameCount,...
    'Count limited',...
    0,...
    1.0,...
    2*corr*I,...
    true,...
    true,...
    true,...
    false,...
    'nextFrameCounter');
    pirelab.getBitwiseOpComp(topNet,[startIn2,invalidInpFrame],nextFrameEnb,'OR');
    pirelab.getUnitDelayComp(topNet,nextFrameEnb,nextFrameEnbDelay);
    pirelab.getUnitDelayEnabledComp(topNet,invalidInpFrame,nextFrame1,nextFrameEnb,'nextFrameReg',true);
    pirelab.getBitwiseOpComp(topNet,inpacket,notinpacket,'NOT');
    pirelab.getSwitchComp(topNet,[notinpacket,falseConst],nextFrame2,nextFrameCountEnb);
    pirelab.getSwitchComp(topNet,[nextFrame2,nextFrame1],nextFrame,nextFrameEnbDelay);
    pirelab.getCompareToValueComp(topNet,nextFrameCount,nextFrameCountEnb,'>',0);



    notendin=newControlSignal(topNet,'notendin',rate);
    notdonepacket=newControlSignal(topNet,'notdonepacket',rate);
    inpacket1=newControlSignal(topNet,'inpacket1',rate);
    inpacketnext=topNet.addSignal(controlType,'inpacketnext');
    pirelab.getBitwiseOpComp(topNet,endIn2Delay,notendin,'NOT');
    pirelab.getBitwiseOpComp(topNet,[notendin,inpacket1],notdonepacket,'AND');
    pirelab.getBitwiseOpComp(topNet,[startIn2Delay,notdonepacket],inpacketnext,'OR');
    pirelab.getUnitDelayComp(topNet,inpacketnext,inpacket1,'inpacket1reg',0.0);
    pirelab.getBitwiseOpComp(topNet,[startIn2Delay,inpacket1],inpacket,'OR');



    for jj=1:numPackets
        for ii=1:2*corr
            for kk=1:I
                parity(ii,kk,jj)=newDataSignal(topNet,sprintf('parity_%d%d%d',ii,kk,jj),pir_ufixpt_t(8,0),rate);
                startData2(ii,kk,jj)=newDataSignal(topNet,sprintf('startData2_%d%d%d',ii,kk,jj),pir_ufixpt_t(8,0),rate);
                paritySlice2(ii)=newDataSignal(topNet,sprintf('paritySlice2_%d',ii),pir_ufixpt_t(8,0),rate);
            end
        end
    end




    packetWrAddr=newDataSignal(topNet,'packetWrAddr',pir_ufixpt_t(max(nextpow2(numPackets),1),0),rate);
    packetAndIntrlvConcat=newDataSignal(topNet,sprintf('packetAndIntrlvConcat'),pir_ufixpt_t(1+max(nextpow2(I),1),0),rate);
    for ii=1:(2^(max(nextpow2(I),1))-I)
        zeroConstConcat(ii)=newDataSignal(topNet,sprintf('zeroConstConcat'),pir_ufixpt_t(8,0),rate);
        pirelab.getConstComp(topNet,zeroConstConcat(ii),0);
    end
    pirelab.getBitConcatComp(topNet,[packetWrAddr,wrIntrlvInd],packetAndIntrlvConcat);
    powerOf2=((2^(max(nextpow2(I),1))-I)==0);
    if(powerOf2)
        for ii=1:2*corr
            pirelab.getMultiPortSwitchComp(topNet,[packetAndIntrlvConcat;parity(ii,:,1)';parity(ii,:,2)'],paritySlice2(ii),1);
        end
    else
        for ii=1:2*corr
            pirelab.getMultiPortSwitchComp(topNet,[packetAndIntrlvConcat;parity(ii,:,1)';zeroConstConcat';parity(ii,:,2)'],paritySlice2(ii),1);
        end
    end



    inputXORed=newDataSignal(topNet,'inputXORed',pir_ufixpt_t(8,0),rate);
    zeroConst=newDataSignal(topNet,'zeroConst',pir_ufixpt_t(8,0),rate);
    startData1=newDataSignal(topNet,'startData1',pir_ufixpt_t(8,0),rate);
    pirelab.getConstComp(topNet,zeroConst,0);
    pirelab.getSwitchComp(topNet,[paritySlice2(1),zeroConst],startData1,startIn2Delay);
    pirelab.getBitwiseOpComp(topNet,[startData1,dataInDelay],inputXORed,'XOR');



    for ii=1:corr
        for jj=1:8
            andOut(ii,jj)=newDataSignal(topNet,sprintf('andOut_%d%d',ii,jj),pir_ufixpt_t(8,0),rate);%#ok<*AGROW> 
            andOutBit(ii,jj)=newDataSignal(topNet,sprintf('andOutBit_%d%d',ii,jj),pir_ufixpt_t(8,0),rate);
            reduceXOR(ii,jj)=newDataSignal(topNet,sprintf('reduceXOR_%d%d',ii,jj),pir_ufixpt_t(1,0),rate);
            reduceXORBit(ii,jj)=newDataSignal(topNet,sprintf('reduceXORBit_%d%d',ii,jj),pir_ufixpt_t(1,0),rate);
            sliceOut(ii,jj)=newDataSignal(topNet,sprintf('sliceOut_%d%d',ii,jj),pir_ufixpt_t(7,0),rate);
            concatOut(ii,jj)=newDataSignal(topNet,sprintf('concatOut_%d%d',ii,jj),pir_ufixpt_t(8,0),rate);
            multOut(ii)=newDataSignal(topNet,sprintf('multOut_%d',ii),pir_ufixpt_t(8,0),rate);
            if(jj==1)
                pirelab.getBitwiseOpComp(topNet,inputXORed,andOut(ii,jj),'AND','andBitMask',true,betaPow8);
                pirelab.getBitReduceComp(topNet,andOut(ii,jj),reduceXOR(ii,jj),'XOR');
                pirelab.getBitSliceComp(topNet,inputXORed,sliceOut(ii,jj),6,0);
                pirelab.getBitConcatComp(topNet,[sliceOut(ii,jj),reduceXOR(ii,jj)],concatOut(ii,jj));
            elseif(jj<8)
                pirelab.getBitwiseOpComp(topNet,concatOut(ii,jj-1),andOut(ii,jj),'AND','andBitMask',true,betaPow8);
                pirelab.getBitReduceComp(topNet,andOut(ii,jj),reduceXOR(ii,jj),'XOR');
                pirelab.getBitSliceComp(topNet,concatOut(ii,jj-1),sliceOut(ii,jj),6,0);
                pirelab.getBitConcatComp(topNet,[sliceOut(ii,jj),reduceXOR(ii,jj)],concatOut(ii,jj));
            end

            if(jj==1)
                pirelab.getBitwiseOpComp(topNet,inputXORed,andOutBit(ii,jj),'AND','andBitMask',true,genPoly(ii));
            else
                pirelab.getBitwiseOpComp(topNet,concatOut(ii,jj-1),andOutBit(ii,jj),'AND','andBitMask',true,genPoly(ii));
            end
            pirelab.getBitReduceComp(topNet,andOutBit(ii,jj),reduceXORBit(ii,jj),'XOR');
        end
        pirelab.getBitConcatComp(topNet,reduceXORBit(ii,:),multOut(ii));
    end



    for ii=1:2*corr
        multOutXORed(ii)=newDataSignal(topNet,sprintf('multOutXORed_%d',ii),pir_ufixpt_t(8,0),rate);
        if(ii<=corr)
            startData3(ii)=newDataSignal(topNet,sprintf('startData3_%d',ii),pir_ufixpt_t(8,0),rate);
            pirelab.getSwitchComp(topNet,[paritySlice2(ii+1),zeroConst],startData3(ii),startIn2Delay);
            pirelab.getBitwiseOpComp(topNet,[startData3(ii),multOut(ii)],multOutXORed(ii),'XOR','multOutXOR');
        elseif(ii==2*corr)
            multOutXORed(ii)=inputXORed;
        else
            startData3(ii)=newDataSignal(topNet,sprintf('startData3_%d',ii),pir_ufixpt_t(8,0),rate);
            pirelab.getSwitchComp(topNet,[paritySlice2(ii+1),zeroConst],startData3(ii),startIn2Delay);
            pirelab.getBitwiseOpComp(topNet,[startData3(ii),multOut(2*corr-ii)],multOutXORed(ii),'XOR','multOutXOR');
        end
    end



    for ii=1:2*corr
        for jj=1:I
            for kk=1:numPackets
                intrlvEnb(jj)=newControlSignal(topNet,sprintf('intrlvEnb_%d',jj),rate);
                packetWrEnb(kk)=newControlSignal(topNet,sprintf('packetWrEnb_%d',kk),rate);
                parityWrEnb(jj,kk)=newControlSignal(topNet,sprintf('parityWrEnb_%d%d',jj,kk),rate);
                parityWrEnb2(jj,kk)=newControlSignal(topNet,sprintf('parityWrEnb2_%d%d',jj,kk),rate);
                parityWrEnb1(jj,kk)=newControlSignal(topNet,sprintf('parityWrEnb1_%d%d',jj,kk),rate);
                notintrlvEnb(jj)=newControlSignal(topNet,sprintf('notPacketWrEnb_%d',jj),rate);
                pirelab.getCompareToValueComp(topNet,wrIntrlvInd,intrlvEnb(jj),'==',jj-1);
                pirelab.getCompareToValueComp(topNet,wrIntrlvInd,notintrlvEnb(jj),'~=',jj-1);
                pirelab.getCompareToValueComp(topNet,packetWrAddr,packetWrEnb(kk),'==',kk-1);
                pirelab.getBitwiseOpComp(topNet,[intrlvEnb(jj),packetWrEnb(kk),validIn2Delay],parityWrEnb1(jj,kk),'AND');
                pirelab.getBitwiseOpComp(topNet,[notintrlvEnb(jj),packetWrEnb(kk),startIn2Delay],parityWrEnb2(jj,kk),'AND');
                pirelab.getBitwiseOpComp(topNet,[parityWrEnb1(jj,kk),parityWrEnb2(jj,kk)],parityWrEnb(jj,kk),'OR');
                pirelab.getSwitchComp(topNet,[multOutXORed(ii),zeroConst],startData2(ii,jj,kk),parityWrEnb2(jj,kk));
                pirelab.getUnitDelayEnabledComp(topNet,startData2(ii,jj,kk),parity(ii,jj,kk),parityWrEnb(jj,kk),0);
            end
        end
    end




    dataReg=newDataSignal(topNet,'dataReg',pir_ufixpt_t(8,0),rate);
    validReg=newControlSignal(topNet,'validReg',rate);
    pirelab.getUnitDelayEnabledComp(topNet,dataInDelay,dataReg,inpacket,sprintf('dataReg'));
    pirelab.getUnitDelayEnabledComp(topNet,validIn2Delay,validReg,inpacket,sprintf('validReg'));



    oneConstkI=newDataSignal(topNet,'oneConstkI',pir_ufixpt_t(nextpow2(k*I+1),0),rate);
    sampleCountRst=newControlSignal(topNet,'inputCountEnb',rate);
    pirelab.getBitwiseOpComp(topNet,[startIn2,endIn2Delay],sampleCountRst,'OR');
    pirelab.getCounterComp(topNet,[sampleCountRst,validIn2Delay],sampleCountVal,...
    'Count limited',...
    0.0,...
    1.0,...
    k*I-1,...
    true,...
    false,...
    true,...
    false,...
    'sampleCounter');
    pirelab.getConstComp(topNet,oneConstkI,1);



    packetRdAddr=newDataSignal(topNet,'packetRdAddr',pir_ufixpt_t(max(nextpow2(numPackets),1),0),rate);
    blockLenVal=newDataSignal(topNet,'blockLenVal',pir_ufixpt_t(nextpow2(n*I+1),0),rate);
    rdPacketInputCountPlus1Val=newDataSignal(topNet,'rdPacketInputCountPlus1Val',pir_ufixpt_t(nextpow2(k*I+1),0),rate);
    parityLengthConstPlus1=newDataSignal(topNet,'parityLengthConstPlus1',pir_ufixpt_t(nextpow2(2*corr*I+1),0),rate);
    for ii=1:numPackets
        inputCountEnb(ii)=newControlSignal(topNet,'inputCountEnb',rate);
        packetRdEnb(ii)=newControlSignal(topNet,'packetRdEnb',rate);
        inputCountRst(ii)=newControlSignal(topNet,'inputCountRst',rate);
        blockLenVec(ii)=newDataSignal(topNet,'blockLenVec',pir_ufixpt_t(nextpow2(n*I+1),0),rate);
        rdPacketInputCountPlus1Vec(ii)=newDataSignal(topNet,'rdPacketInputCountPlus1Vec',pir_ufixpt_t(nextpow2(k*I+1),0),rate);
        pirelab.getAddComp(topNet,[sampleCountVal,parityLengthConstPlus1],blockLenVal);
        pirelab.getAddComp(topNet,[sampleCountVal,oneConstkI],rdPacketInputCountPlus1Val);
        pirelab.getBitwiseOpComp(topNet,[endIn2Delay,packetWrEnb(ii)],inputCountEnb(ii),'AND');
        pirelab.getCompareToValueComp(topNet,packetRdAddr,packetRdEnb(ii),'==',ii-1,'counterEnbComp');
        pirelab.getBitwiseOpComp(topNet,[outputCountRst,packetRdEnb(ii)],inputCountRst(ii),'AND');
        pirelab.getIntDelayEnabledResettableComp(topNet,blockLenVal,blockLenVec(ii),inputCountEnb(ii),inputCountRst(ii),1,'blockLenVec',n*I);
        pirelab.getIntDelayEnabledResettableComp(topNet,rdPacketInputCountPlus1Val,rdPacketInputCountPlus1Vec(ii),inputCountEnb(ii),inputCountRst(ii),1,'rdPacketInputCountPlus1Vec',k*I);
    end



    invalidInpFrameDelay=newControlSignal(topNet,'invalidInpFrameDelay',rate);
    firstStart=newControlSignal(topNet,'firstStart',rate);
    startNextFrameValidFrame2=newControlSignal(topNet,'startNextFrameValidFrame2',rate);
    noStartInvFrameInvert=newControlSignal(topNet,'noStartInvFrameInvert',rate);
    notFirstStart=newControlSignal(topNet,'notFirstStart',rate);
    firstStartEnb=newControlSignal(topNet,'firstStartEnb',rate);
    startNextFrame=newControlSignal(topNet,'startNextFrame',rate);

    pirelab.getUnitDelayEnabledComp(topNet,falseConst,firstStart,firstStartEnb,'firstStartReg',true);
    pirelab.getBitwiseOpComp(topNet,firstStart,notFirstStart,'NOT');
    pirelab.getBitwiseOpComp(topNet,[firstStart,startIn2],firstStartEnb,'AND');
    pirelab.getUnitDelayComp(topNet,invalidInpFrame,invalidInpFrameDelay);

    pirelab.getBitwiseOpComp(topNet,[startIn2,nextFrame],startNextFrame,'AND');
    pirelab.getBitwiseOpComp(topNet,[startNextFrame,notFirstStart],startNextFrameValidFrame2,'AND');

    pirelab.getBitwiseOpComp(topNet,invalidInpFrameDelay,noStartInvFrameInvert,'NOT');

    pirelab.getBitwiseOpComp(topNet,[startNextFrameValidFrame2,invalidInpFrameDelay],packetWrAddrEnb,'XOR');
    pirelab.getCounterComp(topNet,[packetWrAddrEnb,noStartInvFrameInvert],packetWrAddr,...
    'Count limited',...
    0.0,...
    1,...
    numPackets-1,...
    false,...
    false,...
    true,...
    true,...
    'packetWrAddrCounter');




    rdIntrlvInd=newDataSignal(topNet,'rdIntrlvInd',pir_ufixpt_t(max(nextpow2(I),1),0),rate);
    parityCount=newDataSignal(topNet,'parityCount',pir_ufixpt_t(nextpow2(2*corr+1),0),rate);
    rdIntrlvIndEqualI_1=newControlSignal(topNet,'rdIntrlvIndEqualI_1',rate);
    outputCountGrtMsg=newControlSignal(topNet,'outputCountGrtMsg',rate);
    parityCountEnb=newControlSignal(topNet,'parityCountEnb',rate);
    rdIntrlvRst=newControlSignal(topNet,'rdIntrlvRst',rate);
    outputCount=newDataSignal(topNet,'outputCount',pir_ufixpt_t(nextpow2(n*I+1),0),rate);
    outputCountGrt0=newControlSignal(topNet,'outputCountGrt0',rate);
    outputCountEqualMsg=newControlSignal(topNet,'outputCountEqualMsg',rate);
    outputCountEqualMsgValid=newControlSignal(topNet,'outputCountEqualMsgValid',rate);
    outputCountLessMsg=newControlSignal(topNet,'outputCountLessMsg',rate);
    pirelab.getCompareToValueComp(topNet,outputCount,outputCountGrt0,'>',0);
    pirelab.getBitwiseOpComp(topNet,[outputCountEqualMsg,validReg],outputCountEqualMsgValid,'AND');
    pirelab.getCompareToValueComp(topNet,rdIntrlvInd,rdIntrlvIndEqualI_1,'==',I-1);
    pirelab.getBitwiseOpComp(topNet,[outputCountGrtMsg,outputCountGrt0,rdIntrlvIndEqualI_1],parityCountEnb,'AND');
    parityCountRst=rdIntrlvRst;
    pirelab.getCounterComp(topNet,[parityCountRst,parityCountEnb],parityCount,...
    'Count limited',...
    0.0,...
    1,...
    2*corr-1,...
    true,...
    false,...
    true,...
    false,...
    'parityCounter');
    parityOut=newDataSignal(topNet,'parityOut',pir_ufixpt_t(8,0),rate);
    for ii=1:numPackets
        for jj=1:I
            parityOut2(jj,ii)=newDataSignal(topNet,sprintf('parityOut2_%d%d',jj,ii),pir_ufixpt_t(8,0),rate);
            parityOut1(ii)=newDataSignal(topNet,sprintf('parityOut1_%d',ii),pir_ufixpt_t(8,0),rate);
            pirelab.getMultiPortSwitchComp(topNet,[parityCount;parity(:,jj,ii)],parityOut2(jj,ii),1);
        end
    end
    for jj=1:numPackets
        pirelab.getMultiPortSwitchComp(topNet,[rdIntrlvInd;parityOut2(:,jj)],parityOut1(jj),1);
    end
    pirelab.getMultiPortSwitchComp(topNet,[packetRdAddr,parityOut1],parityOut,1);



    dataOut2=newDataSignal(topNet,'dataOut2',pir_ufixpt_t(8,0),rate);
    validOut2=newControlSignal(topNet,'validOut2',rate);
    outputCountGrtCodeLen=newControlSignal(topNet,'outputCountGrtCodeLen',rate);
    outputCountEqual0=newControlSignal(topNet,'outputCountEqual0',rate);
    validOutputCount1=newControlSignal(topNet,'validOutputCount1',rate);
    validOutputCount=newControlSignal(topNet,'validOutputCount',rate);
    outputCountEqual1=newControlSignal(topNet,'outputCountEqual1',rate);
    startOutAdv=newControlSignal(topNet,'startOutAdv',rate);
    validOutAdv=newControlSignal(topNet,'validOutAdv',rate);
    endOutAdv=newControlSignal(topNet,'endOutAdv',rate);
    outputRst=newControlSignal(topNet,'outputRst',rate);
    dataOutAdv=newDataSignal(topNet,'dataOutAdv',pir_ufixpt_t(8,0),rate);
    pirelab.getConstComp(topNet,falseConst,false);
    pirelab.getSwitchComp(topNet,[parityOut,dataReg],dataOut2,outputCountLessMsg);
    pirelab.getSwitchComp(topNet,[trueConst,validReg],validOut2,outputCountLessMsg);
    pirelab.getBitwiseOpComp(topNet,[outputCountGrtCodeLen,outputCountEqual0],validOutputCount1,'NOR');
    pirelab.getBitwiseOpComp(topNet,[validOutputCount1,validOut2],validOutputCount,'AND');
    pirelab.getSwitchComp(topNet,[zeroConst,dataOut2],dataOutAdv,validOutputCount);
    pirelab.getSwitchComp(topNet,[falseConst,validOut2],validOutAdv,validOutputCount);
    pirelab.getBitwiseOpComp(topNet,[outputCountEqual1,validReg],startOutAdv,'AND');



    pirelab.getBitwiseOpComp(topNet,[invalidInpFrame,startNoNextFrame],outputRst,'OR');
    pirelab.getIntDelayEnabledResettableComp(topNet,dataOutAdv,dataOut,trueConst,outputRst,1);
    pirelab.getIntDelayEnabledResettableComp(topNet,startOutAdv,startOut,trueConst,outputRst,1);
    pirelab.getIntDelayEnabledResettableComp(topNet,validOutAdv,validOut,trueConst,outputRst,1);
    pirelab.getIntDelayEnabledResettableComp(topNet,endOutAdv,endOut,trueConst,outputRst,1);



    rdPacketInputCountPlus1=newDataSignal(topNet,'rdPacketInputCountPlus1',pir_ufixpt_t(nextpow2(n*I+1),0),rate);
    blockLen=newDataSignal(topNet,'blockLen',pir_ufixpt_t(nextpow2(n*I+1),0),rate);
    outputCountLessCodeLen=newControlSignal(topNet,'outputCountLessCodeLen',rate);
    notoutputCountLessMsg=newControlSignal(topNet,'notoutputCountLessMsg',rate);
    outputCountEqualCodeLen=newControlSignal(topNet,'outputCountEqualCodeLen',rate);
    outputCountEnb1=newControlSignal(topNet,'outputCountEnb1',rate);
    outputCountEnb2=newControlSignal(topNet,'outputCountEnb2',rate);
    outputCountEnb=newControlSignal(topNet,'outputCountEnb',rate);
    outputCountLoad=newControlSignal(topNet,'outputCountLoad',rate);
    notOutputCountLoad=newControlSignal(topNet,'notOutputCountLoad',rate);
    outputCountLoadRst=newControlSignal(topNet,'outputCountLoadRst',rate);
    outputCountRst1=newControlSignal(topNet,'outputCountRst1',rate);
    outputCountRst2=newControlSignal(topNet,'outputCountRst2',rate);
    loadValue=newDataSignal(topNet,'loadValue',pir_ufixpt_t(nextpow2(n*I+1),0),rate);
    pirelab.getMultiPortSwitchComp(topNet,[packetRdAddr,blockLenVec],blockLen,1);
    pirelab.getMultiPortSwitchComp(topNet,[packetRdAddr,rdPacketInputCountPlus1Vec],rdPacketInputCountPlus1,1);
    pirelab.getConstComp(topNet,parityLengthConstPlus1,2*corr*I+1);
    pirelab.getRelOpComp(topNet,[outputCount,rdPacketInputCountPlus1],outputCountLessMsg,'<=');
    pirelab.getRelOpComp(topNet,[outputCount,rdPacketInputCountPlus1],outputCountEqualMsg,'==');
    pirelab.getRelOpComp(topNet,[outputCount,blockLen],outputCountLessCodeLen,'<=');
    pirelab.getRelOpComp(topNet,[outputCount,blockLen],outputCountGrtCodeLen,'>');
    pirelab.getRelOpComp(topNet,[outputCount,blockLen],outputCountEqualCodeLen,'==');
    pirelab.getRelOpComp(topNet,[outputCount,blockLen],endOutAdv,'==');
    pirelab.getCompareToValueComp(topNet,outputCount,outputCountEqual0,'==',0);
    pirelab.getCompareToValueComp(topNet,outputCount,outputCountEqual1,'==',1);
    pirelab.getBitwiseOpComp(topNet,outputCountLessMsg,notoutputCountLessMsg,'NOT');
    pirelab.getBitwiseOpComp(topNet,[outputCountLessCodeLen,notoutputCountLessMsg],outputCountGrtMsg,'AND');
    pirelab.getBitwiseOpComp(topNet,[outputCountLessMsg,validReg],outputCountEnb1,'AND');
    pirelab.getBitwiseOpComp(topNet,[outputCountEnb1,outputCountGrtMsg],outputCountEnb2,'OR');
    pirelab.getBitwiseOpComp(topNet,[outputCountEnb2,outputCountGrt0],outputCountEnb,'AND');
    pirelab.getConstComp(topNet,trueConst,true);
    pirelab.getConstComp(topNet,loadValue,1);
    pirelab.getBitwiseOpComp(topNet,[startIn2,invalidInpFrame],outputCountLoadRst,'OR');
    pirelab.getSwitchComp(topNet,[startIn2Delay,falseConst],outputCountLoad,outputCountLoadRst);
    pirelab.getBitwiseOpComp(topNet,outputCountLoad,notOutputCountLoad,'NOT');
    pirelab.getBitwiseOpComp(topNet,[outputCountEqualCodeLen,startNoNextFrameDelay,invalidInpFrameDelay],outputCountRst,'OR');
    pirelab.getBitwiseOpComp(topNet,[outputCountEqualCodeLen,notOutputCountLoad],outputCountRst2,'AND');
    pirelab.getBitwiseOpComp(topNet,[outputCountRst2,startNoNextFrame,invalidInpFrame],outputCountRst1,'OR');
    pirelab.getCounterComp(topNet,[outputCountRst1,outputCountLoad,loadValue,outputCountEnb],outputCount,...
    'Count limited',...
    0,...
    1,...
    n*I,...
    true,...
    true,...
    true,...
    false,...
    'outputCounter');



    pirelab.getBitwiseOpComp(topNet,[outputCountEqualMsgValid,startNoNextFrame,invalidInpFrame],rdIntrlvRst,'OR');
    rdIntrlvEnb=outputCountGrtMsg;
    if(I==1)
        pirelab.getConstComp(topNet,rdIntrlvInd,0);
    else
        pirelab.getCounterComp(topNet,[rdIntrlvRst,rdIntrlvEnb],rdIntrlvInd,...
        'Count limited',...
        0.0,...
        1,...
        I-1,...
        true,...
        false,...
        true,...
        false,...
        'rdIntrlvIndCounter');
    end



    packetRdAddrEnb=outputCountEqualCodeLen;
    pirelab.getCounterComp(topNet,packetRdAddrEnb,packetRdAddr,...
    'Count limited',...
    0.0,...
    1,...
    numPackets-1,...
    false,...
    false,...
    true,...
    false,...
    'packetRdAddrCounter');


end



function signal=newControlSignal(topNet,name,rate)
    controlType=pir_ufixpt_t(1,0);
    signal=topNet.addSignal(controlType,name);
    signal.SimulinkRate=rate;
end

function signal=newDataSignal(topNet,name,inType,rate)
    signal=topNet.addSignal(inType,name);
    signal.SimulinkRate=rate;
end
