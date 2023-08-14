function masseyNet=elabMassey(this,topNet,blockInfo,datarate)





    corr=12;

    uint16=pir_ufixpt_t(16,0);
    int16=pir_sfixpt_t(16,0);
    int8=pir_sfixpt_t(8,0);
    ufix17=pir_ufixpt_t(17,0);

    inportNames=cell(2*corr+2,1);

    outportNames=cell(2*corr+3,1);

    for ii=1:2*corr
        inportNames{ii}=sprintf('FinalSyndrome%d',ii);
        inTypes(ii)=uint16;%#ok
        inDataRate(ii)=datarate;%#ok

        outportNames{ii}=sprintf('errlocpoly%d',ii);
        outTypes(ii)=uint16;%#ok

    end
    inportNames{ii+1}='syndromeDone';
    inTypes(ii+1)=pir_ufixpt_t(1,0);
    inDataRate(ii+1)=datarate;

    inportNames{ii+2}='doubleCorr';
    inTypes(ii+2)=pir_ufixpt_t(16,0);
    inDataRate(ii+2)=datarate;

    outportNames{ii+1}='fsmdone';
    outTypes(ii+1)=pir_ufixpt_t(1,0);

    outportNames{ii+2}='errlocpolylength';
    outTypes(ii+2)=uint16;

    outportNames{ii+3}='LStar';
    outTypes(ii+3)=pir_sfixpt_t(8,0);

    masseyNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','masseyNet',...
    'InportNames',inportNames,...
    'InportTypes',inTypes,...
    'InportRates',inDataRate,...
    'OutportNames',outportNames,...
    'OutportTypes',outTypes...
    );


    for ii=1:2*corr
        finalsyndromereg(ii)=masseyNet.PirInputSignals(ii);%#ok
        errlocpoly(ii)=masseyNet.PirOutputSignals(ii);%#ok
    end
    syndromeDone=masseyNet.PirInputSignals(ii+1);
    doubleCorr=masseyNet.PirInputSignals(ii+2);

    fsmdone=masseyNet.PirOutputSignals(ii+1);

    if strcmp(blockInfo.FECFrameType,'Normal')
        N_long=newDataSignal(masseyNet,'N_long',uint16,datarate);
        pirelab.getConstComp(masseyNet,N_long,2^16-1);
    else
        N_long=newDataSignal(masseyNet,'N_long',uint16,datarate);
        pirelab.getConstComp(masseyNet,N_long,2^14-1);
    end

    errlocpolylen=masseyNet.PirOutputSignals(ii+2);
    LOutput=masseyNet.PirOutputSignals(ii+3);

    fsmrun=newControlSignal(masseyNet,'fsmrun',datarate);
    fsmrunTemp=newControlSignal(masseyNet,'fsmrunTemp',datarate);
    fsmrunD1=newControlSignal(masseyNet,'fsmrunD1',datarate);


    synDfsmDOR=newControlSignal(masseyNet,'synDfsmDOR',datarate);
    pirelab.getBitwiseOpComp(masseyNet,[fsmdone,syndromeDone],synDfsmDOR,'OR');
    pirelab.getUnitDelayComp(masseyNet,fsmrunTemp,fsmrunD1);
    pirelab.getBitwiseOpComp(masseyNet,[synDfsmDOR,fsmrunD1],fsmrunTemp,'XOR');
    onesconst=newDataSignal(masseyNet,'onesconst',uint16,datarate);
    pirelab.getConstComp(masseyNet,onesconst,1);
    trueConst=newControlSignal(masseyNet,'trueConst',datarate);
    pirelab.getConstComp(masseyNet,trueConst,1);
    zeroconst=newDataSignal(masseyNet,'zeroconst',uint16,datarate);
    pirelab.getConstComp(masseyNet,zeroconst,0);
    discrep=newDataSignal(masseyNet,'discrep',uint16,datarate);
    discrepD1sampled=newDataSignal(masseyNet,'discrepD1sampled',uint16,datarate);
    discrepD1sampledD1=newDataSignal(masseyNet,'discrepD1sampledD1',uint16,datarate);
    pirelab.getUnitDelayComp(masseyNet,discrepD1sampled,discrepD1sampledD1);


    discrepD1Mod=newDataSignal(masseyNet,'discrepD1Mod',uint16,datarate);
    discrepD1Log=newDataSignal(masseyNet,'discrepD1Log',uint16,datarate);
    discrepD1ModD1=newDataSignal(masseyNet,'discrepD1ModD1',uint16,datarate);
    discrepD1LogD1=newDataSignal(masseyNet,'discrepD1LogD1',uint16,datarate);
    pirelab.getUnitDelayComp(masseyNet,discrepD1Mod,discrepD1ModD1);
    pirelab.getUnitDelayComp(masseyNet,discrepD1Log,discrepD1LogD1);
    L=newDataSignal(masseyNet,'L',int8,datarate);
    LStar=newDataSignal(masseyNet,'LStar',int8,datarate);
    LStarTemp=newDataSignal(masseyNet,'LStarTemp',int8,datarate);
    LStarD1=newDataSignal(masseyNet,'LStarD1',int8,datarate);

    kCC=newDataSignal(masseyNet,'kCC',int8,datarate);
    nCC=newDataSignal(masseyNet,'nCC',int8,datarate);
    nCCCounterEnb=newControlSignal(masseyNet,'nCCCounterEnb',datarate);
    nCCGreatThanZero=newControlSignal(masseyNet,'nCCGreatThanZero',datarate);
    nCCCounterRst=newControlSignal(masseyNet,'nCCCounterRst',datarate);
    nCCLoadEnb=newControlSignal(masseyNet,'nCCLoadEnb',datarate);
    nCCLoadVal=newDataSignal(masseyNet,'nCCLoadVal',int8,datarate);
    LCounterEnb=newControlSignal(masseyNet,'LCounterEnb',datarate);
    LCounterRstTemp=newControlSignal(masseyNet,'LCounterRstTemp',datarate);
    LCounterRstTemp1=newControlSignal(masseyNet,'LCounterRstTemp1',datarate);
    LCounterRst=newControlSignal(masseyNet,'LCounterRst',datarate);
    LCounterMax=newControlSignal(masseyNet,'LCounterMax',datarate);
    sampleCount=newDataSignal(masseyNet,'sampleCount',uint16,datarate);
    sampleCountEnb=newControlSignal(masseyNet,'sampleCountEnb',datarate);
    sampleCountRst=newControlSignal(masseyNet,'sampleCountRst',datarate);


    resampleCount=newDataSignal(masseyNet,'resampleCount',uint16,datarate);
    resampleCountEnb=newControlSignal(masseyNet,'resampleCountEnb',datarate);
    resampleCountRst=newControlSignal(masseyNet,'resampleCountRst',datarate);



    pirelab.getCounterComp(masseyNet,[nCCCounterRst,nCCLoadEnb,nCCLoadVal,nCCCounterEnb],nCC,...
    'Count limited',...
    0.0,...
    1,...
    25,...
    true,...
    true,...
    true,...
    false,...
    'nCCCounter');
    pirelab.getWireComp(masseyNet,syndromeDone,nCCLoadEnb);
    pirelab.getConstComp(masseyNet,nCCLoadVal,1);
    pirelab.getCompareToValueComp(masseyNet,nCC,nCCGreatThanZero,'>',0);
    pirelab.getBitwiseOpComp(masseyNet,[nCCGreatThanZero,LCounterRst],nCCCounterEnb,'AND');
    pirelab.getRelOpComp(masseyNet,[nCC,doubleCorr],nCCCounterRst,'>');


    pirelab.getCounterComp(masseyNet,[LCounterRst,LCounterEnb],L,...
    'Count limited',...
    0.0,...
    1,...
    11,...
    true,...
    false,...
    true,...
    false,...
    'LCounter');

    pirelab.getBitwiseOpComp(masseyNet,[nCCGreatThanZero,sampleCountRst],LCounterEnb,'AND');
    pirelab.getCompareToValueComp(masseyNet,L,LCounterMax,'==',11);



    sampleCountMax=newControlSignal(masseyNet,'sampleCountMax',datarate);
    pirelab.getBitwiseOpComp(masseyNet,[LCounterMax,sampleCountMax],LCounterRstTemp,'AND');
    pirelab.getBitwiseOpComp(masseyNet,[LCounterRstTemp,nCCCounterRst,nCCLoadEnb],LCounterRst,'OR');

    pirelab.getBitwiseOpComp(masseyNet,[nCCGreatThanZero,syndromeDone],fsmrun,'OR');
    pirelab.getUnitDelayResettableComp(masseyNet,discrep,discrepD1sampled,LCounterRst,'discrepRegister',0,'',true);


    pirelab.getCounterComp(masseyNet,[sampleCountRst,sampleCountEnb],sampleCount,...
    'Count limited',...
    0,...
    1,...
    23,...
    true,...
    false,...
    true,...
    false,...
    'sampleCounter');
    sampleCountisZero=newControlSignal(masseyNet,'sampleCountisZero',datarate);
    pirelab.getCompareToValueComp(masseyNet,sampleCount,sampleCountisZero,'==',0);
    pirelab.getBitwiseOpComp(masseyNet,[nCCGreatThanZero,resampleCountRst],sampleCountEnb,'AND');

    sampleCountMaxTemp=newControlSignal(masseyNet,'sampleCountMaxTemp',datarate);
    pirelab.getBitwiseOpComp(masseyNet,[nCCCounterRst,sampleCountMax,nCCLoadEnb],sampleCountRst,'OR');
    pirelab.getCompareToValueComp(masseyNet,sampleCount,sampleCountMaxTemp,'==',23);
    pirelab.getBitwiseOpComp(masseyNet,[sampleCountMaxTemp,resampleCountRst],sampleCountMax,'AND');

    pirelab.getCounterComp(masseyNet,[resampleCountRst,resampleCountEnb],resampleCount,...
    'Count limited',...
    0,...
    1,...
    4,...
    true,...
    false,...
    true,...
    false,...
    'sampleCounter');
    resampleCountisZero=newControlSignal(masseyNet,'resampleCountisZero',datarate);
    resampleCountisOne=newControlSignal(masseyNet,'resampleCountisOne',datarate);
    resampleCountisTwo=newControlSignal(masseyNet,'resampleCountisTwo',datarate);
    resampleCountisThree=newControlSignal(masseyNet,'resampleCountisThree',datarate);
    pirelab.getCompareToValueComp(masseyNet,resampleCount,resampleCountisZero,'==',0);
    pirelab.getCompareToValueComp(masseyNet,resampleCount,resampleCountisOne,'==',1);
    pirelab.getCompareToValueComp(masseyNet,resampleCount,resampleCountisTwo,'==',2);
    pirelab.getCompareToValueComp(masseyNet,resampleCount,resampleCountisThree,'==',3);


    resampZeroClkCyc=newControlSignal(masseyNet,'resampZeroClkCyc',datarate);
    resampFirstClkCyc=newControlSignal(masseyNet,'resampFirstClkCyc',datarate);
    resampSecClkCyc=newControlSignal(masseyNet,'resampSecClkCyc',datarate);
    resampThirdClkCyc=newControlSignal(masseyNet,'resampThirdClkCyc',datarate);
    pirelab.getBitwiseOpComp(masseyNet,[resampleCountisZero,sampleCountisZero],resampZeroClkCyc,'AND');
    pirelab.getBitwiseOpComp(masseyNet,[resampleCountisOne,sampleCountisZero],resampFirstClkCyc,'AND');
    pirelab.getBitwiseOpComp(masseyNet,[resampleCountisTwo,sampleCountisZero],resampSecClkCyc,'AND');
    pirelab.getBitwiseOpComp(masseyNet,[resampleCountisThree,sampleCountisZero],resampThirdClkCyc,'AND');


    pirelab.getWireComp(masseyNet,nCCGreatThanZero,resampleCountEnb);
    resampleCountMax=newControlSignal(masseyNet,'resampleCountMax',datarate);
    pirelab.getBitwiseOpComp(masseyNet,[nCCCounterRst,resampleCountMax,nCCLoadEnb],resampleCountRst,'OR');
    pirelab.getCompareToValueComp(masseyNet,resampleCount,resampleCountMax,'==',4);


    pirelab.getUnitDelayEnabledResettableComp(masseyNet,LStar,LStarD1,resampThirdClkCyc,syndromeDone);
    syndromeEnb=newControlSignal(masseyNet,'syndromeEnb',datarate);
    pirelab.getBitwiseOpComp(masseyNet,[resampZeroClkCyc,syndromeDone],syndromeEnb,'OR');
    for ii=1:2*corr
        lamdaPrior(ii)=newDataSignal(masseyNet,['lamdaPrior_',num2str(ii)],uint16,datarate);%#ok
        lambda(ii)=newDataSignal(masseyNet,['lamda_',num2str(ii)],uint16,datarate);%#ok 
        lambdaD1(ii)=newDataSignal(masseyNet,['lamdaD1_',num2str(ii)],uint16,datarate);%#ok
        lambdaD2(ii)=newDataSignal(masseyNet,['lamdaD2_',num2str(ii)],uint16,datarate);%#ok
        lambdaD1Mod(ii)=newDataSignal(masseyNet,['lamdaD1Mod_',num2str(ii)],uint16,datarate);%#ok
        lambdaD1Log(ii)=newDataSignal(masseyNet,['lamdaD1Log_',num2str(ii)],uint16,datarate);%#ok
        lambdaTemp(ii)=newDataSignal(masseyNet,['lamdaTemp_',num2str(ii)],uint16,datarate);%#ok
        pirelab.getUnitDelayComp(masseyNet,lambdaD1(ii),lambdaD2(ii));

        if ii==1
            if strcmp(blockInfo.FECFrameType,'Normal')
                pirelab.getUnitDelayEnabledResettableComp(masseyNet,lambda(ii),lambdaD1(ii),resampThirdClkCyc,syndromeDone,['lambdaRegister',num2str(ii)],2^16-1,'',true);
            else
                pirelab.getUnitDelayEnabledResettableComp(masseyNet,lambda(ii),lambdaD1(ii),resampThirdClkCyc,syndromeDone,['lambdaRegister',num2str(ii)],2^14-1,'',true);
            end
        else
            pirelab.getUnitDelayEnabledResettableComp(masseyNet,lambda(ii),lambdaD1(ii),resampThirdClkCyc,syndromeDone,['lambdaRegister',num2str(ii)],0,'',true);
        end
        lambdaStar(ii)=newDataSignal(masseyNet,['lamdaStar_',num2str(ii)],uint16,datarate);%#ok
        lambdaStarTemp(ii)=newDataSignal(masseyNet,['lamdaStarTemp_',num2str(ii)],uint16,datarate);%#ok

        Dz(ii)=newDataSignal(masseyNet,['Dz_',num2str(ii)],uint16,datarate);%#ok
        DzD1(ii)=newDataSignal(masseyNet,['DzD1_',num2str(ii)],uint16,datarate);%#ok
        DzD2(ii)=newDataSignal(masseyNet,['DzD2_',num2str(ii)],uint16,datarate);%#ok
        pirelab.getUnitDelayComp(masseyNet,DzD1(ii),DzD2(ii));
        if ii==2
            if strcmp(blockInfo.FECFrameType,'Normal')
                pirelab.getUnitDelayEnabledResettableComp(masseyNet,Dz(ii),DzD1(ii),resampThirdClkCyc,syndromeDone,['DzRegister',num2str(ii)],2^16-1,'',true);
            else
                pirelab.getUnitDelayEnabledResettableComp(masseyNet,Dz(ii),DzD1(ii),resampThirdClkCyc,syndromeDone,['DzRegister',num2str(ii)],2^14-1,'',true);
            end
        else
            pirelab.getUnitDelayEnabledResettableComp(masseyNet,Dz(ii),DzD1(ii),resampThirdClkCyc,syndromeDone);
        end
        syndromeShiftReg(ii)=newDataSignal(masseyNet,['syndromeShiftReg_',num2str(ii)],uint16,datarate);%#ok
        pirelab.getUnitDelayEnabledComp(masseyNet,finalsyndromereg(ii),syndromeShiftReg(ii),syndromeEnb);

    end
    currentLambda=newDataSignal(masseyNet,'currentLambda',uint16,datarate);
    currentSyn=newDataSignal(masseyNet,'currentSyn',uint16,datarate);
    currentLambdaD1=newDataSignal(masseyNet,'currentLambdaD1',uint16,datarate);
    currentSynD1=newDataSignal(masseyNet,'currentSynD1',uint16,datarate);
    synIndex=newDataSignal(masseyNet,'synIndex',int16,datarate);
    synIndexTemp=newDataSignal(masseyNet,'synIndexTemp',int16,datarate);
    synIndexD1=newDataSignal(masseyNet,'synIndexD1',int16,datarate);
    pirelab.getUnitDelayComp(masseyNet,synIndex,synIndexD1);
    pirelab.getSubComp(masseyNet,[nCC,L],synIndexTemp);
    pirelab.getSubComp(masseyNet,[synIndexTemp,onesconst],synIndex);


    temp=newDataSignal(masseyNet,'temp',ufix17,datarate);
    tempMod=newDataSignal(masseyNet,'tempMod',uint16,datarate);
    tempLog=newDataSignal(masseyNet,'tempLog',uint16,datarate);
    isLamdaZero=newControlSignal(masseyNet,'isLamdaZero_',datarate);
    isSynZero=newControlSignal(masseyNet,'isSynZero_',datarate);
    isDiscrepNotZero=newControlSignal(masseyNet,'isDiscrepNotZero',datarate);
    pirelab.getCompareToValueComp(masseyNet,discrepD1sampled,isDiscrepNotZero,'~=',0);
    discrepTemp=newDataSignal(masseyNet,'discrepTemp',uint16,datarate);

    pirelab.getMultiPortSwitchComp(masseyNet,[L,lambdaD1],currentLambda,1,1,'floor','Wrap','Lmux');

    pirelab.getMultiPortSwitchComp(masseyNet,[synIndex,syndromeShiftReg],currentSyn,1,1,'floor','Wrap','synmux');
    pirelab.getUnitDelayComp(masseyNet,currentLambda,currentLambdaD1);
    pirelab.getUnitDelayComp(masseyNet,currentSyn,currentSynD1);
    pirelab.getAddComp(masseyNet,[currentLambda,currentSyn],temp);
    tempD1=newDataSignal(masseyNet,'tempD1',ufix17,datarate);
    pirelab.getUnitDelayComp(masseyNet,temp,tempD1);

    GFTabValNet_discrep=this.elabGfTabVal(masseyNet,blockInfo,datarate);
    GFTabValNet_discrep.addComment('GFTable1ValforDiscrep');
    discrep17Bit=newDataSignal(masseyNet,'discrep17Bit',ufix17,datarate);
    pirelab.getDTCComp(masseyNet,discrepD1sampled,discrep17Bit);
    pirelab.instantiateNetwork(masseyNet,GFTabValNet_discrep,discrep17Bit,[discrepD1Log,discrepD1Mod],'GFTabValNet_discrep');




    GFTabValNet_temp=this.elabGfTabVal(masseyNet,blockInfo,datarate);
    GFTabValNet_temp.addComment('GFTable1ValforTemp');
    pirelab.instantiateNetwork(masseyNet,GFTabValNet_temp,temp,[tempLog,tempMod],'GFTabValNet_temp');
    tempModD1=newDataSignal(masseyNet,'tempModD1',uint16,datarate);
    tempLogD1=newDataSignal(masseyNet,'tempLogD1',uint16,datarate);
    pirelab.getUnitDelayComp(masseyNet,tempMod,tempModD1);
    pirelab.getUnitDelayComp(masseyNet,tempLog,tempLogD1);
    pirelab.getUnitDelayComp(masseyNet,discrepD1Mod,discrepD1ModD1);
    pirelab.getUnitDelayComp(masseyNet,discrepD1Log,discrepD1LogD1);

    GFAddXORNet1=this.elabGfAddXOR(masseyNet,blockInfo,datarate);
    GFAddXORNet1.addComment('GFXORforDiscrep');
    pirelab.instantiateNetwork(masseyNet,GFAddXORNet1,[discrepD1ModD1,tempModD1,discrepD1Log,tempLog],discrepTemp,'GFTabXORNetDiscrep');

    DzEnable=newControlSignal(masseyNet,'DzEnable',datarate);
    nCCMinuskCC=newDataSignal(masseyNet,'nCCMinuskCC',int8,datarate);
    nCCMinuskCCTemp=newDataSignal(masseyNet,'nCCMinuskCCTemp',int8,datarate);

    pirelab.getRelOpComp(masseyNet,[LStarD1,nCCMinuskCC],DzEnable,'<');

    isDiscrepNotZeroTemp=newControlSignal(masseyNet,'isDiscrepNotZeroTemp',datarate);

    LStarEnb=newControlSignal(masseyNet,'LStarEnb',datarate);
    DzEnableD4=newControlSignal(masseyNet,'DzEnableD4',datarate);
    fsmrunD4=newControlSignal(masseyNet,'fsmrunD4',datarate);


    LComprenCCkCC=newControlSignal(masseyNet,'LComprenCCkCC',datarate);
    LComprenCCkCCTemp=newControlSignal(masseyNet,'LComprenCCkCCTemp',datarate);
    pirelab.getIntDelayComp(masseyNet,DzEnable,DzEnableD4,4,'',0);
    pirelab.getIntDelayComp(masseyNet,fsmrun,fsmrunD4,4,'',0);
    pirelab.getBitwiseOpComp(masseyNet,[DzEnable,isDiscrepNotZero,fsmrun,LComprenCCkCCTemp,resampThirdClkCyc],LStarEnb,'AND');

    pirelab.getSwitchComp(masseyNet,[L,nCCMinuskCC],LStarTemp,LStarEnb);


    pirelab.getRelOpComp(masseyNet,[L,LStarD1],LComprenCCkCCTemp,'==');
    pirelab.getBitwiseOpComp(masseyNet,[LComprenCCkCCTemp,fsmrun,resampThirdClkCyc],LComprenCCkCC,'AND');



    pirelab.getUnitDelayEnabledResettableComp(masseyNet,LStarTemp,LStar,LComprenCCkCC,syndromeDone,'',0);



    LLessThanLStar=newControlSignal(masseyNet,'LLessThanLStar',datarate);
    pirelab.getRelOpComp(masseyNet,[L,LStarD1],LLessThanLStar,'<=');


    discrepNotEnbTemp=newControlSignal(masseyNet,'discrepNotEnbTemp',datarate);
    discrepEnbTemp=newControlSignal(masseyNet,'discrepEnbTemp',datarate);
    discrepEnbTemp1=newControlSignal(masseyNet,'discrepEnbTemp1',datarate);
    discrepEnbTemp1D4=newControlSignal(masseyNet,'discrepEnbTemp1D4',datarate);
    pirelab.getIntDelayComp(masseyNet,discrepEnbTemp1,discrepEnbTemp1D4,4,'',0);
    fsmrunD1=newControlSignal(masseyNet,'fsmrunD1',datarate);
    pirelab.getUnitDelayComp(masseyNet,fsmrun,fsmrunD1);
    pirelab.getBitwiseOpComp(masseyNet,[fsmrunD1,discrepEnbTemp],discrepEnbTemp1,'AND');
    pirelab.getCompareToValueComp(masseyNet,currentSyn,isSynZero,'==',0);
    pirelab.getCompareToValueComp(masseyNet,currentLambda,isLamdaZero,'==',0);
    pirelab.getBitwiseOpComp(masseyNet,[isSynZero,isLamdaZero],discrepNotEnbTemp,'OR');
    pirelab.getBitwiseOpComp(masseyNet,discrepNotEnbTemp,discrepEnbTemp,'NOT');
    discrepEnb=newControlSignal(masseyNet,'discrepEnb',datarate);
    pirelab.getBitwiseOpComp(masseyNet,[discrepEnbTemp1,LLessThanLStar,resampSecClkCyc],discrepEnb,'AND');
    pirelab.getSwitchComp(masseyNet,[discrepD1sampled,discrepTemp],discrep,discrepEnb);

    pirelab.getBitwiseOpComp(masseyNet,[isDiscrepNotZero,fsmrun,LComprenCCkCC,resampThirdClkCyc],isDiscrepNotZeroTemp,'AND');


    kCCD1=newDataSignal(masseyNet,'kCCD1',int8,datarate);
    kCCTemp=newDataSignal(masseyNet,'kCCTemp',int8,datarate);
    pirelab.getUnitDelayEnabledResettableComp(masseyNet,kCC,kCCD1,resampThirdClkCyc,syndromeDone,'kCCReg',-1);
    nCCMinusL=newDataSignal(masseyNet,'nCCMinusL',int8,datarate);
    nCCMinusLTemp=newDataSignal(masseyNet,'nCCMinusLTemp',int8,datarate);
    pirelab.getSubComp(masseyNet,[nCC,LStarD1],nCCMinusLTemp);
    pirelab.getSubComp(masseyNet,[nCCMinusLTemp,onesconst],nCCMinusL);
    pirelab.getSubComp(masseyNet,[nCC,kCCD1],nCCMinuskCCTemp);
    pirelab.getSubComp(masseyNet,[nCCMinuskCCTemp,onesconst],nCCMinuskCC);
    pirelab.getSwitchComp(masseyNet,[kCCD1,nCCMinusL],kCCTemp,LStarEnb);
    kCCEnb=newControlSignal(masseyNet,'kCCEnb',datarate);
    pirelab.getBitwiseOpComp(masseyNet,[fsmrun,LComprenCCkCC,resampThirdClkCyc],kCCEnb,'AND');

    pirelab.getUnitDelayEnabledResettableComp(masseyNet,kCCTemp,kCC,kCCEnb,syndromeDone,'',-1);

    discrepInv=newDataSignal(masseyNet,'discrepInv',uint16,datarate);

    pirelab.getSubComp(masseyNet,[N_long,discrepD1sampled],discrepInv);


    LUTInpLamda=newDataSignal(masseyNet,'LUTInpLamda',uint16,datarate);
    LUTInpLamdaLog=newDataSignal(masseyNet,'LUTInpLamdaLog',uint16,datarate);
    LUTInpLamdaMod=newDataSignal(masseyNet,'LUTInpLamdaMod',uint16,datarate);
    LUTInpLamdaLogD1=newDataSignal(masseyNet,'LUTInpLamdaLogD1',uint16,datarate);
    LUTInpLamdaModD1=newDataSignal(masseyNet,'LUTInpLamdaModD1',uint16,datarate);
    pirelab.getUnitDelayComp(masseyNet,LUTInpLamdaLog,LUTInpLamdaLogD1);
    pirelab.getUnitDelayComp(masseyNet,LUTInpLamdaMod,LUTInpLamdaModD1);


    LUTInpDiscrepDz=newDataSignal(masseyNet,'LUTInpDiscrepDz',ufix17,datarate);
    LUTInpDiscrepDzLog=newDataSignal(masseyNet,'LUTInpDiscrepDzLog',uint16,datarate);
    LUTInpDiscrepDzMod=newDataSignal(masseyNet,'LUTInpDiscrepDzMod',uint16,datarate);
    LUTInpDiscrepDzLogD1=newDataSignal(masseyNet,'LUTInpDiscrepDzLogD1',uint16,datarate);
    LUTInpDiscrepDzModD1=newDataSignal(masseyNet,'LUTInpDiscrepDzModD1',uint16,datarate);
    pirelab.getUnitDelayComp(masseyNet,LUTInpDiscrepDzLog,LUTInpDiscrepDzLogD1);
    pirelab.getUnitDelayComp(masseyNet,LUTInpDiscrepDzMod,LUTInpDiscrepDzModD1);

    LUTlambdaStarTemp=newDataSignal(masseyNet,'LUTlambdaStarTemp',uint16,datarate);
    LUTlambdaStarTempD1=newDataSignal(masseyNet,'LUTlambdaStarTempD1',uint16,datarate);
    pirelab.getUnitDelayComp(masseyNet,LUTlambdaStarTemp,LUTlambdaStarTempD1);

    discrepEnbSampledD1=newControlSignal(masseyNet,'discrepEnbSampledD1',datarate);
    pirelab.getUnitDelayEnabledComp(masseyNet,discrepEnb,discrepEnbSampledD1,resampSecClkCyc);


    isDiscrepNotZeroTempHold=newControlSignal(masseyNet,'isDiscrepNotZeroTempHold',datarate);
    isDiscrepNotZeroTempHold1=newControlSignal(masseyNet,'isDiscrepNotZeroTempHold1',datarate);
    pirelab.getUnitDelayComp(masseyNet,isDiscrepNotZeroTempHold,isDiscrepNotZeroTempHold1);
    pirelab.getSwitchComp(masseyNet,[isDiscrepNotZeroTempHold1,isDiscrepNotZeroTemp],isDiscrepNotZeroTempHold,resampThirdClkCyc);

    LComprenCCkCChold=newControlSignal(masseyNet,'LComprenCCkCChold',datarate);
    LComprenCCkCCholdD1=newControlSignal(masseyNet,'LComprenCCkCCholdD1',datarate);
    pirelab.getUnitDelayEnabledComp(masseyNet,LComprenCCkCChold,LComprenCCkCCholdD1,resampThirdClkCyc);
    pirelab.getSwitchComp(masseyNet,[LComprenCCkCCholdD1,LComprenCCkCC],LComprenCCkCChold,resampThirdClkCyc);
    sampleCountD4=newDataSignal(masseyNet,'sampleCountD4',uint16,datarate);
    pirelab.getIntDelayComp(masseyNet,sampleCount,sampleCountD4,4);
    sampleCountD3=newDataSignal(masseyNet,'sampleCountD3',uint16,datarate);
    pirelab.getIntDelayComp(masseyNet,sampleCount,sampleCountD3,3);
    for ii=1:2*corr
        discrepPlusDz(ii)=newDataSignal(masseyNet,['discrepPlusDz_',num2str(ii)],ufix17,datarate);%#ok
        discrepPlusDzMod(ii)=newDataSignal(masseyNet,['discrepPlusDzMod_',num2str(ii)],uint16,datarate);%#ok
        discrepPlusDzLog(ii)=newDataSignal(masseyNet,['discrepPlusDzLog_',num2str(ii)],uint16,datarate);%#ok
        pirelab.getAddComp(masseyNet,[discrepD1sampled,DzD1(ii)],discrepPlusDz(ii));
        isDzD1NotZero(ii)=newControlSignal(masseyNet,['isDzD1NotZero_',num2str(ii)],datarate);%#ok
        lamdaStarEnb(ii)=newControlSignal(masseyNet,['lamdaStarEnb_',num2str(ii)],datarate);%#ok
        isLamdaD1Zero(ii)=newControlSignal(masseyNet,['isLamdaD1Zero_',num2str(ii)],datarate);%#ok
        pirelab.getCompareToValueComp(masseyNet,lambdaD1(ii),isLamdaD1Zero(ii),'==',0);
        pirelab.getCompareToValueComp(masseyNet,DzD1(ii),isDzD1NotZero(ii),'~=',0);
        k=ii-1;
        iiEnb(ii)=newControlSignal(masseyNet,['iiEnb_',num2str(ii)],datarate);%#ok<AGROW>

        isDzD1NotZeroSampled(ii)=newControlSignal(masseyNet,['isDzD1NotZeroSampled',num2str(ii)],datarate);%#ok
        isDzD1NotZeroSampledD1(ii)=newControlSignal(masseyNet,['isDzD1NotZeroSampledD1',num2str(ii)],datarate);%#ok
        pirelab.getUnitDelayComp(masseyNet,isDzD1NotZeroSampled(ii),isDzD1NotZeroSampledD1(ii));
        pirelab.getSwitchComp(masseyNet,[isDzD1NotZeroSampledD1(ii),isDzD1NotZero(ii)],isDzD1NotZeroSampled(ii),resampThirdClkCyc);
        pirelab.getBitwiseOpComp(masseyNet,[discrepEnbSampledD1,isDzD1NotZeroSampled(ii),iiEnb(ii)],lamdaStarEnb(ii),'AND');

        lambdaD1Temp(ii)=newDataSignal(masseyNet,['lamdaD1Temp_',num2str(ii)],uint16,datarate);%#ok
        lambdaD1TempD1(ii)=newDataSignal(masseyNet,['lamdaD1TempD1_',num2str(ii)],uint16,datarate);%#ok
        pirelab.getUnitDelayComp(masseyNet,lambdaD1Temp(ii),lambdaD1TempD1(ii));
        pirelab.getSwitchComp(masseyNet,[lambdaD1TempD1(ii),lambdaD1(ii)],lambdaD1Temp(ii),resampThirdClkCyc);

        discrepPlusDzTemp(ii)=newDataSignal(masseyNet,['discrepPlusDzTemp_',num2str(ii)],ufix17,datarate);%#ok

        discrepPlusDzTempD1(ii)=newDataSignal(masseyNet,['discrepPlusDzTempD1_',num2str(ii)],ufix17,datarate);%#ok
        pirelab.getUnitDelayComp(masseyNet,discrepPlusDzTemp(ii),discrepPlusDzTempD1(ii));
        pirelab.getSwitchComp(masseyNet,[discrepPlusDzTempD1(ii),discrepPlusDz(ii)],discrepPlusDzTemp(ii),resampThirdClkCyc);

        pirelab.getSwitchComp(masseyNet,[lambdaD1(ii),lambdaStarTemp(ii)],lambdaStar(ii),lamdaStarEnb(ii));
        DzTemp(ii)=newDataSignal(masseyNet,['DzTemp_',num2str(ii)],ufix17,datarate);%#ok
        DzMod(ii)=newDataSignal(masseyNet,['DzMod_',num2str(ii)],uint16,datarate);%#ok
        DzTemp1(ii)=newDataSignal(masseyNet,['DzTemp1_',num2str(ii)],uint16,datarate);%#ok
        DzTemp2(ii)=newDataSignal(masseyNet,['DzTemp2_',num2str(ii)],uint16,datarate);%#ok
        DzTemp3(ii)=newDataSignal(masseyNet,['DzTemp3_',num2str(ii)],uint16,datarate);%#ok
        DzTemp17Bit(ii)=newDataSignal(masseyNet,['DzTemp17Bit_',num2str(ii)],ufix17,datarate);%#ok

        pirelab.getAddComp(masseyNet,[lambdaD1(ii),discrepInv],DzTemp(ii));
        GFMod2(ii)=this.elabModulo(masseyNet,blockInfo,DzTemp17Bit(ii),DzMod(ii),datarate);%#ok
        GFMod2(ii).addComment(['GFModulo',num2str(ii)]);
        pirelab.getDTCComp(masseyNet,DzTemp(ii),DzTemp17Bit(ii));
        pirelab.instantiateNetwork(masseyNet,GFMod2(ii),DzTemp17Bit(ii),DzMod(ii),['GFMod2',num2str(ii)]);
        isLamdaD1NotZero(ii)=newControlSignal(masseyNet,['isLamdaD1NotZero',num2str(ii)],datarate);%#ok
        pirelab.getBitwiseOpComp(masseyNet,isLamdaD1Zero(ii),isLamdaD1NotZero(ii),'NOT');
        isLamdaD1NotZeroTemp(ii)=newControlSignal(masseyNet,['isLamdaD1NotZeroTemp',num2str(ii)],datarate);%#ok
        pirelab.getBitwiseOpComp(masseyNet,[isLamdaD1NotZero(ii),LStarEnb,resampThirdClkCyc],isLamdaD1NotZeroTemp(ii),'AND');
        pirelab.getSwitchComp(masseyNet,[zeroconst,DzMod(ii)],DzTemp1(ii),isLamdaD1NotZeroTemp(ii));
        isDzZero(ii)=newControlSignal(masseyNet,['isDzZero',num2str(ii)],datarate);%#ok
        isDzZeroAndLamda(ii)=newControlSignal(masseyNet,['isDzZeroAndLamda',num2str(ii)],datarate);%#ok
        pirelab.getCompareToValueComp(masseyNet,DzMod(ii),isDzZero(ii),'==',0);
        pirelab.getBitwiseOpComp(masseyNet,[isDzZero(ii),isLamdaD1NotZero(ii),LStarEnb,resampThirdClkCyc],isDzZeroAndLamda(ii),'AND');
        pirelab.getSwitchComp(masseyNet,[DzTemp1(ii),N_long],DzTemp2(ii),isDzZeroAndLamda(ii));

        pirelab.getSwitchComp(masseyNet,[DzD1(ii),DzTemp2(ii)],DzTemp3(ii),LStarEnb);

        isDiscrepNotZeroiiEnb(ii)=newControlSignal(masseyNet,['isDiscrepNotZeroiiEnb',num2str(ii)],datarate);%#ok
        pirelab.getBitwiseOpComp(masseyNet,[isDiscrepNotZeroTempHold,iiEnb(ii)],isDiscrepNotZeroiiEnb(ii),'AND');

        LComprenCCkCCiiEnb(ii)=newControlSignal(masseyNet,['LComprenCCkCCiiEnb',num2str(ii)],datarate);%#ok
        pirelab.getBitwiseOpComp(masseyNet,[LComprenCCkCChold,iiEnb(ii)],LComprenCCkCCiiEnb(ii),'AND');


        pirelab.getSwitchComp(masseyNet,[lambdaD1(ii),lambdaStar(ii)],lambdaTemp(ii),isDiscrepNotZeroiiEnb(ii));


        if ii==1
            if strcmp(blockInfo.FECFrameType,'Normal')
                pirelab.getUnitDelayEnabledResettableComp(masseyNet,lambdaTemp(ii),lambda(ii),LComprenCCkCCiiEnb(ii),syndromeDone,'',2^16-1,'');
            else
                pirelab.getUnitDelayEnabledResettableComp(masseyNet,lambdaTemp(ii),lambda(ii),LComprenCCkCCiiEnb(ii),syndromeDone,'',2^14-1,'');
            end
            pirelab.getUnitDelayEnabledResettableComp(masseyNet,zeroconst,Dz(ii),LComprenCCkCC,syndromeDone,'',0,'');
        else
            pirelab.getUnitDelayEnabledResettableComp(masseyNet,lambdaTemp(ii),lambda(ii),LComprenCCkCCiiEnb(ii),syndromeDone,'',0,'');
            pirelab.getUnitDelayEnabledResettableComp(masseyNet,DzTemp3(ii-1),Dz(ii),LComprenCCkCC,syndromeDone,'',0,'');
        end
        pirelab.getDTCComp(masseyNet,lambdaD2(ii),errlocpoly(ii));


        pirelab.getCompareToValueComp(masseyNet,sampleCountD4,iiEnb(ii),'==',k);
        LUTlambdaStarTemptemp(ii)=newDataSignal(masseyNet,['LUTlambdaStarTemptemp',num2str(ii)],uint16,datarate);%#ok<AGROW>
        pirelab.getUnitDelayEnabledResettableComp(masseyNet,LUTlambdaStarTemp,LUTlambdaStarTemptemp(ii),iiEnb(ii),syndromeDone);
        pirelab.getSwitchComp(masseyNet,[LUTlambdaStarTemptemp(ii),LUTlambdaStarTemp],lambdaStarTemp(ii),iiEnb(ii));
    end

    pirelab.getMultiPortSwitchComp(masseyNet,[sampleCountD3,[lambdaD1Temp,zeroconst]],LUTInpLamda,1,1,'floor','Wrap','lambdaMux');


    GFTabValNet_lambda=this.elabGfTabVal(masseyNet,blockInfo,datarate);
    GFTabValNet_lambda.addComment('GFTabValNet for lamda ');
    LUTInpLamda17Bit=newDataSignal(masseyNet,'LUTInpLamda17Bit',ufix17,datarate);

    LUTInpLamdaDelay=newDataSignal(masseyNet,'LUTInpLamdaDelay',uint16,datarate);
    pirelab.getUnitDelayComp(masseyNet,LUTInpLamda,LUTInpLamdaDelay);
    pirelab.getDTCComp(masseyNet,LUTInpLamdaDelay,LUTInpLamda17Bit);
    pirelab.instantiateNetwork(masseyNet,GFTabValNet_lambda,LUTInpLamda17Bit,[LUTInpLamdaLog,LUTInpLamdaMod],'GFTabValNet_lambda');

    pirelab.getMultiPortSwitchComp(masseyNet,[sampleCountD3,[discrepPlusDzTemp,zeroconst]],LUTInpDiscrepDz,1,1,'floor','Wrap','lambdaMux1');
    LUTInpDiscrepDzDelay=newDataSignal(masseyNet,'LUTInpDiscrepDzDelay',ufix17,datarate);
    pirelab.getUnitDelayComp(masseyNet,LUTInpDiscrepDz,LUTInpDiscrepDzDelay);

    GFTabValNet_discrepPlusDz=this.elabGfTabVal(masseyNet,blockInfo,datarate);
    GFTabValNet_discrepPlusDz.addComment('GFTabValNet for discrepPlusDz');
    pirelab.instantiateNetwork(masseyNet,GFTabValNet_discrepPlusDz,LUTInpDiscrepDzDelay,[LUTInpDiscrepDzLog,LUTInpDiscrepDzMod],'GFTabValNet_discrepPlusDz');


    GFAddXORNet_lambdaDz=this.elabGfAddXOR(masseyNet,blockInfo,datarate);
    GFAddXORNet_lambdaDz.addComment('GFTable1ValforlamdaDz');
    pirelab.instantiateNetwork(masseyNet,GFAddXORNet_lambdaDz,[LUTInpLamdaModD1,LUTInpDiscrepDzModD1,LUTInpLamdaLog,LUTInpDiscrepDzLog],LUTlambdaStarTemp,'GFTable1ValforlamdaDz');
    errlocpolylenD1=newDataSignal(masseyNet,'errlocpolylenD1',pir_ufixpt_t(8,0),datarate);
    errlocpolylenDT=newDataSignal(masseyNet,'errlocpolylenDT',pir_ufixpt_t(8,0),datarate);
    pirelab.getUnitDelayComp(masseyNet,errlocpolylenDT,errlocpolylenD1);
    pirelab.getAddComp(masseyNet,[isDiscrepNotZeroTemp,errlocpolylenD1],errlocpolylenDT);
    pirelab.getDTCComp(masseyNet,errlocpolylenDT,errlocpolylen);


    nCCMax=newControlSignal(masseyNet,'nCCMax',datarate);
    pirelab.getRelOpComp(masseyNet,[nCC,doubleCorr],nCCMax,'==');
    fsmdonePrior=newControlSignal(masseyNet,'fsmdonePrior',datarate);
    pirelab.getBitwiseOpComp(masseyNet,[nCCMax,nCCCounterEnb],fsmdonePrior,'AND');
    pirelab.getUnitDelayComp(masseyNet,fsmdonePrior,fsmdone);
    pirelab.getWireComp(masseyNet,LStar,LOutput);



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