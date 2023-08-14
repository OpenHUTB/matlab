function elaborateRSDecoderNetwork(this,topNet,blockInfo,insignals,outsignals)

















    dataIn=insignals(1);
    startInput=insignals(2);
    endInput=insignals(3);
    validInput=insignals(4);




    output=outsignals(1);
    startOut=outsignals(2);
    endOut=outsignals(3);
    validOut=outsignals(4);
    errOut=outsignals(5);
    if length(outsignals)==7
        numErrOut=outsignals(6);
        hasErrPort=true;
        nextFrame=outsignals(7);
    else
        numErrOut=[];
        hasErrPort=false;
        nextFrame=outsignals(6);
    end


    rate=dataIn.SimulinkRate;
    output.SimulinkRate=rate;
    startOut.SimulinkRate=rate;
    endOut.SimulinkRate=rate;
    validOut.SimulinkRate=rate;
    nextFrame.SimulinkRate=rate;


    messageLength=double(blockInfo.MessageLength);
    codewordLength=double(blockInfo.CodewordLength);

    primPoly=double(blockInfo.PrimitivePolynomial);

    parityLength=codewordLength-messageLength;













    if strcmp(blockInfo.BSource,'Auto')
        B=1;
    else
        B=double(blockInfo.B);
    end



    if strcmp(blockInfo.PrimitivePolynomialSource,'Auto')
        [~,tPowerTable,tCorr,tWordSize,tAntiLogTable,tLogTable]=HDLRSGenPoly(codewordLength,messageLength,B);
    else
        [~,tPowerTable,tCorr,tWordSize,tAntiLogTable,tLogTable]=HDLRSGenPoly(codewordLength,messageLength,B,primPoly);
    end

    wordSize=double(tWordSize);
    powerTable=ufi(tPowerTable,wordSize,0);
    corr=double(tCorr);
    alogTable=ufi([uint32(1);tAntiLogTable],wordSize,0);
    logTable=ufi([uint32(0);tLogTable],wordSize,0);



    inType=pir_ufixpt_t(wordSize,0);
    carryType=pir_ufixpt_t(wordSize+1,0);
    countType=pir_ufixpt_t(ceil(log2(2*corr)),0);


    bmLength=4*corr+10;
    convLength=(corr*2)*(corr*2+1)/2;
    chienLength=2.^wordSize;
    delayTotal=bmLength+convLength+chienLength;

    delayWordSize=ceil(log2(delayTotal));
    nPackets=ceil((2.^delayWordSize)/codewordLength)+1;
    ramDepth=ceil(log2(nPackets));
    numPackets=2^ramDepth;
    delayType=pir_ufixpt_t(delayWordSize,0);
    addrType=pir_ufixpt_t(ramDepth+ceil(log2(codewordLength)),0);
    addrCountType=pir_ufixpt_t(ceil(log2(codewordLength)),0);
    addrBankType=pir_ufixpt_t(ramDepth,0);
    if hasErrPort
        numerrType=pir_ufixpt_t(8,0);
    end
    processingTime=bmLength+convLength;
    if processingTime>codewordLength
        nextFrameLowTime=processingTime-codewordLength;
    else
        nextFrameLowTime=0;
    end

    controlType=pir_ufixpt_t(1,0);



    endInputValid=newControlSignal(topNet,'endInputValid',rate);
    startInputValid=newControlSignal(topNet,'startInputValid',rate);

    pirelab.getBitwiseOpComp(topNet,[startInput,validInput],startInputValid,'AND');
    pirelab.getBitwiseOpComp(topNet,[endInput,validInput],endInputValid,'AND');

    startInDel=newControlSignal(topNet,'startInDel',rate);

    endIn_validDel=newControlSignal(topNet,'endin_validDel',rate);

    validInDel=newControlSignal(topNet,'validInDel',rate);
    dataInDel=newDataSignal(topNet,'dataInDel',inType,rate);




    startIn=newControlSignal(topNet,'startin_valid',rate);

    endIn_valid=newControlSignal(topNet,'endin_valid',rate);

    validIn=newControlSignal(topNet,'validIn',rate);


    startIn1=newControlSignal(topNet,'startin_valid1',rate);

    endIn_valid1=newControlSignal(topNet,'endin_valid1',rate);

    validIn1=newControlSignal(topNet,'validIn1',rate);

    sampleControlNet=this.elabSampleControl(topNet,blockInfo,rate);
    sampleControlNet.addComment('Sample control for valid start and end');

    inports(1)=startInputValid;
    inports(2)=endInputValid;
    inports(3)=validInput;

    outports(1)=startInDel;
    outports(2)=endIn_validDel;
    outports(3)=validInDel;
    nextFrameDelay=newControlSignal(topNet,'nextFrameDelay',rate);
    pirelab.instantiateNetwork(topNet,sampleControlNet,inports,outports,'sampleControlNet_inst1');

    pirelab.getUnitDelayComp(topNet,startInDel,startIn1,'startInDelComp',0.0);

    pirelab.getUnitDelayComp(topNet,endIn_validDel,endIn_valid1,'endInDelComp',0.0);
    pirelab.getUnitDelayComp(topNet,validInDel,validIn1,'validInDelComp',0.0);
    pirelab.getUnitDelayComp(topNet,dataIn,dataInDel,'dataInDelComp',0.0);



    sampleCountVal=newDataSignal(topNet,'sampleCountVal',pir_ufixpt_t(16,0),rate);
    sampleCountMax=newControlSignal(topNet,'sampleCountMax',rate);
    sampleCountRst=newControlSignal(topNet,'sampleCountRst',rate);

    sampleCountEnb=newControlSignal(topNet,'sampleCountEnb',rate);
    falseEnd=newControlSignal(topNet,'falseEnd',rate);
    endInOr=newControlSignal(topNet,'endInOr',rate);

    notendin=topNet.addSignal(controlType,'notendin');
    inpacket=topNet.addSignal(controlType,'inpacket');
    inpacketnext=topNet.addSignal(controlType,'inpacketnext');
    notdonepacket=topNet.addSignal(controlType,'notdonepacket');
    endIn=topNet.addSignal(controlType,'endin_packet');


    pirelab.getWireComp(topNet,validIn,sampleCountEnb);

    pirelab.getCounterComp(topNet,[sampleCountRst,sampleCountEnb],sampleCountVal,...
    'Count limited',...
    0.0,...
    1.0,...
    65535,...
    true,...
    false,...
    true,...
    false,...
    'sampleCounter');

    pirelab.getCompareToValueComp(topNet,sampleCountVal,sampleCountMax,'==',codewordLength-1,'counterEnbComp');
    falseEndTemp=newControlSignal(topNet,'falseEndTemp',rate);
    pirelab.getBitwiseOpComp(topNet,[sampleCountMax,endIn_valid1],falseEndTemp,'OR');
    pirelab.getBitwiseOpComp(topNet,[falseEnd,startInDel],sampleCountRst,'OR');
    pirelab.getBitwiseOpComp(topNet,[validIn,falseEndTemp],falseEnd,'AND');
    pirelab.getBitwiseOpComp(topNet,[falseEnd,endIn_valid1],endInOr,'OR');


    inports(1)=startIn1;
    inports(2)=endInOr;
    inports(3)=validIn1;

    outports(1)=startIn;
    outports(2)=endIn_valid;
    outports(3)=validIn;
    pirelab.instantiateNetwork(topNet,sampleControlNet,inports,outports,'sampleControlNet_inst2');

    pirelab.getBitwiseOpComp(topNet,endIn,notendin,'NOT');
    pirelab.getBitwiseOpComp(topNet,[notendin,inpacket],notdonepacket,'AND');
    pirelab.getBitwiseOpComp(topNet,[startIn,notdonepacket],inpacketnext,'OR');
    pirelab.getUnitDelayComp(topNet,inpacketnext,inpacket,'inpacketreg',0.0);




    pirelab.getBitwiseOpComp(topNet,[endIn_valid,inpacket],endIn,'AND');



    dataInDelay=newDataSignal(topNet,'dataInDelay',inType,rate);
    validInDelay=newControlSignal(topNet,'validInDelay',rate);
    startInDelay=newControlSignal(topNet,'startInDelay',rate);
    endInDelay=newControlSignal(topNet,'endInDelay',rate);
    endInDelay2=newControlSignal(topNet,'endInDelay2',rate);
    endIn_validDelay=newControlSignal(topNet,'endIn_validDelay',rate);
    endIn_validDelay1=newControlSignal(topNet,'endIn_validDelay1',rate);

    pirelab.getUnitDelayComp(topNet,dataInDel,dataInDelay,'datainputdelay',0.0);
    pirelab.getUnitDelayComp(topNet,startIn,startInDelay,'startdelay',0.0);
    pirelab.getUnitDelayComp(topNet,endIn,endInDelay,'enddelay',0.0);
    pirelab.getUnitDelayComp(topNet,endInDelay,endInDelay2,'enddelay2',0.0);
    pirelab.getUnitDelayComp(topNet,endIn_valid,endIn_validDelay);
    pirelab.getUnitDelayComp(topNet,endIn_validDelay,endIn_validDelay1);
    pirelab.getUnitDelayComp(topNet,validIn,validInDelay,'dvdelay',0.0);

    actualendInDelay=newControlSignal(topNet,'actualendInDelay',rate);
    actualendInDelay1=newControlSignal(topNet,'actualendInDelay1',rate);
    pirelab.getUnitDelayComp(topNet,endIn_valid1,actualendInDelay);
    pirelab.getUnitDelayComp(topNet,actualendInDelay,actualendInDelay1);

    zeroconst=newDataSignal(topNet,'zeroconst',inType,rate);
    pirelab.getConstComp(topNet,zeroconst,0,'zeroconst');

    correction=newDataSignal(topNet,'correction',inType,rate);
    correctionnext=newDataSignal(topNet,'correctionnext',inType,rate);
    predataout=newDataSignal(topNet,'predataout',inType,rate);
    gatedataout=newDataSignal(topNet,'gatedataout',inType,rate);
    prevalidout=newControlSignal(topNet,'prevalidout',rate);
    prestartout=newControlSignal(topNet,'prestartout',rate);
    preendout=newControlSignal(topNet,'preendout',rate);
    preerrout=newControlSignal(topNet,'preerrout',rate);
    if hasErrPort
        p2numerr=newDataSignal(topNet,'p2numerr',numerrType,rate);
        prenumerr=newDataSignal(topNet,'prenumerr',numerrType,rate);
    end

    p2dvout=newControlSignal(topNet,'p2dvout',rate);
    p2startout=newControlSignal(topNet,'p2startout',rate);
    p2endout=newControlSignal(topNet,'p2endout',rate);
    p2errout=newControlSignal(topNet,'p2errout',rate);
    prestartcurbank=newControlSignal(topNet,'prestartcurbank',rate);




    counterRst=newControlSignal(topNet,'counterRst',rate);
    counterMax=newControlSignal(topNet,'counterMax',rate);
    counterEnb=newControlSignal(topNet,'counterEnb',rate);
    counterVal=newDataSignal(topNet,'counterVal',pir_ufixpt_t(16,0),rate);

    oneconst=newDataSignal(topNet,'oneconst',pir_ufixpt_t(16,0),rate);
    pirelab.getConstComp(topNet,oneconst,1,'oneconst');


    pirelab.getCompareToValueComp(topNet,counterVal,counterEnb,'>',0,'counterEnbComp');


    recvCodeWrdLength=newDataSignal(topNet,'recvCodeWrdLength',pir_ufixpt_t(16,0),rate);
    shortMsgDiffLen=newDataSignal(topNet,'shortMsgDiffLen',pir_ufixpt_t(16,0),rate);
    msgDiffLenCompare=newControlSignal(topNet,'msgDiffLenCompare',rate);
    msgDiffLenCompareTemp=newControlSignal(topNet,'msgDiffLenCompareTemp',rate);
    msgDiffLenCompareTempNot=newControlSignal(topNet,'msgDiffLenCompareTempNot',rate);
    counterRstTemp=newControlSignal(topNet,'counterRstTemp',rate);

    codeWordConst=newDataSignal(topNet,'codeWordConst',pir_ufixpt_t(16,0),rate);
    pirelab.getConstComp(topNet,codeWordConst,codewordLength-1,'codeWordConst');

    codeWordConst1=newDataSignal(topNet,'codeWordConst1',pir_ufixpt_t(16,0),rate);
    pirelab.getConstComp(topNet,codeWordConst1,codewordLength-1,'codeWordConst1');

    codeWordConstFinal=newDataSignal(topNet,'codeWordConstFinal',pir_ufixpt_t(16,0),rate);

    nextFrameLowConst=newDataSignal(topNet,'nextFrameLowConst',pir_ufixpt_t(16,0),rate);
    pirelab.getConstComp(topNet,nextFrameLowConst,nextFrameLowTime,'nextFrameLowConst');

    actualNxtFrameLowTime=newDataSignal(topNet,'actualNxtFrameLowTime',pir_ufixpt_t(16,0),rate);




    nextFramecounterRst=newControlSignal(topNet,'nextFramecounterRst',rate);
    nextFramecounterRstTemp=newControlSignal(topNet,'nextFramecounterRstTemp',rate);
    nextFrameCountMax=newControlSignal(topNet,'nextFrameCountMax',rate);
    nextFrameCountVal=newDataSignal(topNet,'nextFrameCountVal',pir_ufixpt_t(16,0),rate);
    startInForNextFrame=newControlSignal(topNet,'startInForNextFrame',rate);
    endInForNextFrame=newControlSignal(topNet,'endInForNextFrame',rate);
    validInForNextFrame=newControlSignal(topNet,'validInForNextFrame',rate);
    nextFrameMaxFlag=newControlSignal(topNet,'nextFrameMaxFlag',rate);
    nextFrameFirstState=newControlSignal(topNet,'nextFrameFirstState',rate);
    nextFrameFirstStateTemp1=newControlSignal(topNet,'nextFrameFirstStateTemp1',rate);
    nextFrameFirstStateTemp=newControlSignal(topNet,'nextFrameFirstStateTemp',rate);
    endInForNextFrameTwice=newControlSignal(topNet,'endInForNextFrameTwice',rate);
    endInForNextFrameDelay=newControlSignal(topNet,'endInForNextFrameDelay',rate);
    nextFrameTemp=newControlSignal(topNet,'nextFrameTemp',rate);
    nextFrameLowConstGreatZero=newControlSignal(topNet,'nextFrameLowConstGreatZero',rate);
    nextFrameLowConstGreatZeroTemp=newControlSignal(topNet,'nextFrameLowConstGreatZeroTemp',rate);

    pirelab.getCompareToValueComp(topNet,nextFrameLowConst,nextFrameLowConstGreatZeroTemp,'==',0);
    pirelab.getBitwiseOpComp(topNet,[nextFrameLowConstGreatZeroTemp,endInForNextFrameDelay],nextFrameLowConstGreatZero,'AND');
    pirelab.getBitwiseOpComp(topNet,[nextFrameLowConstGreatZero,nextFrameFirstStateTemp1],nextFrameFirstState,'AND');


    pirelab.getUnitDelayComp(topNet,endInForNextFrame,endInForNextFrameDelay);
    pirelab.getBitwiseOpComp(topNet,[endInForNextFrame,endInForNextFrameDelay],endInForNextFrameTwice,'OR');
    pirelab.getBitwiseOpComp(topNet,[nextFrameFirstStateTemp,endInForNextFrameDelay],nextFrameFirstStateTemp1,'AND');

    pirelab.getCompareToValueComp(topNet,shortMsgDiffLen,nextFrameFirstStateTemp,'==',0);

    pirelab.getBitwiseOpComp(topNet,[endInForNextFrame,nextFrameCountMax,validIn],nextFrameMaxFlag,'AND');

    pirelab.getSubComp(topNet,[codeWordConst,sampleCountVal],shortMsgDiffLen);

    pirelab.getUnitDelayEnabledResettableComp(topNet,shortMsgDiffLen,recvCodeWrdLength,endInForNextFrameTwice,startInForNextFrame,'recvCodeWrdLengthreg',0.0,'',false);
    pirelab.getCompareToValueComp(topNet,shortMsgDiffLen,msgDiffLenCompare,'>',0,'mgDiffLenComp');
    pirelab.getBitwiseOpComp(topNet,[msgDiffLenCompare,endInForNextFrame],msgDiffLenCompareTemp,'AND');
    pirelab.getBitwiseOpComp(topNet,msgDiffLenCompareTemp,msgDiffLenCompareTempNot,'NOT');

    pirelab.getAddComp(topNet,[nextFrameLowConst,recvCodeWrdLength],actualNxtFrameLowTime);
    pirelab.getRelOpComp(topNet,[counterVal,actualNxtFrameLowTime],counterMax,'==');

    pirelab.getBitwiseOpComp(topNet,[msgDiffLenCompareTempNot,counterMax],counterRst,'AND');

    syndromeStart=newControlSignal(topNet,'syndromeStart',rate);
    syndromeStartTemp=newControlSignal(topNet,'syndromeStartTemp',rate);
    syndromeStartTemp1=newControlSignal(topNet,'syndromeStartTemp1',rate);
    properEnd=newControlSignal(topNet,'properEnd',rate);


    pirelab.getRelOpComp(topNet,[counterVal,recvCodeWrdLength],syndromeStartTemp,'==');
    counterValCompZero=newControlSignal(topNet,'counterValCompZero',rate);
    pirelab.getCompareToValueComp(topNet,counterVal,counterValCompZero,'>',0);
    msgDiffLenCompareNotZero=newControlSignal(topNet,'msgDiffLenCompareNotZero',rate);
    pirelab.getBitwiseOpComp(topNet,msgDiffLenCompare,msgDiffLenCompareNotZero,'NOT');

    pirelab.getBitwiseOpComp(topNet,[endIn_validDel,msgDiffLenCompareNotZero],properEnd,'AND');
    pirelab.getBitwiseOpComp(topNet,[counterValCompZero,syndromeStartTemp],syndromeStartTemp1,'AND');
    pirelab.getBitwiseOpComp(topNet,[properEnd,syndromeStartTemp1],syndromeStart,'OR');


    syndromeStartDelay=newControlSignal(topNet,'syndromeStartDelay',rate);
    pirelab.getUnitDelayComp(topNet,endIn_validDel,syndromeStartDelay);
    syndromeStartDelay1=newControlSignal(topNet,'syndromeStartDelay1',rate);
    pirelab.getUnitDelayComp(topNet,syndromeStartDelay,syndromeStartDelay1);
    syndromeStartDelay2=newControlSignal(topNet,'syndromeStartDelay2',rate);
    pirelab.getUnitDelayComp(topNet,syndromeStartDelay1,syndromeStartDelay2);
    syndromeStartDelay3=newControlSignal(topNet,'syndromeStartDelay3',rate);
    pirelab.getUnitDelayComp(topNet,syndromeStartDelay2,syndromeStartDelay3);


    counterLoad=newControlSignal(topNet,'counterLoad',rate);
    pirelab.getBitwiseOpComp(topNet,[endIn_validDel,nextFramecounterRstTemp],counterLoad,'OR');



    pirelab.getCounterComp(topNet,[counterRst,endInForNextFrame,oneconst,counterEnb],counterVal,...
    'Count limited',...
    0.0,...
    1.0,...
    65535,...
    true,...
    true,...
    true,...
    false,...
    'nextFramecounter');



    inports(1)=startInDel;
    inports(2)=counterLoad;
    inports(3)=validInDel;

    outports(1)=startInForNextFrame;
    outports(2)=endInForNextFrame;
    outports(3)=validInForNextFrame;

    pirelab.instantiateNetwork(topNet,sampleControlNet,inports,outports,'sampleControlNet_inst2');


    pirelab.getCounterComp(topNet,[nextFramecounterRst,startInDel,oneconst,validInForNextFrame],nextFrameCountVal,...
    'Count limited',...
    0.0,...
    1.0,...
    codewordLength-1,...
    true,...
    true,...
    true,...
    false,...
    'nextFramecounter1');

    pirelab.getCompareToValueComp(topNet,nextFrameCountVal,nextFrameCountMax,'==',codewordLength-1);
    pirelab.getBitwiseOpComp(topNet,[nextFrameCountMax,validInForNextFrame],nextFramecounterRstTemp,'AND');
    pirelab.getBitwiseOpComp(topNet,[nextFramecounterRstTemp,endInForNextFrame],nextFramecounterRst,'OR');

    nxtFrameNet=this.elabNxtFrameCtrl(topNet,rate);
    nxtFrameNet.addComment('Next Frame Signal State Machine');

    inports1(1)=startInDel;
    inports1(2)=endInForNextFrame;
    inports1(3)=counterEnb;
    outports1(1)=nextFrameTemp;

    pirelab.instantiateNetwork(topNet,nxtFrameNet,inports1,outports1,'nxtFrameNet_inst');
    pirelab.getBitwiseOpComp(topNet,[nextFrameFirstState,nextFrameTemp],nextFrame,'OR');
    prestartcurbankdelay=newControlSignal(topNet,'prestartcurbankdelay',rate);



    for ii=1:(2*corr)
        xorfeedback(ii)=newDataSignal(topNet,'xorfeedback',inType,rate);%#ok
        syndromereg(ii)=newDataSignal(topNet,'syndromereg',inType,rate);%#ok
        finalsyndromereg(ii)=newDataSignal(topNet,'finalsyndromereg',inType,rate);%#ok
        syndromegate(ii)=newDataSignal(topNet,'syndromegate',inType,rate);%#ok
        powertableout(ii)=newDataSignal(topNet,'powertableout',inType,rate);%#ok

        syndromezero(ii)=newControlSignal(topNet,sprintf('syndrome%dzero',ii),rate);%#ok

        pirelab.getUnitDelayEnabledComp(topNet,xorfeedback(ii),syndromereg(ii),validInDelay,'synreg',0.0,'',false);
        pirelab.getUnitDelayEnabledComp(topNet,syndromereg(ii),finalsyndromereg(ii),endInDelay2,'synreg1',0.0,'',false);
        pirelab.getSwitchComp(topNet,[syndromereg(ii),zeroconst],syndromegate(ii),startInDelay,'holdmux');

        pirelab.getCompareToValueComp(topNet,syndromereg(ii),syndromezero(ii),'==',0,'synzerocomp');

        if B==0&&ii==1
            powertableout(ii)=syndromegate(ii);%#ok  % forward
        else
            pirelab.getDirectLookupComp(topNet,syndromegate(ii),powertableout(ii),powerTable(ii+B,:),'gfpowertable');
        end
        pirelab.getBitwiseOpComp(topNet,[dataInDelay,powertableout(ii)],xorfeedback(ii),'XOR');
        errlocpoly(ii)=newDataSignal(topNet,sprintf('errloc%dpoly',ii),inType,rate);%#ok
    end

    allsynzero=newControlSignal(topNet,'allsynzero',rate);
    pirelab.getBitwiseOpComp(topNet,syndromezero(:),allsynzero,'AND');
    notallsynzero=newControlSignal(topNet,'notallsynzero',rate);
    pirelab.getBitwiseOpComp(topNet,allsynzero,notallsynzero,'NOT');
    haserrorsreg=newControlSignal(topNet,'haserrorsreg',rate);
    haserrorsfsmreg=newControlSignal(topNet,'haserrorsfsmreg',rate);
    haserrorsconvreg=newControlSignal(topNet,'haserrorsconvreg',rate);
    haserrorschienprereg=newControlSignal(topNet,'haserrorschienprereg',rate);
    haserrorschienreg=newControlSignal(topNet,'haserrorschienreg',rate);

    pirelab.getUnitDelayEnabledComp(topNet,notallsynzero,haserrorsreg,endIn_validDelay1,'synhaserrreg',0.0,'',false);





    fsmdone=newControlSignal(topNet,'fsmdone',rate);
    convdone=newControlSignal(topNet,'convdone',rate);
    chienprerundone=newControlSignal(topNet,'chienprerundone',rate);




    ramrddata=newDataSignal(topNet,'ramrddata',inType,rate);
    ramwraddr=newDataSignal(topNet,'ramwraddr',addrType,rate);
    ramrdaddr=newDataSignal(topNet,'ramrdaddr',addrType,rate);
    ramwren=newControlSignal(topNet,'ramwren',rate);
    ramrden=newControlSignal(topNet,'ramrden',rate);
    ramrdennext=newControlSignal(topNet,'ramrdennext',rate);
    ramrdencontinue=newControlSignal(topNet,'ramrdencontinue',rate);
    notcountstop=newControlSignal(topNet,'notcountstop',rate);

    ramwrcount=newDataSignal(topNet,'ramwrcount',addrCountType,rate);
    ramrdcount=newDataSignal(topNet,'ramrdcount',addrCountType,rate);
    ramwrbank=newDataSignal(topNet,'ramwrbank',addrBankType,rate);
    ramrdbank=newDataSignal(topNet,'ramrdbank',addrBankType,rate);

    ramwrbanken=newControlSignal(topNet,'ramwrbanken',rate);
    masseybank=newDataSignal(topNet,'masseybank',addrBankType,rate);
    convbank=newDataSignal(topNet,'convbank',addrBankType,rate);
    prerunbank=newDataSignal(topNet,'prerunbank',addrBankType,rate);
    chienbank=newDataSignal(topNet,'chienbank',addrBankType,rate);

    ram_insigs=[dataInDelay,ramwraddr,ramwren,ramrdaddr];
    pirelab.getSimpleDualPortRamComp(topNet,ram_insigs,ramrddata,'RSDataRAM');

    pirelab.getBitConcatComp(topNet,[ramwrbank,ramwrcount],ramwraddr);
    pirelab.getBitConcatComp(topNet,[ramrdbank,ramrdcount],ramrdaddr);

    pirelab.getDTCComp(topNet,validInDelay,ramwren);




    firststartsig=newControlSignal(topNet,'firststartsig',rate);
    firststartsigdelay=newControlSignal(topNet,'firststartsigdelay',rate);
    nofirststartsig=newControlSignal(topNet,'nofirststartsig',rate);

    pirelab.getBitwiseOpComp(topNet,[startIn,firststartsigdelay],firststartsig,'OR');
    pirelab.getUnitDelayComp(topNet,firststartsig,firststartsigdelay,'firstStartDelay',0.0);
    pirelab.getBitwiseOpComp(topNet,[startIn,firststartsigdelay],nofirststartsig,'AND');

    pirelab.getUnitDelayComp(topNet,nextFrame,nextFrameDelay);
    pirelab.getBitwiseOpComp(topNet,[nextFrameDelay,nofirststartsig],ramwrbanken,'AND');

    pirelab.getUnitDelayComp(topNet,nextFrame,nextFrameDelay);


    ramWriteCountStart=newControlSignal(topNet,'ramWriteCountStart',rate);
    pirelab.getBitwiseOpComp(topNet,[startIn,nextFrameDelay],ramWriteCountStart,'AND');
    pirelab.getCounterComp(topNet,[startIn,ramwren],ramwrcount,...
    'Count limited',...
    0.0,...
    1.0,...
    2^wordSize-1,...
    true,...
    false,...
    true,...
    false,...
    'wraddrcounter');

    pirelab.getCounterComp(topNet,[prestartcurbankdelay,prevalidout],ramrdcount,...
    'Count limited',...
    0.0,...
    1.0,...
    2^wordSize-1,...
    true,...
    false,...
    true,...
    false,...
    'rdaddrcounter');

    pirelab.getCounterComp(topNet,ramwrbanken,ramwrbank,...
    'Count limited',...
    0,...
    1.0,...
    numPackets-1,...
    false,...
    false,...
    true,...
    false,...
    'wrbankcounter');

    pirelab.getCounterComp(topNet,p2endout,ramrdbank,...
    'Count limited',...
    0.0,...
    1.0,...
    numPackets-1,...
    false,...
    false,...
    true,...
    false,...
    'rdbankcounter');


    for ii=1:numPackets
        wrbankdecode(ii)=newControlSignal(topNet,['wrbankdecode%d',(ii-1)],rate);%#ok
    end

    for ii=1:numPackets
        rdbankdecode(ii)=newControlSignal(topNet,['rdbankdecode%d',(ii-1)],rate);%#ok
    end

    for ii=1:numPackets
        bankvalid(ii)=newControlSignal(topNet,['bankvalid%d',(ii-1)],rate);%#ok
    end

    for ii=1:numPackets
        setvalid(ii)=newControlSignal(topNet,['setvalid%d',(ii-1)],rate);%#ok
    end

    endcompare=newControlSignal(topNet,'encompare',rate);
    rdbankvalid=newControlSignal(topNet,'rdbankvalid',rate);
    for ii=1:numPackets
        endpacketbank(ii)=newControlSignal(topNet,['endpacketbank%d',(ii-1)],rate);%#ok
    end

    for ii=1:numPackets
        holdvalid(ii)=newControlSignal(topNet,['holdvalid%d',(ii-1)],rate);%#ok
    end

    for ii=1:numPackets
        endreadbank(ii)=newControlSignal(topNet,['endreadbank%d',(ii-1)],rate);%#ok
    end


    inputlength=newDataSignal(topNet,'inputlength',addrCountType,rate);
    parityconst=newDataSignal(topNet,'paritylength',addrCountType,rate);
    parityconstplusone=newDataSignal(topNet,'paritylengthplusone',addrCountType,rate);
    for ii=1:numPackets
        packetlength(ii)=newDataSignal(topNet,['packetlength%d',(ii-1)],addrCountType,rate);%#ok
    end



    currentlength=newDataSignal(topNet,'currentlength',addrCountType,rate);
    currentlensub=newDataSignal(topNet,'currentlensub',addrCountType,rate);
    oneaddrcount=newDataSignal(topNet,'oneaddrcount',addrCountType,rate);

    errlocpolysub=newDataSignal(topNet,'errlocpolysub',countType,rate);
    errlocpolysubconv=newDataSignal(topNet,'errlocpolysubconv',countType,rate);
    errlocpolysubchien=newDataSignal(topNet,'errlocpolysubchien',countType,rate);

    errlocpolylen=newDataSignal(topNet,'errlocpolylen',countType,rate);
    errlocpolylenconv=newDataSignal(topNet,'errlocpolylenconv',countType,rate);
    errlocpolylenconveven=newDataSignal(topNet,'errlocpolylenconveven',countType,rate);
    errlocpolylenconvodd=newDataSignal(topNet,'errlocpolylenconvodd',countType,rate);
    errlocpolylenchien=newDataSignal(topNet,'errlocpolylenchien',countType,rate);
    errlocpolylenminusone=newDataSignal(topNet,'errlocpolylenminusone',countType,rate);



    for ii=1:numPackets
        pirelab.getCompareToValueComp(topNet,ramwrbank,wrbankdecode(ii),'==',(ii-1),['wrbankdecoder%d',(ii-1)]);
    end

    for ii=1:numPackets
        pirelab.getCompareToValueComp(topNet,ramrdbank,rdbankdecode(ii),'==',(ii-1),['rdbankdecoder%d',(ii-1)]);
    end
    for ii=1:numPackets
        pirelab.getUnitDelayComp(topNet,setvalid(ii),bankvalid(ii),['bankvalid%dreg',(ii-1)],0.0);
    end







    for ii=1:numPackets
        startReadSetValid(ii)=newControlSignal(topNet,['startReadSetValid_',num2str(ii)],rate);
        pirelab.getBitwiseOpComp(topNet,[endIn_validDelay,wrbankdecode(ii)],endpacketbank(ii),'AND');

    end

    for ii=1:numPackets
        pirelab.getBitwiseOpComp(topNet,[holdvalid(ii),endpacketbank(ii)],setvalid(ii),'OR');
    end

    for ii=1:numPackets
        pirelab.getBitwiseOpComp(topNet,[bankvalid(ii),endreadbank(ii)],holdvalid(ii),'AND');
    end

    for ii=1:numPackets
        pirelab.getBitwiseOpComp(topNet,[rdbankdecode(ii),preendout,prevalidout],endreadbank(ii),'NAND');
    end

    pirelab.getConstComp(topNet,parityconst,parityLength);
    pirelab.getConstComp(topNet,parityconstplusone,parityLength+1);
    pirelab.getSubComp(topNet,[ramwrcount,parityconst],inputlength);
    for ii=1:numPackets
        pirelab.getUnitDelayEnabledComp(topNet,inputlength,packetlength(ii),endpacketbank(ii),['packetlen%dreg',(ii-1)],0.0,'',false);
    end





    pirelab.getUnitDelayEnabledComp(topNet,ramwrbank,masseybank,endIn_validDelay,'masseybankreg',0.0,'',false);
    pirelab.getUnitDelayEnabledComp(topNet,masseybank,convbank,fsmdone,'convbankreg',0.0,'',false);
    pirelab.getUnitDelayEnabledComp(topNet,convbank,prerunbank,convdone,'prerunbankreg',0.0,'',false);
    pirelab.getUnitDelayEnabledComp(topNet,prerunbank,chienbank,chienprerundone,'chienbankreg',0.0,'',false);




    pirelab.getMultiPortSwitchComp(topNet,[ramrdbank,packetlength],currentlength,...
    1,1,'floor','Wrap','currentlengthmux');


    pirelab.getMultiPortSwitchComp(topNet,[ramrdbank,bankvalid],rdbankvalid,...
    1,1,'floor','Wrap','bankvalidmux');
    pirelab.getConstComp(topNet,oneaddrcount,1,'oneaddrconst');
    pirelab.getSubComp(topNet,[currentlength,oneaddrcount],currentlensub,'Floor','Wrap');

    pirelab.getRelOpComp(topNet,[ramrdcount,currentlength],endcompare,'==');
    pirelab.getBitwiseOpComp(topNet,[endcompare,rdbankvalid],preendout,'AND');






    masseyNet=this.elabMassey(topNet,blockInfo,rate);
    masseyNet.addComment('Berklekamp-Massey State-machine');

    for ii=1:2*corr
        inports(ii)=finalsyndromereg(ii);
        outports(ii)=errlocpoly(ii);
    end
    inports(ii+1)=syndromeStartDelay3;
    outports(ii+1)=fsmdone;
    outports(ii+2)=errlocpolysub;
    outports(ii+3)=errlocpolylen;

    pirelab.instantiateNetwork(topNet,masseyNet,inports,outports,'masseyNet_inst');

    moduloconst=newDataSignal(topNet,'moduloconst',inType,rate);
    pirelab.getConstComp(topNet,moduloconst,2.^wordSize-1,'modconst');

    onebit=newControlSignal(topNet,'onebit',rate);
    pirelab.getConstComp(topNet,onebit,1,'onebitconst');
    zerobit=newControlSignal(topNet,'zerobit',rate);
    pirelab.getConstComp(topNet,zerobit,0,'zerobitconst');

    nroots=newDataSignal(topNet,'nroots',countType,rate);
    nrootsdelayed=newDataSignal(topNet,'nrootsdelayed',countType,rate);
    nrootsreg=newDataSignal(topNet,'nrootsreg',countType,rate);
    nrootsstart=newDataSignal(topNet,'nrootsstart',countType,rate);

    anyerr=newControlSignal(topNet,'anyerr',rate);
    comparepolylen=newControlSignal(topNet,'comparepolylen',rate);
    comparepolylen1=newControlSignal(topNet,'comparepolylen1',rate);



    convrun=newControlSignal(topNet,'convrun',rate);

    convnotdone=newControlSignal(topNet,'convnotdone',rate);
    convdonenext=newControlSignal(topNet,'convdonenext',rate);
    convrunnext=newControlSignal(topNet,'convrunnext',rate);
    convcontinue=newControlSignal(topNet,'convcontinue',rate);

    convdonedelay1=newControlSignal(topNet,'convdonedelay1',rate);
    notconvdonedelay1=newControlSignal(topNet,'notconvdonedelay1',rate);

    omegacount=newDataSignal(topNet,'omegacount',countType,rate);
    convcount=newDataSignal(topNet,'convcount',countType,rate);
    errlocaddr=newDataSignal(topNet,'errlocaddr',countType,rate);
    omegacounten=newControlSignal(topNet,'omegacounten',rate);
    convcountreset=newControlSignal(topNet,'convcountreset',rate);
    innerdone=newControlSignal(topNet,'innerdone',rate);
    omegadone=newControlSignal(topNet,'omegadone',rate);

    convsyndrome=newDataSignal(topNet,'convsyndrome',inType,rate);
    converrloc=newDataSignal(topNet,'converrloc',inType,rate);

    convsyndromelog=newDataSignal(topNet,'convsyndromelog',inType,rate);
    converrloclog=newDataSignal(topNet,'converrloclog',inType,rate);
    convlogadd=newDataSignal(topNet,'convlogadd',carryType,rate);
    convlogwrap=newControlSignal(topNet,'convlogwrap',rate);
    convsynzero=newControlSignal(topNet,'convsynzero',rate);
    converrzero=newControlSignal(topNet,'converrzero',rate);
    convzero=newControlSignal(topNet,'convzero',rate);

    convlogaddreduced=newDataSignal(topNet,'convlogaddreduced',inType,rate);
    convlogslice=newDataSignal(topNet,'convlogslice',inType,rate);
    convmodresult=newDataSignal(topNet,'convmodresult',inType,rate);
    convalogout=newDataSignal(topNet,'convalogout',inType,rate);
    convresult=newDataSignal(topNet,'convresult',inType,rate);
    convxor=newDataSignal(topNet,'convxor',inType,rate);
    omegapolymux=newDataSignal(topNet,'omegapolymux',inType,rate);

    omegapoweren=newControlSignal(topNet,'omegapoweren',rate);

    chienvalue=newDataSignal(topNet,'chienvalue',inType,rate);
    chienprevalue=newDataSignal(topNet,'chienprevalue',inType,rate);
    chienzero=newControlSignal(topNet,'chienzero',rate);
    chienprezero=newControlSignal(topNet,'chienprezero',rate);
    chienprezerogated=newControlSignal(topNet,'chienprezerogated',rate);
    omegavalue=newDataSignal(topNet,'omegavalue',inType,rate);
    omegazero=newControlSignal(topNet,'omegazero',rate);
    derivvalue=newDataSignal(topNet,'derivvalue',inType,rate);
    derivzero=newControlSignal(topNet,'derivzero',rate);
    derivvaluelog=newDataSignal(topNet,'derivvaluelog',inType,rate);
    derivinvlog=newDataSignal(topNet,'derivvaluelog',inType,rate);
    omegavaluelog=newDataSignal(topNet,'omegavaluelog',inType,rate);
    correctlogadd=newDataSignal(topNet,'correctlogadd',carryType,rate);
    correctlogwrap=newControlSignal(topNet,'correctlogwrap',rate);
    correctlogaddreduced=newDataSignal(topNet,'correctlogaddreduced',inType,rate);
    correctlogslice=newDataSignal(topNet,'correctlogslice',inType,rate);
    correctmodresult=newDataSignal(topNet,'correctmodresult',inType,rate);
    correctalogout=newDataSignal(topNet,'correctalogout',inType,rate);
    correctresult=newDataSignal(topNet,'correctresult',inType,rate);
    correctzero=newControlSignal(topNet,'correctzero',rate);
    chiennotzero=newControlSignal(topNet,'chiennotzero',rate);
    chienzeroroot=newControlSignal(topNet,'chienzeroroot',rate);
    loadroots=newControlSignal(topNet,'loadroots',rate);

    prerootclken=newControlSignal(topNet,'prerootclken',rate);
    prerootswitch=newControlSignal(topNet,'prerootswitch',rate);
    preroothold=newControlSignal(topNet,'preroothold',rate);
    uncorrectedpreroot=newControlSignal(topNet,'uncorrectedpreroot',rate);
    forceerrorroot=newControlSignal(topNet,'forceerrorroot',rate);
    chienuncorrectedroot=newControlSignal(topNet,'chienuncorrectedroot',rate);
    uncorrectedroot=newControlSignal(topNet,'uncorrectedroot',rate);
    uncorrectednext=newControlSignal(topNet,'uncorrectednext',rate);
    uncorrected=newControlSignal(topNet,'uncorrected',rate);



    derivvaluelogdelay=newDataSignal(topNet,'derivvaluelogdelay',inType,rate);
    omegavaluelogdelay=newDataSignal(topNet,'omegavaluelogdelay',inType,rate);


    chienprerundonedelay=newControlSignal(topNet,'chienprerundonedelay',rate);
    correctzerodelay=newControlSignal(topNet,'correctzerodelay',rate);



    for ii=1:2*corr
        chiensyndrome(ii)=newDataSignal(topNet,sprintf('chien%dsynreg',ii),inType,rate);%#ok  % piped along

        chienreg(ii)=newDataSignal(topNet,sprintf('chien%dreg',ii),inType,rate);%#ok
        chienregnext(ii)=newDataSignal(topNet,sprintf('chienreg%dnext',ii),inType,rate);%#ok
        chienpowertable(ii)=newDataSignal(topNet,sprintf('chien%dpowertable',ii),inType,rate);%#ok
        chienupdate(ii)=newDataSignal(topNet,sprintf('chien%dupdate',ii),inType,rate);%#ok

        chienprereg(ii)=newDataSignal(topNet,sprintf('chien%dprereg',ii),inType,rate);%#ok
        chienpreregnext(ii)=newDataSignal(topNet,sprintf('chienreg%dprenext',ii),inType,rate);%#ok
        chienprepowertable(ii)=newDataSignal(topNet,sprintf('chien%dprepowertable',ii),inType,rate);%#ok
        chienpreupdate(ii)=newDataSignal(topNet,sprintf('chien%dpreupdate',ii),inType,rate);%#ok

        omegaen(ii)=newControlSignal(topNet,sprintf('omega%den',ii),rate);%#ok
        omegacomp(ii)=newControlSignal(topNet,sprintf('omega%dcomp',ii),rate);%#ok
        omegaupdate(ii)=newControlSignal(topNet,sprintf('omega%dupdate',ii),rate);%#ok
        omegapoly(ii)=newDataSignal(topNet,sprintf('omega%dpoly',ii),inType,rate);%#ok
        omeganext(ii)=newDataSignal(topNet,sprintf('omega%dnext',ii),inType,rate);%#ok

        omegapowerreg(ii)=newDataSignal(topNet,sprintf('omega%dpowerreg',ii),inType,rate);%#ok
        omegapowernext(ii)=newDataSignal(topNet,sprintf('omega%dpowernext',ii),inType,rate);%#ok
        omegapowertable(ii)=newDataSignal(topNet,sprintf('omega%dpowertable',ii),inType,rate);%#ok

        omegaprepowerreg(ii)=newDataSignal(topNet,sprintf('omega%dprepowerreg',ii),inType,rate);%#ok
        omegaprepowernext(ii)=newDataSignal(topNet,sprintf('omega%dprepowernext',ii),inType,rate);%#ok
        omegaprepowertable(ii)=newDataSignal(topNet,sprintf('omega%dprepowertable',ii),inType,rate);%#ok

        chienprexortree(ii)=newDataSignal(topNet,sprintf('chienpre%dxortree',ii),inType,rate);%#ok
        chienxortree(ii)=newDataSignal(topNet,sprintf('chien%dxortree',ii),inType,rate);%#ok
        omegaxortree(ii)=newDataSignal(topNet,sprintf('omega%dxortree',ii),inType,rate);%#ok
        derivxortree(ii)=newDataSignal(topNet,sprintf('deriv%dxortree',ii),inType,rate);%#ok

        if ii<=corr
            chienroot(ii)=newControlSignal(topNet,sprintf('chien%droot',ii),rate);%#ok
            chienrootdelay(ii)=newControlSignal(topNet,sprintf('chien%drootdelay',ii),rate);%#ok
            errlocationreg(ii)=newDataSignal(topNet,sprintf('errlocation%dreg',ii),inType,rate);%#ok
            errlocationpipereg(ii)=newDataSignal(topNet,sprintf('errlocationpipe%dreg',ii),inType,rate);%#ok
            errlocationpiperegdelay(ii)=newDataSignal(topNet,sprintf('errlocationpipe%dregdelay',ii),inType,rate);%#ok
            errlocationnext(ii)=newDataSignal(topNet,sprintf('errlocation%dnext',ii),inType,rate);%#ok
            errvaluereg(ii)=newDataSignal(topNet,sprintf('errvalue%dreg',ii),inType,rate);%#ok
            errvaluepipereg(ii)=newDataSignal(topNet,sprintf('errvaluepipe%dreg',ii),inType,rate);%#ok
            errvaluepiperegPrestart(ii)=newDataSignal(topNet,sprintf('errvaluePrestart%dreg',ii),inType,rate);%#ok
            errvaluenext(ii)=newDataSignal(topNet,sprintf('errvalue%dnext',ii),inType,rate);%#ok
            errvalidreg(ii)=newControlSignal(topNet,sprintf('errvalid%dreg',ii),rate);%#ok
            errvalidpipereg(ii)=newControlSignal(topNet,sprintf('errvalidpipe%dreg',ii),rate);%#ok
            errvalidpiperegdelay(ii)=newControlSignal(topNet,sprintf('errvalidpipe%dregdelay',ii),rate);%#ok
            errvalidsigreg(ii)=newControlSignal(topNet,sprintf('errvalidsig%dreg',ii),rate);%#ok
            errvalidsigregdelay(ii)=newControlSignal(topNet,sprintf('errvalidsig%dregdelay',ii),rate);%#ok
            errvalidnext(ii)=newControlSignal(topNet,sprintf('errvalid%dnext',ii),rate);%#ok
            errloadreg(ii)=newControlSignal(topNet,sprintf('errload%dreg',ii),rate);%#ok
            errloadnext(ii)=newControlSignal(topNet,sprintf('errload%dnext',ii),rate);%#ok

        end
    end


    pirelab.getCounterComp(topNet,[fsmdone,omegacounten],omegacount,...
    'Count limited',...
    0.0,...
    1.0,...
    2*corr-1,...
    true,...
    false,...
    true,...
    false,...
    'omegacounter');

    pirelab.getCounterComp(topNet,[convcountreset,convrun],convcount,...
    'Count limited',...
    0.0,...
    1.0,...
    2*corr-1,...
    true,...
    false,...
    true,...
    false,...
    'convcounter');

    pirelab.getRelOpComp(topNet,[omegacount,convcount],innerdone,'==');
    pirelab.getBitwiseOpComp(topNet,[innerdone,fsmdone],convcountreset,'OR');

    pirelab.getCompareToValueComp(topNet,omegacount,omegadone,'==',2*corr-1,'omegacountcompare');
    pirelab.getBitwiseOpComp(topNet,[innerdone,convrun],omegacounten,'AND');
    pirelab.getUnitDelayComp(topNet,convrunnext,convrun,'convrunreg',0.0);
    pirelab.getBitwiseOpComp(topNet,[convrun,convnotdone],convcontinue,'AND');
    pirelab.getBitwiseOpComp(topNet,[fsmdone,convcontinue],convrunnext,'OR');
    pirelab.getBitwiseOpComp(topNet,[omegadone,innerdone],convnotdone,'NAND');
    pirelab.getBitwiseOpComp(topNet,[omegadone,innerdone],convdonenext,'AND');
    pirelab.getUnitDelayComp(topNet,convdonenext,convdone,'convdonereg',0.0);

    pirelab.getUnitDelayComp(topNet,convdone,convdonedelay1,'convdonedly1reg',0.0);



    pirelab.getMultiPortSwitchComp(topNet,[convcount,chiensyndrome],...
    convsyndrome,...
    1,1,'floor','Wrap','chiensynmux');

    pirelab.getSubComp(topNet,[omegacount,convcount],errlocaddr,'Floor','Wrap');

    pirelab.getMultiPortSwitchComp(topNet,[errlocaddr,errlocpoly],...
    converrloc,...
    1,1,'floor','Wrap','chienerrmux');

    pirelab.getMultiPortSwitchComp(topNet,[omegacount,omegapoly],...
    omegapolymux,...
    1,1,'floor','Wrap','omegaxormux');

    pirelab.getDirectLookupComp(topNet,convsyndrome,convsyndromelog,logTable,'convsynlogtable');
    pirelab.getDirectLookupComp(topNet,converrloc,converrloclog,logTable,'converrlogtable');
    pirelab.getCompareToValueComp(topNet,convsyndrome,convsynzero,'==',0,'convsyncmpz');
    pirelab.getCompareToValueComp(topNet,converrloc,converrzero,'==',0,'converrcmpz');
    pirelab.getBitwiseOpComp(topNet,[convsynzero,converrzero],convzero,'OR');
    pirelab.getAddComp(topNet,[convsyndromelog,converrloclog],convlogadd,'Floor','Wrap');
    pirelab.getCompareToValueComp(topNet,convlogadd,convlogwrap,'>',2.^wordSize-1,'convmodcompare');
    pirelab.getSubComp(topNet,[convlogadd,moduloconst],convlogaddreduced,'Floor','Wrap');
    pirelab.getBitSliceComp(topNet,convlogadd,convlogslice,wordSize-1,0);
    pirelab.getSwitchComp(topNet,[convlogslice,convlogaddreduced],convmodresult,convlogwrap,'convmodmux');
    pirelab.getDirectLookupComp(topNet,convmodresult,convalogout,alogTable,'convalogtable');
    pirelab.getSwitchComp(topNet,[convalogout,zeroconst],convresult,convzero,'convzeromux');

    pirelab.getBitwiseOpComp(topNet,[omegapolymux,convresult],convxor,'XOR');





    chienpower=newDataSignal(topNet,'chienpower',inType,rate);
    chienpowerdelay=newDataSignal(topNet,'chienpowerdelay',inType,rate);
    chienrun=newControlSignal(topNet,'chienrun',rate);
    chienrunnext=newControlSignal(topNet,'chienrunnext',rate);
    chiencontinue=newControlSignal(topNet,'chiencontinue',rate);
    chiennotdone=newControlSignal(topNet,'chiennotdone',rate);
    chienpowermax=newControlSignal(topNet,'chienpowermax',rate);
    chiendone=newControlSignal(topNet,'chiendone',rate);

    chienprerun=newControlSignal(topNet,'chienprerun',rate);
    chienprerunnext=newControlSignal(topNet,'chienprerunnext',rate);
    chienpreruncontinue=newControlSignal(topNet,'chienpreruncontinue',rate);
    chienprerunnotdone=newControlSignal(topNet,'chienprerunnotdone',rate);
    chienprerundonenext=newControlSignal(topNet,'chienprerundonenext',rate);

    chienpreruncount=newDataSignal(topNet,'chienpreruncount',inType,rate);
    chienprerunsellen=newDataSignal(topNet,'chienprerunsellen',addrCountType,rate);
    chienprerunlencomp=newDataSignal(topNet,'chienprerunlencomp',addrCountType,rate);
    chienprerunlength=newDataSignal(topNet,'chienprerunlength',addrCountType,rate);
    chienprerunmax=newControlSignal(topNet,'chienprerunmax',rate);
    omegaprepoweren=newControlSignal(topNet,'omegaprepoweren',rate);


    finalordererr=newControlSignal(topNet,'finalordererr',rate);
    finalordererr1=newControlSignal(topNet,'finalordererr1',rate);
    switchctrl=newControlSignal(topNet,'switchctrl',rate);
    switchctrldelay=newControlSignal(topNet,'switchctrldelay',rate);

    convxoreven=newControlSignal(topNet,'convxoreven',rate);
    convxorodd=newControlSignal(topNet,'convxorodd',rate);
    convxorevensample=newControlSignal(topNet,'convxorevensample',rate);
    convxoroddsample=newControlSignal(topNet,'convxoroddsample',rate);
    convxorevendelay=newControlSignal(topNet,'convxorevendelay',rate);
    chiendonedelay=newControlSignal(topNet,'chiendonedelay',rate);
    convdonedelay=newControlSignal(topNet,'convdonedelay',rate);
    errcountreset=newControlSignal(topNet,'errcountreset',rate);
    errcountreset1=newControlSignal(topNet,'errcountreset1',rate);

    errcountgrtzero=newControlSignal(topNet,'errcountgrtzero',rate);
    oneconst1=newDataSignal(topNet,'oneconst1',inType,rate);
    pirelab.getConstComp(topNet,oneconst1,1,'oneconst1');


    pirelab.getUnitDelayComp(topNet,chienprerunnext,chienprerun,'chienprerunreg',0.0);
    pirelab.getBitwiseOpComp(topNet,[chienprerun,chienprerunnotdone],chienpreruncontinue,'AND');
    pirelab.getBitwiseOpComp(topNet,[convdone,chienpreruncontinue],chienprerunnext,'OR');
    pirelab.getBitwiseOpComp(topNet,chienprerundone,chienprerunnotdone,'NOT');
    pirelab.getBitwiseOpComp(topNet,[chienprerunmax,chienprerun],chienprerundonenext,'AND');
    pirelab.getUnitDelayComp(topNet,chienprerundonenext,chienprerundone,'chiendprerunonereg',0.0);

    pirelab.getCounterComp(topNet,[convdone,chienprerun],chienpreruncount,...
    'Count limited',...
    0.0,...
    1.0,...
    2^wordSize-1,...
    true,...
    false,...
    true,...
    false,...
    'chienprerunpower');



    pirelab.getMultiPortSwitchComp(topNet,[prerunbank,packetlength],chienprerunsellen,...
    1,1,'floor','Wrap','prerunlengthmux');
    pirelab.getAddComp(topNet,[chienprerunsellen,parityconstplusone],chienprerunlencomp,'Floor','Wrap');
    pirelab.getBitwiseOpComp(topNet,chienprerunlencomp,chienprerunlength,'NOT');
    pirelab.getRelOpComp(topNet,[chienpreruncount,chienprerunlength],chienprerunmax,'==');


    pirelab.getUnitDelayComp(topNet,chienrunnext,chienrun,'chienrunreg',0.0);
    pirelab.getBitwiseOpComp(topNet,[chienrun,chiennotdone],chiencontinue,'AND');
    pirelab.getBitwiseOpComp(topNet,[chienprerundone,chiencontinue],chienrunnext,'OR');
    pirelab.getBitwiseOpComp(topNet,chienpowermax,chiennotdone,'NOT');
    pirelab.getUnitDelayComp(topNet,chienpowermax,chiendone,'chiendonereg',0.0);

    pirelab.getCounterComp(topNet,[chienprerundone,chienpreruncount,chienrun],chienpower,...
    'Count limited',...
    0.0,...
    1.0,...
    2^wordSize-1,...
    false,...
    true,...
    true,...
    false,...
    'chienpower');


    pirelab.getCompareToValueComp(topNet,chienpower,chienpowermax,'==',2.^wordSize-1,'chiencompare');

    pirelab.getBitwiseOpComp(topNet,[chienprerundone,chienrun],omegapoweren,'OR');

    pirelab.getBitwiseOpComp(topNet,[convdone,chienprerun],omegaprepoweren,'OR');


    for ii=1:2*corr
        pirelab.getUnitDelayEnabledComp(topNet,finalsyndromereg(ii),chiensyndrome(ii),fsmdone,...
        'chiensynreg',0.0,'',false);

        if ii==1
            chienprepowertable(ii)=chienprereg(ii);
            chienpowertable(ii)=chienreg(ii);
        else
            pirelab.getDirectLookupComp(topNet,chienprereg(ii),chienprepowertable(ii),powerTable(ii,:),'gfomegaprepowertable');
            pirelab.getDirectLookupComp(topNet,chienreg(ii),chienpowertable(ii),powerTable(ii,:),'gfomegapowertable');
        end
        pirelab.getUnitDelayEnabledComp(topNet,chienregnext(ii),chienreg(ii),omegapoweren,...
        'chienreg',0.0,'',false);
        pirelab.getSwitchComp(topNet,[chienpowertable(ii),chienprereg(ii)],chienregnext(ii),chienprerundone,'omegapowermux');

        pirelab.getUnitDelayEnabledComp(topNet,chienpreregnext(ii),chienprereg(ii),omegaprepoweren,...
        'chienprereg',0.0,'',false);
        pirelab.getSwitchComp(topNet,[chienprepowertable(ii),errlocpoly(ii)],chienpreregnext(ii),convdone,'omegapowermux');


        pirelab.getUnitDelayEnabledComp(topNet,omeganext(ii),omegapoly(ii),omegaen(ii),...
        'errlocpolyreg',0.0,'',false);
        pirelab.getSwitchComp(topNet,[convxor,zeroconst],omeganext(ii),fsmdone,'omegamux');
        pirelab.getCompareToValueComp(topNet,omegacount,omegacomp(ii),'==',ii-1,'convmodcompare');
        pirelab.getBitwiseOpComp(topNet,[omegacomp(ii),convrun],omegaupdate(ii),'AND');
        pirelab.getBitwiseOpComp(topNet,[fsmdone,omegaupdate(ii)],omegaen(ii),'OR');

        if ii==1
            omegaprepowertable(ii)=omegaprepowerreg(ii);
            omegapowertable(ii)=omegapowerreg(ii);
        else
            pirelab.getDirectLookupComp(topNet,omegaprepowerreg(ii),omegaprepowertable(ii),powerTable(ii,:),'gfomegaprepowertable');
            pirelab.getDirectLookupComp(topNet,omegapowerreg(ii),omegapowertable(ii),powerTable(ii,:),'gfomegapowertable');
        end
        pirelab.getUnitDelayEnabledComp(topNet,omegaprepowernext(ii),omegaprepowerreg(ii),omegaprepoweren,...
        'omegaprepowerreg',0.0,'',false);
        pirelab.getSwitchComp(topNet,[omegaprepowertable(ii),omegapoly(ii)],omegaprepowernext(ii),convdone,'omegaprepowermux');

        pirelab.getUnitDelayEnabledComp(topNet,omegapowernext(ii),omegapowerreg(ii),omegapoweren,...
        'omegapowerreg',0.0,'',false);
        pirelab.getSwitchComp(topNet,[omegapowertable(ii),omegaprepowerreg(ii)],omegapowernext(ii),chienprerundone,'omegapowermux');



        if corr==1
            if ii==2*corr
                pirelab.getBitwiseOpComp(topNet,[chienprexortree(ii-1),chienprereg(ii)],chienprevalue,'XOR');
                pirelab.getBitwiseOpComp(topNet,[chienxortree(ii-1),chienreg(ii)],chienvalue,'XOR');
                pirelab.getBitwiseOpComp(topNet,[omegaxortree(ii-1),omegapowerreg(ii)],omegavalue,'XOR');

                pirelab.getBitwiseOpComp(topNet,[zeroconst,chienreg(ii)],derivvalue,'XOR');

            elseif ii==1

            end
        else
            if ii==2*corr
                pirelab.getBitwiseOpComp(topNet,[chienprexortree(ii-1),chienprereg(ii)],chienprevalue,'XOR');
                pirelab.getBitwiseOpComp(topNet,[chienxortree(ii-1),chienreg(ii)],chienvalue,'XOR');
                pirelab.getBitwiseOpComp(topNet,[omegaxortree(ii-1),omegapowerreg(ii)],omegavalue,'XOR');

                pirelab.getBitwiseOpComp(topNet,[derivxortree(ii-2),chienreg(ii)],derivvalue,'XOR');

            elseif ii==1

            elseif ii==2
                pirelab.getBitwiseOpComp(topNet,[chienprereg(ii-1),chienprereg(ii)],chienprexortree(ii),'XOR');
                pirelab.getBitwiseOpComp(topNet,[chienreg(ii-1),chienreg(ii)],chienxortree(ii),'XOR');
                pirelab.getBitwiseOpComp(topNet,[omegapowerreg(ii-1),omegapowerreg(ii)],omegaxortree(ii),'XOR');
                derivxortree(ii)=chienreg(ii);
            else
                pirelab.getBitwiseOpComp(topNet,[chienprexortree(ii-1),chienprereg(ii)],chienprexortree(ii),'XOR');
                pirelab.getBitwiseOpComp(topNet,[chienxortree(ii-1),chienreg(ii)],chienxortree(ii),'XOR');
                pirelab.getBitwiseOpComp(topNet,[omegaxortree(ii-1),omegapowerreg(ii)],omegaxortree(ii),'XOR');
                if mod(ii,2)==0
                    pirelab.getBitwiseOpComp(topNet,[derivxortree(ii-2),chienreg(ii)],derivxortree(ii),'XOR');
                end
            end
        end



        if ii<=corr
            if ii==1
                pirelab.getSwitchComp(topNet,[zerobit,onebit],errloadnext(ii),chienprerundone,'errloadmux');
                pirelab.getSwitchComp(topNet,[onebit,zerobit],errvalidnext(ii),chienprerundone,'errvalidmux');
            else
                pirelab.getSwitchComp(topNet,[errloadreg(ii-1),zerobit],errloadnext(ii),chienprerundone,'errloadmux');
                pirelab.getSwitchComp(topNet,[errvalidreg(ii-1),zerobit],errvalidnext(ii),chienprerundone,'errvalidmux');
            end
            pirelab.getUnitDelayComp(topNet,chienroot(ii),chienrootdelay(ii));
            pirelab.getBitwiseOpComp(topNet,[chienzeroroot,errloadreg(ii)],chienroot(ii),'AND');

            pirelab.getUnitDelayEnabledComp(topNet,errlocationnext(ii),errlocationreg(ii),chienroot(ii),...
            'errlocreg',0.0,'',false);
            pirelab.getSwitchComp(topNet,[chienpower,zeroconst],errlocationnext(ii),chienprerundone,'errlocationmux');

            pirelab.getUnitDelayEnabledComp(topNet,errvaluenext(ii),errvaluereg(ii),chienrootdelay(ii),...
            'errvalreg',0.0,'',false);
            pirelab.getSwitchComp(topNet,[correctresult,zeroconst],errvaluenext(ii),chienprerundonedelay,'errvaluemux');

            pirelab.getUnitDelayEnabledComp(topNet,errvalidnext(ii),errvalidreg(ii),loadroots,...
            'errvldreg',0.0,'',false);

            pirelab.getUnitDelayEnabledComp(topNet,errloadnext(ii),errloadreg(ii),loadroots,...
            'errldreg',0.0,'',false);

            pirelab.getUnitDelayEnabledComp(topNet,errlocationreg(ii),errlocationpipereg(ii),chiendone,...
            'errlocpipereg',0.0,'',false);
            pirelab.getUnitDelayEnabledComp(topNet,errvaluereg(ii),errvaluepipereg(ii),chiendonedelay,...
            'errvalpipereg',0.0,'',false);
            pirelab.getUnitDelayEnabledComp(topNet,errvalidnext(ii),errvalidpipereg(ii),chiendone,...
            'errvldpipereg',0.0,'',false);
            pirelab.getUnitDelayEnabledComp(topNet,errvalidreg(ii),errvalidsigreg(ii),chiendone,...
            'errvldsigpipereg',0.0,'',false);
            pirelab.getUnitDelayEnabledComp(topNet,errvaluepipereg(ii),errvaluepiperegPrestart(ii),prestartcurbankdelay,...
            'errvaluepiperegPrestart',0.0,'',false);
            pirelab.getUnitDelayEnabledComp(topNet,errlocationpipereg(ii),errlocationpiperegdelay(ii),prestartcurbankdelay);
            pirelab.getUnitDelayEnabledComp(topNet,errvalidpipereg(ii),errvalidpiperegdelay(ii),prestartcurbankdelay);
            pirelab.getUnitDelayEnabledComp(topNet,errvalidsigreg(ii),errvalidsigregdelay(ii),prestartcurbankdelay);
        end

    end
    pirelab.getUnitDelayComp(topNet,prestartcurbank,prestartcurbankdelay);

    pirelab.getUnitDelayComp(topNet,omegavaluelog,omegavaluelogdelay);
    pirelab.getUnitDelayComp(topNet,derivvaluelog,derivvaluelogdelay);



    pirelab.getUnitDelayComp(topNet,chienprerundone,chienprerundonedelay);


    pirelab.getBitwiseOpComp(topNet,[chienrun,chienzero],chienzeroroot,'AND');
    pirelab.getBitwiseOpComp(topNet,[chienzeroroot,chienprerundone],loadroots,'OR');

    pirelab.getBitwiseOpComp(topNet,[chienzeroroot,errvalidreg(corr)],chienuncorrectedroot,'AND');

    pirelab.getBitwiseOpComp(topNet,[chienuncorrectedroot,forceerrorroot],uncorrectedroot,'OR');


    pirelab.getUnitDelayEnabledComp(topNet,uncorrectednext,uncorrected,uncorrectedroot,...
    'uncorrectedreg',0.0,'',false);
    pirelab.getSwitchComp(topNet,[onebit,zerobit],uncorrectednext,chienprerundone,'uncorrectedmux');




    errInFirstLoc=newControlSignal(topNet,'errInFirstLoc',rate);
    pirelab.getBitwiseOpComp(topNet,[chienprerundonedelay,chienzeroroot],errInFirstLoc,'AND');












    loadValue=newDataSignal(topNet,'loadValue',countType,rate);
    pirelab.getSwitchComp(topNet,[zeroconst,oneconst],loadValue,errInFirstLoc);
    pirelab.getCounterComp(topNet,[chienprerundonedelay,loadValue,chienzeroroot],nroots,...
    'Count limited',...
    0.0,...
    1.0,...
    2*corr-1,...
    false,...
    true,...
    true,...
    false,...
    'nrootscount');


    pirelab.getCompareToValueComp(topNet,chienprevalue,chienprezero,'==',0,'chienprezerocompare');
    pirelab.getBitwiseOpComp(topNet,[convdone,chienprerun],prerootclken,'OR');



    pirelab.getBitwiseOpComp(topNet,convdonedelay1,notconvdonedelay1,'NOT');

    pirelab.getBitwiseOpComp(topNet,[chienprezero,notconvdonedelay1,haserrorsconvreg],chienprezerogated,'AND');

    pirelab.getBitwiseOpComp(topNet,[chienprezerogated,uncorrectedpreroot],preroothold,'OR');

    pirelab.getSwitchComp(topNet,[preroothold,zerobit],prerootswitch,convdone,'prerootmux');

    pirelab.getUnitDelayEnabledComp(topNet,prerootswitch,uncorrectedpreroot,prerootclken,...
    'uncorrectedprereg',0.0,'',false);
    pirelab.getUnitDelayEnabledComp(topNet,uncorrectedpreroot,forceerrorroot,chienprerundone,...
    'forceerrorreg',0.0,'',false);


    pirelab.getCompareToValueComp(topNet,chienvalue,chienzero,'==',0,'chienzerocompare');
    pirelab.getBitwiseOpComp(topNet,chienzero,chiennotzero,'NOT');

    pirelab.getCompareToValueComp(topNet,derivvalue,derivzero,'==',0,'derivzerocompare');
    pirelab.getCompareToValueComp(topNet,omegavalue,omegazero,'==',0,'omegazerocompare');

    pirelab.getDirectLookupComp(topNet,derivvalue,derivvaluelog,logTable,'derivlogtable');
    pirelab.getSubComp(topNet,[moduloconst,derivvaluelogdelay],derivinvlog,'Floor','Wrap');

    pirelab.getDirectLookupComp(topNet,omegavalue,omegavaluelog,logTable,'omegalogtable');

    pirelab.getAddComp(topNet,[derivinvlog,omegavaluelogdelay],correctlogadd,'Floor','Wrap');
    pirelab.getCompareToValueComp(topNet,correctlogadd,correctlogwrap,'>',2.^wordSize-1,'correctmodcompare');
    pirelab.getSubComp(topNet,[correctlogadd,moduloconst],correctlogaddreduced,'Floor','Wrap');
    pirelab.getBitSliceComp(topNet,correctlogadd,correctlogslice,wordSize-1,0);
    pirelab.getSwitchComp(topNet,[correctlogslice,correctlogaddreduced],correctmodresult,correctlogwrap,'correctmodmux');

    pirelab.getBitwiseOpComp(topNet,[omegazero,chiennotzero],correctzero,'OR');
    pirelab.getUnitDelayComp(topNet,correctzero,correctzerodelay);
    if B==0
        pirelab.getDirectLookupComp(topNet,correctmodresult,correctalogout,alogTable,'correctalogtable');
        pirelab.getSwitchComp(topNet,[correctalogout,zeroconst],correctresult,correctzerodelay,'correctzeromux');
    elseif B==1
        b1logadd=newDataSignal(topNet,'b1logadd',carryType,rate);
        b1logwrap=newControlSignal(topNet,'b1logwrap',rate);
        b1logaddreduced=newDataSignal(topNet,'b1logaddreduced',inType,rate);
        b1logslice=newDataSignal(topNet,'b1logslice',inType,rate);
        b1modresult=newDataSignal(topNet,'b1modresult',inType,rate);
        pirelab.getUnitDelayComp(topNet,chienpower,chienpowerdelay);
        pirelab.getAddComp(topNet,[correctmodresult,chienpowerdelay],b1logadd,'Floor','Wrap');
        pirelab.getCompareToValueComp(topNet,b1logadd,b1logwrap,'>',2.^wordSize-1,'b1modcompare');
        pirelab.getSubComp(topNet,[b1logadd,moduloconst],b1logaddreduced,'Floor','Wrap');
        pirelab.getBitSliceComp(topNet,b1logadd,b1logslice,wordSize-1,0);
        pirelab.getSwitchComp(topNet,[b1logslice,b1logaddreduced],b1modresult,b1logwrap,'b1modmux');

        pirelab.getDirectLookupComp(topNet,b1modresult,correctalogout,alogTable,'correctalogtable');
        pirelab.getSwitchComp(topNet,[correctalogout,zeroconst],correctresult,correctzerodelay,'correctzeromux');
    else
        b1logadd=newDataSignal(topNet,'b1logadd',carryType,rate);
        b1logwrap=newControlSignal(topNet,'b1logwrap',rate);
        b1logaddreduced=newDataSignal(topNet,'b1logaddreduced',inType,rate);
        b1logslice=newDataSignal(topNet,'b1logslice',inType,rate);
        b1modresult=newDataSignal(topNet,'b1modresult',inType,rate);
        baccum=newDataSignal(topNet,'baccum',inType,rate);
        pirelab.getUnitDelayComp(topNet,chienpower,chienpowerdelay);
        btable=ufi(mod((0:(2^wordSize-1))*B,2^wordSize-1),wordSize,0);
        pirelab.getDirectLookupComp(topNet,chienpowerdelay,baccum,btable,'bcorrecttable');

        pirelab.getAddComp(topNet,[correctmodresult,baccum],b1logadd,'Floor','Wrap');
        pirelab.getCompareToValueComp(topNet,b1logadd,b1logwrap,'>',2.^wordSize-1,'b1modcompare');
        pirelab.getSubComp(topNet,[b1logadd,moduloconst],b1logaddreduced,'Floor','Wrap');
        pirelab.getBitSliceComp(topNet,b1logadd,b1logslice,wordSize-1,0);
        pirelab.getSwitchComp(topNet,[b1logslice,b1logaddreduced],b1modresult,b1logwrap,'b1modmux');

        pirelab.getDirectLookupComp(topNet,b1modresult,correctalogout,alogTable,'correctalogtable');
        pirelab.getSwitchComp(topNet,[correctalogout,zeroconst],correctresult,correctzerodelay,'correctzeromux');
    end





    errcountvalue=newDataSignal(topNet,'errcountvalue',inType,rate);
    errcount=newDataSignal(topNet,'errcount',inType,rate);
    errlocation=newDataSignal(topNet,'errlocation',inType,rate);
    errvalue=newDataSignal(topNet,'errvalue',inType,rate);
    errvalid=newControlSignal(topNet,'errvalid',rate);
    erradvance=newControlSignal(topNet,'erradvance',rate);
    erroffset=newDataSignal(topNet,'erroffset',inType,rate);
    fulllength=newDataSignal(topNet,'fulllength',inType,rate);
    finalerrloc=newDataSignal(topNet,'finalerrloc',inType,rate);
    errgate=newControlSignal(topNet,'errgate',rate);
    notuncorrect=newControlSignal(topNet,'notuncorrect',rate);
    anyuncorrect=newControlSignal(topNet,'anyuncorrect',rate);
    anyuncorrectreg=newControlSignal(topNet,'anyuncorrectreg',rate);
    errcountuncheckSampled=newControlSignal(topNet,'errcountuncheckSampled',rate);


    errcountuncheck=newControlSignal(topNet,'errcountuncheck',rate);
    polylen=newDataSignal(topNet,'oneconst',countType,rate);
    pirelab.getConstComp(topNet,polylen,2*corr-1,'polylen');
















    pirelab.getCounterComp(topNet,[errcountreset,prestartcurbankdelay,oneconst1,erradvance],errcountvalue,...
    'Count limited',...
    0.0,...
    1.0,...
    2*corr-1,...
    true,...
    true,...
    true,...
    false,...
    'errcounter');

    pirelab.getUnitDelayEnabledComp(topNet,errcountuncheck,errcountuncheckSampled,prestartcurbankdelay);
    pirelab.getBitwiseOpComp(topNet,[errcountgrtzero,errgate,errcountuncheckSampled],erradvance,'AND');
    pirelab.getCompareToValueComp(topNet,errcountvalue,errcountgrtzero,'>',0);
    pirelab.getRelOpComp(topNet,[errcountvalue,nrootsstart],errcountreset1,'==');
    pirelab.getBitwiseOpComp(topNet,[errgate,errcountreset1],errcountreset,'AND');

    pirelab.getSubComp(topNet,[errcountvalue,oneconst],errcount,'Floor','Wrap');

    pirelab.getMultiPortSwitchComp(topNet,[errcount,errlocationpiperegdelay],...
    errlocation,...
    1,1,'floor','Wrap','errmux');
    pirelab.getMultiPortSwitchComp(topNet,[errcount,errvaluepiperegPrestart],...
    errvalue,...
    1,1,'floor','Wrap','errmux');
    pirelab.getMultiPortSwitchComp(topNet,[errcount,errvalidpiperegdelay],...
    errvalid,...
    1,1,'floor','Wrap','errmux');

    pirelab.getAddComp(topNet,[currentlength,parityconst],fulllength,'Floor','Wrap');
    pirelab.getBitwiseOpComp(topNet,fulllength,erroffset,'NOT');
    pirelab.getSubComp(topNet,[errlocation,erroffset],finalerrloc,'Floor','Wrap');
    pirelab.getRelOpComp(topNet,[finalerrloc,ramrdcount],errgate,'==');

    pirelab.getBitwiseOpComp(topNet,comparepolylen,errcountuncheck,'NOT');

    pirelab.getBitwiseOpComp(topNet,uncorrected,notuncorrect,'NOT');


    pirelab.getSwitchComp(topNet,[zeroconst,errvalue],correctionnext,erradvance,'correctmux');

    pirelab.getUnitDelayComp(topNet,correctionnext,correction,'correctreg',0.0);


    pirelab.getUnitDelayEnabledComp(topNet,haserrorsreg,haserrorsfsmreg,fsmdone,'synhaserrfsmreg',0.0,'',false);

    pirelab.getUnitDelayEnabledComp(topNet,haserrorsfsmreg,haserrorsconvreg,convdone,'synhaserrconvreg',0.0,'',false);

    pirelab.getUnitDelayEnabledComp(topNet,haserrorsconvreg,haserrorschienprereg,chienprerundone,'synhaserrchienprereg',0.0,'',false);

    pirelab.getUnitDelayEnabledComp(topNet,haserrorschienprereg,haserrorschienreg,chiendone,'synhaserrchienreg',0.0,'',false);

    pirelab.getUnitDelayComp(topNet,nroots,nrootsdelayed,'nrootsdelayed1',0.0);
    pirelab.getUnitDelayEnabledComp(topNet,nrootsdelayed,nrootsreg,chiendonedelay,'nrootsregproc',0.0,'',false);

    pirelab.getUnitDelayEnabledComp(topNet,anyuncorrect,anyuncorrectreg,prestartout,'anyuncreg',0.0,'',false);

    pirelab.getUnitDelayEnabledComp(topNet,nrootsreg,nrootsstart,prestartout,'nrootsstartEnb',0.0,'',false);


    pirelab.getBitwiseOpComp(topNet,[errvalidsigregdelay(:);haserrorschienreg],anyerr,'OR');




    chiendonedelay2=newControlSignal(topNet,'chiendonedelay2',rate);
    pirelab.getUnitDelayComp(topNet,chiendone,chiendonedelay,'0.0');
    pirelab.getUnitDelayComp(topNet,chiendonedelay,chiendonedelay2,'0.0');
    pirelab.getUnitDelayComp(topNet,convdone,convdonedelay,'0.0');

    pirelab.getBitwiseOpComp(topNet,[convdonedelay,convxorevendelay],convxoreven,'XOR');
    pirelab.getUnitDelayComp(topNet,convxoreven,convxorevendelay,'0.0');

    pirelab.getBitwiseOpComp(topNet,convxoreven,convxorodd,'NOT');

    pirelab.getBitwiseOpComp(topNet,[convdonedelay,convxoreven],convxorevensample,'AND');
    pirelab.getBitwiseOpComp(topNet,[convdonedelay,convxorodd],convxoroddsample,'AND');


    pirelab.getUnitDelayEnabledComp(topNet,errlocpolylenconv,errlocpolylenconveven,convxorevensample,'ordererr2',0.0,'',false);
    pirelab.getUnitDelayEnabledComp(topNet,errlocpolylenconv,errlocpolylenconvodd,convxoroddsample,'ordererr3',0.0,'',false);

    pirelab.getBitwiseOpComp(topNet,[chiendone,switchctrldelay],switchctrl,'XOR');
    pirelab.getUnitDelayComp(topNet,switchctrl,switchctrldelay,'0.0');

    pirelab.getSwitchComp(topNet,[errlocpolylenconvodd,errlocpolylenconveven],errlocpolylenchien,switchctrl,'ordererrmux');
    pirelab.getSubComp(topNet,[errlocpolylenchien,oneconst],errlocpolylenminusone,'Floor','Wrap');
    pirelab.getUnitDelayEnabledComp(topNet,errlocpolylen,errlocpolylenconv,convdone,'errlocpolylendelayed',0.0,'',false);

    pirelab.getUnitDelayEnabledComp(topNet,errlocpolysub,errlocpolysubconv,convdone,'errlocpolysubconvReg',0.0,'',false);
    pirelab.getUnitDelayEnabledComp(topNet,errlocpolysubconv,errlocpolysubchien,chiendone,'errlocpolysubchienReg',0.0,'',false);

    pirelab.getRelOpComp(topNet,[errlocpolylenminusone,nrootsreg],comparepolylen,'>');

    pirelab.getRelOpComp(topNet,[errlocpolylenchien,nrootsreg],comparepolylen1,'>');


    pirelab.getUnitDelayEnabledComp(topNet,comparepolylen1,finalordererr,chiendonedelay2,'finalordererrDelay',0.0,'',false);
    pirelab.getUnitDelayEnabledComp(topNet,finalordererr,finalordererr1,prestartout,'finalordererr1Delay',0.0,'',false);




    pirelab.getBitwiseOpComp(topNet,[finalordererr1,preendout],preerrout,'AND');










    for ii=1:numPackets
        delaycount(ii)=newDataSignal(topNet,['delay%dcount',(ii-1)],delayType,rate);%#ok
    end

    for ii=1:numPackets
        delaymax(ii)=newControlSignal(topNet,['delay%dmax',(ii-1)],rate);%#ok
    end

    for ii=1:numPackets
        prestartbank(ii)=newControlSignal(topNet,['prestartbank%d',(ii-1)],rate);%#ok
    end
    delayBankCount=newDataSignal(topNet,'delayBankCount',addrBankType,rate);
    pirelab.getCounterComp(topNet,[ramwrbanken],delayBankCount,...
    'Count limited',...
    0.0,...
    1.0,...
    numPackets-1,...
    false,...
    false,...
    true,...
    false,...
    ['delayBankCounter']);

    for ii=1:numPackets
        startReadSetValidTemp(ii)=newControlSignal(topNet,['startReadSetValidTemp_',num2str(ii)],rate);
        pirelab.getCompareToValueComp(topNet,delayBankCount,startReadSetValidTemp(ii),'==',ii-1);
        pirelab.getBitwiseOpComp(topNet,[actualendInDelay,startReadSetValidTemp(ii)],startReadSetValid(ii),'AND');

        pirelab.getCounterComp(topNet,[startReadSetValid(ii),bankvalid(ii)],delaycount(ii),...
        'Count limited',...
        0.0,...
        1.0,...
        2^delayWordSize-1,...
        true,...
        false,...
        true,...
        false,...
        ['d%dcount',(ii-1)]);
    end
    for ii=1:numPackets
        pirelab.getCompareToValueComp(topNet,delaycount(ii),delaymax(ii),'==',2^delayWordSize-4,['d%dmaxcompare',(ii-1)]);
    end

    for ii=1:numPackets
        pirelab.getBitwiseOpComp(topNet,[bankvalid(ii),delaymax(ii)],prestartbank(ii),'AND');
    end


    pirelab.getBitwiseOpComp(topNet,prestartbank,prestartcurbank,'OR');
    pirelab.getUnitDelayComp(topNet,prestartcurbankdelay,prestartout,'prestartbankreg',0.0);



    pirelab.getUnitDelayComp(topNet,ramrdennext,ramrden,'ramrdenreg',0.0);
    pirelab.getBitwiseOpComp(topNet,[ramrdencontinue,prestartout],ramrdennext,'OR');
    pirelab.getBitwiseOpComp(topNet,[ramrden,notcountstop],ramrdencontinue,'AND');
    pirelab.getBitwiseOpComp(topNet,preendout,notcountstop,'NOT');

    pirelab.getBitwiseOpComp(topNet,[ramrdennext,preendout],prevalidout,'OR');





    pirelab.getBitwiseOpComp(topNet,[ramrddata,correction],predataout,'XOR');
    pirelab.getSwitchComp(topNet,[zeroconst,predataout],gatedataout,p2dvout,'gatemux');
    pirelab.getUnitDelayComp(topNet,gatedataout,output,'dataoutputreg',0.0);

    pirelab.getUnitDelayComp(topNet,prevalidout,p2dvout,'dv2reg',0.0);
    pirelab.getUnitDelayComp(topNet,prestartout,p2startout,'start2reg',0.0);
    pirelab.getUnitDelayComp(topNet,preendout,p2endout,'end2reg',0.0);
    pirelab.getUnitDelayComp(topNet,preerrout,p2errout,'err2reg',0.0);

    pirelab.getUnitDelayComp(topNet,p2dvout,validOut,'dvoutputreg',0.0);
    pirelab.getUnitDelayComp(topNet,p2startout,startOut,'startoutputreg',0.0);
    pirelab.getUnitDelayComp(topNet,p2endout,endOut,'endoutputreg',0.0);
    pirelab.getUnitDelayComp(topNet,p2errout,errOut,'erroutputreg',0.0);


    if hasErrPort
        notp2errout=newControlSignal(topNet,'notp2errout',rate);
        numerrgate=newControlSignal(topNet,'numerrgate',rate);

        pirelab.getDTCComp(topNet,nrootsstart,p2numerr);
        pirelab.getBitwiseOpComp(topNet,p2errout,notp2errout,'NOT');
        pirelab.getBitwiseOpComp(topNet,[notp2errout,p2endout],numerrgate,'AND');
        pirelab.getSwitchComp(topNet,[zeroconst,p2numerr],prenumerr,numerrgate,'errcountmux');
        pirelab.getUnitDelayComp(topNet,prenumerr,numErrOut,'numerroutputreg',0.0);
    end

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



