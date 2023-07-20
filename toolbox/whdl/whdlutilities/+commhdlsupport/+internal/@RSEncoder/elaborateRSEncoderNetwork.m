function elaborateRSEncoderNetwork(this,topNet,blockInfo,insignals,outsignals)








    dataIn=insignals(1);
    startInput=insignals(2);
    endInput=insignals(3);
    validInput=insignals(4);



    output=outsignals(1);
    startOut=outsignals(2);
    endOut=outsignals(3);
    validOut=outsignals(4);
    nextFrame=outsignals(5);


    rate=dataIn.SimulinkRate;
    output.SimulinkRate=rate;
    startOut.SimulinkRate=rate;
    endOut.SimulinkRate=rate;
    validOut.SimulinkRate=rate;
    nextFrame.SimulinkRate=rate;


    messageLength=double(blockInfo.MessageLength);
    codewordLength=double(blockInfo.CodewordLength);
    primPoly=double(blockInfo.PrimitivePolynomial);

    if strcmp(blockInfo.PuncturePatternSource,'off')
        usePuncturePattern=false;
        puncturePattern=[];
        parityLength=codewordLength-messageLength;
        fullParityLength=codewordLength-messageLength;
    else
        usePuncturePattern=true;
        puncturePattern=double(blockInfo.PuncturePattern);
        parityLength=sum(puncturePattern);
        fullParityLength=codewordLength-messageLength;
    end

    if strcmp(blockInfo.BSource,'Auto')
        B=1;
    else
        B=double(blockInfo.B);
    end



    if strcmp(blockInfo.PrimitivePolynomialSource,'Auto')
        [tMultTable,~,~,tWordSize,~,~]=HDLRSGenPoly(codewordLength,messageLength,B);
    else
        [tMultTable,~,~,tWordSize,~,~]=HDLRSGenPoly(codewordLength,messageLength,B,primPoly);
    end

    wordSize=double(tWordSize);

    multTable=ufi(tMultTable,wordSize,0);


    nextFrameLowTime=codewordLength-messageLength;

    dataType=pir_ufixpt_t(wordSize,0);


    startdataIn=newControlSignal(topNet,'startdataIn_valid',rate);
    pirelab.getBitwiseOpComp(topNet,[startInput,validInput],startdataIn,'AND');
    enddataIn_valid=newControlSignal(topNet,'enddataIn_valid',rate);
    pirelab.getBitwiseOpComp(topNet,[endInput,validInput],enddataIn_valid,'AND');



    startIn=newControlSignal(topNet,'startIn',rate);

    endIn_valid=newControlSignal(topNet,'endIn_valid',rate);

    validIn=newControlSignal(topNet,'validIn',rate);


    sampleControlNet=this.elabSampleControl(topNet,blockInfo,rate);
    sampleControlNet.addComment('Sample control for valid start and end');


    sampleCountVal=newDataSignal(topNet,dataType,'sampleCountVal',rate);
    sampleCountMax=newControlSignal(topNet,'sampleCountMax',rate);
    sampleCountMaxWithValid=newControlSignal(topNet,'sampleCountMaxWithValid',rate);
    sampleCountRst=newControlSignal(topNet,'sampleCountRst',rate);
    sampleCountEnb=newControlSignal(topNet,'sampleCountEnb',rate);
    startWithSampEnb=newControlSignal(topNet,'sampleCountEnb',rate);
    resetIfNoEnd=newControlSignal(topNet,'resetIfNoEnd',rate);
    resetIfNoEndDelayed=newControlSignal(topNet,'resetIfNoEndDelayed',rate);

    xorfeedback=newDataSignal(topNet,dataType,'xorfeedback',rate);
    dataInputxor=newDataSignal(topNet,dataType,'dataInputxor',rate);

    c=pirelab.getBitwiseOpComp(topNet,[dataIn,xorfeedback],dataInputxor,'XOR');
    c.addComment('XOR to dataInput with feedback to drive lookup tables');


    startdataIndelayed=newControlSignal(topNet,'startdataIndelayed',rate);

    oneconst=newDataSignal(topNet,dataType,'oneconst',rate);
    pirelab.getConstComp(topNet,oneconst,1,'oneconst');


    endValidNot=newControlSignal(topNet,'endValidNot',rate);

    pirelab.getCounterComp(topNet,[sampleCountRst,startWithSampEnb,oneconst,sampleCountEnb],sampleCountVal,...
    'Count limited',...
    0.0,...
    1.0,...
    messageLength,...
    true,...
    true,...
    true,...
    false,...
    'sampleCounter');
    pirelab.getBitwiseOpComp(topNet,[validIn,endValidNot],sampleCountEnb,'AND');
    pirelab.getCompareToValueComp(topNet,sampleCountVal,sampleCountMax,'==',messageLength-1,'counterEnbComp');
    pirelab.getBitwiseOpComp(topNet,[sampleCountEnb,startIn],startWithSampEnb,'AND');
    pirelab.getBitwiseOpComp(topNet,[sampleCountMax,validIn],sampleCountMaxWithValid,'AND');
    pirelab.getBitwiseOpComp(topNet,[sampleCountMaxWithValid,enddataIn_valid],sampleCountRst,'OR');


    pirelab.getBitwiseOpComp(topNet,[sampleCountMaxWithValid,endValidNot],resetIfNoEnd,'AND');
    pirelab.getUnitDelayComp(topNet,resetIfNoEnd,resetIfNoEndDelayed,'resetIfNoEndDelayed',0.0);


    inports(1)=startdataIn;
    inports(2)=enddataIn_valid;
    inports(3)=validInput;
    inports(4)=resetIfNoEndDelayed;

    outports(1)=startIn;
    outports(2)=endIn_valid;
    outports(3)=validIn;

    pirelab.instantiateNetwork(topNet,sampleControlNet,inports,outports,'sampleControlNet_inst');






    counterRst=newControlSignal(topNet,'counterRst',rate);
    counterRstNoEnd=newControlSignal(topNet,'counterRstNoEnd',rate);
    counterMax=newControlSignal(topNet,'counterMax',rate);
    counterEnb=newControlSignal(topNet,'counterEnb',rate);
    counterVal=newDataSignal(topNet,dataType,'counterVal',rate);




    pirelab.getCompareToValueComp(topNet,counterVal,counterEnb,'>',0,'counterEnbComp');
    pirelab.getCompareToValueComp(topNet,counterVal,counterMax,'==',nextFrameLowTime,'counterRstComp');
    pirelab.getBitwiseOpComp(topNet,[startIn,counterMax],counterRst,'OR');
    pirelab.getBitwiseOpComp(topNet,endIn_valid,endValidNot,'NOT');
    pirelab.getBitwiseOpComp(topNet,[counterRst,endValidNot],counterRstNoEnd,'AND');


    pirelab.getCounterComp(topNet,[counterRstNoEnd,endIn_valid,oneconst,counterEnb],counterVal,...
    'Count limited',...
    0.0,...
    1.0,...
    nextFrameLowTime,...
    true,...
    true,...
    true,...
    false,...
    'nextFramecounter');

    nxtFrameNet=this.elabNxtFrameCtrl(topNet,rate);
    nxtFrameNet.addComment('Next Frame Signal State Machine');

    inports1(1)=startIn;
    inports1(2)=endIn_valid;
    inports1(3)=counterEnb;
    inports1(4)=resetIfNoEndDelayed;

    outports1(1)=nextFrame;

    pirelab.instantiateNetwork(topNet,nxtFrameNet,inports1,outports1,'nxtFrameNet_inst');





    pirelab.getUnitDelayComp(topNet,startIn,startdataIndelayed,'startdelay',0.0);


    if parityLength==2
        countType=pir_ufixpt_t(1,0);
    else
        countType=pir_ufixpt_t(ceil(log2(parityLength-1)),0);
    end
    paritycount=newDataSignal(topNet,countType,'paritycount',rate);

    parityout=newDataSignal(topNet,dataType,'parityout',rate);
    parityEnable=newControlSignal(topNet,'parityEnable',rate);
    sendparity=newControlSignal(topNet,'sendparity',rate);
    sendparitytemp=newControlSignal(topNet,'sendparitytemp',rate);

    notdone=newControlSignal(topNet,'notdone',rate);
    parityend=newControlSignal(topNet,'parityend',rate);
    paritydone=newControlSignal(topNet,'paritydone',rate);
    notparityend=newControlSignal(topNet,'notparityend',rate);

    prevalidOut=newControlSignal(topNet,'prevalidOut',rate);

    parityenprime=newControlSignal(topNet,'parityenprime',rate);
    enddataIn_valid_dly=newControlSignal(topNet,'enddataIn_valid_dly',rate);

    pirelab.getCompareToValueComp(topNet,paritycount,parityend,'==',parityLength-1,'paritycompare');
    pirelab.getBitwiseOpComp(topNet,[parityend,startIn],paritydone,'OR');
    pirelab.getBitwiseOpComp(topNet,parityend,notparityend,'NOT');
    pirelab.getBitwiseOpComp(topNet,[notparityend,sendparity],notdone,'AND');


    startInNot=newControlSignal(topNet,'startInNot',rate);
    pirelab.getBitwiseOpComp(topNet,startIn,startInNot,'NOT');
    pirelab.getBitwiseOpComp(topNet,[parityEnable,enddataIn_valid_dly],sendparitytemp,'OR');
    pirelab.getBitwiseOpComp(topNet,[sendparitytemp,startInNot],sendparity,'AND');

    pirelab.getBitwiseOpComp(topNet,[validIn,sendparity],prevalidOut,'OR');



    pirelab.getUnitDelayComp(topNet,endIn_valid,enddataIn_valid_dly,'endvaldly',0.0,'',false);
    pirelab.getBitwiseOpComp(topNet,[validIn,enddataIn_valid_dly],parityenprime,'OR');

    oneconst1=newDataSignal(topNet,countType,'oneconst1',rate);
    pirelab.getConstComp(topNet,oneconst1,1,'oneconst1');

    pirelab.getCompareToValueComp(topNet,paritycount,parityEnable,'>',0,'paritycompare1');

    pirelab.getCounterComp(topNet,[paritydone,enddataIn_valid_dly,oneconst1,sendparity],paritycount,...
    'Count limited',...
    0.0,...
    1.0,...
    parityLength-1,...
    true,...
    true,...
    true,...
    false,...
    'paritycount');





    zeroconst=newDataSignal(topNet,dataType,'zeroconst',rate);
    pirelab.getConstComp(topNet,zeroconst,0,'zeroconst');




    for ii=1:fullParityLength
        table(ii)=newDataSignal(topNet,dataType,sprintf('gftable%d',ii),rate);%#ok
        delayreg(ii)=newDataSignal(topNet,dataType,sprintf('gftablereg%d',ii),rate);%#ok
        startmux(ii)=newDataSignal(topNet,dataType,sprintf('startmux%d',ii),rate);%#ok
        parityreg(ii)=newDataSignal(topNet,dataType,sprintf('parityreg%d',ii),rate);%#ok 
        parity(ii)=newDataSignal(topNet,dataType,sprintf('parity%d',ii),rate);%#ok

    end








    startdataInEnb=startIn;


    for ii=1:fullParityLength
        pirelab.getDirectLookupComp(topNet,dataInputxor,table(ii),multTable(ii,:),'gftable');
        pirelab.getUnitDelayEnabledComp(topNet,table(ii),delayreg(ii),validIn,'gftablereg',0.0,'',false);

        pirelab.getSwitchComp(topNet,[delayreg(ii),zeroconst],startmux(ii),startIn,'startmux');

        if ii==(codewordLength-messageLength)

            pirelab.getUnitDelayEnabledResettableComp(topNet,startmux(ii),parityreg(ii),parityenprime,startdataInEnb,...
            'paritystate',0.0,'',true);
        else
            pirelab.getBitwiseOpComp(topNet,[startmux(ii),parityreg(ii+1)],parity(ii),'XOR');
            pirelab.getUnitDelayEnabledResettableComp(topNet,parity(ii),parityreg(ii),parityenprime,startdataInEnb,...
            'paritystate',0.0,'',true);

        end
    end

    pirelab.getSwitchComp(topNet,[parity(1),zeroconst],xorfeedback,startIn);
    tempoutput=newDataSignal(topNet,dataType,'tempoutput',rate);

    if usePuncturePattern
        xorfeedbackdelayed=newDataSignal(topNet,dataType,'xorfeedbackdelayed',rate);
        pirelab.getUnitDelayComp(topNet,xorfeedback,xorfeedbackdelayed,'xorfeedbackdelreg');
        parityToSend=[xorfeedbackdelayed,parityreg(2:end)];
        parityToSend=parityToSend(logical(puncturePattern));
        paritycountdelayed=newDataSignal(topNet,countType,'paritycountdelayed',rate);
        pirelab.getUnitDelayComp(topNet,paritycount,paritycountdelayed,'paritycountdelreg');

        pirelab.getMultiPortSwitchComp(topNet,[paritycountdelayed,parityToSend],parityout,...
        1,1,'floor','Wrap','parityoutmux');
        sendparitydelayed=newControlSignal(topNet,'sendparitydelayed',rate);
        pirelab.getUnitDelayComp(topNet,sendparity,sendparitydelayed,'sendparitydelreg');

        fdataInalmux=newDataSignal(topNet,dataType,'fdataInalmux',rate);

        dataIndelayed=newDataSignal(topNet,dataType,'dataIndelayed',rate);
        pirelab.getUnitDelayComp(topNet,dataIn,dataIndelayed,'dataIndelreg');

        prevalidOutdelayed=newControlSignal(topNet,'prevalidOutdelayed',rate);
        pirelab.getUnitDelayComp(topNet,prevalidOut,prevalidOutdelayed,'prevalidOutdelreg');

        pirelab.getSwitchComp(topNet,[dataIndelayed,parityout],fdataInalmux,sendparitydelayed,'fdataInalmux');
        pirelab.getUnitDelayEnabledComp(topNet,fdataInalmux,tempoutput,prevalidOutdelayed,'outputreg',0.0,'',false);

        pirelab.getUnitDelayComp(topNet,prevalidOutdelayed,validOut,'validreg',0.0,'',false);

        startInDelay2=newControlSignal(topNet,'startInDelay2',rate);
        pirelab.getUnitDelayComp(topNet,startdataIndelayed,startInDelay2,'startInDelay2reg');
        pirelab.getWireComp(topNet,startInDelay2,startOut);

        parityendDelay=newControlSignal(topNet,'parityendDelay',rate);
        pirelab.getUnitDelayComp(topNet,parityend,parityendDelay,'parityendDelayreg');
        pirelab.getUnitDelayComp(topNet,parityendDelay,endOut,'endreg',0.0,'',false);
    else
        parityToSend=[xorfeedback,parityreg(2:end)];
        pirelab.getMultiPortSwitchComp(topNet,[paritycount,parityToSend],parityout,...
        1,1,'floor','Wrap','parityoutmux');
        fdataInalmux=newDataSignal(topNet,dataType,'fdataInalmux',rate);
        pirelab.getSwitchComp(topNet,[dataIn,parityout],fdataInalmux,sendparity,'fdataInalmux');
        pirelab.getUnitDelayEnabledComp(topNet,fdataInalmux,tempoutput,prevalidOut,'outputreg',0.0,'',false);
        pirelab.getUnitDelayComp(topNet,prevalidOut,validOut,'endreg',0.0,'',false);
        pirelab.getWireComp(topNet,startdataIndelayed,startOut);
        pirelab.getUnitDelayComp(topNet,parityend,endOut,'endreg',0.0,'',false);
    end
    pirelab.getSwitchComp(topNet,[zeroconst,tempoutput],output,validOut,'finaldatamux');

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



