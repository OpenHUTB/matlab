

classdef pireml<handle



    methods(Static)




        hC=getAddComp(hN,hInSignals,hOutSignals,rndMode,satMode,...
        compName,accumType,inputSigns,desc,slbh)
        hC=getSubComp(hN,hInSignals,hOutSignals,rndMode,satMode,compName,accumType)
        hC=getMulComp(hN,hInSignals,hOutSignals,rndMode,satMode,compName,inputSigns)
        hC=getReciprocalComp(hN,hInSignals,hOutSignals,newtonInfo)
        hC=getRecipSqrtNewtonComp(hN,hInSignals,hOutSignals,newtonInfo)
        hC=getSqrtNewtonComp(hN,hInSignals,hOutSignals,newtonInfo)

        hC=getGainComp(hN,hInSignals,hOutSignals,gainFactor,gainMode,constMultiplierOptimMode,roundMode,satMode,compName)

        hC=getMinMaxComp(hN,hInSignals,hOutSignals,compName,opName,isDSPBlk,outputMode)

        hC=getAbsComp(hN,hInSignals,hOutSignals,oType_ex,compName)
        hC=getUnaryMinusComp(hN,hInSignals,hOutSignals,oType_ex,compName)

        hC=getIncDecRWV(hN,hInSignals,hOutSignals,mode,compName)
        hC=getIncDecSI(hN,hInSignals,hOutSignals,mode,compName)
        hC=getDecToZeroRWVComp(hN,hC,hInSignals,hOutSignals,name)

        hC=getAssignmentComp(hN,hInputSignals,hOutputSignals,zeroBasedIndex,...
        indexOptions,indices,outLen,compName)
        hC=getSignToNumComp(hN,hInSignals,hOutSignals,compName)
        hC=getSaturateComp(hN,hInSignals,hOutSignals,lowerLimit,upperLimit,rndMeth,compName)
        hC=getSaturateDynamicComp(hN,hInSignals,hOutSignals,rndMode,satMode,compName)
        hC=getDeadZoneComp(hN,hInSignals,hOutSignals,lowerLimit,upperLimit,compName)
        hC=getDeadZoneDynamicComp(hN,hInSignals,hOutSignals,compName)
        hC=getBacklashComp(hN,hInSignals,hOutSignals,backlashWidth,initialOutput,compName)
        hC=getHitCrossComp(hN,hInSignals,hOutSignals,hcOffset,hcDirectionMode,compName)
        hC=getStringLengthComp(hN,hInSignals,hOutSignals,compName,outTpEx);

        hC=getSubStringComp(hN,hInSignals,hOutSignals,compName,outTpEx)





        hC=getDTCComp(hN,hInSignals,hOutSignals,rndMode,satMode,convMode,compName)
        dtcOutSignal=insertDTCCompOnInput(hN,hCInSignal,hCOutType,rndMode,satMode,receivingCompName)
        checkSignalTypeValidity(hSignalType,compName)





        hC=getBitSliceComp(hN,hInSignals,hOutSignals,msbPos,lsbPos,compName)
        hC=getBitConcatComp(hN,hInSignals,hOutSignals,compName)
        hC=getBitReduceComp(hN,hInSignals,hOutSignals,opName,compName)
        hC=getBitRotateComp(hN,hInSignals,hOutSignals,opName,rotateLength,compName)
        hC=getBitShiftComp(hN,hInSignals,hOutSignals,opName,shiftLength,shiftBinPtLength,compName)
        hC=getBitwiseOpComp(hN,hSignalsIn,hSignalsOut,opName,compName,useBitMask,bitMask)
        hC=getBitSetComp(hN,hInSignals,hOutSignals,isBitSet,bitIndex,compName,useBitMask)
        hC=getBitSetByBitMaskComp(hN,hInSignals,hOutSignals,isBitSet,bitIndex,compName)
        hC=getBitSetByConcatComp(hN,hInSignals,hOutSignals,isBitSet,bitIndex,compName)
        hC=getBitExtractComp(hN,hInSignals,hOutSignals,ul,ll,mode,compName)
        hC=getDynamicBitShiftComp(hN,hInSignals,hOutSignals,shift_mode,compName)




        hC=getRelOpComp(hN,hSignalsIn,hSignalsOut,opName,compName)
        hC=getCompareToValueComp(hN,hSignalsIn,hSignalsOut,opName,constVal,compName)
        hC=getLogicComp(hN,hSignalsIn,hSignalsOut,opName,compName)

        hOutSignal=getCompareToZero(hN,hSignal,opName,outSigName,compName)




        hC=getConcatenateComp(hN,hInSignals,hOutSignals,compName)
        hC=getMuxComp(hN,hInSignals,hOutSignals,compName)
        hC=getDemuxComp(hN,hInSignals,hOutSignals,compName)
        hC=getDemuxCompOnInput(hN,hInSignal)
        hC=getWireComp(hN,hInSignals,hOutSignals,compName,desc,slHandle)
        hC=getReshapeComp(hN,hInSignals,hOutSignals,outDimType,outDims,compName)
        hC=getTransposeComp(hN,hInSignals,hOutSignals,compName);



        demuxComp=demuxSignal(hN,hInSignal)

        hC=getHardwareDemuxComp(hN,hInSignals,hOutSignals,compName)




        hC=getComplex2RealImag(hN,hInSignals,hOutSignals,opMode,compName)
        hC=getRealImag2Complex(hN,hInSignals,hOutSignals,inputTypeMode,cval,compName)




        hC=getConstComp(hN,hOutSignals,constValue,compName)
        hC=getCounterLimitedComp(hN,hOutSignal,count_limit,outputRate,compName,ic,limitedCounterOptimize,clkEn)
        hC=getCounterFreeRunningComp(hN,hOutSignal,outputRate,compName,ic,clkEn)
        [hC,hComp]=getCounterComp(varargin)




        hC=getDirectLookupComp(hN,hInSignals,hOutSignals,table_data,compName,diagnostics)
        hC=getPreLookupComp(hN,hInSignals,hOutSignals,bp_data,bpType,kType,fType,idxOnly,powerof2,compName)
        hC=getLookupNDComp(hN,hInSignals,hOutSignals,table_data,powerof2,bpType,oType,fType,interpVal,bp_data,compName)




        hC=getSwitchComp(hN,inSignals,outSignals,addrSignal,compName,...
        compareStr,compareVal)
        hC=getMultiPortSwitchComp(hN,hInSignals,hOutSignal,inputmode,...
        zeroBasedIndex,rndMode,satMode,compName,portSel,codingStyle)
        hC=getSelectorComp(hN,hInSignals,hOutSignals,zeroBasedIndex,...
        indexOptions,indices,outLen,compName)
        hC=getVariableSelectorComp(hN,hInSignals,hOutSignals,zerOneIdxMode,...
        idxMode,elements,fillValues,rowsOrCols,numInputs,compName)
        hC=getMultiportSelectorComp(hN,hInSignals,hOutSignals,rowsOrCols,...
        idxCellArray,compName)




        hC=getUnitDelayComp(hN,hInSignals,hOutSignals,compName,ic,resettype,desc,slbh)
        hC=getUnitDelayEnabledComp(hN,hInSignals,hOutSignals,compName,ic,resettype,desc,slbh)
        hC=getUnitDelayResettableComp(hN,hInSignals,hOutSignals,hRstSignals,compName,ic,resettype,softreset,desc,slHandle)
        hC=getUnitDelayEnabledResettableComp(hN,hInSignals,hOutSignals,hEnbSignals,hRstSignals,compName,ic,resettype,softreset,desc,slHandle)
        hC=getIntDelayComp(hN,hSignalsIn,hSignalsOut,delayNumber,compName,ic,resettype,rambased,desc,slbh)
        hC=getIntDelayRamComp(hN,hSignalsIn,hSignalsOut,delayNumber,compname,resetnone,desc)
        hC=getIntDelayEnabledComp(hN,hSignalsIn,hSignalsOut,delayNumber,compName,ic,resettype,hEnbSignals,desc,slbh)
        hC=getIntDelayEnabledResettableComp(hN,hSignalsIn,hSignalsOut,delayNumber,compName,ic,resettype,hEnbSignals,hRstSignal,desc,slbh)
        hC=getTapDelayComp(hN,hSignalsIn,hSignalsOut,delayNumber,compName,ic,delayorder,includeCurrent,resettype,desc,slbh)
        hC=getTapDelayEnabledResettableComp(hN,hSignalsIn,hSignalsOut,delayNumber,compName,ic,delayorder,includeCurrent,resettype,hEnbSignals,hRstSignal,desc,slbh)
        hC=getBypassRegisterComp(hN,hInSignals,hOutSignals,byPassEnable,clkEnable,compName,ic)





        [RamNet,RamComp]=getRAMBasedShiftRegisterComp(hN,hSignalsIn,hSignalsOut,...
        delayNumber,thresholdSize,compName,resetnone,ramName,RamNet)


        hC=getMemoryComp(hN,hInSignals,hOutSignals,size,directFeedthrough,compName)




        hC=getRateTransitionComp(hN,hInSignals,hOutSignals,outputRate,initVal,extraDelayAvl,compName,integrity,deterministic)
        hC=getUpSampleComp(hN,hInSignal,hOutSignal,upSampleFactor,sampleOffset,initVal,compName,slHandle,desc)
        hC=getDownSampleComp(hN,hInSignal,hOutSignal,downSampleFactor,sampleOffset,initVal,extraDelayAvl,compName,slHandle,desc)




        hC=getAssertionComp()




        hC=getFilterComp(hN,hC,hFilterImpl)





        hC=getSerializerComp(hN,hInSignals,hOutSignals,compName,sleepCycles)
        hC=getDeserializerComp(hN,hInSignals,hOutSignals,compName,sleepCycles)
        hC=getDataBufferComp(hN,hInSignals,hOutSignals,compName)
        hC=getDataUnbufferComp(hN,hInSignals,hOutSignals,ctrInitVal,compName)
        hC=getSerializerSingleRateComp(hN,hInSignals,hOutSignals,compName)

        hC=getSerializer1DComp(varargin)
        hC=getDeserializer1DComp(varargin)




        hC=getCordicAtan2PreQuadCorrectionComp(hN,hInSignals,hOutSignals,oType_ex)
        hC=getCordicAtan2PostQuadCorrectionComp(hN,hInSignals,hOutSignals,oType_ex)
        hC=getCordicAtan2RotationComp(hN,hInSignals,hOutSignals,lut_value,idx)



        hC=getDivNonRestoreIteratorComp(hN,hInSignals,hOutSignals,idx)
        hC=getDivPostCorrectionComp(hN,hInSignals,hOutSignals)
        hC=getDivPreCorrectionComp(hN,hInSignals,hOutSignals)
    end

    methods(Static,Access=private)
        hC=getLookupComp(hN,hInSignals,hOutSignals,compName,emlScript,emlParams)
    end
end

