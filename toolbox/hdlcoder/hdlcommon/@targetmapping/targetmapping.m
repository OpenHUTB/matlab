
classdef targetmapping<handle

    methods(Static)
        flag=mode(hSignals,platform)
        [isSupportedFloat,dataType,isSingleType,isDoubleType,isHalfType]=isValidDataType(type)
        flag=hasFloatingPointPort(hC)
        flag=hasComplexType(type)
        muxOutSignal=muxInputSignal(hN,inputSignal,dimLen,compName)
        vectorConcatOutSignal=getVectorConcatComp(hN,inputSignal,outputSignal,compName)
        newInputSignals=makeInputsUniformInDimension(hN,hInSignals,compName)
        newInputSignals=makeInputSameDimensionAsOutput(hN,hInSignals,hOutSignals,compName)
        comp=getCompareToValueComp(hN,hInSignals,hSignalsOut,opName,constVal,compName,nfpOptions)
        hSig=getCompareToZero(hN,hInSignal,opName,outSigName,compName)
        satComp=getSaturateComp(hN,hInSignals,hOutSignals,lowerLimit,upperLimit,name)
        satComp=getSaturationDynamicComp(hN,hInSignals,hOutSignals,name);
        adderComp=getTwoInputAddComp(hN,hInSignals,hOutSignals,rndMode,satMode,compName,...
        accumType,inputSigns,desc,slbh,nfpOptions)
        mulComp=getTwoInputMulComp(hN,hInSignals,hOutSignals,rndMode,satMode,compName,...
        inputSigns,desc,slbh,nfpOptions)
        gainComp=getGainComp(hN,hInSignals,hOutSignals,gainFactor,gainMode,constMultiplierOptimMode,...
        roundMode,satMode,compName,gainParamGeneric,isPowerOfTwo,TunableParamStr,TunableParamType,...
        nfpOptions,matMulKind)
        relopComp=getRelOpComp(hN,hSignalsIn,hSignalsOut,opName,sameDT,compName,desc,slHandle)
        satComp=getNFPSaturateComp(hN,hInSignals,hOutSignals,lowerLimit,upperLimit,name)
        satComp=getNFPSaturationDynamicComp(hN,hInSignals,hOutSignals,name)
    end
end
