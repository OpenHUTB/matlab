function newNet=elaborateFilter(this,hN,blockInfo,dataInType,dataOutType,phaseType)









    dataRate=hN.PirInputSignals(1).SimulinkRate;

    newNet=pirelab.createNewNetwork(...
    'Network',hN,...
    'Name','FIR Rate Conversion Filter',...
    'InportNames',{'data','dataValid','phase','phaseValid','request'},...
    'InportTypes',[dataInType,pir_boolean_t,phaseType,pir_boolean_t,pir_boolean_t],...
    'InportRates',repmat(dataRate,1,5),...
    'OutportNames',{'dataOut','validOut'},...
    'OutportTypes',[dataOutType,pir_boolean_t]);

    newNet.addComment('FIR Rate Conversion Filter');





    data=newNet.PirInputSignals(1);
    dataValid=newNet.PirInputSignals(2);
    phase=newNet.PirInputSignals(3);
    phaseValid=newNet.PirInputSignals(4);
    request=newNet.PirInputSignals(5);

    dataOut=newNet.PirOutputSignals(1);
    validOut=newNet.PirOutputSignals(2);





    numChannels=dataInType.getDimensions;

    if numChannels==1
        isComplex=dataInType.isComplexType;
    else
        isComplex=dataInType.BaseType.isComplexType;
    end


    dataInFixType=dataInType.BaseType.BaseType;

    L=blockInfo.InterpolationFactor;

    delayLineLength=ceil(length(blockInfo.Numerator)/L);



    numerator=blockInfo.Numerator;
    padding=zeros(delayLineLength*L-length(numerator),1,'like',numerator);
    numeratorPadded=[numerator(:);padding];
    polyCoeffs=reshape(numeratorPadded,L,delayLineLength);
    polyCoeffsFi=fi(polyCoeffs,blockInfo.CoefficientsDataType);









    coeffFixType=numerictype2pirtype(blockInfo.CoefficientsDataType);
    coeffDPType=getDataPathType(coeffFixType,false,numChannels);


    extraBit=(dataInFixType.Signed~=coeffFixType.Signed);
    productFixType=pir_fixpt_t(...
    dataInFixType.Signed||coeffFixType.Signed,...
    dataInFixType.WordLength+coeffFixType.WordLength+extraBit,...
    dataInFixType.FractionLength+coeffFixType.FractionLength);
    productDPType=getDataPathType(productFixType,isComplex,numChannels);


    inputNT=pirtype2numerictype(dataInFixType);
    [accNT,yNT]=dsphdl.private.HDLFIRRateConverter.getPrecision(...
    polyCoeffsFi,inputNT,blockInfo.OutputDataType);

    accFixType=numerictype2pirtype(accNT);
    accDPType=getDataPathType(accFixType,isComplex,numChannels);

    outputFixType=numerictype2pirtype(yNT);
    outputDPType=getDataPathType(outputFixType,isComplex,numChannels);






    capture=newNet.addSignal(pir_boolean_t,'capture');

    for k=1:delayLineLength
        kstr=num2str(k-1);
        coeffTableOut(k)=newNet.addSignal(coeffFixType,['coeffTableOut',kstr]);%#ok<AGROW>
        coeffVec(k)=newNet.addSignal(coeffDPType,['coeffVec',kstr]);%#ok<AGROW>
        coeffReg(k)=newNet.addSignal(coeffDPType,['coeffReg',kstr]);%#ok<AGROW>        
        coeffMultPipe(k)=newNet.addSignal(coeffDPType,['coeffMultPipe',kstr]);%#ok<AGROW>
        tap(k)=newNet.addSignal(dataInType,['tap',kstr]);%#ok<AGROW>
        tapReg(k)=newNet.addSignal(dataInType,['tapReg',kstr]);%#ok<AGROW>
        tapMultPipe(k)=newNet.addSignal(dataInType,['tapMultPipe',kstr]);%#ok<AGROW>
        product(k)=newNet.addSignal(productDPType,['product',kstr]);%#ok<AGROW>
        productPipe(k)=newNet.addSignal(productDPType,['productPipe',kstr]);%#ok<AGROW>
        adderInput(k)=newNet.addSignal(accDPType,['adderInput',kstr]);%#ok<AGROW>
    end


    acc=newNet.addSignal(accDPType,'acc');


    y=newNet.addSignal(outputDPType,'y');






    dataOut.SimulinkRate=dataRate;
    validOut.SimulinkRate=dataRate;


    pirelab.getBitwiseOpComp(newNet,[request,phaseValid],capture,'AND');


    unitDelayIn=data;




    for k=1:delayLineLength

        kstr=num2str(k-1);


        pirelab.getUnitDelayEnabledComp(newNet,unitDelayIn,tap(k),...
        dataValid,['tapInst',kstr]);

        unitDelayIn=tap(k);

        this.getSimpleLookupComp(newNet,phase,coeffTableOut(k),polyCoeffsFi(:,k),...
        ['coeffTableInst',kstr],['coefficient table for tap ',kstr]);

        if numChannels==1

            coeff=coeffTableOut(k);
        else

            pirelab.getMuxComp(newNet,repmat(coeffTableOut(k),1,numChannels),coeffVec(k));
            coeff=coeffVec(k);
        end



        pirelab.getUnitDelayEnabledComp(newNet,coeff,coeffReg(k),capture,...
        ['coeffRegInst',kstr]);
        pirelab.getUnitDelayEnabledComp(newNet,tap(k),tapReg(k),capture,...
        ['tapRegInst',kstr]);


        pirelab.getIntDelayEnabledComp(newNet,coeffReg(k),coeffMultPipe(k),request,2,...
        ['productPipeInst',kstr]);
        pirelab.getIntDelayEnabledComp(newNet,tapReg(k),tapMultPipe(k),request,2,...
        ['productPipeInst',kstr]);


        pirelab.getMulComp(newNet,[coeffMultPipe(k),tapMultPipe(k)],product(k),...
        'Floor','Wrap',['multInst',kstr]);


        pirelab.getIntDelayEnabledComp(newNet,product(k),productPipe(k),request,2,...
        ['productPipeInst',kstr]);


        pirelab.getDTCComp(newNet,productPipe(k),adderInput(k),'Floor','Wrap');

    end


    elaborateAdderTree(newNet,adderInput,request,acc);


    pirelab.getDTCComp(newNet,acc,y,blockInfo.RoundingMethod,blockInfo.OverflowAction);


    pirelab.getUnitDelayEnabledComp(newNet,y,dataOut,request,'outputRegInst');



    validPipeLength=1+4+ceil(log2(delayLineLength))+1;


    pirelab.getIntDelayEnabledComp(newNet,phaseValid,validOut,request,...
    validPipeLength,'validOutPipeInst');


    for k=1:length(newNet.Signals)
        newNet.Signals(k).SimulinkRate=dataRate;
    end

end





function elaborateAdderTree(hN,terms,enable,sumOut)

    numStages=ceil(log2(length(terms)));


    termsIn=terms;


    for ks=1:numStages

        numTerms=length(termsIn);
        numAdders=floor(numTerms/2);
        spareTerm=mod(numTerms,2);


        termsOut=termsIn(1:numAdders+spareTerm);


        for ka=1:numAdders

            name=['sumStage',num2str(ks-1),'Term',num2str(ka-1)];


            adderOut=hN.addSignal(sumOut.Type,name);
            pirelab.getAddComp(hN,termsIn(2*ka-1:2*ka),adderOut,'Floor','Wrap');


            termsOut(ka)=hN.addSignal(adderOut.Type,name);
            pirelab.getUnitDelayEnabledComp(hN,adderOut,termsOut(ka),...
            enable,[name,'RegInst']);

        end


        if spareTerm


            name=['sumStage',num2str(ks-1),'Term',num2str(numAdders)];
            termsOut(numAdders+1)=hN.addSignal(sumOut.Type,name);
            pirelab.getUnitDelayEnabledComp(hN,termsIn(numTerms),termsOut(numAdders+1),...
            enable,[name,'RegInst']);

        end


        termsIn=termsOut;

    end


    pirelab.getWireComp(hN,termsIn(1),sumOut);

end






function dataPathType=getDataPathType(baseFixType,isComplex,numChannels)

    if isComplex
        dataPathBaseType=pir_complex_t(baseFixType);
    else
        dataPathBaseType=baseFixType;
    end

    if numChannels==1
        dataPathType=dataPathBaseType;
    else
        dataPathType=pirelab.getPirVectorType(dataPathBaseType,numChannels,false);
    end

end





function pirt=numerictype2pirtype(nt)

    pirt=pir_fixpt_t(nt.SignednessBool,nt.WordLength,-nt.FractionLength);
end





function nt=pirtype2numerictype(pirt)

    nt=numerictype(pirt.Signed,pirt.WordLength,-pirt.FractionLength);
end
