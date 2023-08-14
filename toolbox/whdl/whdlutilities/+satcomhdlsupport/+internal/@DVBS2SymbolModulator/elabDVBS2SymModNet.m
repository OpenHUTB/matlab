function elabDVBS2SymModNet(this,topNet,blockInfo,insignals,outsignals)







    dataIn=insignals(1);
    validIn=insignals(2);

    if(strcmpi(blockInfo.ModulationSourceParams,'Input port'))
        modIndx=insignals(3);
        codeRateIndx=insignals(4);
        loadIn=insignals(5);
    end


    dataOut=outsignals(1);
    validOut=outsignals(2);

    rate=dataIn.SimulinkRate;
    dataOut.SimulinkRate=rate;
    validOut.SimulinkRate=rate;

    if strcmp(blockInfo.OutputDataType,'Custom')
        outDT=pir_sfixpt_t(blockInfo.WordLength,-(blockInfo.WordLength-2));
    end


    buffLenSig=newDataSignal(topNet,pir_ufixpt_t(3,0),'buffLenSig',rate);
    modIndxSig=newDataSignal(topNet,pir_ufixpt_t(3,0),'modIndxSig',rate);
    codeRateIndxSig=newDataSignal(topNet,pir_ufixpt_t(3,0),'codeRateIndxSig',rate);


    fiMath1Reset=fimath('RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision','SumMode','FullPrecision');
    nt2Reset=numerictype(0,1,0);
    resetIn=newControlSignal(topNet,'resetIn',rate);
    resetIn1=newControlSignal(topNet,'resetIn1',rate);
    bpskEvenSymFlag=newControlSignal(topNet,'bpskEvenSymFlag',rate);
    bpskEvenSymFlag1=newControlSignal(topNet,'bpskEvenSymFlag1',rate);
    ConstantZeroForScReset=newControlSignal(topNet,'ConstantZeroForScReset',rate);

    inpPortFlag=newControlSignal(topNet,'inpPortFlag',rate);
    pirelab.getConstComp(topNet,inpPortFlag,~strcmpi(blockInfo.ModulationSourceParams,'Property'),'inputPortFlag');
    pirelab.getConstComp(topNet,...
    ConstantZeroForScReset,...
    fi(0,nt2Reset,fiMath1Reset,'hex','0'),...
    'ConstantReset','on',1,'','','');
    pirelab.getSwitchComp(topNet,...
    [resetIn1,ConstantZeroForScReset],...
    resetIn,...
    inpPortFlag,'SwitchReset',...
    '>',0,'Floor','Wrap');
    pirelab.getSwitchComp(topNet,...
    [bpskEvenSymFlag1,ConstantZeroForScReset],...
    bpskEvenSymFlag,...
    inpPortFlag,'SwitchBPSKFlag',...
    '>',0,'Floor','Wrap');

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
        pirelab.getConstComp(topNet,modIndxSig,numBitPerSym);
        pirelab.getConstComp(topNet,buffLenSig,numBitPerSym);

        if strcmp(blockInfo.ModulationScheme,'16-APSK')
            switch(blockInfo.CodeRateAPSK)
            case '2/3'
                codeRateIndex=1;
            case '3/4'
                codeRateIndex=2;
            case '4/5'
                codeRateIndex=3;
            case '5/6'
                codeRateIndex=4;
            case '8/9'
                codeRateIndex=5;
            case '9/10'
                codeRateIndex=6;
            otherwise
                codeRateIndex=2;
            end
        else
            switch(blockInfo.CodeRateAPSK)
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
        end
        pirelab.getConstComp(topNet,codeRateIndxSig,codeRateIndex);
    else



        sampScModCodeRateIdxNet=this.elabLoadModIdxCodeRateIdx(topNet,blockInfo,rate);
        sampScModCodeRateIdxNet.addComment('Load modIdx and codeRateIdx');

        inports_sampScModCod(1)=loadIn;
        inports_sampScModCod(2)=modIndx;
        inports_sampScModCod(3)=codeRateIndx;
        inports_sampScModCod(4)=validIn;

        outports_sampScModCod(1)=modIndxSig;
        outports_sampScModCod(2)=codeRateIndxSig;
        outports_sampScModCod(3)=resetIn1;
        outports_sampScModCod(4)=bpskEvenSymFlag1;

        pirelab.instantiateNetwork(topNet,sampScModCodeRateIdxNet,inports_sampScModCod,outports_sampScModCod,'sampScModCodeRateIdxNet_inst');
        pirelab.getConstComp(topNet,buffLenSig,5);
    end



    dataInDTC=newDataSignal(topNet,pir_ufixpt_t(1,0),'dataInDTC',rate);
    pirelab.getDTCComp(topNet,dataIn,dataInDTC);



    dataInDelay1=newDataSignal(topNet,pir_ufixpt_t(1,0),'dataInDelay1',rate);
    pirelab.getUnitDelayComp(topNet,dataInDTC,dataInDelay1);


    validInDelay1=newControlSignal(topNet,'validInDelay1',rate);
    pirelab.getUnitDelayComp(topNet,validIn,validInDelay1);


    modIndxSigDelay1=newDataSignal(topNet,pir_ufixpt_t(3,0),'modIndxSigDelay1',rate);
    pirelab.getUnitDelayComp(topNet,modIndxSig,modIndxSigDelay1);


    codeRateIndxSigDelay1=newDataSignal(topNet,pir_ufixpt_t(3,0),'codeRateIndxSigDelay1',rate);
    pirelab.getUnitDelayComp(topNet,codeRateIndxSig,codeRateIndxSigDelay1);


    unitAvgPowerFlagIn=newControlSignal(topNet,'unitAvgPowerFlagIn',rate);
    pirelab.getConstComp(topNet,unitAvgPowerFlagIn,blockInfo.UnitAveragePower,'constBlkwithUnitAvgpowerFlag');


    bpskEnable=newControlSignal(topNet,'bpskEnable',rate);
    qpskEnable=newControlSignal(topNet,'qpskEnable',rate);
    psk8Enable=newControlSignal(topNet,'psk8Enable',rate);
    apsk16Enable=newControlSignal(topNet,'apsk16Enable',rate);
    apsk32Enable=newControlSignal(topNet,'apsk32Enable',rate);

    pirelab.getCompareToValueComp(topNet,modIndxSigDelay1,bpskEnable,'==',1);
    pirelab.getCompareToValueComp(topNet,modIndxSigDelay1,qpskEnable,'==',2);
    pirelab.getCompareToValueComp(topNet,modIndxSigDelay1,psk8Enable,'==',3);
    pirelab.getCompareToValueComp(topNet,modIndxSigDelay1,apsk16Enable,'==',4);
    pirelab.getCompareToValueComp(topNet,modIndxSigDelay1,apsk32Enable,'==',5);

    validInBPSK=newControlSignal(topNet,'validInBPSK',rate);
    validInQPSK=newControlSignal(topNet,'validInQPSK',rate);
    validIn8PSK=newControlSignal(topNet,'validIn8PSK',rate);
    validIn16APSK=newControlSignal(topNet,'validIn16APSK',rate);
    validIn32APSK=newControlSignal(topNet,'validIn32APSK',rate);

    pirelab.getBitwiseOpComp(topNet,[validInDelay1,bpskEnable],validInBPSK,'AND');
    pirelab.getBitwiseOpComp(topNet,[validInDelay1,qpskEnable],validInQPSK,'AND');
    pirelab.getBitwiseOpComp(topNet,[validInDelay1,psk8Enable],validIn8PSK,'AND');
    pirelab.getBitwiseOpComp(topNet,[validInDelay1,apsk16Enable],validIn16APSK,'AND');
    pirelab.getBitwiseOpComp(topNet,[validInDelay1,apsk32Enable],validIn32APSK,'AND');



    addrBPSK=newDataSignal(topNet,pir_ufixpt_t(1,0),'addrBPSK',rate);
    addrBPSKValidOut=newControlSignal(topNet,'addrBPSKValidOut',rate);

    pirelab.getIntDelayComp(topNet,dataInDelay1,addrBPSK,0,'delay_addrBPSK');
    pirelab.getIntDelayComp(topNet,validInBPSK,addrBPSKValidOut,0,'delay_bpskAddrGen');


    addrQPSK=newDataSignal(topNet,pir_ufixpt_t(2,0),'addrQPSK',rate);
    addrQPSKValidOut=newControlSignal(topNet,'addrQPSKValidOut',rate);

    buffInpGenAddrQPSKNet=this.elabBuffInpGenAddrQPSK(topNet,blockInfo,rate);
    buffInpGenAddrQPSKNet.addComment('Buffer input data and generate address QPSK');

    inbuffInpGenQPSKAddr(1)=dataInDelay1;
    inbuffInpGenQPSKAddr(2)=validInQPSK;
    inbuffInpGenQPSKAddr(3)=resetIn;

    outbuffInpGenQPSKAddr(1)=addrQPSK;
    outbuffInpGenQPSKAddr(2)=addrQPSKValidOut;

    addrQPSKDelay=newDataSignal(topNet,pir_ufixpt_t(2,0),'addrQPSKDelay',rate);
    addrQPSKValidOutDelay=newControlSignal(topNet,'addrQPSKValidOutDelay',rate);
    pirelab.getIntDelayComp(topNet,addrQPSK,addrQPSKDelay,1,'delay_addrQPSK');
    pirelab.getIntDelayComp(topNet,addrQPSKValidOut,addrQPSKValidOutDelay,1,'delay_addrQPSKValidOut');

    pirelab.instantiateNetwork(topNet,buffInpGenAddrQPSKNet,inbuffInpGenQPSKAddr,outbuffInpGenQPSKAddr,'buffInpGenQPSKAddr_inst');


    addr8PSK=newDataSignal(topNet,pir_ufixpt_t(3,0),'addr8PSK',rate);
    addr8PSKValidOut=newControlSignal(topNet,'addr8PSKValidOut',rate);

    buffInpGenAddr8PSKNet=this.elabBuffInpGenAddr8PSK(topNet,blockInfo,rate);
    buffInpGenAddr8PSKNet.addComment('Buffer input data and generate address 8PSK');

    inbuffInpGen8PSKAddr(1)=dataInDelay1;
    inbuffInpGen8PSKAddr(2)=validIn8PSK;
    inbuffInpGen8PSKAddr(3)=resetIn;

    outbuffInpGen8PSKAddr(1)=addr8PSK;
    outbuffInpGen8PSKAddr(2)=addr8PSKValidOut;

    addr8PSKDelay=newDataSignal(topNet,pir_ufixpt_t(3,0),'addr8PSKDelay',rate);
    addr8PSKValidOutDelay=newControlSignal(topNet,'addr8PSKValidOutDelay',rate);
    pirelab.getIntDelayComp(topNet,addr8PSK,addr8PSKDelay,1,'delay_addr8PSK');
    pirelab.getIntDelayComp(topNet,addr8PSKValidOut,addr8PSKValidOutDelay,1,'delay_addr8PSKValidOut');

    pirelab.instantiateNetwork(topNet,buffInpGenAddr8PSKNet,inbuffInpGen8PSKAddr,outbuffInpGen8PSKAddr,'buffInpGen8PSKAddr_inst');


    addr16APSK=newDataSignal(topNet,pir_ufixpt_t(4,0),'addr16APSK',rate);
    addr16APSKValidOut=newControlSignal(topNet,'addr16APSKValidOut',rate);

    buffInpGenAddr16APSKNet=this.elabBuffInpGenAddr16APSK(topNet,blockInfo,rate);
    buffInpGenAddr16APSKNet.addComment('Buffer input data and generate address 16APSK');

    inbuffInpGen16APSKAddr(1)=dataInDelay1;
    inbuffInpGen16APSKAddr(2)=validIn16APSK;
    inbuffInpGen16APSKAddr(3)=resetIn;

    outbuffInpGen16APSKAddr(1)=addr16APSK;
    outbuffInpGen16APSKAddr(2)=addr16APSKValidOut;

    addr16APSKDelay=newDataSignal(topNet,pir_ufixpt_t(4,0),'addr16APSKDelay',rate);
    addr16APSKValidOutDelay=newControlSignal(topNet,'addr16APSKValidOutDelay',rate);
    pirelab.getIntDelayComp(topNet,addr16APSK,addr16APSKDelay,1,'delay_addr16APSK');
    pirelab.getIntDelayComp(topNet,addr16APSKValidOut,addr16APSKValidOutDelay,2,'delay_addr16APSKValidOut');

    pirelab.instantiateNetwork(topNet,buffInpGenAddr16APSKNet,inbuffInpGen16APSKAddr,outbuffInpGen16APSKAddr,'buffInpGen16APSKAddr_inst');


    addr32APSK=newDataSignal(topNet,pir_ufixpt_t(5,0),'addr32APSK',rate);
    addr32APSKValidOut=newControlSignal(topNet,'addr32APSKValidOut',rate);

    buffInpGenAddr32APSKNet=this.elabBuffInpGenAddr32APSK(topNet,blockInfo,rate);
    buffInpGenAddr32APSKNet.addComment('Buffer input data and generate address 32APSK');

    inbuffInpGen32APSKAddr(1)=dataInDelay1;
    inbuffInpGen32APSKAddr(2)=validIn32APSK;
    inbuffInpGen32APSKAddr(3)=resetIn;

    outbuffInpGen32APSKAddr(1)=addr32APSK;
    outbuffInpGen32APSKAddr(2)=addr32APSKValidOut;

    addr32APSKDelay=newDataSignal(topNet,pir_ufixpt_t(5,0),'addr32APSKDelay',rate);
    addr32APSKValidOutDelay=newControlSignal(topNet,'addr32APSKValidOutDelay',rate);
    pirelab.getIntDelayComp(topNet,addr32APSK,addr32APSKDelay,1,'delay_addr32APSK');
    pirelab.getIntDelayComp(topNet,addr32APSKValidOut,addr32APSKValidOutDelay,2,'delay_addr32APSKValidOut',0);

    pirelab.instantiateNetwork(topNet,buffInpGenAddr32APSKNet,inbuffInpGen32APSKAddr,outbuffInpGen32APSKAddr,'buffInpGen32APSKAddr_inst');


    bpskdataOutEvenSymModRe=newDataSignal(topNet,outDT,'bpskdataOutEvenSymModRe',rate);
    bpskdataOutEvenSymModIm=newDataSignal(topNet,outDT,'bpskdataOutEvenSymModIm',rate);
    bpskdataOutEvenSymMod=newDataSignal(topNet,pir_complex_t(outDT),'bpskdataOutEvenSymMod',rate);

    bpskdataOutOddSymModRe=newDataSignal(topNet,outDT,'bpskdataOutOddSymModRe',rate);
    bpskdataOutOddSymModIm=newDataSignal(topNet,outDT,'bpskdataOutOddSymModIm',rate);
    bpskdataOutOddSymMod=newDataSignal(topNet,pir_complex_t(outDT),'bpskdataOutOddSymMod',rate);

    bpskvalidOutSymMod=newControlSignal(topNet,'bpskvalidOutSymMod',rate);

    bpskdataOutSymMod=newDataSignal(topNet,pir_complex_t(outDT),'bpskdataOutSymMod',rate);


    qpskdataOutSymModRe=newDataSignal(topNet,outDT,'qpskdataOutSymModRe',rate);
    qpskdataOutSymModIm=newDataSignal(topNet,outDT,'qpskdataOutSymModIm',rate);
    qpskdataOutSymMod=newDataSignal(topNet,pir_complex_t(outDT),'qpskdataOutSymMod',rate);
    qpskvalidOutSymMod=newControlSignal(topNet,'qpskvalidOutSymMod',rate);

    dataOutSymMod=newDataSignal(topNet,pir_complex_t(outDT),'dataOutSymMod',rate);
    validOutSymMod=newControlSignal(topNet,'validOutSymMod',rate);

    lutWL=blockInfo.WordLength;
    fimath_lut=fimath('RoundingMethod','Floor','OverflowAction','Wrap');




    lutPiBy2BPSKEven=fi([1+j,-1-j]/sqrt(2),1,lutWL,lutWL-2,'RoundingMethod','Floor','OverflowAction','Wrap');
    lutPiBy2BPSKEvenSym=fi(lutPiBy2BPSKEven,1,lutWL,lutWL-2,fimath_lut);

    pirelab.getDirectLookupComp(topNet,addrBPSK,bpskdataOutEvenSymModRe,lutPiBy2BPSKEvenSym.real,...
    'TablePiBy2BPSKEvenRe');
    pirelab.getDirectLookupComp(topNet,addrBPSK,bpskdataOutEvenSymModIm,lutPiBy2BPSKEvenSym.imag,...
    'TablePiBy2BPSKEvenIm');
    pirelab.getRealImag2Complex(topNet,[bpskdataOutEvenSymModRe,bpskdataOutEvenSymModIm],bpskdataOutEvenSymMod);


    lutPiBy2BPSKOdd=fi([-1+j,1-j]/sqrt(2),1,lutWL,lutWL-2,'RoundingMethod','Floor','OverflowAction','Wrap');
    lutPiBy2BPSKOddSym=fi(lutPiBy2BPSKOdd,1,lutWL,lutWL-2,fimath_lut);

    pirelab.getDirectLookupComp(topNet,addrBPSK,bpskdataOutOddSymModRe,lutPiBy2BPSKOddSym.real,...
    'TablePiBy2BPSKOddRe');
    pirelab.getDirectLookupComp(topNet,addrBPSK,bpskdataOutOddSymModIm,lutPiBy2BPSKOddSym.imag,...
    'TablePiBy2BPSKOddIm');
    pirelab.getRealImag2Complex(topNet,[bpskdataOutOddSymModRe,bpskdataOutOddSymModIm],bpskdataOutOddSymMod);


    evenSymFlag=newControlSignal(topNet,'evenSymFlag',rate);
    resetInBPSKFlag=newControlSignal(topNet,'resetInBPSKFlag',rate);
    pirelab.getBitwiseOpComp(topNet,[resetIn,bpskEvenSymFlag],resetInBPSKFlag,'OR');

    pirelab.getCounterComp(topNet,[resetInBPSKFlag,addrBPSKValidOut],evenSymFlag,...
    'Count limited',...
    1,...
    -1,...
    0,...
    true,...
    false,...
    true,...
    false,...
    'evenSymcounter');

    pirelab.getSwitchComp(topNet,...
    [bpskdataOutEvenSymMod,bpskdataOutOddSymMod],...
    bpskdataOutSymMod,...
    evenSymFlag,'BPSKSwitch',...
    '>',0,'Floor','Wrap');

    bpskdataOutSymModD1=newDataSignal(topNet,pir_complex_t(outDT),'bpskdataOutSymModD1',rate);
    pirelab.getIntDelayComp(topNet,bpskdataOutSymMod,bpskdataOutSymModD1,4+3,'delay_bpskdataOutSymMod');
    pirelab.getIntDelayComp(topNet,addrBPSKValidOut,bpskvalidOutSymMod,4+3,'delay_addrBPSKValidOut');


    lutQPSK=fi([1+j,1-j,-1+j,-1-j]/sqrt(2),1,lutWL,lutWL-2,'RoundingMethod','Floor','OverflowAction','Wrap');
    lutQPSKSym=fi(lutQPSK,1,lutWL,lutWL-2,fimath_lut);
    pirelab.getDirectLookupComp(topNet,addrQPSKDelay,qpskdataOutSymModRe,lutQPSKSym.real,...
    'TableQPSKRe');
    pirelab.getDirectLookupComp(topNet,addrQPSKDelay,qpskdataOutSymModIm,lutQPSKSym.imag,...
    'TableQPSKIm');
    pirelab.getRealImag2Complex(topNet,[qpskdataOutSymModRe,qpskdataOutSymModIm],qpskdataOutSymMod);
    qpskdataOutSymModD1=newDataSignal(topNet,pir_complex_t(outDT),'qpskdataOutSymModD1',rate);
    pirelab.getIntDelayComp(topNet,qpskdataOutSymMod,qpskdataOutSymModD1,3+1,'delay_qpskdataOutSymMod');
    pirelab.getIntDelayComp(topNet,addrQPSKValidOutDelay,qpskvalidOutSymMod,3+1,'delay_QPSKValidOut');


    lut8PSK=fi([(1/sqrt(2)+j/sqrt(2)),1+j*0,-1+j*0,(-1/sqrt(2)-j/sqrt(2))...
    ,0+j,(1/sqrt(2)-j/sqrt(2)),(-1/sqrt(2)+j/sqrt(2)),0-j],1,lutWL,lutWL-2,'RoundingMethod','Floor','OverflowAction','Wrap');
    lut8PSKSym=fi(lut8PSK,1,lutWL,lutWL-2,fimath_lut);


    psk8dataOutSymModRe=newDataSignal(topNet,outDT,'psk8dataOutSymModRe',rate);
    psk8dataOutSymModIm=newDataSignal(topNet,outDT,'psk8dataOutSymModIm',rate);
    psk8dataOutSymMod=newDataSignal(topNet,pir_complex_t(outDT),'psk8dataOutSymMod',rate);
    psk8validOutSymMod=newControlSignal(topNet,'psk8validOutSymMod',rate);

    pirelab.getDirectLookupComp(topNet,addr8PSKDelay,psk8dataOutSymModRe,lut8PSKSym.real,...
    'Table8PSKRe');
    pirelab.getDirectLookupComp(topNet,addr8PSKDelay,psk8dataOutSymModIm,lut8PSKSym.imag,...
    'Table8PSKIm');
    pirelab.getRealImag2Complex(topNet,[psk8dataOutSymModRe,psk8dataOutSymModIm],psk8dataOutSymMod);
    psk8dataOutSymModD1=newDataSignal(topNet,pir_complex_t(outDT),'psk8dataOutSymModD1',rate);
    pirelab.getIntDelayComp(topNet,psk8dataOutSymMod,psk8dataOutSymModD1,2+1,'delay_psk8dataOutSymMod');
    pirelab.getIntDelayComp(topNet,addr8PSKValidOutDelay,psk8validOutSymMod,2+1,'delay_8PSKValidOut');



    g=[3.15,2.85,2.75,2.7,2.6,2.57].';
    APSK16InCirConstl=[(1./g)*((1/sqrt(2))+j*(1/sqrt(2))),(1./g)*((1/sqrt(2))-j*(1/sqrt(2)))...
    ,(1./g)*((-1/sqrt(2))+j*(1/sqrt(2))),(1./g)*((-1/sqrt(2))-j*(1/sqrt(2)))];
    APSK16OutCirConstl=[(1/sqrt(2))+j*(1/sqrt(2)),(1/sqrt(2))-j*(1/sqrt(2)),-(1/sqrt(2))+j*(1/sqrt(2)),-(1/sqrt(2))-j*(1/sqrt(2))...
    ,((sqrt(3)+1)+j*(sqrt(3)-1))/(2*sqrt(2)),((sqrt(3)+1)-j*(sqrt(3)-1))/(2*sqrt(2)),(-(sqrt(3)+1)+j*(sqrt(3)-1))/(2*sqrt(2)),(-(sqrt(3)+1)-j*(sqrt(3)-1))/(2*sqrt(2))...
    ,((sqrt(3)-1)+j*(sqrt(3)+1))/(2*sqrt(2)),((sqrt(3)-1)-j*(sqrt(3)+1))/(2*sqrt(2)),(-(sqrt(3)-1)+j*(sqrt(3)+1))/(2*sqrt(2)),(-(sqrt(3)-1)-j*(sqrt(3)+1))/(2*sqrt(2))];
    unNorm16APSK=[repmat(APSK16OutCirConstl,6,1),APSK16InCirConstl];
    unNorm16APSKFix=fi(unNorm16APSK,1,lutWL,lutWL-2,'RoundingMethod','Floor','OverflowAction','Wrap');
    lutUnNorm16APSKSym=fi(unNorm16APSKFix,1,lutWL,lutWL-2,fimath_lut);

    powUnNorm16APSK=mean(abs(unNorm16APSK).^2,2);
    lutNorm16APSK=unNorm16APSK./sqrt(powUnNorm16APSK);
    lutNorm16APSKFix=fi(lutNorm16APSK,1,lutWL,lutWL-2,'RoundingMethod','Floor','OverflowAction','Wrap');
    lutNorm16APSKSym=fi(lutNorm16APSKFix,1,lutWL,lutWL-2,fimath_lut);


    apsk16unNormReal=newDataSignal(topNet,outDT,'apsk16UnNormReal',rate);
    apsk16unNormImag=newDataSignal(topNet,outDT,'apsk16UnNormImag',rate);
    apsk16unNorm=newDataSignal(topNet,pir_complex_t(outDT),'apsk16unNorm',rate);


    apsk16NormReal=newDataSignal(topNet,outDT,'apsk16NormReal',rate);
    apsk16NormImag=newDataSignal(topNet,outDT,'apsk16NormImag',rate);
    apsk16Norm=newDataSignal(topNet,pir_complex_t(outDT),'apsk16Norm',rate);



    for ii=1:6
        apsk16unNormRe(ii)=newDataSignal(topNet,outDT,sprintf('apsk16unNormReRate%d',ii),rate);%#ok
        apsk16unNormIm(ii)=newDataSignal(topNet,outDT,sprintf('apsk16unNormImRate%d',ii),rate);%#ok
        pirelab.getDirectLookupComp(topNet,addr16APSKDelay,apsk16unNormRe(ii),real(lutUnNorm16APSKSym(ii,:)),...
        'TableUnNorm16APSKRe');
        pirelab.getDirectLookupComp(topNet,addr16APSKDelay,apsk16unNormIm(ii),imag(lutUnNorm16APSKSym(ii,:)),...
        'TableUnNorm16APSKIm');

        apsk16NormRe(ii)=newDataSignal(topNet,outDT,sprintf('apsk16NormReRate%d',ii),rate);%#ok
        apsk16NormIm(ii)=newDataSignal(topNet,outDT,sprintf('apsk16NormReImRate%d',ii),rate);%#ok
        pirelab.getDirectLookupComp(topNet,addr16APSKDelay,apsk16NormRe(ii),real(lutNorm16APSKSym(ii,:)),...
        'TableNorm16APSKRe');
        pirelab.getDirectLookupComp(topNet,addr16APSKDelay,apsk16NormIm(ii),imag(lutNorm16APSKSym(ii,:)),...
        'TableNorm16APSKIm');

    end

    codeRateIndx16APSKD2=newDataSignal(topNet,pir_ufixpt_t(3,0),'codeRateIndx16APSKD2',rate);
    pirelab.getIntDelayComp(topNet,codeRateIndxSigDelay1,codeRateIndx16APSKD2,5,'delay_codeRateIndxSigDelay1_16APSK');


    pirelab.getMultiPortSwitchComp(topNet,[codeRateIndx16APSKD2,apsk16unNormRe(1),apsk16unNormRe(2),apsk16unNormRe(3),apsk16unNormRe(4),apsk16unNormRe(5)...
    ,apsk16unNormRe(6)],apsk16unNormReal,1,2,'floor','Wrap','apsk16unNormRealSwitch');

    pirelab.getMultiPortSwitchComp(topNet,[codeRateIndx16APSKD2,apsk16unNormIm(1),apsk16unNormIm(2),apsk16unNormIm(3),apsk16unNormIm(4),apsk16unNormIm(5)...
    ,apsk16unNormIm(6)],apsk16unNormImag,1,2,'floor','Wrap','apsk16unNormImagSwitch');


    pirelab.getMultiPortSwitchComp(topNet,[codeRateIndx16APSKD2,apsk16NormRe(1),apsk16NormRe(2),apsk16NormRe(3),apsk16NormRe(4),apsk16NormRe(5)...
    ,apsk16NormRe(6)],apsk16NormReal,1,2,'floor','Wrap','apsk16NormRealSwitch');

    pirelab.getMultiPortSwitchComp(topNet,[codeRateIndx16APSKD2,apsk16NormIm(1),apsk16NormIm(2),apsk16NormIm(3),apsk16NormIm(4),apsk16NormIm(5)...
    ,apsk16NormIm(6)],apsk16NormImag,1,2,'floor','Wrap','apsk16NormImagSwitch');


    apsk16unNormRealD1=newDataSignal(topNet,outDT,'apsk16UnNormRealD1',rate);
    apsk16unNormImagD1=newDataSignal(topNet,outDT,'apsk16UnNormImagD1',rate);


    apsk16NormRealD1=newDataSignal(topNet,outDT,'apsk16NormRealD1',rate);
    apsk16NormImagD1=newDataSignal(topNet,outDT,'apsk16NormImagD1',rate);

    pirelab.getIntDelayComp(topNet,apsk16unNormReal,apsk16unNormRealD1,1,'delay_apsk16unNormReal');
    pirelab.getIntDelayComp(topNet,apsk16unNormImag,apsk16unNormImagD1,1,'delay_apsk16unNormImag');
    pirelab.getIntDelayComp(topNet,apsk16NormReal,apsk16NormRealD1,1,'delay_apsk16NormReal');
    pirelab.getIntDelayComp(topNet,apsk16NormImag,apsk16NormImagD1,1,'delay_apsk16NormImag');

    pirelab.getRealImag2Complex(topNet,[apsk16unNormRealD1,apsk16unNormImagD1],apsk16unNorm);
    pirelab.getRealImag2Complex(topNet,[apsk16NormRealD1,apsk16NormImagD1],apsk16Norm);


    apsk16DataOutSymMod=newDataSignal(topNet,pir_complex_t(outDT),'apsk16DataOutSymMod',rate);
    pirelab.getSwitchComp(topNet,...
    [apsk16Norm,apsk16unNorm],...
    apsk16DataOutSymMod,...
    unitAvgPowerFlagIn,'Switch16APSK',...
    '>',0,'Floor','Wrap');

    apsk16DataOutSymModD1=newDataSignal(topNet,pir_complex_t(outDT),'apsk16DataOutSymModD1',rate);
    apsk16validOutSymMod=newControlSignal(topNet,'apsk16validOutSymMod',rate);
    pirelab.getIntDelayComp(topNet,apsk16DataOutSymMod,apsk16DataOutSymModD1,1,'delay_apsk16unNorm');
    pirelab.getIntDelayComp(topNet,addr16APSKValidOutDelay,apsk16validOutSymMod,1,'delay_16APSKValidOut');


    g1=[2.84,2.72,2.64,2.54,2.53].';
    g2=[5.27,4.87,4.64,4.33,4.30].';

    APSK32InMidCirConstl=[(g1./g2)*((1/sqrt(2))+j*(1/sqrt(2))),(g1./g2)*((sqrt(3)-1)+j*(sqrt(3)+1))/(2*sqrt(2))...
    ,(g1./g2)*((1/sqrt(2))-j*(1/sqrt(2))),(g1./g2)*((sqrt(3)-1)-j*(sqrt(3)+1))/(2*sqrt(2))...
    ,(g1./g2)*(-(1/sqrt(2))+j*(1/sqrt(2))),(g1./g2)*(-(sqrt(3)-1)+j*(sqrt(3)+1))/(2*sqrt(2))...
    ,(g1./g2)*(-(1/sqrt(2))-j*(1/sqrt(2))),(g1./g2)*(-(sqrt(3)-1)-j*(sqrt(3)+1))/(2*sqrt(2))...
    ,(g1./g2)*((sqrt(3)+1)+j*(sqrt(3)-1))/(2*sqrt(2)),(1./g2)*((1/sqrt(2))+j*(1/sqrt(2)))...
    ,(g1./g2)*((sqrt(3)+1)-j*(sqrt(3)-1))/(2*sqrt(2)),(1./g2)*((1/sqrt(2))-j*(1/sqrt(2)))...
    ,(g1./g2)*(-(sqrt(3)+1)+j*(sqrt(3)-1))/(2*sqrt(2)),(1./g2)*((-1/sqrt(2))+j*(1/sqrt(2)))...
    ,(g1./g2)*(-(sqrt(3)+1)-j*(sqrt(3)-1))/(2*sqrt(2)),(1./g2)*((-1/sqrt(2))-j*(1/sqrt(2)))];

    APSK32OutCirConstl=[cos(pi/8)+j*sin(pi/8),cos(3*pi/8)+j*sin(3*pi/8),((1/sqrt(2))-j*(1/sqrt(2))),-j...
    ,(-(1/sqrt(2))+j*(1/sqrt(2))),j,-cos(pi/8)-j*sin(pi/8),-cos(3*pi/8)-j*sin(3*pi/8)...
    ,1,((1/sqrt(2))+j*(1/sqrt(2))),cos(pi/8)-j*sin(pi/8),cos(3*pi/8)-j*sin(3*pi/8)...
    ,-cos(pi/8)+j*sin(pi/8),-cos(3*pi/8)+j*sin(3*pi/8),-1,(-(1/sqrt(2))-j*(1/sqrt(2)))];

    unNorm32APSK=[APSK32InMidCirConstl(:,1:8),repmat(APSK32OutCirConstl(1:8),5,1),APSK32InMidCirConstl(:,9:16),repmat(APSK32OutCirConstl(9:16),5,1)];
    powUnNorm32APSK=mean(abs(unNorm32APSK).^2,2);
    lutNorm32APSK=unNorm32APSK./sqrt(powUnNorm32APSK);

    unNorm32APSKFix=fi(unNorm32APSK,1,lutWL,lutWL-2,'RoundingMethod','Floor','OverflowAction','Wrap');
    lutUnNorm32APSKSym=fi(unNorm32APSKFix,1,lutWL,lutWL-2,fimath_lut);

    lutNorm32APSKFix=fi(lutNorm32APSK,1,lutWL,lutWL-2,'RoundingMethod','Floor','OverflowAction','Wrap');
    lutNorm32APSKSym=fi(lutNorm32APSKFix,1,lutWL,lutWL-2,fimath_lut);


    apsk32unNormReal=newDataSignal(topNet,outDT,'apsk32UnNormReal',rate);
    apsk32unNormImag=newDataSignal(topNet,outDT,'apsk32UnNormImag',rate);
    apsk32unNorm=newDataSignal(topNet,pir_complex_t(outDT),'apsk32unNorm',rate);


    apsk32NormReal=newDataSignal(topNet,outDT,'apsk32NormReal',rate);
    apsk32NormImag=newDataSignal(topNet,outDT,'apsk32NormImag',rate);
    apsk32Norm=newDataSignal(topNet,pir_complex_t(outDT),'apsk32Norm',rate);



    for ii=1:5
        apsk32unNormRe(ii)=newDataSignal(topNet,outDT,sprintf('apsk32unNormReRate%d',ii),rate);%#ok
        apsk32unNormIm(ii)=newDataSignal(topNet,outDT,sprintf('apsk32unNormImRate%d',ii),rate);%#ok
        pirelab.getDirectLookupComp(topNet,addr32APSKDelay,apsk32unNormRe(ii),real(lutUnNorm32APSKSym(ii,:)),...
        'TableUnNorm32APSKRe');
        pirelab.getDirectLookupComp(topNet,addr32APSKDelay,apsk32unNormIm(ii),imag(lutUnNorm32APSKSym(ii,:)),...
        'TableUnNorm32APSKIm');

        apsk32NormRe(ii)=newDataSignal(topNet,outDT,sprintf('apsk32NormReRate%d',ii),rate);%#ok
        apsk32NormIm(ii)=newDataSignal(topNet,outDT,sprintf('apsk32NormReImRate%d',ii),rate);%#ok
        pirelab.getDirectLookupComp(topNet,addr32APSKDelay,apsk32NormRe(ii),real(lutNorm32APSKSym(ii,:)),...
        'TableNorm32APSKRe');
        pirelab.getDirectLookupComp(topNet,addr32APSKDelay,apsk32NormIm(ii),imag(lutNorm32APSKSym(ii,:)),...
        'TableNorm32APSKIm');

    end

    codeRateIndx32APSKD2=newDataSignal(topNet,pir_ufixpt_t(3,0),'codeRateIndx32APSKD2',rate);
    pirelab.getIntDelayComp(topNet,codeRateIndxSigDelay1,codeRateIndx32APSKD2,6,'delay_codeRateIndxSigDelay1_32APSK');



    pirelab.getMultiPortSwitchComp(topNet,[codeRateIndx32APSKD2,apsk32unNormRe(1),apsk32unNormRe(2),apsk32unNormRe(3),apsk32unNormRe(4),apsk32unNormRe(5)...
    ],apsk32unNormReal,1,2,'floor','Wrap','apsk32unNormRealSwitch');

    pirelab.getMultiPortSwitchComp(topNet,[codeRateIndx32APSKD2,apsk32unNormIm(1),apsk32unNormIm(2),apsk32unNormIm(3),apsk32unNormIm(4),apsk32unNormIm(5)...
    ],apsk32unNormImag,1,2,'floor','Wrap','apsk32unNormImagSwitch');



    pirelab.getMultiPortSwitchComp(topNet,[codeRateIndx32APSKD2,apsk32NormRe(1),apsk32NormRe(2),apsk32NormRe(3),apsk32NormRe(4),apsk32NormRe(5)...
    ],apsk32NormReal,1,2,'floor','Wrap','apsk32NormRealSwitch');

    pirelab.getMultiPortSwitchComp(topNet,[codeRateIndx32APSKD2,apsk32NormIm(1),apsk32NormIm(2),apsk32NormIm(3),apsk32NormIm(4),apsk32NormIm(5)...
    ],apsk32NormImag,1,2,'floor','Wrap','apsk32NormImagSwitch');


    apsk32unNormRealD1=newDataSignal(topNet,outDT,'apsk32UnNormRealD1',rate);
    apsk32unNormImagD1=newDataSignal(topNet,outDT,'apsk32UnNormImagD1',rate);


    apsk32NormRealD1=newDataSignal(topNet,outDT,'apsk32NormRealD1',rate);
    apsk32NormImagD1=newDataSignal(topNet,outDT,'apsk32NormImagD1',rate);

    pirelab.getIntDelayComp(topNet,apsk32unNormReal,apsk32unNormRealD1,1,'delay_apsk32unNormReal');
    pirelab.getIntDelayComp(topNet,apsk32unNormImag,apsk32unNormImagD1,1,'delay_apsk32unNormImag');
    pirelab.getIntDelayComp(topNet,apsk32NormReal,apsk32NormRealD1,1,'delay_apsk32NormReal');
    pirelab.getIntDelayComp(topNet,apsk32NormImag,apsk32NormImagD1,1,'delay_apsk32NormImag');

    pirelab.getRealImag2Complex(topNet,[apsk32unNormRealD1,apsk32unNormImagD1],apsk32unNorm);

    pirelab.getRealImag2Complex(topNet,[apsk32NormRealD1,apsk32NormImagD1],apsk32Norm);

    apsk32DataOutSymMod=newDataSignal(topNet,pir_complex_t(outDT),'apsk32DataOutSymMod',rate);
    pirelab.getSwitchComp(topNet,...
    [apsk32Norm,apsk32unNorm],...
    apsk32DataOutSymMod,...
    unitAvgPowerFlagIn,'Switch32APSK',...
    '>',0,'Floor','Wrap');

    modIndxSigDelay2=newDataSignal(topNet,pir_ufixpt_t(3,0),'modIndxSigDelay2',rate);
    pirelab.getIntDelayComp(topNet,modIndxSigDelay1,modIndxSigDelay2,7,'delay_modIndxSigDelay1');

    pirelab.getMultiPortSwitchComp(topNet,[modIndxSigDelay2,bpskdataOutSymModD1,qpskdataOutSymModD1,psk8dataOutSymModD1,apsk16DataOutSymModD1...
    ,apsk32DataOutSymMod],dataOutSymMod,1,2,'floor','Wrap','dataOutMux');
    pirelab.getMultiPortSwitchComp(topNet,[modIndxSigDelay2,bpskvalidOutSymMod,qpskvalidOutSymMod,psk8validOutSymMod,apsk16validOutSymMod...
    ,addr32APSKValidOutDelay],validOutSymMod,1,2,'floor','Wrap','validOutMux');

    ComplxZeroConst=newDataSignal(topNet,pir_complex_t(outDT),'ComplxZeroConst',rate);
    pirelab.getConstComp(topNet,...
    ComplxZeroConst,...
    0+0i,...
    'constComplxZero','on',1,'','','');

    dataOutSymModD1=newDataSignal(topNet,pir_complex_t(outDT),'dataOutSymModD1',rate);
    pirelab.getIntDelayComp(topNet,dataOutSymMod,dataOutSymModD1,1,'delay_dataOutSymMod');
    pirelab.getIntDelayComp(topNet,validOutSymMod,validOut,1,'delay_validOut');

    pirelab.getSwitchComp(topNet,...
    [dataOutSymModD1,ComplxZeroConst],...
    dataOut,...
    validOut,'SwitchDataOut',...
    '>',0,'Floor','Wrap');

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
