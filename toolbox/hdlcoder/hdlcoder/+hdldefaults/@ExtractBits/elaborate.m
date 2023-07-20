function hNewC=elaborate(this,hN,hC)




    [ul,ll,mode]=this.getBlockInfo(hC.SimulinkHandle,hC);





    if hasDoubleType(hC)
        hNewC=addWireComp(hC,hN);
    elseif accessingUndefinedBits(hC,ul,ll)
        hNewC=replicateExtractBitsNative(hC,hN);
    else
        hNewC=pirelab.getBitExtractComp(hN,hC.PirInputSignals,hC.PirOutputSignals,ul,ll,mode,hC.Name);
    end

end


function dbl=hasDoubleType(hC)

    hCOutSignal=hC.SLOutputSignals(1);
    hOutBT=hCOutSignal.Type.getLeafType;
    dbl=hOutBT.isFloatType();

end


function invalidExtract=accessingUndefinedBits(hC,upperBound,lowerBound)

    hCInSignal=hC.SLInputSignals(1);
    hCOutSignal=hC.SLOutputSignals(1);

    hInBT=hCInSignal.Type.getLeafType;
    hOutBT=hCOutSignal.Type.getLeafType;

    numInBits=hInBT.WordLength;
    numOutBits=hOutBT.WordLength;

    sliceLen=upperBound-lowerBound+1;

    invalidExtract=hOutBT.isNumericType&&...
    (upperBound>numInBits-1||...
    lowerBound<0||...
    upperBound<lowerBound||...
    numOutBits>numInBits||...
    sliceLen~=numOutBits);

end


function hNewC=addWireComp(hC,hN)

    hCInSignal=hC.SLInputSignals(1);
    hCOutSignal=hC.SLOutputSignals(1);

    hNewC=pirelab.getWireComp(hN,hCInSignal,hCOutSignal);

end


function hNewC=replicateExtractBitsNative(hC,hN)

    hCInSignal=hC.SLInputSignals(1);
    hCOutSignal=hC.SLOutputSignals(1);

    fullPath=getfullname(hC.SimulinkHandle);

    dtc1Name=[fullPath,'/','Extract Desired Bits'];

    dtc1_TypeInfo=get_param(dtc1Name,'CompiledPortDataTypes');
    dtc1_OutBaseType=pirelab.convertSLType2PirType(dtc1_TypeInfo.Outport{1});

    dtc1_ComplexInfo=get_param(dtc1Name,'CompiledPortComplexSignals');
    dtc1_OutComplexInfo=dtc1_ComplexInfo.Outport(1);
    if dtc1_OutComplexInfo
        dtc1_OutComplexType=pir_complex_t(dtc1_OutBaseType);
    else
        dtc1_OutComplexType=dtc1_OutBaseType;
    end

    if hCInSignal.Type.isArrayType
        dimLen=pirelab.getVectorTypeInfo(hCInSignal);
        dtc1_OutType=pirelab.getPirVectorType(dtc1_OutComplexType,dimLen);
    else
        dtc1_OutType=dtc1_OutComplexType;
    end
    dtc1OutSignal=hN.addSignal(dtc1_OutType,'dtc1');

    hNewC=pirelab.getDTCComp(hN,hCInSignal,dtc1OutSignal,'Floor','Wrap','RWV',sprintf('dtc1_%s',hC.Name));

    pirelab.getDTCComp(hN,dtc1OutSignal,hCOutSignal,'Floor','Wrap','SI',sprintf('dtc2_%s',hC.Name));

end
