function unitCapacitanceStage=discreteTimeCapacitor(aNumerator,aDenominator,bNumerator,bDenominator,cNumerator,cDenominator,...
    gNumerator,gDenominator,architecture,order,Vref,numberLevel,OSR,Vin,capacitorDensity,capacitanceCoefficient,SNR)





    k=1.38065E-23;
    T=300;
    processMatch=[0.2,0.4];


    if rem(order,2)==1
        processMatchStage=[processMatch(1),ones(1,order-1)*processMatch(2)];
    else
        processMatchStage=[ones(1,2)*processMatch(1),ones(1,order-2)*processMatch(2)];
    end


    limitMatchCapacitor=(capacitanceCoefficient./processMatchStage).^2.*capacitorDensity*10^(-15);


    minProcessCapacitance=8*8*capacitorDensity/10^15;

    maxSignal=Vin;
    inputPower=(maxSignal)^2/2;

    architectureLast=upper(architecture(3:4));

    switch architectureLast
    case 'FB'
        aNumeratorNew=aNumerator;
        aDenominatorNew=aDenominator;
        bNumeratorNew=bNumerator(1:order);
        bDenominatorNew=bDenominator(1:order);
        cNumeratorNew=[0,cNumerator(1:(order-1))];
        cDenominatorNew=[0,cDenominator(1:(order-1))];
        SamplingCapCoeff=[bNumerator(1),cNumerator(1:order-1)];
    case 'FF'
        cNumeratorNew=cNumerator;
        cDenominatorNew=cDenominator;
        aNumeratorNew=zeros(1,order);
        aDenominatorNew=ones(1,order);
        bNumeratorNew=bNumerator(1:order);
        bDenominatorNew=bDenominator(1:order);
        SamplingCapCoeff=cNumerator;
    otherwise
        unitCapacitanceStage=0;
    end

    gNumeratorNew=zeros(1,order);
    gDenominatorNew=ones(1,order);
    if rem(order,2)==0
        g_index=1;
    else
        g_index=0;
    end
    for i=1:length(gNumerator)
        gNumeratorNew(2*i-g_index)=gNumerator(i);
        gDenominatorNew(2*i-g_index)=gDenominator(i);
    end

    samplingCapacitor=[];
    noisePower=inputPower/10^(SNR/10);


    noisePowerFraction1=noisePower*OSR;
    SNR=10*log10(inputPower*OSR/noisePowerFraction1);
    SNR=real(SNR)-10*log10(0.7);
    switch architectureLast
    case 'FB'
        for i=1:order
            stageSNR=SNR-(i-1)*(10*log10((OSR)^(1/order)));
            kTCNoise=inputPower*OSR/10^(stageSNR/10);
            if i==1
                a=Vref*(numberLevel-1)*aNumeratorNew(i)/aDenominatorNew(i);
                b=bNumeratorNew(i)/bDenominatorNew(i);
                g=gNumeratorNew(i)/gDenominatorNew(i);
                samplingCapacitor(i)=4*k*T/kTCNoise*(1+a/b+g/b);
            else
                a=Vref*(numberLevel-1)*aNumeratorNew(i)/aDenominatorNew(i);
                b=bNumeratorNew(i)/bDenominatorNew(i);
                c=cNumeratorNew(i)/cDenominatorNew(i);
                g=gNumeratorNew(i)/gDenominatorNew(i);
                samplingCapacitor(i)=4*k*T/kTCNoise*(1+a/c+g/c+b/c);
            end

        end

    case 'FF'
        for i=1:order
            stageSNR=SNR-(i-1)*(10*log10((OSR)^(1/order)));
            kTCNoise=inputPower*OSR/10^(stageSNR/10);
            if i==1
                a=aNumeratorNew(i)/aDenominatorNew(i);
                b=bNumeratorNew(i)/bDenominatorNew(i);
                c=Vref*(numberLevel-1)*cNumeratorNew(i)/cDenominatorNew(i);
                g=gNumeratorNew(i)/gDenominatorNew(i);
                samplingCapacitor(i)=4*k*T/kTCNoise*(1+c/b+g/b);
            else
                a=aNumeratorNew(i)/aDenominatorNew(i);
                b=bNumeratorNew(i)/bDenominatorNew(i);
                c=cNumeratorNew(i)/cDenominatorNew(i);
                g=gNumeratorNew(i)/gDenominatorNew(i);
                samplingCapacitor(i)=4*k*T/kTCNoise*(1+g/c+b/c);


            end
        end

    end

    unitCapacitance=(floor(samplingCapacitor./SamplingCapCoeff*10^15)+1)/10^15;
    unitCapacitanceStage=max(minProcessCapacitance*ones(1,order),unitCapacitance);
    unitCapacitanceStage=max(unitCapacitanceStage,limitMatchCapacitor);

    for i=1:order-1
        if gNumeratorNew(i)
            unitCapacitanceStage(i+1)=max(unitCapacitanceStage(i)/2,unitCapacitanceStage(i+1));
        end
    end