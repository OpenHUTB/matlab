function[net,finalDelay]=elabFramePipe(this,topNet,blockInfo,sectionNum)




    inportNames={'dataIn','validIn'};
    outportNames={'dataOut','validOut'};

    ctrlType=pir_boolean_t();


    outputType=topNet.getType('FixedPoint','Signed',blockInfo.sectionTypeSign,...
    'WordLength',blockInfo.sectionTypeWL,...
    'FractionLength',blockInfo.sectionTypeFL);
    outputVecType=pirelab.getPirVectorType(outputType,[blockInfo.FrameSize,1]);

    inputType=topNet.getType('FixedPoint','Signed',blockInfo.sectionTypeSign,...
    'WordLength',blockInfo.sectionTypeWL,...
    'FractionLength',blockInfo.sectionTypeFL);
    inputVecType=pirelab.getPirVectorType(inputType,[blockInfo.FrameSize,1]);


    net=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name',sprintf('BiquadFramePipeSection%d',sectionNum),...
    'InportNames',inportNames,...
    'InportTypes',[inputVecType,ctrlType],...
    'InportRates',repmat(blockInfo.inRate,1,2),...
    'OutportNames',outportNames,...
    'OutportTypes',[outputVecType,ctrlType]...
    );





    dataIn=net.PirInputSignals(1);
    validIn=net.PirInputSignals(2);
    dataRate=blockInfo.inRate;

    dataOut=net.PirOutputSignals(1);
    validOut=net.PirOutputSignals(2);
    dataOut.SimulinkRate=dataRate;
    validOut.SimulinkRate=dataRate;

    outputTypeWL=blockInfo.sectionTypeWL;
    outputTypeFL=blockInfo.sectionTypeFL;


    denCoeffWL=blockInfo.denCoeffWL;
    denCoeffFL=blockInfo.denCoeffFL;

    denProdType=net.getType('FixedPoint','Signed',true,...
    'WordLength',outputTypeWL+denCoeffWL,...
    'FractionLength',outputTypeFL+denCoeffFL);

    state1Type=net.getType('FixedPoint','Signed',true,...
    'WordLength',denProdType.WordLength+1,...
    'FractionLength',denProdType.FractionLength);
    state2Type=net.getType('FixedPoint','Signed',true,...
    'WordLength',denProdType.WordLength,...
    'FractionLength',denProdType.FractionLength);

    inReg=net.addSignal(inputVecType,'inReg');
    inReg.SimulinkRate=dataRate;
    inValidReg=net.addSignal(ctrlType,'inValidReg');
    inValidReg.SimulinkRate=dataRate;

    delayvalidout=net.addSignal(ctrlType,'delayvalidout');
    prevalidout.SimulinkRate=dataRate;

    prevalidout=net.addSignal(ctrlType,'prevalidout');
    prevalidout.SimulinkRate=dataRate;
    preout=net.addSignal(outputType,'preout');
    preout.SimulinkRate=dataRate;

    numvalidout=net.addSignal(ctrlType,'numvalidout');
    numvalidout.SimulinkRate=dataRate;

    numDelayLineVecType=pirelab.getPirVectorType(inputType,[blockInfo.FrameSize,1]);

    num1Delay=net.addSignal(numDelayLineVecType,'num1Delay');
    num1Delay.SimulinkRate=dataRate;
    num2Delay=net.addSignal(numDelayLineVecType,'num2Delay');
    num2Delay.SimulinkRate=dataRate;




    state1a=net.addSignal(state1Type,'state1a');
    state2a=net.addSignal(state2Type,'state2a');
    state1a.SimulinkRate=dataRate;
    state2a.SimulinkRate=dataRate;
    state1b=net.addSignal(state1Type,'state1b');
    state2b=net.addSignal(state2Type,'state2b');
    state1b.SimulinkRate=dataRate;
    state2b.SimulinkRate=dataRate;

    den1InPipe1a=net.addSignal(outputType,'den1InPipe1a');
    den1InPipe1a.SimulinkRate=dataRate;
    den1InPipe2a=net.addSignal(outputType,'den1InPipe2a');
    den1InPipe2a.SimulinkRate=dataRate;
    den1OutPipe1a=net.addSignal(denProdType,'den1OutPipe1a');
    den1OutPipe1a.SimulinkRate=dataRate;

    den1InPipe1b=net.addSignal(outputType,'den1InPipe1b');
    den1InPipe1b.SimulinkRate=dataRate;
    den1InPipe2b=net.addSignal(outputType,'den1InPipe2b');
    den1InPipe2b.SimulinkRate=dataRate;
    den1OutPipe1b=net.addSignal(denProdType,'den1OutPipe1b');
    den1OutPipe1b.SimulinkRate=dataRate;

    denOutDelaya=net.addSignal(outputType,'denOutDelaya');
    denOutDelaya.SimulinkRate=dataRate;

    denOutDelayb=net.addSignal(outputType,'denOutDelayb');
    denOutDelayb.SimulinkRate=dataRate;

    den2InPipe1a=net.addSignal(outputType,'den2InPipe1a');
    den2InPipe1a.SimulinkRate=dataRate;
    den2InPipe2a=net.addSignal(outputType,'den2InPipe2a');
    den2InPipe2a.SimulinkRate=dataRate;
    den2OutPipe1a=net.addSignal(denProdType,'den2OutPipe1a');
    den2OutPipe1a.SimulinkRate=dataRate;

    den2InPipe1b=net.addSignal(outputType,'den2InPipe1b');
    den2InPipe1b.SimulinkRate=dataRate;
    den2InPipe2b=net.addSignal(outputType,'den2InPipe2b');
    den2InPipe2b.SimulinkRate=dataRate;
    den2OutPipe1b=net.addSignal(denProdType,'den2OutPipe1b');
    den2OutPipe1b.SimulinkRate=dataRate;

    denProd1a=net.addSignal(denProdType,'denProd1a');
    denProd2a=net.addSignal(denProdType,'denProd2a');
    denProd1b=net.addSignal(denProdType,'denProd1b');
    denProd2b=net.addSignal(denProdType,'denProd2b');

    denOuta=net.addSignal(outputType,'denOuta');
    denOuta.SimulinkRate=dataRate;
    denOutb=net.addSignal(outputType,'denOutb');
    denOutb.SimulinkRate=dataRate;

    denOutareg=net.addSignal(outputType,'denOutareg');
    denOutareg.SimulinkRate=dataRate;
    denOutbreg=net.addSignal(outputType,'denOutbreg');
    denOutbreg.SimulinkRate=dataRate;

    denOutPreviousb=net.addSignal(outputType,'denOutPreviousb');
    denOutPreviousb.SimulinkRate=dataRate;
    denOutPrevious2b=net.addSignal(outputType,'denOutPrevious2b');
    denOutPrevious2b.SimulinkRate=dataRate;

    denOutVec=net.addSignal(outputVecType,'denOutVec');
    denOutVec.SimulinkRate=dataRate;




    pirelab.getUnitDelayEnabledComp(net,dataIn,inReg,validIn,'InRegister');
    pirelab.getUnitDelayComp(net,validIn,inValidReg,'InValidRegister');
    finalDelay=1;


    pirelab.getUnitDelayEnabledComp(net,inReg,num1Delay,inValidReg,'NumDelayRegA');
    pirelab.getUnitDelayEnabledComp(net,num1Delay,num2Delay,inValidReg,'NumDelayRegB');
    comboNum=[num2Delay.split.PirOutputSignals;...
    num1Delay.split.PirOutputSignals;...
    inReg.split.PirOutputSignals];

    for ii=1:blockInfo.FrameSize
        for jj=1:3
            tapName=sprintf('Num%d_%d',ii,jj);
            tapInput=comboNum(blockInfo.FrameSize-1+ii+(3-jj)-1);
            numGain(jj)=this.elabPipeGain(net,blockInfo,...
            cast(blockInfo.PipeNumerator(sectionNum,jj),'like',blockInfo.numCoeffs),...
            tapInput,inValidReg,tapName);
        end


        newSumTypeL1=net.getType('FixedPoint','Signed',true,...
        'WordLength',numGain(1).Type.WordLength+1,...
        'FractionLength',numGain(1).Type.FractionLength);
        newSumTypeL2=net.getType('FixedPoint','Signed',true,...
        'WordLength',numGain(1).Type.WordLength+1,...
        'FractionLength',numGain(1).Type.FractionLength);
        sumL1V1=net.addSignal(newSumTypeL1,sprintf('numsum%d_L1V1',ii));
        sumL1V2=net.addSignal(newSumTypeL1,sprintf('numsum%d_L1V2',ii));
        sumL2V1=net.addSignal(newSumTypeL2,sprintf('numsum%d_L2V1',ii));
        sumL1V1.SimulinkRate=dataRate;
        sumL1V2.SimulinkRate=dataRate;
        sumL2V1.SimulinkRate=dataRate;

        sumregL1V1=net.addSignal(newSumTypeL1,sprintf('numsumreg%d_L1V1',ii));
        sumregL1V2=net.addSignal(newSumTypeL1,sprintf('numsumreg%d_L1V2',ii));
        sumregL2V1=net.addSignal(newSumTypeL2,sprintf('numsumreg%d_L2V1',ii));
        sumregL1V1.SimulinkRate=dataRate;
        sumregL1V2.SimulinkRate=dataRate;
        sumregL2V1.SimulinkRate=dataRate;

        pirelab.getAddComp(net,[numGain(1),numGain(2)],sumL1V1);
        pirelab.getDTCComp(net,numGain(3),sumL1V2,'Floor','Wrap');
        pirelab.getUnitDelayEnabledComp(net,sumL1V1,sumregL1V1,inValidReg,sprintf('sum%d_L1V1Reg',ii));
        pirelab.getUnitDelayEnabledComp(net,sumL1V2,sumregL1V2,inValidReg,sprintf('sum%d_L1V2Reg',ii));
        pirelab.getAddComp(net,[sumL1V1,sumL1V2],sumL2V1);
        pirelab.getUnitDelayEnabledComp(net,sumL2V1,sumregL2V1,inValidReg,sprintf('sum%d_L2V1Reg',ii));
        numout(ii)=sumregL2V1;%#ok

    end

    numVecType=pirelab.getPirVectorType(newSumTypeL2,[blockInfo.FrameSize,1]);
    numoutvect=net.addSignal(numVecType,'numoutvect');

    pirelab.getMuxComp(net,numout,numoutvect);



    quantizedNewNumerator=fi(blockInfo.PipeNewNumerator,1,blockInfo.denCoeffs.WordLength);
    [tempnewnumout,~,newnumdelay]=this.elabInlineFIR(net,blockInfo,...
    quantizedNewNumerator(sectionNum,:),...
    numoutvect,inValidReg,sprintf('NumZero%d',sectionNum));

    finalDelay=finalDelay+newnumdelay;
    newnumhighdelay1=net.addSignal(tempnewnumout(1).Type,'newnumhighdelay');
    pirelab.getUnitDelayEnabledComp(net,tempnewnumout(1),newnumhighdelay1,inValidReg,'delhigh1');
    newnumlowdelay1=tempnewnumout(2);


    newnumout(1)=newnumhighdelay1;
    newnumout(blockInfo.FrameSize)=newnumlowdelay1;
    for ii=2:blockInfo.FrameSize-1
        balancePreData=net.addSignal(newSumTypeL2,sprintf('balancePre%dnewnum',ii));
        balanceData=net.addSignal(newSumTypeL2,sprintf('balance%dnewnum',ii));
        pirelab.getIntDelayEnabledComp(net,numout(ii),balancePreData,inValidReg,newnumdelay,sprintf('balpredelay%d',ii));
        pirelab.getUnitDelayEnabledComp(net,balancePreData,balanceData,inValidReg,sprintf('baldelay%d',ii));
        newnumout(ii)=balanceData;
    end


    newNumType=newnumout(1).Type;
    newNumIntBits=newNumType.WordLength+newNumType.FractionLength;
    state1IntBits=state1Type.WordLength+state1Type.FractionLength;
    denSum1FL=min(state1Type.FractionLength,newNumType.FractionLength);
    denSum1WL=max(newNumIntBits,state1IntBits)-denSum1FL;

    denSum1Type=net.getType('FixedPoint','Signed',true,...
    'WordLength',denSum1WL,...
    'FractionLength',denSum1FL);
    denSum2Type=net.getType('FixedPoint','Signed',true,...
    'WordLength',state2Type.WordLength+1,...
    'FractionLength',state2Type.FractionLength);
    denSum1a=net.addSignal(denSum1Type,'denSum1a');
    denSum1a.SimulinkRate=dataRate;
    denSum2a=net.addSignal(denSum2Type,'denSum2a');
    denSum2a.SimulinkRate=dataRate;

    denSum1b=net.addSignal(denSum1Type,'denSum1b');
    denSum1b.SimulinkRate=dataRate;
    denSum2b=net.addSignal(denSum2Type,'denSum2b');
    denSum2b.SimulinkRate=dataRate;

    pirelab.getUnitDelayEnabledComp(net,denSum2a,state1a,inValidReg,'State1AReg');
    pirelab.getUnitDelayEnabledComp(net,den2OutPipe1a,state2a,inValidReg,'State2AReg');
    pirelab.getUnitDelayEnabledComp(net,denSum2b,state1b,inValidReg,'State1BReg');
    pirelab.getUnitDelayEnabledComp(net,den2OutPipe1b,state2b,inValidReg,'State2BReg');



    denFrameProdWL=outputTypeWL+denCoeffWL;
    denFrameProdFL=outputTypeFL+blockInfo.denCoeffOrigFL;
    denFrameProdType=net.getType('FixedPoint','Signed',true,...
    'WordLength',denFrameProdWL,...
    'FractionLength',denFrameProdFL);
    denFrameProdIntBits=denFrameProdWL+denFrameProdFL;
    newnumIntBits=newNumType.WordLength+newNumType.FractionLength;
    denFrameSumWordLength=max(denFrameProdIntBits,newnumIntBits)-min(denFrameProdFL,newNumType.FractionLength);
    denFrameSumFractionLength=min(denFrameProdFL,newNumType.FractionLength);
    denFrameSumType=net.getType('FixedPoint','Signed',true,...
    'WordLength',denFrameSumWordLength,...
    'FractionLength',denFrameSumFractionLength);

    for ii=2:blockInfo.FrameSize-1
        denFrameSum1(ii)=net.addSignal(denFrameSumType,sprintf('den%dSum1',ii));%#ok
        denFrameSum1(ii).SimulinkRate=dataRate;%#ok
        denFrameSum2(ii)=net.addSignal(denFrameSumType,sprintf('den%dSum2',ii));%#ok
        denFrameSum2(ii).SimulinkRate=dataRate;%#ok

        denFrame1InPipe1(ii)=net.addSignal(outputType,sprintf('den%d1InPipe1',ii));%#ok
        denFrame1InPipe1(ii).SimulinkRate=dataRate;%#ok
        denFrame1InPipe2(ii)=net.addSignal(outputType,sprintf('den%d1InPipe2',ii));%#ok
        denFrame1InPipe2(ii).SimulinkRate=dataRate;%#ok

        denFrame1OutPipe1(ii)=net.addSignal(denFrameProdType,sprintf('den%d1OutPipe1',ii));%#ok
        denFrame1OutPipe1(ii).SimulinkRate=dataRate;%#ok
        denFrame1OutPipe2(ii)=net.addSignal(denFrameProdType,sprintf('den%d1OutPipe2',ii));%#ok
        denFrame1OutPipe2(ii).SimulinkRate=dataRate;%#ok

        denFrame2InPipe1(ii)=net.addSignal(outputType,sprintf('den%d2InPipe1',ii));%#ok
        denFrame2InPipe1(ii).SimulinkRate=dataRate;%#ok
        denFrame2InPipe2(ii)=net.addSignal(outputType,sprintf('den%d2InPipe2',ii));%#ok
        denFrame2InPipe2(ii).SimulinkRate=dataRate;%#ok

        denFrame2OutPipe1(ii)=net.addSignal(denFrameProdType,sprintf('den%d2OutPipe1',ii));%#ok
        denFrame2OutPipe1(ii).SimulinkRate=dataRate;%#ok
        denFrame2OutPipe2(ii)=net.addSignal(denFrameProdType,sprintf('den%d2OutPipe2',ii));%#ok
        denFrame2OutPipe2(ii).SimulinkRate=dataRate;%#ok

        denFrameProd1(ii)=net.addSignal(denFrameProdType,sprintf('den%dProd1',ii));%#ok
        denFrameProd2(ii)=net.addSignal(denFrameProdType,sprintf('den%dProd2',ii));%#ok

        denFrameOut(ii)=net.addSignal(outputType,sprintf('den%dOutDelay',ii));%#ok
        denFrameOut(ii).SimulinkRate=dataRate;%#ok
        denFrameOutDelay(ii)=net.addSignal(outputType,sprintf('den%dOutDelay',ii));%#ok
        denFrameOutDelay(ii).SimulinkRate=dataRate;%#ok
    end

    pirelab.getAddComp(net,[newnumout(1),state1a],denSum1a);
    pirelab.getAddComp(net,[den1OutPipe1a,state2a],denSum2a);
    pirelab.getAddComp(net,[newnumout(end),state1b],denSum1b);
    pirelab.getAddComp(net,[den1OutPipe1b,state2b],denSum2b);

    pirelab.getDTCComp(net,denSum1a,denOuta,...
    blockInfo.RoundingMethod,blockInfo.OverflowAction);
    pirelab.getDTCComp(net,denSum1b,denOutb,...
    blockInfo.RoundingMethod,blockInfo.OverflowAction);


    combinedSize=blockInfo.PipeLevel*blockInfo.FrameSize;

    pirelab.getUnitDelayEnabledComp(net,denOuta,den1InPipe1a,inValidReg,'den1InPipeReg1a');
    pirelab.getUnitDelayEnabledComp(net,den1InPipe1a,den1InPipe2a,inValidReg,'den1InPipeReg2a');
    pirelab.getUnitDelayEnabledComp(net,denOutb,den1InPipe1b,inValidReg,'den1InPipeReg1b');
    pirelab.getUnitDelayEnabledComp(net,den1InPipe1b,den1InPipe2b,inValidReg,'den1InPipeReg2b');

    pirelab.getGainComp(net,den1InPipe2a,denProd1a,...
    fi(-blockInfo.PipeDenominator(sectionNum,combinedSize+1),1,denCoeffWL,-denCoeffFL),...
    blockInfo.gainMode,blockInfo.gainOptimMode);
    pirelab.getGainComp(net,den1InPipe2b,denProd1b,...
    fi(-blockInfo.PipeDenominator(sectionNum,combinedSize+1),1,denCoeffWL,-denCoeffFL),...
    blockInfo.gainMode,blockInfo.gainOptimMode);

    pirelab.getUnitDelayEnabledComp(net,denProd1a,den1OutPipe1a,inValidReg,'den1OutPipeReg1a');
    pirelab.getUnitDelayEnabledComp(net,denProd1b,den1OutPipe1b,inValidReg,'den1OutPipeReg1b');

    pirelab.getIntDelayEnabledComp(net,denOuta,denOutDelaya,inValidReg,3,'den2DelayRega');
    pirelab.getUnitDelayEnabledComp(net,denOutDelaya,den2InPipe1a,inValidReg,'den2InPipeReg1a');
    pirelab.getUnitDelayEnabledComp(net,den2InPipe1a,den2InPipe2a,inValidReg,'den2InPipeReg2a');
    pirelab.getIntDelayEnabledComp(net,denOutb,denOutDelayb,inValidReg,3,'den2DelayRegb');
    pirelab.getUnitDelayEnabledComp(net,denOutDelayb,den2InPipe1b,inValidReg,'den2InPipeReg1b');
    pirelab.getUnitDelayEnabledComp(net,den2InPipe1b,den2InPipe2b,inValidReg,'den2InPipeReg2b');

    pirelab.getGainComp(net,den2InPipe2a,denProd2a,...
    fi(-blockInfo.PipeDenominator(sectionNum,2*combinedSize+1),1,denCoeffWL,-denCoeffFL),...
    blockInfo.gainMode,blockInfo.gainOptimMode);
    pirelab.getGainComp(net,den2InPipe2b,denProd2b,...
    fi(-blockInfo.PipeDenominator(sectionNum,2*combinedSize+1),1,denCoeffWL,-denCoeffFL),...
    blockInfo.gainMode,blockInfo.gainOptimMode);

    pirelab.getUnitDelayEnabledComp(net,denProd2a,den2OutPipe1a,inValidReg,'den2OutPipeReg1a');
    pirelab.getUnitDelayEnabledComp(net,denProd2b,den2OutPipe1b,inValidReg,'den2OutPipeReg1b');

    pirelab.getUnitDelayEnabledComp(net,denOuta,denOutareg,inValidReg,'denOutRega');
    pirelab.getUnitDelayEnabledComp(net,denOutb,denOutbreg,inValidReg,'denOutRegb');

    pirelab.getUnitDelayEnabledComp(net,denOutb,denOutPreviousb,inValidReg,'denOutPrevRegb');
    pirelab.getUnitDelayEnabledComp(net,denOutPreviousb,denOutPrevious2b,inValidReg,'denOutPrev2Regb');


    finalDelay=finalDelay+4*(blockInfo.FrameSize)+2;
    previousInput=denOuta;
    previous2Input=denOutPreviousb;
    for ii=2:blockInfo.FrameSize-1
        if ii>2
            denInputSignal=net.addSignal(newnumout(ii).Type,sprintf('den%dInputDelay',ii));
            denInputSignal.SimulinkRate=dataRate;
            pirelab.getIntDelayEnabledComp(net,newnumout(ii),denInputSignal,inValidReg,(ii-1)*4,sprintf('denInput%dreg',ii));
            newnumSignal=denInputSignal;
        else
            denInputSignal=net.addSignal(newnumout(ii).Type,sprintf('den%dInputDelay',ii));
            denInputSignal.SimulinkRate=dataRate;
            pirelab.getIntDelayEnabledComp(net,newnumout(ii),denInputSignal,inValidReg,4,sprintf('denInput%dreg',ii));
            newnumSignal=denInputSignal;
        end
        pirelab.getUnitDelayEnabledComp(net,previousInput,denFrame1InPipe1(ii),inValidReg,sprintf('den1F%dInPipeReg1',ii));
        pirelab.getUnitDelayEnabledComp(net,denFrame1InPipe1(ii),denFrame1InPipe2(ii),inValidReg,sprintf('den1F%dInPipeReg2',ii));
        pirelab.getGainComp(net,denFrame1InPipe2(ii),denFrameProd1(ii),...
        fi(-blockInfo.Denominator(sectionNum,2),1,denCoeffWL,-blockInfo.denCoeffOrigFL),...
        blockInfo.gainMode,blockInfo.gainOptimMode);
        pirelab.getUnitDelayEnabledComp(net,denFrameProd1(ii),denFrame1OutPipe1(ii),inValidReg,sprintf('den1F%dOutPipeReg1',ii));
        pirelab.getUnitDelayEnabledComp(net,denFrame1OutPipe1(ii),denFrame1OutPipe2(ii),inValidReg,sprintf('den1F%dOutPipeReg2',ii));

        pirelab.getUnitDelayEnabledComp(net,previous2Input,denFrame2InPipe1(ii),inValidReg,sprintf('den2F%dInPipeReg1',ii));
        pirelab.getUnitDelayEnabledComp(net,denFrame2InPipe1(ii),denFrame2InPipe2(ii),inValidReg,sprintf('den2F%dInPipeReg2',ii));
        pirelab.getGainComp(net,denFrame2InPipe2(ii),denFrameProd2(ii),...
        fi(-blockInfo.Denominator(sectionNum,3),1,denCoeffWL,-blockInfo.denCoeffOrigFL),...
        blockInfo.gainMode,blockInfo.gainOptimMode);
        pirelab.getUnitDelayEnabledComp(net,denFrameProd2(ii),denFrame2OutPipe1(ii),inValidReg,sprintf('den2F%dOutPipeReg1',ii));
        pirelab.getUnitDelayEnabledComp(net,denFrame2OutPipe1(ii),denFrame2OutPipe2(ii),inValidReg,sprintf('den2F%dOutPipeReg2',ii));

        pirelab.getAddComp(net,[newnumSignal,denFrame1OutPipe2(ii)],denFrameSum1(ii));
        pirelab.getAddComp(net,[denFrameSum1(ii),denFrame2OutPipe2(ii)],denFrameSum2(ii));

        pirelab.getDTCComp(net,denFrameSum2(ii),denFrameOut(ii),...
        blockInfo.RoundingMethod,blockInfo.OverflowAction);

        pirelab.getIntDelayEnabledComp(net,denFrameOut(ii),denFrameOutDelay(ii),inValidReg,...
        ((blockInfo.FrameSize-2)*4-(ii-2)*4),...
        sprintf('denF%ddelayreg',ii));

        prevDenDelay=net.addSignal(previousInput.Type,sprintf('den%dPrevDenDelay',ii));
        prevDenDelay.SimulinkRate=dataRate;
        pirelab.getIntDelayEnabledComp(net,previousInput,prevDenDelay,inValidReg,4,sprintf('den%dPrevDenreg',ii));
        previous2Input=prevDenDelay;
        previousInput=denFrameOut(ii);
    end
    if blockInfo.FrameSize==2
        denFrame=[denOutareg,denOutbreg];
    else
        denFrame=[denOutareg,denFrameOutDelay(2:blockInfo.FrameSize-1),denOutbreg];
    end
    for ii=1:blockInfo.FrameSize
        denFrameBalanced(ii)=net.addSignal(outputType,sprintf('den%dFrameBalanced',ii));%#ok
        if ii==1
            balance=(blockInfo.FrameSize-1)*4;
            pirelab.getIntDelayEnabledComp(net,denFrame(ii),denFrameBalanced(ii),inValidReg,balance,sprintf('denF%dbalreg',ii));
        elseif ii==blockInfo.FrameSize
            balance=(blockInfo.FrameSize-1)*4;
            pirelab.getIntDelayEnabledComp(net,denFrame(ii),denFrameBalanced(ii),inValidReg,balance,sprintf('denF%dbalreg',ii));
        else
            pirelab.getUnitDelayEnabledComp(net,denFrame(ii),denFrameBalanced(ii),inValidReg,sprintf('denF%dbalreg',ii));
        end
    end


    finalDelay=finalDelay+1;
    pirelab.getIntDelayEnabledComp(net,inValidReg,delayvalidout,inValidReg,finalDelay);
    pirelab.getLogicComp(net,[inValidReg,delayvalidout],prevalidout,'and');
    pirelab.getMuxComp(net,denFrameBalanced,denOutVec);
    pirelab.getUnitDelayEnabledComp(net,denOutVec,dataOut,inValidReg,'outputReg');
    pirelab.getUnitDelayComp(net,prevalidout,validOut,'validoutputreg');

end



