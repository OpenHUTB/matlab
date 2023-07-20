



classdef pircore<handle










    methods(Static)




        hC=getAddComp(hN,hInSignals,hOutSignals,rndMode,satMode,...
        compName,accumType,inputSigns,desc,slbh,nfpOptions)
        hC=getSubComp(hN,hInSignals,hOutSignals,rndMode,satMode,compName,accumType)
        hC=getMulComp(hN,hInSignals,hOutSignals,rndMode,satMode,...
        compName,inputSigns,desc,slbh,dspMode,nfpOptions,mulKind,matMulKind)
        hC=getScalarMACComp(hN,hInSignals,hOutSignals,rndMode,ovMode,compName,desc,slbh,hwModeLatency,adderSign,nfpOptions,fused)
        hC=getVectorMACComp(hN,hInSignals,hOutSignals,rndMode,ovMode,compName,desc,slbh,initialValue,elabMode)
        hC=getStreamingMACComp(hN,hInSignals,hOutSignals,rndMode,compName,InitValueSetting,initValue,numberOfSamples,opMode,...
        Cbox_ValidOut,Cbox_EndInAndOut,Cbox_StartOut,Cbox_CountOut,PortInString,PortOutString)
        hC=getReciprocalComp(hN,hInSignals,hOutSignals,newtonInfo,slbh,nfpOptions)
        hC=getRecipSqrtNewtonComp(hN,hInSignals,hOutSignals,newtonInfo,slbh)
        hC=getSqrtNewtonComp(hN,hInSignals,hOutSignals,newtonInfo,slbh)
        hC=getGainComp(hN,hInSignals,hOutSignals,gainFactor,gainMode,constMultiplierOptimMode,...
        roundMode,satMode,compName,dspMode,TunableParamStr,TunableParamType,nfpOptions,matMulKind)

        hC=getMinMaxComp(hN,hInSignals,hOutSignals,compName,opName,isDSPBlk,outputMode,isOneBased,desc,slbh,nfpOptions)

        hC=getAbsComp(hN,hInSignals,hOutSignals,roundingMode,satMode,compName)
        hC=getUnaryMinusComp(hN,hInSignals,hOutSignals,satMode,compName)
        hC=getAssignmentComp(hN,hInputSignals,hOutputSignals,oneBasedIdx,ndims,idxParamArray,...
        idxOptionsArray,outputSizeArray,compName)
        hC=getSignToNumComp(hN,hInSignals,hOutSignals,compName)
        hC=getSaturateComp(hN,hInSignals,hOutSignals,lowerLimit,upperLimit,rndMeth,compName)
        hC=getSaturateDynamicComp(hN,hInSignals,hOutSignals,rndMode,satMode,compName)
        hC=getDeadZoneComp(hN,hInSignals,hOutSignals,lowerLimit,upperLimit,compName)
        hC=getDeadZoneDynamicComp(hN,hInSignals,hOutSignals,compName)
        hC=getBacklashComp(hN,hInSignals,hOutSignals,backlashWidth,initialOutput,compName)
        hC=getHitCrossComp(hN,hInSignals,hOutSignals,hcOffset,hcDirectionMode,compName)

        hC=getIncrementSI(hN,hInSignals,hOutSignals,compName)
        hC=getIncrementRWV(hN,hInSignals,hOutSignals,compName)
        hC=getDecrementSI(hN,hInSignals,hOutSignals,compName)
        hC=getDecrementRWV(hN,hInSignals,hOutSignals,compName)
        hC=getDecToZeroRWVComp(hN,hC,hInSignals,hOutSignals,name)
        hC=getSqrtComp(hN,hInSignals,hOutSignals,compName,slbh,fname,nfpOptions)
        hC=getMathComp(hN,hInSignals,hOutSignals,compName,slbh,fname,nfpOptions)
        hC=getTrigonometricComp(hN,hInSignals,hOutSignals,compName,slbh,fname,nfpOtions)
        hC=getComplexConjugateComp(hN,slbh,hInSignals,hOutSignals,satMode,compName,rndMode)
        hC=getTransposeComp(hN,hInSignals,hOutSignals,compName);
        hC=getHermitianComp(hN,hInSignals,hOutSignals,satMode,compName);
        hC=getRoundingFunctionComp(hN,hInSignals,hOutSignals,op,compName,nfpOptions);




        hC=getDTCComp(hN,hInSignals,hOutSignals,rndMode,satMode,convMode,...
        compName,desc,slbh,nfpOptions)




        hC=getBitSliceComp(hN,hInSignals,hOutSignals,msbPos,lsbPos,compName)
        hC=getBitConcatComp(hN,hInSignals,hOutSignals,compName)
        hC=getBitReduceComp(hN,hInSignals,hOutSignals,opName,compName)
        hC=getBitRotateComp(hN,hInSignals,hOutSignals,opName,rotateLength,compName)
        hC=getBitShiftComp(hN,hInSignals,hOutSignals,opName,shiftLength,shiftBinPtLength,compName)
        hC=getDynamicBitShiftComp(hN,hInSignals,hOutSignals,shift_mode,compName)
        hC=getLibBitShiftComp(hN,hInSignals,hOutSignals,opName,shiftLength,compName)
        hC=getBitwiseOpComp(hN,hSignalsIn,hSignalsOut,opName,compName,useBitMask,bitMask,isBitMaskZero)
        hC=getBitSetComp(hN,hInSignals,hOutSignals,isBitSet,bitIndex,compName,useBitMask)
        hC=getBitExtractComp(hN,hInSignals,hOutSignals,ul,ll,mode,compName)





        hC=getRelOpComp(hN,hSignalsIn,hSignalsOut,compName,op,sameDT,desc,slHandle,nfpOptions)
        hC=getCompareToValueComp(hN,hSignalsIn,hSignalsOut,opName,constVal,compName,isConstZero)
        hC=getLogicComp(hN,hInSignals,hOutSignals,op,compName,desc,slHandle)

        hOutSignal=getCompareToZero(hN,hSignal,opName,outSigName,compName)




        hC=getConcatenateComp(hN,hInSignals,hOutSignals,mode,dim,compName,shouldDrawOverride);
        hC=getReshapeComp(hN,hInSignals,hOutSignals,outDimType,outDims,compName)
        hC=getMuxComp(hN,hInSignals,hOutSignals,compName)
        hC=getDemuxComp(hN,hInSignals,hOutSignals,compName)
        hC=getWireComp(hN,hInSignals,hOutSignals,compName,desc,slHandle)
        hC=getNFPReinterpretCastComp(hN,hInSignals,hOutSignals,compName,desc,slHandle)
        hC=getRepeatComp(hN,hInSignals,hOutSignals,repetitionCount,compName,desc,slHandle)
        hC=getDemuxCompOnInput(hN,hInSignal)
        hC=getMultiPortSwitchComp(hN,hInSignals,hOutSignals,inputmode,...
        zeroBasedIndex,rndMode,satMode,compName,portSel,dpForDefault,diagForDefaultErr,codingStyle)
        hC=getSelectorComp(hN,hInSignals,hOutSignals,indexMode,indexOptionArray,...
        indexParamArray,outputSizeArray,numDims,compName)
        hC=getMultiportSelectorComp(hN,hInSignals,hOutSignals,rowsOrCols,...
        idxCellArray,idxErrMode,compName)
        hC=getVariableSelectorComp(hN,hInputSignals,hOutputSignals,...
        zerOneIdxMode,idxMode,elements,fillValues,rowsOrCols,numInputs,...
        compName)
        hC=getSplitComp(hN,hInputSignals,hOutputSignals,compName)


        demuxOutputs=demuxSignal(hN,hInSignal)

        hC=getHardwareDemuxComp(hN,hInSignals,hOutSignals,compName)

        hC=getBusCreatorComp(hN,hInSignals,hOutSignals,busTypeStr,nonVirtualBus,compName)
        hC=getBusSelectorComp(hN,hInSignals,hOutSignals,indexStr,outputIsBus,compName)

        hC=getBustoVectorComp(hN,hInSignals,hOutSignal,compName,slHandle)

        hC=getBusAssignmentComp(hN,hInSignals,hOutSignal,assignedSignals,compName)


        hC=getNFPSparseConstMultiplyComp(hN,hInSignals,hOutSignals,constMatrixSize,...
        constMatrix,latency,sharingFactor,fpDelays,nfpOptions,name)


        hC=getVerbatimTextComp(hN,hC,base_text)




        hC=getComplex2RealImag(hN,hInSignals,hOutSignals,opMode,compName)
        hC=getRealImag2Complex(hN,hInSignals,hOutSignals,inputTypeMode,cval,compName)




        hC=getConstComp(hN,hOutSignals,constValue,compName,vectorParams1D,isConstZero,TunableParamStr,ConstBusName,ConstBusType)
        hC=getCounterLimitedComp(hN,hOutSignals,count_limit,compName)
        hC=getCounterFreeRunningComp(hN,hOutSignals,compName)
        hC=getCounterComp(hN,hInSignals,hOutSignals,type,initval,stepval,maxval,resetport,loadport,enbport,dirport,compName,countFrom)




        hC=getDirectLookupComp(hN,hInSignals,hOutSignals,table_data,compName,slbh,dims,...
        inputsSelectThisObjectFromTable,diagnostics,tableDataType,mapToRAM)
        hC=getPreLookupComp(hN,hInSignals,hOutSignals,bp_data,bpType,kType,fType,idxOnly,...
        powerof2,compName,slbh,diagnostics)
        hC=getLookupNDComp(hN,hInSignals,hOutSignals,table_data,powerof2,bpType,oType,fType,...
        interpVal,bp_data,compName,slbh,dims,rndMode,satMode,diagnostics,extrap,mapToRAM)




        hC=getSwitchComp(hN,inSignals,outSignals,addrSignal,compName,compareStr,compareVal,rndMode,ovMode,desc,slHandle)




        hC=getUnitDelayComp(hN,hInSignals,hOutSignals,compName,ic,resettype,desc,slbh)
        hC=getUnitDelayEnabledComp(hN,hInSignals,hOutSignals,hEnbSignal,compName,ic,resettype,desc,slbh,isSynchronousDelay)
        hC=getUnitDelayEnabledResettableComp(hN,hInSignals,hOutSignals,hEnbSignal,hRstSignal,compName,ic,resettype,softreset,desc,slbh,isSynchronousDelay)
        hC=getUnitDelayResettableComp(hN,hInSignals,hOutSignals,hRstSignal,compName,ic,resettype,softreset,desc,slbh,isSynchronousDelay)
        hC=getIntDelayComp(hN,hSignalsIn,hSignalsOut,delayNumber,compName,ic,resettype,rambased,desc,slbh)
        hC=getIntDelayEnabledResettableComp(hN,hSignalsIn,hSignalsOut,delayNumber,compName,ic,resettype,hEnbSignals,hRstSignals,rambased,desc,slbh)
        hC=getTapDelayComp(hN,hSignalsIn,hSignalsOut,delayNumber,compName,ic,delayorder,includeCurrent,resettype,desc,slbh)
        hC=getTapDelayEnabledComp(hN,hInSignals,hOutSignals,delayNumber,compName,ic,delayorder,includeCurrent,resettype,desc,slbh)
        hC=getTapDelayResettableComp(hN,hInSignals,hOutSignals,delayNumber,compName,ic,delayorder,includeCurrent,resettype,desc,slbh)
        hC=getTapDelayEnabledResettableComp(hN,hInSignals,hOutSignals,delayNumber,compName,ic,delayorder,includeCurrent,resettype,hEnbSignals,hRstSignals,desc,slbh)





        [RamNet,RamNetInstance]=getSinglePortRamComp(hN,hInSignals,hOutSignals,compName,...
        numBanks,bankNo,readNewData,simulinkHandle,RamNet,needWrapper,initialVal,RAMDirective)
        [RamNet,RamNetInstance]=getSimpleDualPortRamComp(hN,hInSignals,hOutSignals,compName,...
        numBanks,bankNo,simulinkHandle,RamNet,ramCorePrefix,needWrapper,initialVal,RAMDirective)
        [RamNet,RamNetInstance]=getDualPortRamComp(hN,hInSignals,hOutSignals,compName,...
        numBanks,bankNo,readNewData,simulinkHandle,RamNet,needWrapper,initialVal,RAMDirective)
        [RamNet,RamNetInstance]=getDualRateDualPortRamComp(hN,hInSignals,hOutSignals,compName,...
        readNewData,simulinkHandle,RamNet,needWrapper)




        hC=getRateTransitionComp(hN,hInSignals,hOutSignals,outputRate,initVal,compName,desc,slHandle,integrity,deterministic)
        hC=getUpSampleComp(hN,hInSignal,hOutSignal,upSampleFactor,sampleOffset,initVal,compName,desc,slHandle)
        hC=getDownSampleComp(hN,hInSignal,hOutSignal,downSampleFactor,sampleOffset,initVal,compName,desc,slHandle)




        hC=getSerializerComp(hN,hInSignals,hOutSignals,compName)
        hC=getDeserializerComp(hN,hInSignals,hOutSignals,compName)
        hC=getDataBufferComp(hN,hInSignals,hOutSignals,compName)
        hC=getDataUnbufferComp(hN,hInSignals,hOutSignals,compName)

        hC=getSerializer1DComp(hN,hInSignals,hOutSignals,ratio,idleCycles,validInPort,startOutPort,validOutPort,compName)
        hC=getDeserializer1DComp(hN,hInSignals,hOutSignals,ratio,idleCycles,initVal,startInPort,validInPort,validOutPort,compName)



        hC=getFilterComp(hN,hInSignals,hOutSignals,hImpl,hFiltObj,compName,slHandle)




        hC=getMegaFunctionComp(hN,name,inputSignals,outputSignals,...
        entityName,inportNames,outportNames,clkNames,ceNames,ceclrNames,latency,...
        slbh);




        hC=getDspbaComp(hN,name,inputSignals,outputSignals,...
        entityName,inportNames,outportNames,clkNames,ceNames,ceclrNames,busInputPortNames,busInputPortWidths,busReadEnablePortNames,...
        rates,baseRate,blackBoxAttributes,vhdlComponentLibrary,...
        slbh);




        hC=getXsgComp(hN,name,inputSignals,outputSignals,...
        entityName,inportNames,outportNames,clkNames,ceNames,ceclrNames,...
        rates,baseRate,hasDownSample,blackBoxAttributes,vhdlComponentLibrary,...
        slbh);

        hC=getXsgVivadoComp(hN,name,inputSignals,outputSignals,...
        entityName,inportNames,outportNames,clkNames,ceNames,ceclrNames,...
        rates,baseRate,hasDownSample,blackBoxAttributes,vhdlComponentLibrary,...
        slbh);




        hC=getTBClockgenComp(hN,hInSignal,hClockSignal,highTime,lowTime)
        hC=getTBCheckerComp(hN,hInSignals,hOutSignals)
        hC=getTBCompletionComp(hN,hInSignals,extraMsgStr)
        hC=getTBCounterModComp(hN,hInSignal,hOutSignal,modValue)
        hC=getTBFileReaderComp(hN,hInSigs,hOutSigs,fileName,compName)
        hC=getTBPackageComp(hN)
        hC=getTBToHexComp(hN,hT)
        hC=getTBResetgenComp(hN,hInSignal,hResetSignal,tResetHold)
        hC=getTBStimulusSwitchComp(hN,hInSignals,hOutSignal,hSelSignal,compName)
        hC=getTBTimeDelayComp(hN,hInSignal,hOutSignal,timeDelay,compName)




        hC=getAssertionComp(hN,hSignalsIn,compName,label,enabled,assertFailFcn,stopSimulation)




        hC=getNilComp(hN,hInSignals,hOutSignals,compName,desc,slHandle)






        [RamNet,RamComp]=getRAMBasedShiftRegisterComp(hN,hSignalsIn,hSignalsOut,...
        delayNumber,thresholdSize,compName,ramName,RamNet)





        [isReset,initValScalarExpandable,ic,preserveInitValDimensions]=processDelayIC(ic)
        setRAMNetworkFlags(ramNIC,ramComp)
    end
end


