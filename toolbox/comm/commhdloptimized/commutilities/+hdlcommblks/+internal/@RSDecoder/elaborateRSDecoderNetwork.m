function elaborateRSDecoderNetwork(this,topNet,blockInfo)%#ok<INUSL>

















    insignals=topNet.PirInputSignals;

    in=insignals(1);
    startInput=insignals(2);
    endInput=insignals(3);
    dvIn=insignals(4);


    outsignals=topNet.PirOutputSignals;

    output=outsignals(1);
    startOut=outsignals(2);
    endOut=outsignals(3);
    dvOut=outsignals(4);
    errOut=outsignals(5);
    if length(outsignals)==6
        numErrOut=outsignals(6);
        hasErrPort=true;
    else
        numErrOut=[];
        hasErrPort=false;
    end


    rate=in.SimulinkRate;
    output.SimulinkRate=rate;
    startOut.SimulinkRate=rate;
    endOut.SimulinkRate=rate;
    dvOut.SimulinkRate=rate;



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
    count2Type=pir_ufixpt_t(1+ceil(log2(2*corr)),0);

    bmLength=2*corr+10;
    convLength=(corr*2)*(corr*2+1)/2;
    chienLength=2.^wordSize;
    delayTotal=bmLength+convLength+chienLength;
    delayWordSize=ceil(log2(delayTotal));
    delayType=pir_ufixpt_t(delayWordSize,0);
    addrType=pir_ufixpt_t(2+ceil(log2(codewordLength)),0);
    addrCountType=pir_ufixpt_t(ceil(log2(codewordLength)),0);
    addrBankType=pir_ufixpt_t(2,0);
    if hasErrPort
        numerrType=pir_ufixpt_t(8,0);
    end


    controlType=pir_ufixpt_t(1,0);


    startIn=topNet.addSignal(controlType,'startin_valid');
    pirelab.getBitwiseOpComp(topNet,[startInput,dvIn],startIn,'AND');
    endIn_valid=topNet.addSignal(controlType,'endin_valid');
    pirelab.getBitwiseOpComp(topNet,[endInput,dvIn],endIn_valid,'AND');


    notendin=topNet.addSignal(controlType,'notendin');
    inpacket=topNet.addSignal(controlType,'inpacket');
    inpacketnext=topNet.addSignal(controlType,'inpacketnext');
    notdonepacket=topNet.addSignal(controlType,'notdonepacket');
    endIn=topNet.addSignal(controlType,'endin_packet');

    pirelab.getBitwiseOpComp(topNet,endIn,notendin,'NOT');
    pirelab.getBitwiseOpComp(topNet,[notendin,inpacket],notdonepacket,'AND');
    pirelab.getBitwiseOpComp(topNet,[startIn,notdonepacket],inpacketnext,'OR');
    pirelab.getUnitDelayComp(topNet,inpacketnext,inpacket,'inpacketreg',0.0);




    pirelab.getBitwiseOpComp(topNet,[endIn_valid,inpacket],endIn,'AND');


    datainreg=newDataSignal(topNet,'datainreg',inType,rate);
    dvindelayed=newControlSignal(topNet,'dvindelayed',rate);
    startindelayed=newControlSignal(topNet,'startindelayed',rate);
    endindelayed=newControlSignal(topNet,'endindelayed',rate);
    endindelay2=newControlSignal(topNet,'endindelay2',rate);
    endindelay3=newControlSignal(topNet,'endindelay3',rate);

    pirelab.getUnitDelayComp(topNet,in,datainreg,'datainputdelay',0.0);
    pirelab.getUnitDelayComp(topNet,startIn,startindelayed,'startdelay',0.0);
    pirelab.getUnitDelayComp(topNet,endIn,endindelayed,'enddelay',0.0);
    pirelab.getUnitDelayComp(topNet,endindelayed,endindelay2,'enddelay2',0.0);
    pirelab.getUnitDelayComp(topNet,endindelay2,endindelay3,'enddelay3',0.0);
    pirelab.getUnitDelayComp(topNet,dvIn,dvindelayed,'dvdelay',0.0);

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





    for ii=1:(2*corr)
        xorfeedback(ii)=newDataSignal(topNet,'xorfeedback',inType,rate);%#ok
        syndromereg(ii)=newDataSignal(topNet,'syndromereg',inType,rate);%#ok
        finalsyndromereg(ii)=newDataSignal(topNet,'finalsyndromereg',inType,rate);%#ok
        syndromegate(ii)=newDataSignal(topNet,'syndromegate',inType,rate);%#ok
        powertableout(ii)=newDataSignal(topNet,'powertableout',inType,rate);%#ok

        syndromezero(ii)=newControlSignal(topNet,sprintf('syndrome%dzero',ii),rate);%#ok

        pirelab.getUnitDelayEnabledComp(topNet,xorfeedback(ii),syndromereg(ii),dvindelayed,'synreg',0.0,'',false);
        pirelab.getUnitDelayEnabledComp(topNet,syndromereg(ii),finalsyndromereg(ii),endindelay2,'synreg',0.0,'',false);
        pirelab.getSwitchComp(topNet,[syndromereg(ii),zeroconst],syndromegate(ii),startindelayed,'holdmux');

        pirelab.getCompareToValueComp(topNet,syndromereg(ii),syndromezero(ii),'==',0,'synzerocomp');

        if B==0&&ii==1
            powertableout(ii)=syndromegate(ii);%#ok  % forward
        else
            pirelab.getDirectLookupComp(topNet,syndromegate(ii),powertableout(ii),powerTable(ii+B,:),'gfpowertable');
        end
        pirelab.getBitwiseOpComp(topNet,[datainreg,powertableout(ii)],xorfeedback(ii),'XOR');
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

    pirelab.getUnitDelayEnabledComp(topNet,notallsynzero,haserrorsreg,endindelay2,'synhaserrreg',0.0,'',false);





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

    ram_insigs=[datainreg,ramwraddr,ramwren,ramrdaddr];
    pirelab.getSimpleDualPortRamComp(topNet,ram_insigs,ramrddata,'RSDataRAM');

    pirelab.getBitConcatComp(topNet,[ramwrbank,ramwrcount],ramwraddr);
    pirelab.getBitConcatComp(topNet,[ramrdbank,ramrdcount],ramrdaddr);

    pirelab.getDTCComp(topNet,dvindelayed,ramwren);
    pirelab.getDTCComp(topNet,endindelay2,ramwrbanken);


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

    pirelab.getCounterComp(topNet,[prestartcurbank,prevalidout],ramrdcount,...
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
    0.0,...
    1.0,...
    3,...
    false,...
    false,...
    true,...
    false,...
    'wrbankcounter');

    pirelab.getCounterComp(topNet,p2endout,ramrdbank,...
    'Count limited',...
    0.0,...
    1.0,...
    3,...
    false,...
    false,...
    true,...
    false,...
    'rdbankcounter');


    wrbankdecode0=newControlSignal(topNet,'wrbankdecode0',rate);
    wrbankdecode1=newControlSignal(topNet,'wrbankdecode1',rate);
    wrbankdecode2=newControlSignal(topNet,'wrbankdecode2',rate);
    wrbankdecode3=newControlSignal(topNet,'wrbankdecode3',rate);

    rdbankdecode0=newControlSignal(topNet,'rdbankdecode0',rate);
    rdbankdecode1=newControlSignal(topNet,'rdbankdecode1',rate);
    rdbankdecode2=newControlSignal(topNet,'rdbankdecode2',rate);
    rdbankdecode3=newControlSignal(topNet,'rdbankdecode3',rate);

    bankvalid0=newControlSignal(topNet,'bankvalid0',rate);
    bankvalid1=newControlSignal(topNet,'bankvalid1',rate);
    bankvalid2=newControlSignal(topNet,'bankvalid2',rate);
    bankvalid3=newControlSignal(topNet,'bankvalid3',rate);

    setvalid0=newControlSignal(topNet,'setvalid0',rate);
    setvalid1=newControlSignal(topNet,'setvalid1',rate);
    setvalid2=newControlSignal(topNet,'setvalid2',rate);
    setvalid3=newControlSignal(topNet,'setvalid3',rate);

    endcompare=newControlSignal(topNet,'encompare',rate);
    rdbankvalid=newControlSignal(topNet,'rdbankvalid',rate);

    endpacketbank0=newControlSignal(topNet,'endpacketbank0',rate);
    endpacketbank1=newControlSignal(topNet,'endpacketbank1',rate);
    endpacketbank2=newControlSignal(topNet,'endpacketbank2',rate);
    endpacketbank3=newControlSignal(topNet,'endpacketbank3',rate);

    holdvalid0=newControlSignal(topNet,'holdvalid0',rate);
    holdvalid1=newControlSignal(topNet,'holdvalid1',rate);
    holdvalid2=newControlSignal(topNet,'holdvalid2',rate);
    holdvalid3=newControlSignal(topNet,'holdvalid3',rate);

    endreadbank0=newControlSignal(topNet,'endreadbank0',rate);
    endreadbank1=newControlSignal(topNet,'endreadbank1',rate);
    endreadbank2=newControlSignal(topNet,'endreadbank2',rate);
    endreadbank3=newControlSignal(topNet,'endreadbank3',rate);


    inputlength=newDataSignal(topNet,'inputlength',addrCountType,rate);
    parityconst=newDataSignal(topNet,'paritylength',addrCountType,rate);
    parityconstplusone=newDataSignal(topNet,'paritylengthplusone',addrCountType,rate);


    packetlength0=newDataSignal(topNet,'packetlength0',addrCountType,rate);
    packetlength1=newDataSignal(topNet,'packetlength1',addrCountType,rate);
    packetlength2=newDataSignal(topNet,'packetlength2',addrCountType,rate);
    packetlength3=newDataSignal(topNet,'packetlength3',addrCountType,rate);


    currentlength=newDataSignal(topNet,'currentlength',addrCountType,rate);
    currentlensub=newDataSignal(topNet,'currentlensub',addrCountType,rate);
    oneaddrcount=newDataSignal(topNet,'oneaddrcount',addrCountType,rate);





    pirelab.getCompareToValueComp(topNet,ramwrbank,wrbankdecode0,'==',0,'wrbankdecoder0');
    pirelab.getCompareToValueComp(topNet,ramwrbank,wrbankdecode1,'==',1,'wrbankdecoder1');
    pirelab.getCompareToValueComp(topNet,ramwrbank,wrbankdecode2,'==',2,'wrbankdecoder2');
    pirelab.getCompareToValueComp(topNet,ramwrbank,wrbankdecode3,'==',3,'wrbankdecoder3');

    pirelab.getCompareToValueComp(topNet,ramrdbank,rdbankdecode0,'==',0,'rdbankdecoder0');
    pirelab.getCompareToValueComp(topNet,ramrdbank,rdbankdecode1,'==',1,'rdbankdecoder1');
    pirelab.getCompareToValueComp(topNet,ramrdbank,rdbankdecode2,'==',2,'rdbankdecoder2');
    pirelab.getCompareToValueComp(topNet,ramrdbank,rdbankdecode3,'==',3,'rdbankdecoder3');



    pirelab.getUnitDelayComp(topNet,setvalid0,bankvalid0,'bankvalid0reg',0.0);
    pirelab.getUnitDelayComp(topNet,setvalid1,bankvalid1,'bankvalid1reg',0.0);
    pirelab.getUnitDelayComp(topNet,setvalid2,bankvalid2,'bankvalid2reg',0.0);
    pirelab.getUnitDelayComp(topNet,setvalid3,bankvalid3,'bankvalid3reg',0.0);







    pirelab.getBitwiseOpComp(topNet,[endindelayed,wrbankdecode0],endpacketbank0,'AND');
    pirelab.getBitwiseOpComp(topNet,[endindelayed,wrbankdecode1],endpacketbank1,'AND');
    pirelab.getBitwiseOpComp(topNet,[endindelayed,wrbankdecode2],endpacketbank2,'AND');
    pirelab.getBitwiseOpComp(topNet,[endindelayed,wrbankdecode3],endpacketbank3,'AND');

    pirelab.getBitwiseOpComp(topNet,[holdvalid0,endpacketbank0],setvalid0,'OR');
    pirelab.getBitwiseOpComp(topNet,[holdvalid1,endpacketbank1],setvalid1,'OR');
    pirelab.getBitwiseOpComp(topNet,[holdvalid2,endpacketbank2],setvalid2,'OR');
    pirelab.getBitwiseOpComp(topNet,[holdvalid3,endpacketbank3],setvalid3,'OR');

    pirelab.getBitwiseOpComp(topNet,[bankvalid0,endreadbank0],holdvalid0,'AND');
    pirelab.getBitwiseOpComp(topNet,[bankvalid1,endreadbank1],holdvalid1,'AND');
    pirelab.getBitwiseOpComp(topNet,[bankvalid2,endreadbank2],holdvalid2,'AND');
    pirelab.getBitwiseOpComp(topNet,[bankvalid3,endreadbank3],holdvalid3,'AND');

    pirelab.getBitwiseOpComp(topNet,[rdbankdecode0,preendout,prevalidout],endreadbank0,'NAND');
    pirelab.getBitwiseOpComp(topNet,[rdbankdecode1,preendout,prevalidout],endreadbank1,'NAND');
    pirelab.getBitwiseOpComp(topNet,[rdbankdecode2,preendout,prevalidout],endreadbank2,'NAND');
    pirelab.getBitwiseOpComp(topNet,[rdbankdecode3,preendout,prevalidout],endreadbank3,'NAND');

    pirelab.getConstComp(topNet,parityconst,parityLength);
    pirelab.getConstComp(topNet,parityconstplusone,parityLength+1);
    pirelab.getSubComp(topNet,[ramwrcount,parityconst],inputlength);

    pirelab.getUnitDelayEnabledComp(topNet,inputlength,packetlength0,endpacketbank0,'packetlen0reg',0.0,'',false);
    pirelab.getUnitDelayEnabledComp(topNet,inputlength,packetlength1,endpacketbank1,'packetlen1reg',0.0,'',false);
    pirelab.getUnitDelayEnabledComp(topNet,inputlength,packetlength2,endpacketbank2,'packetlen2reg',0.0,'',false);
    pirelab.getUnitDelayEnabledComp(topNet,inputlength,packetlength3,endpacketbank3,'packetlen3reg',0.0,'',false);





    pirelab.getUnitDelayEnabledComp(topNet,ramwrbank,masseybank,endindelayed,'masseybankreg',0.0,'',false);
    pirelab.getUnitDelayEnabledComp(topNet,masseybank,convbank,fsmdone,'convbankreg',0.0,'',false);
    pirelab.getUnitDelayEnabledComp(topNet,convbank,prerunbank,convdone,'prerunbankreg',0.0,'',false);
    pirelab.getUnitDelayEnabledComp(topNet,prerunbank,chienbank,chienprerundone,'chienbankreg',0.0,'',false);


    pirelab.getMultiPortSwitchComp(topNet,[ramrdbank,packetlength0,packetlength1,packetlength2,packetlength3],currentlength,...
    1,1,'floor','Wrap','currentlengthmux');

    pirelab.getMultiPortSwitchComp(topNet,[ramrdbank,bankvalid0,bankvalid1,bankvalid2,bankvalid3],rdbankvalid,...
    1,1,'floor','Wrap','bankvalidmux');

    pirelab.getConstComp(topNet,oneaddrcount,1,'oneaddrconst');
    pirelab.getSubComp(topNet,[currentlength,oneaddrcount],currentlensub,'Floor','Wrap');

    pirelab.getRelOpComp(topNet,[ramrdcount,currentlength],endcompare,'==');
    pirelab.getBitwiseOpComp(topNet,[endcompare,rdbankvalid],preendout,'AND');

    pirelab.getBitwiseOpComp(topNet,[ramrddata,correction],predataout,'XOR');


    syndromeholdmux=newDataSignal(topNet,'syndromeholdmux',inType,rate);
    synlog=newDataSignal(topNet,'synlog',inType,rate);
    synzero=newControlSignal(topNet,'synzero',rate);

    dvalue=newDataSignal(topNet,'dvalue',inType,rate);
    dvaluelog=newDataSignal(topNet,'dvaluelog',inType,rate);



    dzero=newControlSignal(topNet,'dzero',rate);
    dnotzero=newControlSignal(topNet,'dnotzero',rate);
    dupdate=newControlSignal(topNet,'dupdate',rate);

    dm=newDataSignal(topNet,'dm',inType,rate);
    dmlog=newDataSignal(topNet,'dmlog',inType,rate);
    dmmux=newDataSignal(topNet,'dmmux',inType,rate);



    dminvlog=newDataSignal(topNet,'dminvlog',inType,rate);

    dmzero=newControlSignal(topNet,'dmzero',rate);
    dmone=newControlSignal(topNet,'dmone',rate);

    correctionadd=newDataSignal(topNet,'correctionadd',carryType,rate);
    correctionslice=newDataSignal(topNet,'correctionslice',inType,rate);
    correctionwrap=newControlSignal(topNet,'correctionwrap',rate);
    correctionreduced=newDataSignal(topNet,'correctionreduced',inType,rate);
    correctionlog=newDataSignal(topNet,'correctionlog',inType,rate);

    holdregen=newControlSignal(topNet,'holdregen',rate);

    fsmrun=newControlSignal(topNet,'fsmrun',rate);
    fsmrunnext=newControlSignal(topNet,'fsmrunnext',rate);
    fsmrunearly=newControlSignal(topNet,'fsmrunearly',rate);
    fsmcontinue=newControlSignal(topNet,'fsmcontinue',rate);
    fsmnotmax=newControlSignal(topNet,'fsmnotmax',rate);
    fsmmax=newControlSignal(topNet,'fsmmax',rate);

    fsmcount=newDataSignal(topNet,'fsmcount',countType,rate);
    fsmonecount=newDataSignal(topNet,'fsmonecount',countType,rate);
    comparelength=newControlSignal(topNet,'comparelength',rate);
    updatelength=newControlSignal(topNet,'updatelength',rate);

    cpolyen=newControlSignal(topNet,'cpolyen',rate);
    currentshiften=newControlSignal(topNet,'currentshiften',rate);

    lregen=newControlSignal(topNet,'lregen',rate);
    lcount=newDataSignal(topNet,'lcount',countType,rate);
    nextlcount=newDataSignal(topNet,'nextlcount',countType,rate);
    lcountsub=newDataSignal(topNet,'lcountsub',countType,rate);
    twolcount=newDataSignal(topNet,'twolcount',count2Type,rate);
    lcountextend=newDataSignal(topNet,'lcountextend',count2Type,rate);

    errlocpolylen=newDataSignal(topNet,'errlocpolylen',countType,rate);
    nroots=newDataSignal(topNet,'nroots',countType,rate);
    nrootsreg=newDataSignal(topNet,'nrootsreg',countType,rate);
    nrootsstart=newDataSignal(topNet,'nrootsstart',countType,rate);
    errlocpolysub=newDataSignal(topNet,'errlocpolysub',countType,rate);
    anyerr=newControlSignal(topNet,'anyerr',rate);
    comparepolylen=newControlSignal(topNet,'comparepolylen',rate);

    currentshift=newDataSignal(topNet,'currentshift',countType,rate);
    nextshift=newDataSignal(topNet,'nextshift',countType,rate);
    shiftadd=newDataSignal(topNet,'shiftadd',countType,rate);

    moduloconst=newDataSignal(topNet,'moduloconst',inType,rate);
    pirelab.getConstComp(topNet,moduloconst,2.^wordSize-1,'modconst');

    oneconst=newDataSignal(topNet,'oneconst',inType,rate);
    pirelab.getConstComp(topNet,oneconst,1,'oneconst');

    onebit=newControlSignal(topNet,'onebit',rate);
    pirelab.getConstComp(topNet,onebit,1,'onebitconst');
    zerobit=newControlSignal(topNet,'zerobit',rate);
    pirelab.getConstComp(topNet,zerobit,0,'zerobitconst');

    countzero=newDataSignal(topNet,'countzero',countType,rate);
    pirelab.getConstComp(topNet,countzero,0,'countzero');

    countone=newDataSignal(topNet,'countone',countType,rate);
    pirelab.getConstComp(topNet,countone,1,'countone');







    for ii=1:2*corr
        nextcpoly(ii)=newDataSignal(topNet,sprintf('next%dcpoly',ii),inType,rate);%#ok
        cpoly(ii)=newDataSignal(topNet,sprintf('c%dpoly',ii),inType,rate);%#ok
        cpolylog(ii)=newDataSignal(topNet,'cpolylog',inType,rate);%#ok
        cpolyxor(ii)=newDataSignal(topNet,sprintf('cpoly%dxor',ii),inType,rate);%#ok

        errlocpoly(ii)=newDataSignal(topNet,sprintf('errloc%dpoly',ii),inType,rate);%#ok

        nextppoly(ii)=newDataSignal(topNet,sprintf('next%dppoly',ii),inType,rate);%#ok
        ppoly(ii)=newDataSignal(topNet,sprintf('p%dpoly',ii),inType,rate);%#ok

        ppolyshift(ii)=newDataSignal(topNet,sprintf('p%dpolyshift',ii),inType,rate);%#ok

        ppolyzero(ii)=newControlSignal(topNet,'ppolyzero',rate);%#ok
        ppolylogwrap(ii)=newControlSignal(topNet,'ppolylogwrap',rate);%#ok

        ppolylog(ii)=newDataSignal(topNet,'ppolylog',inType,rate);%#ok
        ppolylogadd(ii)=newDataSignal(topNet,'ppolylogadd',carryType,rate);%#ok
        ppolylogslice(ii)=newDataSignal(topNet,'ppolylogslice',inType,rate);%#ok
        ppolyreduced(ii)=newDataSignal(topNet,'ppolyreduced',inType,rate);%#ok
        ppolymodresult(ii)=newDataSignal(topNet,'ppolymodresult',inType,rate);%#ok
        ppolyalogout(ii)=newDataSignal(topNet,'ppolyalogout',inType,rate);%#ok
        ppolymulresult(ii)=newDataSignal(topNet,'ppolymulresult',inType,rate);%#ok

        holdin(ii)=newDataSignal(topNet,'holdin',inType,rate);%#ok
        syndromeholdreg(ii)=newDataSignal(topNet,'syndromeholdreg',inType,rate);%#ok
        syndromeshiftreg(ii)=newDataSignal(topNet,'syndromeshiftreg',inType,rate);%#ok
        syndromezeroshiftnext(ii)=newControlSignal(topNet,'syndromezeroshiftnext',rate);%#ok
        syndromezeroshiftreg(ii)=newControlSignal(topNet,'syndromezeroshiftreg',rate);%#ok

        logadd(ii)=newDataSignal(topNet,'logadd',carryType,rate);%#ok
        logslice(ii)=newDataSignal(topNet,'logslice',inType,rate);%#ok
        logaddreduced(ii)=newDataSignal(topNet,'logaddreduced',inType,rate);%#ok
        modresult(ii)=newDataSignal(topNet,'modresult',inType,rate);%#ok
        alogout(ii)=newDataSignal(topNet,'alogout',inType,rate);%#ok
        mulresult(ii)=newDataSignal(topNet,'mulresult',inType,rate);%#ok

        xortree(ii)=newDataSignal(topNet,'xortree',inType,rate);%#ok


        lreg(ii)=newControlSignal(topNet,'lreg',rate);%#ok
        lgreatereq(ii)=newControlSignal(topNet,'lgreatereq',rate);%#ok
        lregmux(ii)=newControlSignal(topNet,'lregmux',rate);%#ok
        lreginv(ii)=newControlSignal(topNet,'lreginv',rate);%#ok

        logwrap(ii)=newControlSignal(topNet,'logwrap',rate);%#ok
        cpolyzero(ii)=newControlSignal(topNet,'cpolyzero',rate);%#ok
        mulzero(ii)=newControlSignal(topNet,'mulzero',rate);%#ok
    end



    shiftvector=[fliplr(ppoly),repmat(zeroconst,1,2*corr)];


    for ii=1:2*corr

        if ii==2*corr
            pirelab.getSwitchComp(topNet,[zeroconst,finalsyndromereg(ii)],holdin(ii),endindelay3,'holdmux');
        else
            pirelab.getSwitchComp(topNet,[syndromeholdreg(ii+1),finalsyndromereg(ii)],holdin(ii),endindelay3,'holdmux');
        end
        pirelab.getUnitDelayEnabledComp(topNet,holdin(ii),syndromeholdreg(ii),holdregen,...
        'synholdregproc',0.0,'',false);
        if ii==1

            pirelab.getUnitDelayEnabledComp(topNet,synlog,syndromeshiftreg(ii),holdregen,...
            'synshiftreg',0.0,'',false);

            pirelab.getCompareToValueComp(topNet,syndromeholdmux,synzero,'==',0,'synlogcomp');


            pirelab.getBitwiseOpComp(topNet,[fsmrunnext,fsmrun],fsmrunearly,'OR');

            pirelab.getBitwiseOpComp(topNet,[synzero,fsmrunearly],syndromezeroshiftnext(ii),'AND');

            pirelab.getUnitDelayEnabledComp(topNet,syndromezeroshiftnext(ii),syndromezeroshiftreg(ii),holdregen,...
            'synzeroshiftreg',0.0,'',false);
            pirelab.getUnitDelayEnabledComp(topNet,onebit,lreg(ii),lregen,...
            'lshiftreg',0.0,'',false);

        else
            pirelab.getUnitDelayEnabledComp(topNet,syndromeshiftreg(ii-1),syndromeshiftreg(ii),holdregen,...
            'synshiftreg',0.0,'',false);


            pirelab.getBitwiseOpComp(topNet,[syndromezeroshiftreg(ii-1),fsmrun],syndromezeroshiftnext(ii),'AND');
            pirelab.getUnitDelayEnabledComp(topNet,syndromezeroshiftnext(ii),syndromezeroshiftreg(ii),holdregen,...
            'synzeroshiftreg',0.0,'',false);
            pirelab.getCompareToValueComp(topNet,nextlcount,lgreatereq(ii),'>=',ii-1);
            pirelab.getSwitchComp(topNet,[lgreatereq(ii),zerobit],lregmux(ii),endindelay3,'lregmux');
            pirelab.getUnitDelayEnabledComp(topNet,lregmux(ii),lreg(ii),lregen,...
            'lshiftreg',0.0,'',false);

        end


        pirelab.getDirectLookupComp(topNet,cpoly(ii),cpolylog(ii),logTable,'cpolylogtable');
        pirelab.getAddComp(topNet,[cpolylog(ii),syndromeshiftreg(ii)],logadd(ii),'Floor','Wrap');
        pirelab.getCompareToValueComp(topNet,logadd(ii),logwrap(ii),'>',2.^wordSize-1,'modcompare');
        pirelab.getSubComp(topNet,[logadd(ii),moduloconst],logaddreduced(ii),'Floor','Wrap');
        pirelab.getBitSliceComp(topNet,logadd(ii),logslice(ii),wordSize-1,0);
        pirelab.getSwitchComp(topNet,[logslice(ii),logaddreduced(ii)],modresult(ii),logwrap(ii),'modmux');
        pirelab.getDirectLookupComp(topNet,modresult(ii),alogout(ii),alogTable,'alogtable');
        pirelab.getCompareToValueComp(topNet,cpoly(ii),cpolyzero(ii),'==',0,'cpolycompare');

        pirelab.getBitwiseOpComp(topNet,lreg(ii),lreginv(ii),'NOT');
        pirelab.getBitwiseOpComp(topNet,[lreginv(ii),syndromezeroshiftreg(ii),cpolyzero(ii)],mulzero(ii),'OR');
        pirelab.getSwitchComp(topNet,[alogout(ii),zeroconst],mulresult(ii),mulzero(ii),'mulzeromux');

        if ii==2*corr
            pirelab.getBitwiseOpComp(topNet,[xortree(ii-1),mulresult(ii)],dvalue,'XOR');
        elseif ii==1

        elseif ii==2
            pirelab.getBitwiseOpComp(topNet,[mulresult(ii-1),mulresult(ii)],xortree(ii),'XOR');
        else
            pirelab.getBitwiseOpComp(topNet,[xortree(ii-1),mulresult(ii)],xortree(ii),'XOR');
        end



        pirelab.getUnitDelayEnabledComp(topNet,nextcpoly(ii),cpoly(ii),cpolyen,...
        'cpolyreg',0.0,'',false);

        pirelab.getUnitDelayEnabledComp(topNet,nextppoly(ii),ppoly(ii),lregen,...
        'ppolyreg',0.0,'',false);

        pirelab.getUnitDelayEnabledComp(topNet,cpoly(ii),errlocpoly(ii),fsmdone,...
        'errlocpolyreg',0.0,'',false);

        if ii==1
            pirelab.getSwitchComp(topNet,[cpolyxor(ii),oneconst],nextcpoly(ii),endindelay3,'cpolymux');
            pirelab.getSwitchComp(topNet,[cpoly(ii),oneconst],nextppoly(ii),endindelay3,'ppolymux');
        elseif ii==2
            pirelab.getSwitchComp(topNet,[cpolyxor(ii),zeroconst],nextcpoly(ii),endindelay3,'cpolymux');
            pirelab.getSwitchComp(topNet,[cpoly(ii),zeroconst],nextppoly(ii),endindelay3,'ppolymux');
        else
            pirelab.getSwitchComp(topNet,[cpolyxor(ii),zeroconst],nextcpoly(ii),endindelay3,'cpolymux');
            pirelab.getSwitchComp(topNet,[cpoly(ii),zeroconst],nextppoly(ii),endindelay3,'ppolymux');
        end






        startIndex=2*corr-ii+2;
        pirelab.getMultiPortSwitchComp(topNet,[currentshift,shiftvector(startIndex:startIndex+2*corr-1)],...
        ppolyshift(ii),...
        1,1,'floor','Wrap','ppolyshiftmux');
        insig=ppolyshift(ii);
        pirelab.getDirectLookupComp(topNet,insig,ppolylog(ii),logTable,'ppolylogtable');
        pirelab.getAddComp(topNet,[ppolylog(ii),correctionlog],ppolylogadd(ii),'Floor','Wrap');
        pirelab.getCompareToValueComp(topNet,ppolylogadd(ii),ppolylogwrap(ii),'>',2.^wordSize-1,'ppolymodcompare');
        pirelab.getSubComp(topNet,[ppolylogadd(ii),moduloconst],ppolyreduced(ii),'Floor','Wrap');
        pirelab.getBitSliceComp(topNet,ppolylogadd(ii),ppolylogslice(ii),wordSize-1,0);
        pirelab.getSwitchComp(topNet,[ppolylogslice(ii),ppolyreduced(ii)],ppolymodresult(ii),ppolylogwrap(ii),'ppolymodmux');
        pirelab.getDirectLookupComp(topNet,ppolymodresult(ii),ppolyalogout(ii),alogTable,'ppolyalogtable');
        pirelab.getCompareToValueComp(topNet,insig,ppolyzero(ii),'==',0,'ppolycompare');
        pirelab.getSwitchComp(topNet,[ppolyalogout(ii),zeroconst],ppolymulresult(ii),ppolyzero(ii),'ppolymulzeromux');
        pirelab.getBitwiseOpComp(topNet,[cpoly(ii),ppolymulresult(ii)],cpolyxor(ii),'XOR');

    end

    pirelab.getUnitDelayEnabledComp(topNet,lcount,errlocpolylen,...
    fsmdone,'errlocpolylenreg',0.0,'',false);

    pirelab.getBitwiseOpComp(topNet,[endindelay3,fsmrun],holdregen,'OR');

    pirelab.getBitwiseOpComp(topNet,[fsmrun,dnotzero],dupdate,'AND');

    pirelab.getUnitDelayEnabledComp(topNet,dmmux,dm,lregen,'dmreg',0.0,'',false);
    pirelab.getSwitchComp(topNet,[dvalue,oneconst],dmmux,endindelay3,'dmmuxcomp');


    pirelab.getRelOpComp(topNet,[twolcount,fsmonecount],comparelength,'<');
    pirelab.getBitwiseOpComp(topNet,[dupdate,comparelength],updatelength,'AND');

    pirelab.getBitwiseOpComp(topNet,[endindelay3,updatelength],lregen,'OR');
    pirelab.getBitwiseOpComp(topNet,[endindelay3,dupdate],cpolyen,'OR');

    pirelab.getUnitDelayEnabledComp(topNet,nextlcount,lcount,lregen,...
    'lcountreg',0.0,'',false);

    pirelab.getDTCComp(topNet,lcount,lcountextend,'Floor','Wrap');

    pirelab.getBitShiftComp(topNet,lcountextend,twolcount,'sll',1);

    pirelab.getBitwiseOpComp(topNet,[cpolyen,dzero],currentshiften,'OR');

    pirelab.getUnitDelayEnabledComp(topNet,nextshift,currentshift,currentshiften,...
    'currentshiftreg',0.0,'',false);
    pirelab.getAddComp(topNet,[currentshift,countone],shiftadd,'Floor','Wrap');
    pirelab.getSwitchComp(topNet,[shiftadd,countzero],nextshift,lregen,'shiftmux');

    pirelab.getAddComp(topNet,[fsmcount,countone],fsmonecount,'Floor','Wrap');
    pirelab.getSubComp(topNet,[fsmonecount,lcount],lcountsub,'Floor','Wrap');
    pirelab.getSwitchComp(topNet,[lcountsub,countzero],nextlcount,endindelay3,'lcountmux');


    pirelab.getSwitchComp(topNet,[syndromeholdreg(2),finalsyndromereg(1)],syndromeholdmux,endindelay3,'synholdmux');
    pirelab.getDirectLookupComp(topNet,syndromeholdmux,synlog,logTable,'synlogtable');

    pirelab.getCompareToValueComp(topNet,dvalue,dzero,'==',0,'dcompare');
    pirelab.getCompareToValueComp(topNet,dvalue,dnotzero,'~=',0,'dnotcompare');
    pirelab.getDirectLookupComp(topNet,dvalue,dvaluelog,logTable,'dvaluelogtable');

    pirelab.getCompareToValueComp(topNet,dm,dmzero,'==',0,'dmcompare');
    pirelab.getCompareToValueComp(topNet,dm,dmone,'==',1,'dmcompare2');
    pirelab.getDirectLookupComp(topNet,dm,dmlog,logTable,'synlogtable');
    pirelab.getSubComp(topNet,[moduloconst,dmlog],dminvlog,'Floor','Wrap');

    pirelab.getAddComp(topNet,[dvaluelog,dminvlog],correctionadd,'Floor','Wrap');
    pirelab.getCompareToValueComp(topNet,correctionadd,correctionwrap,'>',2.^wordSize-1,'modcomparecorrection');
    pirelab.getBitSliceComp(topNet,correctionadd,correctionslice,wordSize-1,0);
    pirelab.getSubComp(topNet,[correctionadd,moduloconst],correctionreduced,'Floor','Wrap');
    pirelab.getSwitchComp(topNet,[correctionslice,correctionreduced],correctionlog,correctionwrap,'modmux');




    pirelab.getUnitDelayComp(topNet,fsmrunnext,fsmrun,'fsmrunreg',0.0);

    pirelab.getCounterComp(topNet,fsmrun,fsmcount,...
    'Count limited',...
    0.0,...
    1.0,...
    2*corr-1,...
    false,...
    false,...
    true,...
    false,...
    'fsmcountproc');
    pirelab.getCompareToValueComp(topNet,fsmcount,fsmnotmax,'~=',2*corr-1,'fsmmaxproc');
    pirelab.getBitwiseOpComp(topNet,[fsmrun,fsmnotmax],fsmcontinue,'AND');
    pirelab.getBitwiseOpComp(topNet,[endindelay3,fsmcontinue],fsmrunnext,'OR');
    pirelab.getBitwiseOpComp(topNet,fsmnotmax,fsmmax,'NOT');
    pirelab.getUnitDelayComp(topNet,fsmmax,fsmdone,'fsmrunreg',0.0);





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
    convcounten=newControlSignal(topNet,'convcounten',rate);
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
            errlocationreg(ii)=newDataSignal(topNet,sprintf('errlocation%dreg',ii),inType,rate);%#ok
            errlocationpipereg(ii)=newDataSignal(topNet,sprintf('errlocationpipe%dreg',ii),inType,rate);%#ok
            errlocationnext(ii)=newDataSignal(topNet,sprintf('errlocation%dnext',ii),inType,rate);%#ok
            errvaluereg(ii)=newDataSignal(topNet,sprintf('errvalue%dreg',ii),inType,rate);%#ok
            errvaluepipereg(ii)=newDataSignal(topNet,sprintf('errvaluepipe%dreg',ii),inType,rate);%#ok
            errvaluenext(ii)=newDataSignal(topNet,sprintf('errvalue%dnext',ii),inType,rate);%#ok
            errvalidreg(ii)=newControlSignal(topNet,sprintf('errvalid%dreg',ii),rate);%#ok
            errvalidpipereg(ii)=newControlSignal(topNet,sprintf('errvalidpipe%dreg',ii),rate);%#ok
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

    pirelab.getMultiPortSwitchComp(topNet,[prerunbank,packetlength0,packetlength1,packetlength2,packetlength3],chienprerunsellen,...
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
            chienpowertable(ii)=chienreg(ii);%#ok
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
            omegaprepowertable(ii)=omegaprepowerreg(ii);%#ok
            omegapowertable(ii)=omegapowerreg(ii);%#ok
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
            derivxortree(ii)=chienreg(ii);%#ok  % forward reference
        else
            pirelab.getBitwiseOpComp(topNet,[chienprexortree(ii-1),chienprereg(ii)],chienprexortree(ii),'XOR');
            pirelab.getBitwiseOpComp(topNet,[chienxortree(ii-1),chienreg(ii)],chienxortree(ii),'XOR');
            pirelab.getBitwiseOpComp(topNet,[omegaxortree(ii-1),omegapowerreg(ii)],omegaxortree(ii),'XOR');
            if mod(ii,2)==0
                pirelab.getBitwiseOpComp(topNet,[derivxortree(ii-2),chienreg(ii)],derivxortree(ii),'XOR');
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

            pirelab.getBitwiseOpComp(topNet,[chienzeroroot,errloadreg(ii)],chienroot(ii),'AND');

            pirelab.getUnitDelayEnabledComp(topNet,errlocationnext(ii),errlocationreg(ii),chienroot(ii),...
            'errlocreg',0.0,'',false);
            pirelab.getSwitchComp(topNet,[chienpower,zeroconst],errlocationnext(ii),chienprerundone,'errlocationmux');

            pirelab.getUnitDelayEnabledComp(topNet,errvaluenext(ii),errvaluereg(ii),chienroot(ii),...
            'errvalreg',0.0,'',false);
            pirelab.getSwitchComp(topNet,[correctresult,zeroconst],errvaluenext(ii),chienprerundone,'errvaluemux');

            pirelab.getUnitDelayEnabledComp(topNet,errvalidnext(ii),errvalidreg(ii),loadroots,...
            'errvldreg',0.0,'',false);

            pirelab.getUnitDelayEnabledComp(topNet,errloadnext(ii),errloadreg(ii),loadroots,...
            'errldreg',0.0,'',false);

            pirelab.getUnitDelayEnabledComp(topNet,errlocationreg(ii),errlocationpipereg(ii),chiendone,...
            'errlocpipereg',0.0,'',false);
            pirelab.getUnitDelayEnabledComp(topNet,errvaluereg(ii),errvaluepipereg(ii),chiendone,...
            'errvalpipereg',0.0,'',false);
            pirelab.getUnitDelayEnabledComp(topNet,errvalidreg(ii),errvalidpipereg(ii),chiendone,...
            'errvldpipereg',0.0,'',false);


        end

    end

    pirelab.getBitwiseOpComp(topNet,[chienrun,chienzero],chienzeroroot,'AND');
    pirelab.getBitwiseOpComp(topNet,[chienzeroroot,chienprerundone],loadroots,'OR');

    pirelab.getBitwiseOpComp(topNet,[chienzeroroot,errvalidreg(corr)],chienuncorrectedroot,'AND');

    pirelab.getBitwiseOpComp(topNet,[chienuncorrectedroot,forceerrorroot],uncorrectedroot,'OR');


    pirelab.getUnitDelayEnabledComp(topNet,uncorrectednext,uncorrected,uncorrectedroot,...
    'uncorrectedreg',0.0,'',false);
    pirelab.getSwitchComp(topNet,[onebit,zerobit],uncorrectednext,chienprerundone,'uncorrectedmux');

    pirelab.getCounterComp(topNet,[chienprerundone,chienzeroroot],nroots,...
    'Count limited',...
    0.0,...
    1.0,...
    2*corr-1,...
    true,...
    false,...
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
    pirelab.getSubComp(topNet,[moduloconst,derivvaluelog],derivinvlog,'Floor','Wrap');

    pirelab.getDirectLookupComp(topNet,omegavalue,omegavaluelog,logTable,'omegalogtable');

    pirelab.getAddComp(topNet,[derivinvlog,omegavaluelog],correctlogadd,'Floor','Wrap');
    pirelab.getCompareToValueComp(topNet,correctlogadd,correctlogwrap,'>',2.^wordSize-1,'correctmodcompare');
    pirelab.getSubComp(topNet,[correctlogadd,moduloconst],correctlogaddreduced,'Floor','Wrap');
    pirelab.getBitSliceComp(topNet,correctlogadd,correctlogslice,wordSize-1,0);
    pirelab.getSwitchComp(topNet,[correctlogslice,correctlogaddreduced],correctmodresult,correctlogwrap,'correctmodmux');

    pirelab.getBitwiseOpComp(topNet,[omegazero,chiennotzero],correctzero,'OR');

    if B==0
        pirelab.getDirectLookupComp(topNet,correctmodresult,correctalogout,alogTable,'correctalogtable');
        pirelab.getSwitchComp(topNet,[correctalogout,zeroconst],correctresult,correctzero,'correctzeromux');
    elseif B==1
        b1logadd=newDataSignal(topNet,'b1logadd',carryType,rate);
        b1logwrap=newControlSignal(topNet,'b1logwrap',rate);
        b1logaddreduced=newDataSignal(topNet,'b1logaddreduced',inType,rate);
        b1logslice=newDataSignal(topNet,'b1logslice',inType,rate);
        b1modresult=newDataSignal(topNet,'b1modresult',inType,rate);

        pirelab.getAddComp(topNet,[correctmodresult,chienpower],b1logadd,'Floor','Wrap');
        pirelab.getCompareToValueComp(topNet,b1logadd,b1logwrap,'>',2.^wordSize-1,'b1modcompare');
        pirelab.getSubComp(topNet,[b1logadd,moduloconst],b1logaddreduced,'Floor','Wrap');
        pirelab.getBitSliceComp(topNet,b1logadd,b1logslice,wordSize-1,0);
        pirelab.getSwitchComp(topNet,[b1logslice,b1logaddreduced],b1modresult,b1logwrap,'b1modmux');

        pirelab.getDirectLookupComp(topNet,b1modresult,correctalogout,alogTable,'correctalogtable');
        pirelab.getSwitchComp(topNet,[correctalogout,zeroconst],correctresult,correctzero,'correctzeromux');
    else
        b1logadd=newDataSignal(topNet,'b1logadd',carryType,rate);
        b1logwrap=newControlSignal(topNet,'b1logwrap',rate);
        b1logaddreduced=newDataSignal(topNet,'b1logaddreduced',inType,rate);
        b1logslice=newDataSignal(topNet,'b1logslice',inType,rate);
        b1modresult=newDataSignal(topNet,'b1modresult',inType,rate);
        baccum=newDataSignal(topNet,'baccum',inType,rate);

        btable=ufi(mod((0:(2^wordSize-1))*B,2^wordSize-1),wordSize,0);
        pirelab.getDirectLookupComp(topNet,chienpower,baccum,btable,'bcorrecttable');

        pirelab.getAddComp(topNet,[correctmodresult,baccum],b1logadd,'Floor','Wrap');
        pirelab.getCompareToValueComp(topNet,b1logadd,b1logwrap,'>',2.^wordSize-1,'b1modcompare');
        pirelab.getSubComp(topNet,[b1logadd,moduloconst],b1logaddreduced,'Floor','Wrap');
        pirelab.getBitSliceComp(topNet,b1logadd,b1logslice,wordSize-1,0);
        pirelab.getSwitchComp(topNet,[b1logslice,b1logaddreduced],b1modresult,b1logwrap,'b1modmux');

        pirelab.getDirectLookupComp(topNet,b1modresult,correctalogout,alogTable,'correctalogtable');
        pirelab.getSwitchComp(topNet,[correctalogout,zeroconst],correctresult,correctzero,'correctzeromux');
    end





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
    ordererr=newControlSignal(topNet,'ordererr',rate);

    pirelab.getCounterComp(topNet,[prestartcurbank,erradvance],errcount,...
    'Count limited',...
    0.0,...
    1.0,...
    2*corr-1,...
    true,...
    false,...
    true,...
    false,...
    'errcounter');

    pirelab.getMultiPortSwitchComp(topNet,[errcount,errlocationpipereg],...
    errlocation,...
    1,1,'floor','Wrap','errmux');
    pirelab.getMultiPortSwitchComp(topNet,[errcount,errvaluepipereg],...
    errvalue,...
    1,1,'floor','Wrap','errmux');
    pirelab.getMultiPortSwitchComp(topNet,[errcount,errvalidpipereg],...
    errvalid,...
    1,1,'floor','Wrap','errmux');

    pirelab.getAddComp(topNet,[currentlength,parityconst],fulllength,'Floor','Wrap');
    pirelab.getBitwiseOpComp(topNet,fulllength,erroffset,'NOT');
    pirelab.getSubComp(topNet,[errlocation,erroffset],finalerrloc,'Floor','Wrap');
    pirelab.getRelOpComp(topNet,[finalerrloc,ramrdcount],errgate,'==');

    pirelab.getBitwiseOpComp(topNet,uncorrected,notuncorrect,'NOT');
    pirelab.getBitwiseOpComp(topNet,[errgate,errvalid,notuncorrect,prevalidout],erradvance,'AND');

    pirelab.getSwitchComp(topNet,[zeroconst,errvalue],correctionnext,erradvance,'correctmux');

    pirelab.getUnitDelayComp(topNet,correctionnext,correction,'correctreg',0.0);


    pirelab.getUnitDelayEnabledComp(topNet,haserrorsreg,haserrorsfsmreg,fsmdone,'synhaserrfsmreg',0.0,'',false);

    pirelab.getUnitDelayEnabledComp(topNet,haserrorsfsmreg,haserrorsconvreg,convdone,'synhaserrconvreg',0.0,'',false);

    pirelab.getUnitDelayEnabledComp(topNet,haserrorsconvreg,haserrorschienprereg,chienprerundone,'synhaserrchienprereg',0.0,'',false);

    pirelab.getUnitDelayEnabledComp(topNet,haserrorschienprereg,haserrorschienreg,chiendone,'synhaserrchienreg',0.0,'',false);

    pirelab.getUnitDelayEnabledComp(topNet,nroots,nrootsreg,chiendone,'nrootsregproc',0.0,'',false);

    pirelab.getUnitDelayEnabledComp(topNet,anyuncorrect,anyuncorrectreg,prestartout,'anyuncreg',0.0,'',false);

    pirelab.getUnitDelayEnabledComp(topNet,nrootsreg,nrootsstart,prestartout,'nrootsstart',0.0,'',false);


    pirelab.getBitwiseOpComp(topNet,[errvalidpipereg(:);haserrorschienreg],anyerr,'OR');
    pirelab.getSubComp(topNet,[errlocpolylen,countone],errlocpolysub,'Floor','Wrap');
    pirelab.getRelOpComp(topNet,[errlocpolysub,nrootsreg],comparepolylen,'>');
    pirelab.getBitwiseOpComp(topNet,[comparepolylen,anyerr],ordererr,'AND');
    pirelab.getBitwiseOpComp(topNet,[uncorrected,ordererr],anyuncorrect,'OR');

    pirelab.getBitwiseOpComp(topNet,[anyuncorrectreg,preendout],preerrout,'AND');











    delaycount0=newDataSignal(topNet,'delay0count',delayType,rate);
    delaycount1=newDataSignal(topNet,'delay1count',delayType,rate);
    delaycount2=newDataSignal(topNet,'delay2count',delayType,rate);
    delaycount3=newDataSignal(topNet,'delay3count',delayType,rate);

    delaymax0=newControlSignal(topNet,'delay0max',rate);
    delaymax1=newControlSignal(topNet,'delay1max',rate);
    delaymax2=newControlSignal(topNet,'delay2max',rate);
    delaymax3=newControlSignal(topNet,'delay3max',rate);

    prestartbank0=newControlSignal(topNet,'prestartbank0',rate);
    prestartbank1=newControlSignal(topNet,'prestartbank1',rate);
    prestartbank2=newControlSignal(topNet,'prestartbank2',rate);
    prestartbank3=newControlSignal(topNet,'prestartbank3',rate);

    pirelab.getCounterComp(topNet,[endpacketbank0,bankvalid0],delaycount0,...
    'Count limited',...
    0.0,...
    1.0,...
    2^delayWordSize-1,...
    true,...
    false,...
    true,...
    false,...
    'd0count');
    pirelab.getCounterComp(topNet,[endpacketbank1,bankvalid1],delaycount1,...
    'Count limited',...
    0.0,...
    1.0,...
    2^delayWordSize-1,...
    true,...
    false,...
    true,...
    false,...
    'd1count');
    pirelab.getCounterComp(topNet,[endpacketbank2,bankvalid2],delaycount2,...
    'Count limited',...
    0.0,...
    1.0,...
    2^delayWordSize-1,...
    true,...
    false,...
    true,...
    false,...
    'd2count');
    pirelab.getCounterComp(topNet,[endpacketbank3,bankvalid3],delaycount3,...
    'Count limited',...
    0.0,...
    1.0,...
    2^delayWordSize-1,...
    true,...
    false,...
    true,...
    false,...
    'd3count');

    pirelab.getCompareToValueComp(topNet,delaycount0,delaymax0,'==',2^delayWordSize-4,'d0maxcompare');
    pirelab.getCompareToValueComp(topNet,delaycount1,delaymax1,'==',2^delayWordSize-4,'d1maxcompare');
    pirelab.getCompareToValueComp(topNet,delaycount2,delaymax2,'==',2^delayWordSize-4,'d2maxcompare');
    pirelab.getCompareToValueComp(topNet,delaycount3,delaymax3,'==',2^delayWordSize-4,'d3maxcompare');

    pirelab.getBitwiseOpComp(topNet,[bankvalid0,delaymax0],prestartbank0,'AND');
    pirelab.getBitwiseOpComp(topNet,[bankvalid1,delaymax1],prestartbank1,'AND');
    pirelab.getBitwiseOpComp(topNet,[bankvalid2,delaymax2],prestartbank2,'AND');
    pirelab.getBitwiseOpComp(topNet,[bankvalid3,delaymax3],prestartbank3,'AND');
    pirelab.getBitwiseOpComp(topNet,[prestartbank0,prestartbank1,prestartbank2,prestartbank3],prestartcurbank,'OR');
    pirelab.getUnitDelayComp(topNet,prestartcurbank,prestartout,'prestartbankreg',0.0);



    pirelab.getUnitDelayComp(topNet,ramrdennext,ramrden,'ramrdenreg',0.0);
    pirelab.getBitwiseOpComp(topNet,[ramrdencontinue,prestartout],ramrdennext,'OR');
    pirelab.getBitwiseOpComp(topNet,[ramrden,notcountstop],ramrdencontinue,'AND');
    pirelab.getBitwiseOpComp(topNet,preendout,notcountstop,'NOT');

    pirelab.getBitwiseOpComp(topNet,[ramrdennext,preendout],prevalidout,'OR');






    pirelab.getSwitchComp(topNet,[zeroconst,predataout],gatedataout,p2dvout,'gatemux');
    pirelab.getUnitDelayComp(topNet,gatedataout,output,'dataoutputreg',0.0);

    pirelab.getUnitDelayComp(topNet,prevalidout,p2dvout,'dv2reg',0.0);
    pirelab.getUnitDelayComp(topNet,prestartout,p2startout,'start2reg',0.0);
    pirelab.getUnitDelayComp(topNet,preendout,p2endout,'end2reg',0.0);
    pirelab.getUnitDelayComp(topNet,preerrout,p2errout,'err2reg',0.0);

    pirelab.getUnitDelayComp(topNet,p2dvout,dvOut,'dvoutputreg',0.0);
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


