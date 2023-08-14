function[hC,status]=getMegaFunctionCompFPF(functor,args)



    targetCompInventory=args{1};
    hN=args{2};
    hInSignals=args{3};
    hOutSignals=args{4};
    className=args{5};
    latencyFreq=args{6};
    isFreqDriven=args{7};
    dryRun=isempty(hN);

    if(length(args)>7)
        additionalArgs=args(8:end);
    else
        additionalArgs={};
    end

    hC=[];

    if(~targetmapping.isValidDataType(hInSignals(1).Type)&&...
        ~targetmapping.isValidDataType(hOutSignals(1).Type))
        return;
    end
    [~,inType]=pirelab.getVectorTypeInfo(hInSignals(1));
    [~,outType]=pirelab.getVectorTypeInfo(hOutSignals(1));


    deviceInfo=hdlgetdeviceinfo;

    [altMegaFunctionName,extraDir,status]=functor(targetCompInventory,inType,outType,className,latencyFreq,isFreqDriven,dryRun,deviceInfo,additionalArgs{:});
    if(~dryRun)
        if(~isempty(altMegaFunctionName))
            if(isFreqDriven)
                assert(status.status==0);
                latency=status.achievedLatency;
            else
                latency=latencyFreq;
            end

            switch(length(hInSignals))
            case{1}
                [hC,numOfInst]=alteratarget.getTargetSpecificInstantiationCompsWithOneInputFPF(hN,hInSignals,hOutSignals,altMegaFunctionName,latency);
            case{2}
                [hC,numOfInst]=alteratarget.getTargetSpecificInstantiationCompsWithTwoInputsFPF(hN,hInSignals,hOutSignals,altMegaFunctionName,latency);
            case{3}
                [hC,numOfInst]=alteratarget.getTargetSpecificInstantiationCompsWithThreeInputsFPF(hN,hInSignals,hOutSignals,altMegaFunctionName,latency);
            otherwise
                assert(false);
            end

            targetCompInventory.add(altMegaFunctionName,altMegaFunctionName,latencyFreq,isFreqDriven,extraDir,numOfInst);

            targetcodegen.alteradspbadriver.setDSPBALibSynthesisScriptsNeeded(true);
        end
    end

