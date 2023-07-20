function dtcComp=getDTCComp(hN,hInSignals,hOutSignals,...
    roundMode,satMode,conversionMode,compName,desc,slbh,nfpOptions)



















    if nargin<10
        nfpOptions.Latency=int8(0);
        nfpOptions.MantMul=int8(0);
        nfpOptions.Denormals=int8(0);
    end

    if nargin<9
        slbh=-1;
    end

    if nargin<8
        desc='';
    end

    if(nargin<7)
        compName='dtc';
    end

    if(nargin<6)
        conversionMode='RWV';
    end

    if(nargin<5)
        satMode='Wrap';
    end

    if(nargin<4)
        roundMode='Floor';
    end
    nfpMode=targetcodegen.targetCodeGenerationUtils.isNFPMode;
    hInSigs=hInSignals;
    hOutSigs=hOutSignals;
    if iscell(hOutSignals)
        hOutSigs=hOutSignals{:};
    end
    if iscell(hInSignals)
        hInSigs=hInSignals{:};
    end

    if nfpMode&&hInSigs.Type.BaseType.isFloatType&&...
        hOutSigs.Type.BaseType.isBooleanType




        outType=hOutSigs.Type;
        dlen=outType.getDimensions;
        wordLength=hInSigs.Type.BaseType.WordLength;
        bitsSigType=pirelab.getPirVectorType(hdlcoder.tp_unsigned(wordLength),dlen);
        bitsSig=hN.addSignal(bitsSigType,[compName,'_toBits']);
        bitsSig.SimulinkRate=hInSigs(1).SimulinkRate;
        pirelab.getNFPReinterpretCastComp(hN,hInSigs,bitsSig,[compName,'_reinterpret']);

        mantAndExpSigType=pirelab.getPirVectorType(hdlcoder.tp_unsigned(wordLength-1),dlen);
        mantAndExpSig=hN.addSignal(mantAndExpSigType,[compName,'_expAndMant']);
        mantAndExpSig.SimulinkRate=hInSigs(1).SimulinkRate;
        pirelab.getBitSliceComp(hN,bitsSig,mantAndExpSig,wordLength-2,0,[compName,'_getExpAndMant']);


        dtcComp=pirelab.getCompareToValueComp(hN,mantAndExpSig,hOutSigs,'~=',0,compName);
    elseif hInSigs.Type.BaseType.isEnumType


        inputmode=1;dataPortOrder='Specify indices';
        dataPortForDefault='Last data port';
        diagForDefaultErr=true;
        codingStyle='case_stmt';

        outType=hOutSigs.Type;
        enumTypeInSignal=hInSigs.Type.BaseType;
        enumName=enumTypeInSignal.Name;
        enumArray=enumeration(enumName);
        numInputs=numel(enumArray);
        portSel=enumArray;


        temp=hN.addSignal(enumTypeInSignal,enumName);
        temp.SimulinkRate=hInSigs(1).SimulinkRate;


        dmux_comp=pirelab.getDemuxComp(hN,hInSignals,temp,'Demux');
        hDemuxOutSigs=dmux_comp.PirOutputSignals;
        enumVectorLength=length(hDemuxOutSigs);

        mswitchOut=hdlhandles(enumVectorLength,1);
        dtcSigned32toOutput=hdlhandles(enumVectorLength,1);
        inputSignalsToSwitch=hdlhandles(numInputs,1);
        dtcDataOut=hdlhandles(enumVectorLength,1);
        signedType=pir_fixpt_t(1,32,0);
        outputType=outType.BaseType;


        for j=1:1:enumVectorLength
            inputArrayToSwitch=hDemuxOutSigs(j);
            dtcDataOut(j)=hN.addSignal(outType.BaseType,'dtcDataOut(j)');
            dtcDataOut(j).SimulinkRate=hInSigs(1).SimulinkRate;


            for i=1:1:numInputs
                inputSignalsToSwitch(i)=hN.addSignal(signedType,'inputSignalsToSwitch(i)');
                inputSignalsToSwitch(i).SimulinkRate=hInSigs(1).SimulinkRate;
            end

            for i=1:1:numInputs
                pirelab.getConstComp(hN,inputSignalsToSwitch(i),enumTypeInSignal.EnumValues(i),'inputSignalsToSwitch(i)');
            end



            if~hOutSigs.Type.BaseType.isFloatType
                for i=1:1:numInputs
                    dtcSigned32toOutput(i)=hN.addSignal(outputType,'dtcSigned32toOutput(i)');
                    dtcSigned32toOutput(i).SimulinkRate=hInSigs(1).SimulinkRate;
                end

                for i=1:1:numInputs
                    pirelab.getDTCComp(hN,inputSignalsToSwitch(i),dtcSigned32toOutput(i),...
                    roundMode,satMode,'RWV','dtc',desc,slbh,nfpOptions);
                    inputArrayToSwitch(:,end+1)=dtcSigned32toOutput(i);
                end
            else
                for i=1:1:numInputs
                    inputArrayToSwitch(:,end+1)=inputSignalsToSwitch(i);
                end

            end




            if hOutSigs.Type.BaseType.isFloatType
                mswitchOut(j)=hN.addSignal(signedType,'mswitchOut(j)');
                mswitchOut(j).SimulinkRate=hInSigs(1).SimulinkRate;

                dtcComp=pirelab.getMultiPortSwitchComp(hN,inputArrayToSwitch,mswitchOut(j),...
                inputmode,dataPortOrder,roundMode,satMode,...
                'MultiportSwitch',portSel,dataPortForDefault,numInputs,nfpOptions,diagForDefaultErr,codingStyle);

                pirelab.getDTCComp(hN,mswitchOut(j),dtcDataOut(j),...
                roundMode,satMode,'RWV','dtc',desc,slbh,nfpOptions);
            else

                dtcComp=pirelab.getMultiPortSwitchComp(hN,inputArrayToSwitch,dtcDataOut(j),...
                inputmode,dataPortOrder,roundMode,satMode,...
                'MultiportSwitch',portSel,dataPortForDefault,numInputs,nfpOptions,diagForDefaultErr,codingStyle);

            end

            if(j==enumVectorLength)
                pirelab.getMuxComp(hN,dtcDataOut(1:end),hOutSignals,'Mux');
            end
        end

    elseif hOutSigs.Type.BaseType.isEnumType


        outType=hOutSigs.Type;
        enumOutBaseType=outType.BaseType;
        enumName=enumOutBaseType.Name;
        numEnumValues=length(enumOutBaseType.EnumValues);
        enumValues=enumeration(enumName);
        dlen=outType.getDimensions;
        temp=hdlhandles(numEnumValues,1);

        for i=1:1:numEnumValues
            temp(i)=hN.addSignal(outType,[enumName,'_',num2str(i)]);
            temp(i).SimulinkRate=hInSignals(1).SimulinkRate;
        end

        for i=1:1:numEnumValues
            pirelab.getConstComp(hN,temp(i),enumValues(i),[enumName,'_',num2str(i)]);
        end


        opName='==';
        compareStr='>';
        compareVal=0;
        booleanBaseType=pir_boolean_t;

        boolOut=hdlhandles(numEnumValues-1,1);
        switchOut=hdlhandles(numEnumValues-1,1);

        inputInt=hInSigs(1);




        for j=1:1:numEnumValues-1
            constVal(j)=enumOutBaseType.EnumValues(j);
            booleanType=pirelab.getPirVectorType(booleanBaseType,dlen);
            boolOut(j)=hN.addSignal(booleanType,'boolOut(j)');
            boolOut(j).SimulinkRate=hInSigs(1).SimulinkRate;
            pirelab.getCompareToValueComp(hN,inputInt,boolOut(j),opName,constVal(j),'CompareToValue',nfpOptions);
        end


        for k=1:1:numEnumValues-2
            switchOut(k)=hN.addSignal(outType,'switchOut(k)');
            switchOut(k).SimulinkRate=hInSigs(1).SimulinkRate;
        end


        inputsToSwitch=[temp(numEnumValues-1),temp(numEnumValues)];


        for m=numEnumValues-2:-1:1
            pirelab.getSwitchComp(hN,inputsToSwitch,switchOut(m),boolOut(m+1),...
            'Switch',compareStr,compareVal);
            if(m-1==0)
                inputSig=[temp(m),switchOut(m)];
                break;
            else
                inputsToSwitch=[temp(m),switchOut(m)];
            end

        end


        dtcComp=pirelab.getSwitchComp(hN,inputSig,hOutSignals(1),boolOut(1),...
        'Switch',compareStr,compareVal);


    else
        dtcComp=pircore.getDTCComp(hN,hInSignals,hOutSignals,...
        roundMode,satMode,conversionMode,compName,desc,slbh,nfpOptions);
    end

    if~hInSigs.Type.isComplexType&&hOutSigs.Type.isComplexType


        dtcComp=pirelab.convertReal2Complex(hN,hOutSigs,false,compName);
    end

end
