function elaborateCCSDSRSDecoderNetwork(this,topNet,blockInfo,insignals,outsignals)















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
    codewordLength=255;
    I=double(blockInfo.InterleavingDepth);

    parityLength=codewordLength-messageLength;
    nI=codewordLength*I;
    if(messageLength==239)
        corr=8;
        B=120;
    else
        corr=16;
        B=112;
    end

    [~,~,~,~,tPowerTable,tAntiLogTable,tLogTable,tD2C,tC2D]=HDLCCSDSRSCodeTables(messageLength);

    wordSize=8;
    D2C=ufi(tD2C,wordSize,0);
    C2D=ufi(tC2D,wordSize,0);
    powerTable=ufi(tPowerTable,wordSize,0);
    alogTable=ufi([uint8(1);tAntiLogTable],wordSize,0);
    logTable=ufi([uint8(0);tLogTable],wordSize,0);


    inType=pir_ufixpt_t(wordSize,0);
    carryType=pir_ufixpt_t(wordSize+1,0);
    countType=pir_ufixpt_t(ceil(log2(2*corr)),0);


    bmLength=4*corr+10;
    convLength=(corr*2)*(corr*2+1)/2;
    chienLength=2.^wordSize;
    delayTotal=bmLength+convLength+chienLength;

    delayWordSize=ceil(log2(delayTotal));
    nPackets=ceil((2.^delayWordSize)/nI)+1;
    ramDepth=ceil(log2(nPackets));
    numPackets=2^ramDepth;
    delayType=pir_ufixpt_t(delayWordSize,0);
    addrType=pir_ufixpt_t(ramDepth+ceil(log2(nI)),0);
    addrCountType=pir_ufixpt_t(ceil(log2(nI)),0);
    addrBankType=pir_ufixpt_t(ramDepth,0);
    if hasErrPort
        numerrType=pir_ufixpt_t(8,0);
    end
    processingTime=bmLength+convLength;
    if processingTime>nI
        nextFrameLowTime=processingTime-nI;
    else
        nextFrameLowTime=0;
    end

    controlType=pir_ufixpt_t(1,0);


    startIn=newControlSignal(topNet,'startin_valid',rate);

    endIn_valid=newControlSignal(topNet,'endin_valid',rate);

    validIn=newControlSignal(topNet,'validIn',rate);

    sampleControlNet=this.elabSampleControl(topNet,blockInfo,rate);
    sampleControlNet.addComment('Sample control for valid start and end');




    sampleCountVal=newDataSignal(topNet,'sampleCountVal',pir_ufixpt_t(nextpow2(nI+1),0),rate);
    sampleCountMax=newControlSignal(topNet,'sampleCountRst',rate);
    sampleCountRst=newControlSignal(topNet,'sampleCountRst',rate);
    sampleCountEnb=newControlSignal(topNet,'sampleCountEnb',rate);
    falseEnd=newControlSignal(topNet,'falseEnd',rate);
    endInOr=newControlSignal(topNet,'endInOr',rate);


    notendin=topNet.addSignal(controlType,'notendin');
    inpacket=topNet.addSignal(controlType,'inpacket');
    inpacketnext=topNet.addSignal(controlType,'inpacketnext');
    notdonepacket=topNet.addSignal(controlType,'notdonepacket');
    endIn=topNet.addSignal(controlType,'endin_packet');
    oneSampleConst=newDataSignal(topNet,'oneSampleConst',pir_ufixpt_t(nextpow2(nI+1),0),rate);
    validStart=topNet.addSignal(controlType,'validStart');
    pirelab.getConstComp(topNet,oneSampleConst,1);
    pirelab.getCounterComp(topNet,[sampleCountRst,validStart,oneSampleConst,sampleCountEnb],sampleCountVal,...
    'Count limited',...
    0.0,...
    1.0,...
    nI-1,...
    true,...
    true,...
    true,...
    false,...
    'sampleCounter');

    notStartInput=topNet.addSignal(controlType,'notStartInput');
    noStEndInput=topNet.addSignal(controlType,'noStEndInput');
    maxValid=topNet.addSignal(controlType,'maxValid');

    pirelab.getBitwiseOpComp(topNet,[startInput,validIn],validStart,'AND');
    pirelab.getBitwiseOpComp(topNet,startInput,notStartInput,'NOT');
    pirelab.getBitwiseOpComp(topNet,[notStartInput,endInput,validIn],noStEndInput,'AND');

    pirelab.getBitwiseOpComp(topNet,[validIn,inpacketnext],sampleCountEnb,'AND');
    pirelab.getCompareToValueComp(topNet,sampleCountVal,sampleCountMax,'==',nI-1,'counterEnbComp');
    pirelab.getBitwiseOpComp(topNet,[sampleCountMax,validIn],maxValid,'AND');
    pirelab.getBitwiseOpComp(topNet,[maxValid,noStEndInput],sampleCountRst,'OR');
    pirelab.getBitwiseOpComp(topNet,[validIn,sampleCountRst],falseEnd,'AND');
    pirelab.getBitwiseOpComp(topNet,[falseEnd,noStEndInput],endInOr,'OR');


    inports(1)=startInput;
    inports(2)=endInOr;
    inports(3)=validInput;

    outports(1)=startIn;
    outports(2)=endIn_valid;
    outports(3)=validIn;
    pirelab.instantiateNetwork(topNet,sampleControlNet,inports,outports,'sampleControlNet_inst');



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
    endInDelay3=newControlSignal(topNet,'endInDelay3',rate);
    endInAndFinal=newControlSignal(topNet,'endInDelay3',rate);
    endInAndFinalDelay=newControlSignal(topNet,'endInDelay3',rate);
    dataInConvBasis=newDataSignal(topNet,'dataInConvBasis',inType,rate);
    endFinal=newControlSignal(topNet,'endFinal',rate);

    pirelab.getDirectLookupComp(topNet,dataIn,dataInConvBasis,D2C,'D2C_LUT');
    pirelab.getUnitDelayComp(topNet,dataInConvBasis,dataInDelay,'datainputdelay',0.0);
    pirelab.getUnitDelayComp(topNet,startIn,startInDelay,'startdelay',0.0);
    pirelab.getBitwiseOpComp(topNet,[endIn,endFinal],endInAndFinal,'AND');
    pirelab.getUnitDelayComp(topNet,endInAndFinal,endInAndFinalDelay,'enddelay',0.0);
    pirelab.getUnitDelayComp(topNet,endFinal,endInDelay,'enddelay',0.0);
    pirelab.getUnitDelayComp(topNet,endInDelay,endInDelay2,'enddelay2',0.0);
    pirelab.getUnitDelayComp(topNet,endInDelay2,endInDelay3,'enddelay3',0.0);
    pirelab.getUnitDelayComp(topNet,validIn,validInDelay,'dvdelay',0.0);

    zeroconst=newDataSignal(topNet,'zeroconst',inType,rate);
    pirelab.getConstComp(topNet,zeroconst,0,'zeroconst');

    for jj=1:I
        correctionnext(jj)=newDataSignal(topNet,'correctionnext',inType,rate);
    end
    correction=newDataSignal(topNet,'correction',inType,rate);

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




    counterEnb=newControlSignal(topNet,'counterEnb',rate);
    counterEnb1=newControlSignal(topNet,'counterEnb1',rate);
    counterVal=newDataSignal(topNet,'counterVal',pir_ufixpt_t(16,0),rate);

    oneconst=newDataSignal(topNet,'oneconst',pir_ufixpt_t(16,0),rate);
    pirelab.getConstComp(topNet,oneconst,1,'oneconst');

    clocksCount=newDataSignal(topNet,'clocksCount',pir_ufixpt_t(nextpow2(nI+1),0),rate);
    shortNextFrameCount=newDataSignal(topNet,'shortNextFrameCount',pir_ufixpt_t(nextpow2(nI),0),rate);
    clocksCountEnb=newControlSignal(topNet,'clocksCountEnb',rate);
    clocksCountMax=newControlSignal(topNet,'clocksCountMax',rate);
    shortNextFrameCountEnb1=newControlSignal(topNet,'shortNextFrameCountEnb1',rate);
    shortNextFrameCountEnb=newControlSignal(topNet,'shortNextFrameCountEnb',rate);
    shortNextFrameCountRst=newControlSignal(topNet,'shortNextFrameCountRst',rate);
    nextFrameEnb=newControlSignal(topNet,'nextFrameEnb',rate);
    clocksCountMaxMinusOne=newControlSignal(topNet,'clocksCountMaxMinusOne',rate);
    clocksCountMaxMinusOneDelay=newControlSignal(topNet,'clocksCountMaxMinusOneDelay',rate);
    endFinal1=newControlSignal(topNet,'endFinal1',rate);
    endFinal2=newControlSignal(topNet,'endFinal2',rate);
    intrlvIndCorrect=newControlSignal(topNet,'intrlvIndCorrect',rate);
    inputCWLenCorrect=newControlSignal(topNet,'inputCWLenCorrect',rate);
    endIn1=newControlSignal(topNet,'endIn1',rate);
    pirelab.getBitwiseOpComp(topNet,[shortNextFrameCountEnb,clocksCountMaxMinusOneDelay],endFinal1,'AND');
    pirelab.getBitwiseOpComp(topNet,[endIn1,clocksCountMax],endFinal2,'AND');
    pirelab.getBitwiseOpComp(topNet,[endFinal1,endFinal2],endFinal,'OR');
    pirelab.getCompareToValueComp(topNet,clocksCount,clocksCountEnb,'<',nI-2);
    pirelab.getCompareToValueComp(topNet,clocksCount,clocksCountMax,'==',nI-2);
    pirelab.getBitwiseOpComp(topNet,[shortNextFrameCountEnb1,counterEnb1],nextFrameEnb,'OR');
    pirelab.getCompareToValueComp(topNet,clocksCount,clocksCountMaxMinusOne,'==',nI-3);
    pirelab.getUnitDelayComp(topNet,clocksCountMaxMinusOne,clocksCountMaxMinusOneDelay,0.0);
    pirelab.getCompareToValueComp(topNet,counterVal,counterEnb1,'>',0);
    pirelab.getBitwiseOpComp(topNet,[endFinal,counterEnb1],counterEnb,'OR');
    pirelab.getCounterComp(topNet,[startIn,clocksCountEnb],clocksCount,...
    'Count limited',...
    0.0,...
    1.0,...
    nI-2,...
    true,...
    false,...
    true,...
    false,...
    'clocksCountcounter');

    resetValid=newControlSignal(topNet,'resetValid',rate);
    pirelab.getBitwiseOpComp(topNet,[endIn,inputCWLenCorrect,intrlvIndCorrect],endIn1,'AND');
    pirelab.getBitwiseOpComp(topNet,[shortNextFrameCountEnb1,endIn1],shortNextFrameCountEnb,'OR');
    pirelab.getCompareToValueComp(topNet,shortNextFrameCount,shortNextFrameCountEnb1,'>',0);
    pirelab.getBitwiseOpComp(topNet,[clocksCountMax,startIn],shortNextFrameCountRst,'OR');

    pirelab.getCounterComp(topNet,[shortNextFrameCountRst,shortNextFrameCountEnb],shortNextFrameCount,...
    'Count limited',...
    0.0,...
    1.0,...
    nI-1,...
    true,...
    false,...
    true,...
    false,...
    'shortNextFrameCounter');


    pirelab.getCounterComp(topNet,[startIn,counterEnb],counterVal,...
    'Count limited',...
    0.0,...
    1.0,...
    nextFrameLowTime,...
    true,...
    false,...
    true,...
    false,...
    'nextFramecounter');

    nxtFrameNet=this.elabNxtFrameCtrl(topNet,rate);
    nxtFrameNet.addComment('Next Frame Signal State Machine');

    inports1(1)=startIn;
    inports1(2)=endIn;
    inports1(3)=nextFrameEnb;
    outports1(1)=nextFrame;



    pirelab.instantiateNetwork(topNet,nxtFrameNet,inports1,outports1,'nxtFrameNet_inst');
    prestartcurbankdelay=newControlSignal(topNet,'prestartcurbankdelay',rate);



    intrlvIndIn=newDataSignal(topNet,'intrlvIndIn',pir_ufixpt_t(nextpow2(I+1+1),0),rate);
    intrlvSynCount=newDataSignal(topNet,'intrlvSynCount',pir_ufixpt_t(nextpow2(I+1),0),rate);
    intrlvOneConst=newDataSignal(topNet,'intrlvOneConst',pir_ufixpt_t(nextpow2(I+1),0),rate);
    intrlvSynCountGrtZero=newControlSignal(topNet,'intrlvSynCountGrtZero',rate);
    intrlvSynCountEnb=newControlSignal(topNet,'intrlvSynCountEnb',rate);
    intrlvSynCountRst=newControlSignal(topNet,'intrlvSynCountRst',rate);
    pirelab.getCompareToValueComp(topNet,intrlvSynCount,intrlvSynCountGrtZero,'>',0);
    pirelab.getCompareToValueComp(topNet,intrlvSynCount,intrlvSynCountRst,'==',I);
    pirelab.getBitwiseOpComp(topNet,[intrlvSynCountGrtZero,validIn],intrlvSynCountEnb,'AND');
    pirelab.getConstComp(topNet,intrlvOneConst,1);

    pirelab.getCounterComp(topNet,[intrlvSynCountRst,startIn,intrlvOneConst,intrlvSynCountEnb],intrlvSynCount,...
    'Count limited',...
    0.0,...
    1.0,...
    I,...
    true,...
    true,...
    true,...
    false,...
    'intrlvSynCounter');

    for jj=1:I
        intrlvIndFlagForSyn(jj)=newControlSignal(topNet,sprintf('intrlvIndFlagForSyn%d',jj),rate);%#ok<*AGROW>
        pirelab.getCompareToValueComp(topNet,intrlvIndIn,intrlvIndFlagForSyn(jj),'==',(jj-1),['CompareIntrlvInd%d',jj]);

        enbSynReg(jj)=newControlSignal(topNet,sprintf('enbSynReg%d',jj),rate);
        pirelab.getBitwiseOpComp(topNet,[intrlvIndFlagForSyn(jj),validInDelay],enbSynReg(jj),'AND');

        gateSwitchCtrl(jj)=newControlSignal(topNet,'gateSwitchCtrl',rate);
        pirelab.getCompareToValueComp(topNet,intrlvSynCount,gateSwitchCtrl(jj),'==',jj);

        for ii=1:(2*corr)
            xorfeedback(ii,jj)=newDataSignal(topNet,'xorfeedback',inType,rate);
            syndromereg(ii,jj)=newDataSignal(topNet,'syndromereg',inType,rate);
            finalsyndromereg(ii,jj)=newDataSignal(topNet,'finalsyndromereg',inType,rate);
            syndromegate(ii,jj)=newDataSignal(topNet,'syndromegate',inType,rate);
            powertableout(ii,jj)=newDataSignal(topNet,'powertableout',inType,rate);

            syndromezero(ii,jj)=newControlSignal(topNet,sprintf('syndrome%dzero',ii),rate);

            pirelab.getUnitDelayEnabledComp(topNet,xorfeedback(ii,jj),syndromereg(ii,jj),enbSynReg(jj),'synreg',0.0,'',false);
            pirelab.getUnitDelayEnabledComp(topNet,syndromereg(ii,jj),finalsyndromereg(ii,jj),endInDelay2,'synreg',0.0,'',false);
            pirelab.getSwitchComp(topNet,[syndromereg(ii,jj),zeroconst],syndromegate(ii,jj),gateSwitchCtrl(jj),'gateSwitchCtrl');

            pirelab.getCompareToValueComp(topNet,syndromereg(ii,jj),syndromezero(ii,jj),'==',0,'synzerocomp');

            pirelab.getDirectLookupComp(topNet,syndromegate(ii,jj),powertableout(ii,jj),powerTable(ii+B,:),'gfpowertable');
            pirelab.getBitwiseOpComp(topNet,[dataInDelay,powertableout(ii,jj)],xorfeedback(ii,jj),'XOR');
            errlocpoly(ii,jj)=newDataSignal(topNet,sprintf('errloc%d_%dpoly',ii,jj),inType,rate);
        end

    end


    for jj=1:I
        allsynzero(jj)=newControlSignal(topNet,'allsynzero',rate);
        pirelab.getBitwiseOpComp(topNet,syndromezero(:,jj),allsynzero(jj),'AND');
        notallsynzero(jj)=newControlSignal(topNet,'notallsynzero',rate);
        pirelab.getBitwiseOpComp(topNet,allsynzero(jj),notallsynzero(jj),'NOT');
        haserrorsreg(jj)=newControlSignal(topNet,'haserrorsreg',rate);
        haserrorsfsmreg(jj)=newControlSignal(topNet,'haserrorsfsmreg',rate);
        haserrorsconvreg(jj)=newControlSignal(topNet,'haserrorsconvreg',rate);
        haserrorschienprereg(jj)=newControlSignal(topNet,'haserrorschienprereg',rate);
        haserrorschienreg(jj)=newControlSignal(topNet,'haserrorschienreg',rate);

        pirelab.getUnitDelayEnabledComp(topNet,notallsynzero(jj),haserrorsreg(jj),endInDelay2,'synhaserrreg',0.0,'',false);
    end




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
    ramwrbanken1=newControlSignal(topNet,'ramwrbanken1',rate);
    ramwrbanken2=newControlSignal(topNet,'ramwrbanken2',rate);
    ramwrbanken2Comp=newControlSignal(topNet,'ramwrbanken2Comp',rate);
    inCorrectFrame=newControlSignal(topNet,'inCorrectFrame',rate);
    masseybank=newDataSignal(topNet,'masseybank',addrBankType,rate);
    convbank=newDataSignal(topNet,'convbank',addrBankType,rate);
    prerunbank=newDataSignal(topNet,'prerunbank',addrBankType,rate);

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

    pirelab.getBitwiseOpComp(topNet,[nextFrame,nofirststartsig],ramwrbanken1,'AND');

    pirelab.getCounterComp(topNet,[startIn,ramwren],ramwrcount,...
    'Count limited',...
    0.0,...
    1.0,...
    nI-1,...
    true,...
    false,...
    true,...
    false,...
    'wraddrcounter');


    pirelab.getCounterComp(topNet,[startIn,ramwren],intrlvIndIn,...
    'Count limited',...
    0.0,...
    1.0,...
    I-1,...
    true,...
    false,...
    true,...
    false,...
    'intrlvIndIncounter');

    inputCWLenWithParity=newDataSignal(topNet,'inputCWLenWithParity',inType,rate);
    inputCWLenWithParityEnb=newControlSignal(topNet,'inputCWLenWithParityEnb',rate);
    intrlvIndMax=newControlSignal(topNet,'intrlvIndMax',rate);
    pirelab.getCompareToValueComp(topNet,intrlvIndIn,intrlvIndMax,'==',I-1);
    pirelab.getBitwiseOpComp(topNet,[intrlvIndMax,ramwren],inputCWLenWithParityEnb,'AND');

    if(I==1)
        intrlvIndMaxMinusOneConst=0;
    else
        intrlvIndMaxMinusOneConst=I-2;
    end

    intrlvIndMaxMinusOne=newControlSignal(topNet,'intrlvIndMaxMinusOne',rate);
    inputCWLenGrtMin=newControlSignal(topNet,'inputCWLenGrtMin',rate);
    inputCWLenGrtMinMinusOne=newControlSignal(topNet,'inputCWLenGrtMinMinusOne',rate);
    notValidInDelay=newControlSignal(topNet,'notValidInDelay',rate);
    intrlvIndMaxMinusOneAndValidInDelay=newControlSignal(topNet,'intrlvIndMaxMinusOneAndValidInDelay',rate);
    intrlvIndMaxAndNotValidInDelay=newControlSignal(topNet,'intrlvIndMaxAndNotValidInDelay',rate);
    inputCWLenGrtMinMinusOneAndValidInDelay=newControlSignal(topNet,'inputCWLenGrtMinMinusOneAndValidInDelay',rate);
    inputCWLenGrtMinAndNotValidInDelay=newControlSignal(topNet,'inputCWLenGrtMinAndNotValidInDelay',rate);

    pirelab.getCompareToValueComp(topNet,intrlvIndIn,intrlvIndMaxMinusOne,'==',intrlvIndMaxMinusOneConst);
    pirelab.getCompareToValueComp(topNet,ramwrcount,inputCWLenGrtMin,'>=',((codewordLength-messageLength+1)*I-1));
    pirelab.getCompareToValueComp(topNet,ramwrcount,inputCWLenGrtMinMinusOne,'>=',((codewordLength-messageLength+1)*I-2));
    pirelab.getBitwiseOpComp(topNet,validInDelay,notValidInDelay,'NOT');
    pirelab.getBitwiseOpComp(topNet,[intrlvIndMaxMinusOne,validInDelay],intrlvIndMaxMinusOneAndValidInDelay,'AND');
    pirelab.getBitwiseOpComp(topNet,[intrlvIndMax,notValidInDelay],intrlvIndMaxAndNotValidInDelay,'AND');
    pirelab.getBitwiseOpComp(topNet,[intrlvIndMaxMinusOneAndValidInDelay,intrlvIndMaxAndNotValidInDelay],intrlvIndCorrect,'OR');
    pirelab.getBitwiseOpComp(topNet,[inputCWLenGrtMinMinusOne,validInDelay],inputCWLenGrtMinMinusOneAndValidInDelay,'AND');
    pirelab.getBitwiseOpComp(topNet,[inputCWLenGrtMin,notValidInDelay],inputCWLenGrtMinAndNotValidInDelay,'AND');
    pirelab.getBitwiseOpComp(topNet,[inputCWLenGrtMinMinusOneAndValidInDelay,inputCWLenGrtMinAndNotValidInDelay],inputCWLenCorrect,'OR');

    pirelab.getCounterComp(topNet,[startIn,inputCWLenWithParityEnb],inputCWLenWithParity,...
    'Count limited',...
    0.0,...
    1.0,...
    codewordLength-1,...
    true,...
    false,...
    true,...
    false,...
    'inputCWLenWithParitycounter');

    pirelab.getCounterComp(topNet,[prestartcurbankdelay,prevalidout],ramrdcount,...
    'Count limited',...
    0.0,...
    1.0,...
    nI-1,...
    true,...
    false,...
    true,...
    false,...
    'rdaddrcounter');

    intrlvIndOut=newDataSignal(topNet,'intrlvIndOut',pir_ufixpt_t(nextpow2(I+1+1),0),rate);
    msgLenOut=newDataSignal(topNet,'msgLenOut',inType,rate);
    pirelab.getCounterComp(topNet,[prestartcurbankdelay,prevalidout],intrlvIndOut,...
    'Count limited',...
    0.0,...
    1.0,...
    I-1,...
    true,...
    false,...
    true,...
    false,...
    'rdaddrcounter');

    msgLenOutEnb=newControlSignal(topNet,'msgLenOutEnb',rate);
    intrlvIndOutMax=newControlSignal(topNet,'intrlvIndOutMax',rate);
    pirelab.getCompareToValueComp(topNet,intrlvIndOut,intrlvIndOutMax,'==',I-1);
    pirelab.getBitwiseOpComp(topNet,[intrlvIndOutMax,prevalidout],msgLenOutEnb,'AND');
    pirelab.getCounterComp(topNet,[prestartcurbankdelay,msgLenOutEnb],msgLenOut,...
    'Count limited',...
    0.0,...
    1.0,...
    codewordLength-1,...
    true,...
    false,...
    true,...
    false,...
    'rdaddrcounter');


    pirelab.getBitwiseOpComp(topNet,[intrlvIndCorrect,inputCWLenCorrect],inCorrectFrame,'NAND');
    pirelab.getBitwiseOpComp(topNet,[endIn,inCorrectFrame],ramwrbanken2,'AND');
    pirelab.getBitwiseOpComp(topNet,ramwrbanken2,ramwrbanken2Comp,'NOT');
    pirelab.getBitwiseOpComp(topNet,[ramwrbanken1,ramwrbanken2],ramwrbanken,'OR');

    pirelab.getCounterComp(topNet,[ramwrbanken,ramwrbanken2Comp],ramwrbank,...
    'Count limited',...
    0,...
    1.0,...
    numPackets-1,...
    false,...
    false,...
    true,...
    true,...
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
        wrbankdecode(ii)=newControlSignal(topNet,['wrbankdecode%d',(ii-1)],rate);
    end

    for ii=1:numPackets
        rdbankdecode(ii)=newControlSignal(topNet,['rdbankdecode%d',(ii-1)],rate);
    end

    for ii=1:numPackets
        bankvalid(ii)=newControlSignal(topNet,['bankvalid%d',(ii-1)],rate);
    end

    for ii=1:numPackets
        setvalid(ii)=newControlSignal(topNet,['setvalid%d',(ii-1)],rate);
    end

    endcompare=newControlSignal(topNet,'encompare',rate);
    rdbankvalid=newControlSignal(topNet,'rdbankvalid',rate);
    for ii=1:numPackets
        endpacketbank(ii)=newControlSignal(topNet,['endpacketbank%d',(ii-1)],rate);
    end

    for ii=1:numPackets
        holdvalid(ii)=newControlSignal(topNet,['holdvalid%d',(ii-1)],rate);
    end

    for ii=1:numPackets
        endreadbank(ii)=newControlSignal(topNet,['endreadbank%d',(ii-1)],rate);
    end


    inputlength=newDataSignal(topNet,'inputlength',addrCountType,rate);
    inputlengthFinal=newDataSignal(topNet,'inputlength',addrCountType,rate);
    inputlengthMinusOne=newDataSignal(topNet,'inputlength',addrCountType,rate);
    parityconst=newDataSignal(topNet,'paritylength',addrCountType,rate);
    parityconstplusone=newDataSignal(topNet,'paritylengthplusone',inType,rate);
    parityconstintoI=newDataSignal(topNet,'parityconstintoI',addrCountType,rate);
    parityconstintoIPlusOne=newDataSignal(topNet,'parityconstintoI',addrCountType,rate);
    parityconst8Bit=newDataSignal(topNet,'parityconstintoI',inType,rate);
    parityconst8BitPlusOne=newDataSignal(topNet,'parityconst8BitPlusOne',inType,rate);
    for ii=1:numPackets
        packetlength(ii)=newDataSignal(topNet,['packetlength%d',(ii-1)],addrCountType,rate);
    end



    currentlength=newDataSignal(topNet,'currentlength',addrCountType,rate);
    currentlensub=newDataSignal(topNet,'currentlensub',addrCountType,rate);
    oneaddrcount=newDataSignal(topNet,'oneaddrcount',addrCountType,rate);

    for jj=1:I
        errlocpolysub(jj)=newDataSignal(topNet,'errlocpolysub',countType,rate);
    end

    for jj=1:I
        errlocpolylen(jj)=newDataSignal(topNet,'errlocpolylen',countType,rate);
        errlocpolylenconv(jj)=newDataSignal(topNet,'errlocpolylenconv',countType,rate);
        errlocpolylenconveven(jj)=newDataSignal(topNet,'errlocpolylenconveven',countType,rate);
        errlocpolylenconvodd(jj)=newDataSignal(topNet,'errlocpolylenconvodd',countType,rate);
        errlocpolylenchien(jj)=newDataSignal(topNet,'errlocpolylenchien',countType,rate);
        errlocpolylenminusone(jj)=newDataSignal(topNet,'errlocpolylenminusone',countType,rate);
    end




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
        pirelab.getBitwiseOpComp(topNet,[endInDelay,wrbankdecode(ii)],endpacketbank(ii),'AND');
    end

    notNextFrame=newControlSignal(topNet,'notNextFrame',rate);
    pirelab.getBitwiseOpComp(topNet,nextFrame,notNextFrame,'NOT');
    pirelab.getBitwiseOpComp(topNet,[startIn,notNextFrame],resetValid,'AND');

    for ii=1:numPackets
        resetValidBank(ii)=newControlSignal(topNet,'resetValidBank',rate);
        pirelab.getBitwiseOpComp(topNet,[resetValid,wrbankdecode(ii)],resetValidBank(ii),'NAND');
        setvalidHold(ii)=newControlSignal(topNet,sprintf('setvalidHold%d',ii),rate);
        pirelab.getBitwiseOpComp(topNet,[holdvalid(ii),endpacketbank(ii)],setvalidHold(ii),'OR');
        pirelab.getBitwiseOpComp(topNet,[resetValidBank(ii),setvalidHold(ii)],setvalid(ii),'AND');
    end

    for ii=1:numPackets
        pirelab.getBitwiseOpComp(topNet,[bankvalid(ii),endreadbank(ii)],holdvalid(ii),'AND');
    end

    for ii=1:numPackets
        pirelab.getBitwiseOpComp(topNet,[rdbankdecode(ii),preendout,prevalidout],endreadbank(ii),'NAND');
    end

    for jj=1:numPackets
        inputCWLenWithoutParitySampled(jj)=newDataSignal(topNet,'inputCWLenWithoutParitySampled',inType,rate);
    end
    inputCWLenWithoutParity=newDataSignal(topNet,'inputCWLenWithoutParity',inType,rate);
    inputCWLenWithoutParityMinusOne=newDataSignal(topNet,'inputCWLenWithoutParityMinusOne',inType,rate);
    inputCWLenWithoutParityFinal=newDataSignal(topNet,'inputCWLenWithoutParityMinusOne',inType,rate);
    pirelab.getConstComp(topNet,parityconst,parityLength);
    pirelab.getConstComp(topNet,parityconst8Bit,parityLength);
    pirelab.getConstComp(topNet,parityconst8BitPlusOne,parityLength+1);
    pirelab.getConstComp(topNet,parityconstplusone,parityLength+1);
    pirelab.getConstComp(topNet,parityconstintoI,parityLength*I);
    pirelab.getConstComp(topNet,parityconstintoIPlusOne,parityLength*I+1);
    pirelab.getSubComp(topNet,[ramwrcount,parityconstintoI],inputlength);
    pirelab.getSubComp(topNet,[ramwrcount,parityconstintoIPlusOne],inputlengthMinusOne);
    pirelab.getSubComp(topNet,[inputCWLenWithParity,parityconst8Bit],inputCWLenWithoutParity);
    pirelab.getSubComp(topNet,[inputCWLenWithParity,parityconst8BitPlusOne],inputCWLenWithoutParityMinusOne);
    pirelab.getSwitchComp(topNet,[inputlengthMinusOne,inputlength],inputlengthFinal,endInAndFinalDelay);
    pirelab.getSwitchComp(topNet,[inputCWLenWithoutParityMinusOne,inputCWLenWithoutParity],inputCWLenWithoutParityFinal,endInAndFinalDelay);
    for ii=1:numPackets
        pirelab.getUnitDelayEnabledComp(topNet,inputlengthFinal,packetlength(ii),endpacketbank(ii),['packetlen%dreg',(ii-1)],0.0,'',false);
        pirelab.getUnitDelayEnabledComp(topNet,inputCWLenWithoutParityFinal,inputCWLenWithoutParitySampled(ii),endpacketbank(ii),['packetlen%dreg',(ii-1)],0.0,'',false);
    end





    pirelab.getUnitDelayEnabledComp(topNet,ramwrbank,masseybank,endInDelay,'masseybankreg',0.0,'',false);
    pirelab.getUnitDelayEnabledComp(topNet,masseybank,convbank,fsmdone,'convbankreg',0.0,'',false);
    pirelab.getUnitDelayEnabledComp(topNet,convbank,prerunbank,convdone,'prerunbankreg',0.0,'',false);

    currentCWLength=newDataSignal(topNet,'currentCWLength',inType,rate);

    pirelab.getMultiPortSwitchComp(topNet,[ramrdbank,packetlength],currentlength,...
    1,1,'floor','Wrap','currentlengthmux');
    pirelab.getMultiPortSwitchComp(topNet,[ramrdbank,inputCWLenWithoutParitySampled],currentCWLength,...
    1,1,'floor','Wrap','currentlengthmux');
    pirelab.getMultiPortSwitchComp(topNet,[ramrdbank,bankvalid],rdbankvalid,...
    1,1,'floor','Wrap','bankvalidmux');
    pirelab.getConstComp(topNet,oneaddrcount,1,'oneaddrconst');
    pirelab.getSubComp(topNet,[currentlength,oneaddrcount],currentlensub,'Floor','Wrap');

    pirelab.getRelOpComp(topNet,[ramrdcount,currentlength],endcompare,'==');
    pirelab.getBitwiseOpComp(topNet,[endcompare,rdbankvalid],preendout,'AND');







    for jj=1:I
        masseyNet(jj)=this.elabMassey(topNet,blockInfo,rate);
        masseyNet(jj).addComment('Berklekamp-Massey State-machine');
        fsmdoneSeparately(jj)=newControlSignal(topNet,sprintf('fsmdoneSeparately%d',jj),rate);

        for ii=1:2*corr
            inports(ii,jj)=finalsyndromereg(ii,jj);
            outports(ii,jj)=errlocpoly(ii,jj);
        end

        inports(ii+1,jj)=endInDelay3;
        outports(ii+1,jj)=fsmdoneSeparately(jj);
        outports(ii+2,jj)=errlocpolysub(jj);
        outports(ii+3,jj)=errlocpolylen(jj);
        pirelab.instantiateNetwork(topNet,masseyNet(jj),inports(:,jj),outports(:,jj),sprintf('masseyNet_inst%d',jj));

    end

    pirelab.getBitwiseOpComp(topNet,fsmdoneSeparately(:),fsmdone,'AND');


    moduloconst=newDataSignal(topNet,'moduloconst',inType,rate);
    pirelab.getConstComp(topNet,moduloconst,2.^wordSize-1,'modconst');

    onebit=newControlSignal(topNet,'onebit',rate);
    pirelab.getConstComp(topNet,onebit,1,'onebitconst');
    zerobit=newControlSignal(topNet,'zerobit',rate);
    pirelab.getConstComp(topNet,zerobit,0,'zerobitconst');

    for jj=1:I
        nroots(jj)=newDataSignal(topNet,'nroots',countType,rate);
        nrootsdelayed(jj)=newDataSignal(topNet,'nrootsdelayed',countType,rate);
        nrootsreg(jj)=newDataSignal(topNet,'nrootsreg',countType,rate);

        anyerr(jj)=newControlSignal(topNet,'anyerr',rate);
        comparepolylen(jj)=newControlSignal(topNet,'comparepolylen',rate);
        comparepolylen1(jj)=newControlSignal(topNet,'comparepolylen1',rate);
    end
    nrootsstart=newDataSignal(topNet,'nrootsstart',inType,rate);



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

    for jj=1:I
        convsyndrome(jj)=newDataSignal(topNet,'convsyndrome',inType,rate);
        converrloc(jj)=newDataSignal(topNet,'converrloc',inType,rate);
        convsyndromelog(jj)=newDataSignal(topNet,'convsyndromelog',inType,rate);
        converrloclog(jj)=newDataSignal(topNet,'converrloclog',inType,rate);
        convlogadd(jj)=newDataSignal(topNet,'convlogadd',carryType,rate);
        convlogwrap(jj)=newControlSignal(topNet,'convlogwrap',rate);
        convsynzero(jj)=newControlSignal(topNet,'convsynzero',rate);
        converrzero(jj)=newControlSignal(topNet,'converrzero',rate);
        convzero(jj)=newControlSignal(topNet,'convzero',rate);

        convlogaddreduced(jj)=newDataSignal(topNet,'convlogaddreduced',inType,rate);
        convlogslice(jj)=newDataSignal(topNet,'convlogslice',inType,rate);
        convmodresult(jj)=newDataSignal(topNet,'convmodresult',inType,rate);
        convalogout(jj)=newDataSignal(topNet,'convalogout',inType,rate);
        convresult(jj)=newDataSignal(topNet,'convresult',inType,rate);
        convxor(jj)=newDataSignal(topNet,'convxor',inType,rate);
    end

    for jj=1:I
        omegapolymux(jj)=newDataSignal(topNet,'omegapolymux',inType,rate);
    end
    omegapoweren=newControlSignal(topNet,'omegapoweren',rate);

    for jj=1:I
        chienprevalue(jj)=newDataSignal(topNet,'chienprevalue',inType,rate);
        chienvalue(jj)=newDataSignal(topNet,'chienvalue',inType,rate);
        chienzero(jj)=newControlSignal(topNet,'chienzero',rate);
        chienprezero(jj)=newControlSignal(topNet,'chienprezero',rate);
        chienprezerogated(jj)=newControlSignal(topNet,'chienprezerogated',rate);
        omegavalue(jj)=newDataSignal(topNet,'omegavalue',inType,rate);
        omegazero(jj)=newControlSignal(topNet,'omegazero',rate);
        derivvalue(jj)=newDataSignal(topNet,'derivvalue',inType,rate);
        derivzero(jj)=newControlSignal(topNet,'derivzero',rate);
        derivvaluelog(jj)=newDataSignal(topNet,'derivvaluelog',inType,rate);
        derivinvlog(jj)=newDataSignal(topNet,'derivvaluelog',inType,rate);
        omegavaluelog(jj)=newDataSignal(topNet,'omegavaluelog',inType,rate);
        correctlogadd(jj)=newDataSignal(topNet,'correctlogadd',carryType,rate);
        correctlogwrap(jj)=newControlSignal(topNet,'correctlogwrap',rate);
        correctlogaddreduced(jj)=newDataSignal(topNet,'correctlogaddreduced',inType,rate);
        correctlogslice(jj)=newDataSignal(topNet,'correctlogslice',inType,rate);
        correctmodresult(jj)=newDataSignal(topNet,'correctmodresult',inType,rate);
        correctalogout(jj)=newDataSignal(topNet,'correctalogout',inType,rate);
        correctresult(jj)=newDataSignal(topNet,'correctresult',inType,rate);
        correctzero(jj)=newControlSignal(topNet,'correctzero',rate);
        chiennotzero(jj)=newControlSignal(topNet,'chiennotzero',rate);
        chienzeroroot(jj)=newControlSignal(topNet,'chienzeroroot',rate);
        loadroots(jj)=newControlSignal(topNet,'loadroots',rate);

        prerootclken=newControlSignal(topNet,'prerootclken',rate);
        prerootswitch(jj)=newControlSignal(topNet,'prerootswitch',rate);
        preroothold(jj)=newControlSignal(topNet,'preroothold',rate);
        uncorrectedpreroot(jj)=newControlSignal(topNet,'uncorrectedpreroot',rate);
        forceerrorroot(jj)=newControlSignal(topNet,'forceerrorroot',rate);
        chienuncorrectedroot(jj)=newControlSignal(topNet,'chienuncorrectedroot',rate);
        uncorrectedroot(jj)=newControlSignal(topNet,'uncorrectedroot',rate);
        uncorrectednext(jj)=newControlSignal(topNet,'uncorrectednext',rate);
        uncorrected(jj)=newControlSignal(topNet,'uncorrected',rate);
    end


    for jj=1:I
        omegavaluelogdelay(jj)=newDataSignal(topNet,'omegavaluelogdelay',inType,rate);
        derivvaluelogdelay(jj)=newDataSignal(topNet,'derivvaluelogdelay',inType,rate);
        correctzerodelay(jj)=newControlSignal(topNet,'correctzerodelay',rate);
    end

    chienprerundonedelay=newControlSignal(topNet,'chienprerundonedelay',rate);



    for jj=1:I
        for ii=1:2*corr
            chiensyndrome(ii,jj)=newDataSignal(topNet,sprintf('chien%dsynreg',ii),inType,rate);

            chienreg(ii,jj)=newDataSignal(topNet,sprintf('chien%dreg',ii),inType,rate);
            chienregnext(ii,jj)=newDataSignal(topNet,sprintf('chienreg%dnext',ii),inType,rate);
            chienpowertable(ii,jj)=newDataSignal(topNet,sprintf('chien%dpowertable',ii),inType,rate);
            chienupdate(ii)=newDataSignal(topNet,sprintf('chien%dupdate',ii),inType,rate);%#ok

            chienprereg(ii,jj)=newDataSignal(topNet,sprintf('chien%dprereg',ii),inType,rate);
            chienpreregnext(ii,jj)=newDataSignal(topNet,sprintf('chienreg%dprenext',ii),inType,rate);
            chienprepowertable(ii,jj)=newDataSignal(topNet,sprintf('chien%dprepowertable',ii),inType,rate);
            chienpreupdate(ii)=newDataSignal(topNet,sprintf('chien%dpreupdate',ii),inType,rate);%#ok

            omegaen(ii,jj)=newControlSignal(topNet,sprintf('omega%den',ii),rate);
            omegacomp(ii,jj)=newControlSignal(topNet,sprintf('omega%dcomp',ii),rate);
            omegaupdate(ii,jj)=newControlSignal(topNet,sprintf('omega%dupdate',ii),rate);
            omegapoly(ii,jj)=newDataSignal(topNet,sprintf('omega%dpoly',ii),inType,rate);
            omeganext(ii,jj)=newDataSignal(topNet,sprintf('omega%dnext',ii),inType,rate);

            omegapowerreg(ii,jj)=newDataSignal(topNet,sprintf('omega%dpowerreg',ii),inType,rate);
            omegapowernext(ii,jj)=newDataSignal(topNet,sprintf('omega%dpowernext',ii),inType,rate);
            omegapowertable(ii,jj)=newDataSignal(topNet,sprintf('omega%dpowertable',ii),inType,rate);

            omegaprepowerreg(ii,jj)=newDataSignal(topNet,sprintf('omega%dprepowerreg',ii),inType,rate);
            omegaprepowernext(ii,jj)=newDataSignal(topNet,sprintf('omega%dprepowernext',ii),inType,rate);
            omegaprepowertable(ii,jj)=newDataSignal(topNet,sprintf('omega%dprepowertable',ii),inType,rate);

            chienprexortree(ii,jj)=newDataSignal(topNet,sprintf('chienpre%dxortree',ii),inType,rate);
            chienxortree(ii,jj)=newDataSignal(topNet,sprintf('chien%dxortree',ii),inType,rate);
            omegaxortree(ii,jj)=newDataSignal(topNet,sprintf('omega%dxortree',ii),inType,rate);
            derivxortree(ii,jj)=newDataSignal(topNet,sprintf('deriv%dxortree',ii),inType,rate);

            if ii<=corr
                chienroot(ii,jj)=newControlSignal(topNet,sprintf('chien%droot',ii),rate);
                chienrootdelay(ii,jj)=newControlSignal(topNet,sprintf('chien%drootdelay',ii),rate);
                errlocationreg(ii,jj)=newDataSignal(topNet,sprintf('errlocation%dreg',ii),inType,rate);
                errlocationpipereg(ii,jj)=newDataSignal(topNet,sprintf('errlocationpipe%dreg',ii),inType,rate);
                errlocationpiperegdelay(ii,jj)=newDataSignal(topNet,sprintf('errlocationpipe%dregdelay',ii),inType,rate);
                errlocationnext(ii,jj)=newDataSignal(topNet,sprintf('errlocation%dnext',ii),inType,rate);
                errvaluereg(ii,jj)=newDataSignal(topNet,sprintf('errvalue%dreg',ii),inType,rate);
                errvaluepipereg(ii,jj)=newDataSignal(topNet,sprintf('errvaluepipe%dreg',ii),inType,rate);
                errvaluepiperegPrestart(ii,jj)=newDataSignal(topNet,sprintf('errvaluePrestart%dreg',ii),inType,rate);
                errvaluenext(ii,jj)=newDataSignal(topNet,sprintf('errvalue%dnext',ii),inType,rate);
                errvalidreg(ii,jj)=newControlSignal(topNet,sprintf('errvalid%dreg',ii),rate);
                errvalidpipereg(ii,jj)=newControlSignal(topNet,sprintf('errvalidpipe%dreg',ii),rate);
                errvalidpiperegdelay(ii,jj)=newControlSignal(topNet,sprintf('errvalidpipe%dregdelay',ii),rate);
                errvalidsigreg(ii,jj)=newControlSignal(topNet,sprintf('errvalidsig%dreg',ii),rate);
                errvalidsigregdelay(ii,jj)=newControlSignal(topNet,sprintf('errvalidsig%dregdelay',ii),rate);
                errvalidnext(ii,jj)=newControlSignal(topNet,sprintf('errvalid%dnext',ii),rate);
                errloadreg(ii,jj)=newControlSignal(topNet,sprintf('errload%dreg',ii),rate);
                errloadnext(ii,jj)=newControlSignal(topNet,sprintf('errload%dnext',ii),rate);

            end
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



    for jj=1:I
        pirelab.getMultiPortSwitchComp(topNet,[convcount;chiensyndrome(:,jj)],...
        convsyndrome(jj),...
        1,1,'floor','Wrap','chiensynmux');
    end

    pirelab.getSubComp(topNet,[omegacount,convcount],errlocaddr,'Floor','Wrap');

    for jj=1:I
        pirelab.getMultiPortSwitchComp(topNet,[errlocaddr;errlocpoly(:,jj)],...
        converrloc(jj),...
        1,1,'floor','Wrap','chienerrmux');
    end


    for jj=1:I
        pirelab.getMultiPortSwitchComp(topNet,[omegacount;omegapoly(:,jj)],...
        omegapolymux(jj),...
        1,1,'floor','Wrap','omegaxormux');
    end

    for jj=1:I
        pirelab.getDirectLookupComp(topNet,convsyndrome(jj),convsyndromelog(jj),logTable,'convsynlogtable');
        pirelab.getDirectLookupComp(topNet,converrloc(jj),converrloclog(jj),logTable,'converrlogtable');
        pirelab.getCompareToValueComp(topNet,convsyndrome(jj),convsynzero(jj),'==',0,'convsyncmpz');
        pirelab.getCompareToValueComp(topNet,converrloc(jj),converrzero(jj),'==',0,'converrcmpz');
        pirelab.getBitwiseOpComp(topNet,[convsynzero(jj),converrzero(jj)],convzero(jj),'OR');
        pirelab.getAddComp(topNet,[convsyndromelog(jj),converrloclog(jj)],convlogadd(jj),'Floor','Wrap');
        pirelab.getCompareToValueComp(topNet,convlogadd(jj),convlogwrap(jj),'>',2.^wordSize-1,'convmodcompare');
        pirelab.getSubComp(topNet,[convlogadd(jj),moduloconst],convlogaddreduced(jj),'Floor','Wrap');
        pirelab.getBitSliceComp(topNet,convlogadd(jj),convlogslice(jj),wordSize-1,0);
        pirelab.getSwitchComp(topNet,[convlogslice(jj),convlogaddreduced(jj)],convmodresult(jj),convlogwrap(jj),'convmodmux');
        pirelab.getDirectLookupComp(topNet,convmodresult(jj),convalogout(jj),alogTable,'convalogtable');
        pirelab.getSwitchComp(topNet,[convalogout(jj),zeroconst],convresult(jj),convzero(jj),'convzeromux');

        pirelab.getBitwiseOpComp(topNet,[omegapolymux(jj),convresult(jj)],convxor(jj),'XOR');
    end




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
    chienprerunsellen=newDataSignal(topNet,'chienprerunsellen',inType,rate);
    chienprerunlencomp=newDataSignal(topNet,'chienprerunlencomp',inType,rate);
    chienprerunlength=newDataSignal(topNet,'chienprerunlength',inType,rate);
    chienprerunmax=newControlSignal(topNet,'chienprerunmax',rate);
    omegaprepoweren=newControlSignal(topNet,'omegaprepoweren',rate);

    for jj=1:I

        finalordererr(jj)=newControlSignal(topNet,'finalordererr',rate);
        finalordererr1(jj)=newControlSignal(topNet,'finalordererr1',rate);
        switchctrl=newControlSignal(topNet,'switchctrl',rate);
        switchctrldelay=newControlSignal(topNet,'switchctrldelay',rate);

        convxoreven=newControlSignal(topNet,'convxoreven',rate);
        convxorodd=newControlSignal(topNet,'convxorodd',rate);
        convxorevensample=newControlSignal(topNet,'convxorevensample',rate);
        convxoroddsample=newControlSignal(topNet,'convxoroddsample',rate);
        convxorevendelay=newControlSignal(topNet,'convxorevendelay',rate);
        chiendonedelay=newControlSignal(topNet,'chiendonedelay',rate);
        convdonedelay=newControlSignal(topNet,'convdonedelay',rate);
        errcountreset(jj)=newControlSignal(topNet,'errcountreset',rate);
        errcountreset1(jj)=newControlSignal(topNet,'errcountreset1',rate);
        errcountgrtzero(jj)=newControlSignal(topNet,'errcountgrtzero',rate);
    end

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


    pirelab.getMultiPortSwitchComp(topNet,[prerunbank,inputCWLenWithoutParitySampled],chienprerunsellen,...
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


    for jj=1:I
        for ii=1:2*corr
            pirelab.getUnitDelayEnabledComp(topNet,finalsyndromereg(ii,jj),chiensyndrome(ii,jj),fsmdone,...
            'chiensynreg',0.0,'',false);

            if ii==1
                chienprepowertable(ii,jj)=chienprereg(ii,jj);
                chienpowertable(ii,jj)=chienreg(ii,jj);
            else
                pirelab.getDirectLookupComp(topNet,chienprereg(ii,jj),chienprepowertable(ii,jj),powerTable(ii,:),'gfomegaprepowertable');
                pirelab.getDirectLookupComp(topNet,chienreg(ii,jj),chienpowertable(ii,jj),powerTable(ii,:),'gfomegapowertable');
            end
            pirelab.getUnitDelayEnabledComp(topNet,chienregnext(ii,jj),chienreg(ii,jj),omegapoweren,...
            'chienreg',0.0,'',false);
            pirelab.getSwitchComp(topNet,[chienpowertable(ii,jj),chienprereg(ii,jj)],chienregnext(ii,jj),chienprerundone,'omegapowermux');

            pirelab.getUnitDelayEnabledComp(topNet,chienpreregnext(ii,jj),chienprereg(ii,jj),omegaprepoweren,...
            'chienprereg',0.0,'',false);
            pirelab.getSwitchComp(topNet,[chienprepowertable(ii,jj),errlocpoly(ii,jj)],chienpreregnext(ii,jj),convdone,'omegapowermux');


            pirelab.getUnitDelayEnabledComp(topNet,omeganext(ii,jj),omegapoly(ii,jj),omegaen(ii,jj),...
            'errlocpolyreg',0.0,'',false);
            pirelab.getSwitchComp(topNet,[convxor(jj),zeroconst],omeganext(ii,jj),fsmdone,'omegamux');
            pirelab.getCompareToValueComp(topNet,omegacount,omegacomp(ii,jj),'==',ii-1,'convmodcompare');
            pirelab.getBitwiseOpComp(topNet,[omegacomp(ii,jj),convrun],omegaupdate(ii,jj),'AND');
            pirelab.getBitwiseOpComp(topNet,[fsmdone,omegaupdate(ii,jj)],omegaen(ii,jj),'OR');

            if ii==1
                omegaprepowertable(ii,jj)=omegaprepowerreg(ii,jj);
                omegapowertable(ii,jj)=omegapowerreg(ii,jj);
            else
                pirelab.getDirectLookupComp(topNet,omegaprepowerreg(ii,jj),omegaprepowertable(ii,jj),powerTable(ii,:),'gfomegaprepowertable');
                pirelab.getDirectLookupComp(topNet,omegapowerreg(ii,jj),omegapowertable(ii,jj),powerTable(ii,:),'gfomegapowertable');
            end
            pirelab.getUnitDelayEnabledComp(topNet,omegaprepowernext(ii,jj),omegaprepowerreg(ii,jj),omegaprepoweren,...
            'omegaprepowerreg',0.0,'',false);
            pirelab.getSwitchComp(topNet,[omegaprepowertable(ii,jj),omegapoly(ii,jj)],omegaprepowernext(ii,jj),convdone,'omegaprepowermux');

            pirelab.getUnitDelayEnabledComp(topNet,omegapowernext(ii,jj),omegapowerreg(ii,jj),omegapoweren,...
            'omegapowerreg',0.0,'',false);
            pirelab.getSwitchComp(topNet,[omegapowertable(ii,jj),omegaprepowerreg(ii,jj)],omegapowernext(ii,jj),chienprerundone,'omegapowermux');



            if ii==2*corr
                pirelab.getBitwiseOpComp(topNet,[chienprexortree(ii-1,jj),chienprereg(ii,jj)],chienprevalue(jj),'XOR');
                pirelab.getBitwiseOpComp(topNet,[chienxortree(ii-1,jj),chienreg(ii,jj)],chienvalue(jj),'XOR');
                pirelab.getBitwiseOpComp(topNet,[omegaxortree(ii-1,jj),omegapowerreg(ii,jj)],omegavalue(jj),'XOR');

                pirelab.getBitwiseOpComp(topNet,[derivxortree(ii-2,jj),chienreg(ii,jj)],derivvalue(jj),'XOR');

            elseif ii==1

            elseif ii==2
                pirelab.getBitwiseOpComp(topNet,[chienprereg(ii-1,jj),chienprereg(ii,jj)],chienprexortree(ii,jj),'XOR');
                pirelab.getBitwiseOpComp(topNet,[chienreg(ii-1,jj),chienreg(ii,jj)],chienxortree(ii,jj),'XOR');
                pirelab.getBitwiseOpComp(topNet,[omegapowerreg(ii-1,jj),omegapowerreg(ii,jj)],omegaxortree(ii,jj),'XOR');
                derivxortree(ii,jj)=chienreg(ii,jj);
            else
                pirelab.getBitwiseOpComp(topNet,[chienprexortree(ii-1,jj),chienprereg(ii,jj)],chienprexortree(ii,jj),'XOR');
                pirelab.getBitwiseOpComp(topNet,[chienxortree(ii-1,jj),chienreg(ii,jj)],chienxortree(ii,jj),'XOR');
                pirelab.getBitwiseOpComp(topNet,[omegaxortree(ii-1,jj),omegapowerreg(ii,jj)],omegaxortree(ii,jj),'XOR');
                if mod(ii,2)==0
                    pirelab.getBitwiseOpComp(topNet,[derivxortree(ii-2,jj),chienreg(ii,jj)],derivxortree(ii,jj),'XOR');
                end
            end



            if ii<=corr
                if ii==1
                    pirelab.getSwitchComp(topNet,[zerobit,onebit],errloadnext(ii,jj),chienprerundone,'errloadmux');
                    pirelab.getSwitchComp(topNet,[onebit,zerobit],errvalidnext(ii,jj),chienprerundone,'errvalidmux');
                else
                    pirelab.getSwitchComp(topNet,[errloadreg(ii-1,jj),zerobit],errloadnext(ii,jj),chienprerundone,'errloadmux');
                    pirelab.getSwitchComp(topNet,[errvalidreg(ii-1,jj),zerobit],errvalidnext(ii,jj),chienprerundone,'errvalidmux');
                end
                pirelab.getUnitDelayComp(topNet,chienroot(ii,jj),chienrootdelay(ii,jj));
                pirelab.getBitwiseOpComp(topNet,[chienzeroroot(jj),errloadreg(ii,jj)],chienroot(ii,jj),'AND');

                pirelab.getUnitDelayEnabledComp(topNet,errlocationnext(ii,jj),errlocationreg(ii,jj),chienroot(ii,jj),...
                'errlocreg',0.0,'',false);
                pirelab.getSwitchComp(topNet,[chienpower,zeroconst],errlocationnext(ii,jj),chienprerundone,'errlocationmux');

                pirelab.getUnitDelayEnabledComp(topNet,errvaluenext(ii,jj),errvaluereg(ii,jj),chienrootdelay(ii,jj),...
                'errvalreg',0.0,'',false);
                pirelab.getSwitchComp(topNet,[correctresult(jj),zeroconst],errvaluenext(ii,jj),chienprerundonedelay,'errvaluemux');

                pirelab.getUnitDelayEnabledComp(topNet,errvalidnext(ii,jj),errvalidreg(ii,jj),loadroots(jj),...
                'errvldreg',0.0,'',false);

                pirelab.getUnitDelayEnabledComp(topNet,errloadnext(ii,jj),errloadreg(ii,jj),loadroots(jj),...
                'errldreg',0.0,'',false);

                pirelab.getUnitDelayEnabledComp(topNet,errlocationreg(ii,jj),errlocationpipereg(ii,jj),chiendone,...
                'errlocpipereg',0.0,'',false);
                pirelab.getUnitDelayEnabledComp(topNet,errvaluereg(ii,jj),errvaluepipereg(ii,jj),chiendonedelay,...
                'errvalpipereg',0.0,'',false);
                pirelab.getUnitDelayEnabledComp(topNet,errvalidnext(ii,jj),errvalidpipereg(ii,jj),chiendone,...
                'errvldpipereg',0.0,'',false);
                pirelab.getUnitDelayEnabledComp(topNet,errvalidreg(ii,jj),errvalidsigreg(ii,jj),chiendone,...
                'errvldsigpipereg',0.0,'',false);
                pirelab.getUnitDelayEnabledComp(topNet,errvaluepipereg(ii,jj),errvaluepiperegPrestart(ii,jj),prestartcurbankdelay,...
                'errvaluepiperegPrestart',0.0,'',false);
                pirelab.getUnitDelayComp(topNet,errlocationpipereg(ii,jj),errlocationpiperegdelay(ii,jj));
                pirelab.getUnitDelayComp(topNet,errvalidpipereg(ii,jj),errvalidpiperegdelay(ii,jj));
                pirelab.getUnitDelayComp(topNet,errvalidsigreg(ii,jj),errvalidsigregdelay(ii,jj));
            end

        end
    end
    pirelab.getUnitDelayComp(topNet,prestartcurbank,prestartcurbankdelay);

    for jj=1:I
        pirelab.getUnitDelayComp(topNet,omegavaluelog(jj),omegavaluelogdelay(jj));
        pirelab.getUnitDelayComp(topNet,derivvaluelog(jj),derivvaluelogdelay(jj));
    end


    pirelab.getUnitDelayComp(topNet,chienprerundone,chienprerundonedelay);

    for jj=1:I
        pirelab.getBitwiseOpComp(topNet,[chienrun,chienzero(jj)],chienzeroroot(jj),'AND');
        pirelab.getBitwiseOpComp(topNet,[chienzeroroot(jj),chienprerundone],loadroots(jj),'OR');

        pirelab.getBitwiseOpComp(topNet,[chienzeroroot(jj),errvalidreg(corr,jj)],chienuncorrectedroot(jj),'AND');

        pirelab.getBitwiseOpComp(topNet,[chienuncorrectedroot(jj),forceerrorroot(jj)],uncorrectedroot(jj),'OR');


        pirelab.getUnitDelayEnabledComp(topNet,uncorrectednext(jj),uncorrected(jj),uncorrectedroot(jj),...
        'uncorrectedreg',0.0,'',false);
        pirelab.getSwitchComp(topNet,[onebit,zerobit],uncorrectednext(jj),chienprerundone,'uncorrectedmux');




        errInFirstLoc(jj)=newControlSignal(topNet,'errInFirstLoc',rate);
        pirelab.getBitwiseOpComp(topNet,[chienprerundonedelay,chienzeroroot(jj)],errInFirstLoc(jj),'AND');

        loadValue(jj)=newDataSignal(topNet,'loadValue',countType,rate);
        pirelab.getSwitchComp(topNet,[zeroconst,oneconst],loadValue(jj),errInFirstLoc(jj));
        pirelab.getCounterComp(topNet,[chienprerundonedelay,loadValue(jj),chienzeroroot(jj)],nroots(jj),...
        'Count limited',...
        0.0,...
        1.0,...
        2*corr-1,...
        false,...
        true,...
        true,...
        false,...
        'nrootscount');


        pirelab.getCompareToValueComp(topNet,chienprevalue(jj),chienprezero(jj),'==',0,'chienprezerocompare');
        pirelab.getBitwiseOpComp(topNet,[convdone,chienprerun],prerootclken,'OR');



        pirelab.getBitwiseOpComp(topNet,convdonedelay1,notconvdonedelay1,'NOT');

        pirelab.getBitwiseOpComp(topNet,[chienprezero(jj),notconvdonedelay1,haserrorsconvreg(jj)],chienprezerogated(jj),'AND');

        pirelab.getBitwiseOpComp(topNet,[chienprezerogated(jj),uncorrectedpreroot(jj)],preroothold(jj),'OR');

        pirelab.getSwitchComp(topNet,[preroothold(jj),zerobit],prerootswitch(jj),convdone,'prerootmux');

        pirelab.getUnitDelayEnabledComp(topNet,prerootswitch(jj),uncorrectedpreroot(jj),prerootclken,...
        'uncorrectedprereg',0.0,'',false);
        pirelab.getUnitDelayEnabledComp(topNet,uncorrectedpreroot(jj),forceerrorroot(jj),chienprerundone,...
        'forceerrorreg',0.0,'',false);


        pirelab.getCompareToValueComp(topNet,chienvalue(jj),chienzero(jj),'==',0,'chienzerocompare');
        pirelab.getBitwiseOpComp(topNet,chienzero(jj),chiennotzero(jj),'NOT');

        pirelab.getCompareToValueComp(topNet,derivvalue(jj),derivzero(jj),'==',0,'derivzerocompare');
        pirelab.getCompareToValueComp(topNet,omegavalue(jj),omegazero(jj),'==',0,'omegazerocompare');

        pirelab.getDirectLookupComp(topNet,derivvalue(jj),derivvaluelog(jj),logTable,'derivlogtable');
        pirelab.getSubComp(topNet,[moduloconst,derivvaluelogdelay(jj)],derivinvlog(jj),'Floor','Wrap');

        pirelab.getDirectLookupComp(topNet,omegavalue(jj),omegavaluelog(jj),logTable,'omegalogtable');

        pirelab.getAddComp(topNet,[derivinvlog(jj),omegavaluelogdelay(jj)],correctlogadd(jj),'Floor','Wrap');
        pirelab.getCompareToValueComp(topNet,correctlogadd(jj),correctlogwrap(jj),'>',2.^wordSize-1,'correctmodcompare');
        pirelab.getSubComp(topNet,[correctlogadd(jj),moduloconst],correctlogaddreduced(jj),'Floor','Wrap');
        pirelab.getBitSliceComp(topNet,correctlogadd(jj),correctlogslice(jj),wordSize-1,0);
        pirelab.getSwitchComp(topNet,[correctlogslice(jj),correctlogaddreduced(jj)],correctmodresult(jj),correctlogwrap(jj),'correctmodmux');

        pirelab.getBitwiseOpComp(topNet,[omegazero(jj),chiennotzero(jj)],correctzero(jj),'OR');
        pirelab.getUnitDelayComp(topNet,correctzero(jj),correctzerodelay(jj));
        b1logadd(jj)=newDataSignal(topNet,'b1logadd',carryType,rate);
        b1logwrap(jj)=newControlSignal(topNet,'b1logwrap',rate);
        b1logaddreduced(jj)=newDataSignal(topNet,'b1logaddreduced',inType,rate);
        b1logslice(jj)=newDataSignal(topNet,'b1logslice',inType,rate);
        b1modresult(jj)=newDataSignal(topNet,'b1modresult',inType,rate);
        baccum=newDataSignal(topNet,'baccum',inType,rate);
        pirelab.getUnitDelayComp(topNet,chienpower,chienpowerdelay);
        btable=ufi(mod((0:(2^wordSize-1))*B*11,2^wordSize-1),wordSize,0);
        pirelab.getDirectLookupComp(topNet,chienpowerdelay,baccum,btable,'bcorrecttable');

        pirelab.getAddComp(topNet,[correctmodresult(jj),baccum],b1logadd(jj),'Floor','Wrap');
        pirelab.getCompareToValueComp(topNet,b1logadd(jj),b1logwrap(jj),'>',2.^wordSize-1,'b1modcompare');
        pirelab.getSubComp(topNet,[b1logadd(jj),moduloconst],b1logaddreduced(jj),'Floor','Wrap');
        pirelab.getBitSliceComp(topNet,b1logadd(jj),b1logslice(jj),wordSize-1,0);
        pirelab.getSwitchComp(topNet,[b1logslice(jj),b1logaddreduced(jj)],b1modresult(jj),b1logwrap(jj),'b1modmux');

        pirelab.getDirectLookupComp(topNet,b1modresult(jj),correctalogout(jj),alogTable,'correctalogtable');
        pirelab.getSwitchComp(topNet,[correctalogout(jj),zeroconst],correctresult(jj),correctzerodelay(jj),'correctzeromux');
    end




    for jj=1:I
        errcountvalue(jj)=newDataSignal(topNet,'errcountvalue',inType,rate);
        errcount(jj)=newDataSignal(topNet,'errcount',inType,rate);
        errlocation(jj)=newDataSignal(topNet,'errlocation',inType,rate);
        errvalue(jj)=newDataSignal(topNet,'errvalue',inType,rate);
        errvalid(jj)=newControlSignal(topNet,'errvalid',rate);
        erradvance(jj)=newControlSignal(topNet,'erradvance',rate);
        finalerrloc(jj)=newDataSignal(topNet,'finalerrloc',inType,rate);
        errgate(jj)=newControlSignal(topNet,sprintf('errgate%d',jj),rate);
        notuncorrect(jj)=newControlSignal(topNet,'notuncorrect',rate);
        anyuncorrect(jj)=newControlSignal(topNet,'anyuncorrect',rate);
        anyuncorrectreg(jj)=newControlSignal(topNet,'anyuncorrectreg',rate);
        errcountuncheck(jj)=newControlSignal(topNet,'errcountuncheck',rate);
    end
    fulllength=newDataSignal(topNet,'fulllength',inType,rate);
    erroffset=newDataSignal(topNet,'erroffset',inType,rate);


    polylen=newDataSignal(topNet,'oneconst',countType,rate);
    pirelab.getConstComp(topNet,polylen,2*corr-1,'polylen');




    for jj=1:I
        pirelab.getCounterComp(topNet,[errcountreset(jj),prestartcurbankdelay,oneconst1,erradvance(jj)],errcountvalue(jj),...
        'Count limited',...
        0.0,...
        1.0,...
        2*corr-1,...
        true,...
        true,...
        true,...
        false,...
        'errcounter');

        pirelab.getBitwiseOpComp(topNet,[errcountgrtzero(jj),errgate(jj),errcountuncheck(jj)],erradvance(jj),'AND');
        pirelab.getCompareToValueComp(topNet,errcountvalue(jj),errcountgrtzero(jj),'>',0);
        pirelab.getRelOpComp(topNet,[errcountvalue(jj),nrootsreg(jj)],errcountreset1(jj),'==');
        pirelab.getBitwiseOpComp(topNet,[errgate(jj),errcountreset1(jj)],errcountreset(jj),'AND');

        pirelab.getSubComp(topNet,[errcountvalue(jj),oneconst],errcount(jj),'Floor','Wrap');

        pirelab.getMultiPortSwitchComp(topNet,[errcount(jj);errlocationpiperegdelay(:,jj)],...
        errlocation(jj),...
        1,1,'floor','Wrap','errmux');
        pirelab.getMultiPortSwitchComp(topNet,[errcount(jj);errvaluepiperegPrestart(:,jj)],...
        errvalue(jj),...
        1,1,'floor','Wrap','errmux');
        pirelab.getMultiPortSwitchComp(topNet,[errcount(jj);errvalidpiperegdelay(:,jj)],...
        errvalid(jj),...
        1,1,'floor','Wrap','errmux');

        pirelab.getAddComp(topNet,[currentCWLength,parityconst8Bit],fulllength,'Floor','Wrap');
        pirelab.getBitwiseOpComp(topNet,fulllength,erroffset,'NOT');
        pirelab.getSubComp(topNet,[errlocation(jj),erroffset],finalerrloc(jj),'Floor','Wrap');

        errgate1(jj)=newControlSignal(topNet,'errgate1',rate);
        pirelab.getRelOpComp(topNet,[finalerrloc(jj),msgLenOut],errgate1(jj),'==');

        curIntrlvOut(jj)=newControlSignal(topNet,sprintf('curIntrlvOut%d',jj),rate);
        pirelab.getCompareToValueComp(topNet,intrlvIndOut,curIntrlvOut(jj),'==',jj-1);

        pirelab.getBitwiseOpComp(topNet,[errgate1(jj),curIntrlvOut(jj)],errgate(jj),'AND');

        pirelab.getBitwiseOpComp(topNet,comparepolylen(jj),errcountuncheck(jj),'NOT');

        pirelab.getBitwiseOpComp(topNet,uncorrected(jj),notuncorrect(jj),'NOT');

        pirelab.getSwitchComp(topNet,[zeroconst,errvalue(jj)],correctionnext(jj),erradvance(jj),'correctmux');

        correction1(jj)=newDataSignal(topNet,'correction1',inType,rate);
        pirelab.getUnitDelayComp(topNet,correctionnext(jj),correction1(jj),'correctreg',0.0);


        pirelab.getUnitDelayEnabledComp(topNet,haserrorsreg(jj),haserrorsfsmreg(jj),fsmdone,'synhaserrfsmreg',0.0,'',false);

        pirelab.getUnitDelayEnabledComp(topNet,haserrorsfsmreg(jj),haserrorsconvreg(jj),convdone,'synhaserrconvreg',0.0,'',false);

        pirelab.getUnitDelayEnabledComp(topNet,haserrorsconvreg(jj),haserrorschienprereg(jj),chienprerundone,'synhaserrchienprereg',0.0,'',false);

        pirelab.getUnitDelayEnabledComp(topNet,haserrorschienprereg(jj),haserrorschienreg(jj),chiendone,'synhaserrchienreg',0.0,'',false);

        pirelab.getUnitDelayComp(topNet,nroots(jj),nrootsdelayed(jj),'nrootsdelayed',0.0);
        pirelab.getUnitDelayEnabledComp(topNet,nrootsdelayed(jj),nrootsreg(jj),chiendonedelay,'nrootsregproc',0.0,'',false);

        pirelab.getUnitDelayEnabledComp(topNet,anyuncorrect(jj),anyuncorrectreg(jj),prestartout,'anyuncreg',0.0,'',false);

        nrootsstart1(jj)=newDataSignal(topNet,'nrootsstart1',countType,rate);
        pirelab.getUnitDelayEnabledComp(topNet,nrootsreg(jj),nrootsstart1(jj),prestartout,'nrootsstart',0.0,'',false);


        pirelab.getBitwiseOpComp(topNet,[errvalidsigregdelay(:,jj);haserrorschienreg(jj)],anyerr(jj),'OR');




        chiendonedelay2=newControlSignal(topNet,'chiendonedelay2',rate);
        pirelab.getUnitDelayComp(topNet,chiendone,chiendonedelay,'0.0');
        pirelab.getUnitDelayComp(topNet,chiendonedelay,chiendonedelay2,'0.0');
        pirelab.getUnitDelayComp(topNet,convdone,convdonedelay,'0.0');

        pirelab.getBitwiseOpComp(topNet,[convdonedelay,convxorevendelay],convxoreven,'XOR');
        pirelab.getUnitDelayComp(topNet,convxoreven,convxorevendelay,'0.0');

        pirelab.getBitwiseOpComp(topNet,convxoreven,convxorodd,'NOT');

        pirelab.getBitwiseOpComp(topNet,[convdonedelay,convxoreven],convxorevensample,'AND');
        pirelab.getBitwiseOpComp(topNet,[convdonedelay,convxorodd],convxoroddsample,'AND');


        pirelab.getUnitDelayEnabledComp(topNet,errlocpolylenconv(jj),errlocpolylenconveven(jj),convxorevensample,'ordererr2',0.0,'',false);
        pirelab.getUnitDelayEnabledComp(topNet,errlocpolylenconv(jj),errlocpolylenconvodd(jj),convxoroddsample,'ordererr3',0.0,'',false);

        pirelab.getBitwiseOpComp(topNet,[chiendone,switchctrldelay],switchctrl,'XOR');
        pirelab.getUnitDelayComp(topNet,switchctrl,switchctrldelay,'0.0');

        pirelab.getSwitchComp(topNet,[errlocpolylenconvodd(jj),errlocpolylenconveven(jj)],errlocpolylenchien(jj),switchctrl,'ordererrmux');
        pirelab.getSubComp(topNet,[errlocpolylenchien(jj),oneconst],errlocpolylenminusone(jj),'Floor','Wrap');
        pirelab.getUnitDelayEnabledComp(topNet,errlocpolylen(jj),errlocpolylenconv(jj),convdone,'errlocpolylendelayed',0.0,'',false);

        pirelab.getRelOpComp(topNet,[errlocpolylenminusone(jj),nrootsreg(jj)],comparepolylen(jj),'>');
        pirelab.getRelOpComp(topNet,[errlocpolylenchien(jj),nrootsreg(jj)],comparepolylen1(jj),'>');


        pirelab.getUnitDelayEnabledComp(topNet,comparepolylen1(jj),finalordererr(jj),chiendonedelay2,'finalordererrDelay',0.0,'',false);
        pirelab.getUnitDelayEnabledComp(topNet,finalordererr(jj),finalordererr1(jj),prestartout,'finalordererr1Delay',0.0,'',false);

    end

    intrlvIndOutDelay=newDataSignal(topNet,'intrlvIndOutDelay',pir_ufixpt_t(nextpow2(I+1+1),0),rate);
    pirelab.getUnitDelayComp(topNet,intrlvIndOut,intrlvIndOutDelay,'0.0');
    pirelab.getMultiPortSwitchComp(topNet,[intrlvIndOutDelay,correction1],correction,...
    1,1,'floor','Wrap','currentlengthmux');

    finalordererr2=newControlSignal(topNet,'finalordererr2',rate);
    pirelab.getBitwiseOpComp(topNet,finalordererr1(:),finalordererr2,'OR');
    pirelab.getBitwiseOpComp(topNet,[finalordererr2,preendout],preerrout,'AND');

    switch I
    case 2
        pirelab.getAddComp(topNet,nrootsstart1(:),nrootsstart,'floor','wrap','AddAllnRoots',pir_ufixpt_t(8,0),...
        '++');
    case 3
        pirelab.getAddComp(topNet,nrootsstart1(:),nrootsstart,'floor','wrap','AddAllnRoots',pir_ufixpt_t(8,0),...
        '+++');
    case 4
        pirelab.getAddComp(topNet,nrootsstart1(:),nrootsstart,'floor','wrap','AddAllnRoots',pir_ufixpt_t(8,0),...
        '++++');
    case 5
        pirelab.getAddComp(topNet,nrootsstart1(:),nrootsstart,'floor','wrap','AddAllnRoots',pir_ufixpt_t(8,0),...
        '+++++');
    case 8
        pirelab.getAddComp(topNet,nrootsstart1(:),nrootsstart,'floor','wrap','AddAllnRoots',pir_ufixpt_t(8,0),...
        '++++++++');
    otherwise
        pirelab.getDTCComp(topNet,nrootsstart1,nrootsstart);
    end








    for ii=1:numPackets
        delaycount(ii)=newDataSignal(topNet,['delay%dcount',(ii-1)],delayType,rate);
    end

    for ii=1:numPackets
        delaymax(ii)=newControlSignal(topNet,['delay%dmax',(ii-1)],rate);
    end

    for ii=1:numPackets
        prestartbank(ii)=newControlSignal(topNet,['prestartbank%d',(ii-1)],rate);
    end

    for ii=1:numPackets
        delaycountenb(ii)=newControlSignal(topNet,'delaycountenb',rate);
        delaylimit(ii)=newControlSignal(topNet,'delaylimit',rate);
        pirelab.getCompareToValueComp(topNet,delaycount(ii),delaylimit(ii),'<',2^delayWordSize-1,['d%dmaxcompare',(ii-1)]);
        pirelab.getBitwiseOpComp(topNet,[bankvalid(ii),delaylimit(ii)],delaycountenb(ii),'AND');
        pirelab.getCompareToValueComp(topNet,delaycount(ii),delaymax(ii),'==',2^delayWordSize-4,['d%dmaxcompare',(ii-1)]);
    end

    for ii=1:numPackets
        pirelab.getCounterComp(topNet,[endpacketbank(ii),delaycountenb(ii)],delaycount(ii),...
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
        pirelab.getBitwiseOpComp(topNet,[bankvalid(ii),delaymax(ii)],prestartbank(ii),'AND');
    end

    pirelab.getBitwiseOpComp(topNet,prestartbank,prestartcurbank,'OR');
    pirelab.getUnitDelayComp(topNet,prestartcurbankdelay,prestartout,'prestartbankreg',0.0);



    pirelab.getUnitDelayComp(topNet,ramrdennext,ramrden,'ramrdenreg',0.0);
    pirelab.getBitwiseOpComp(topNet,[ramrdencontinue,prestartout],ramrdennext,'OR');
    pirelab.getBitwiseOpComp(topNet,[ramrden,notcountstop],ramrdencontinue,'AND');
    pirelab.getBitwiseOpComp(topNet,preendout,notcountstop,'NOT');

    pirelab.getBitwiseOpComp(topNet,[ramrdennext,preendout],prevalidout,'OR');

    predataoutDualBasis=newDataSignal(topNet,'predataoutDualBasis',inType,rate);



    pirelab.getBitwiseOpComp(topNet,[ramrddata,correction],predataout,'XOR');
    pirelab.getDirectLookupComp(topNet,predataout,predataoutDualBasis,C2D,'C2D_LUT');
    pirelab.getSwitchComp(topNet,[zeroconst,predataoutDualBasis],gatedataout,p2dvout,'gatemux');
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