



classdef pirelab < handle












































methods ( Static )







hC = getAddComp( hN, hInSignals, hOutSignals, rndMode, satMode, compName, accumType,  ...
inputSigns, desc, slbh, nfpOptions, traceComment )



hC = getAddTreeComp( hN, hInSignals, hOutSignals, rndMode, satMode, compName,  ...
accumType, inputSigns, desc, slbh, nfpOptions )

hC = getSubComp( hN, hInSignals, hOutSignals, rndMode, satMode, compName, accumType )


hC = getMulComp( hN, hInSignals, hOutSignals, rndMode, satMode,  ...
compName, inputSigns, desc, slbh, dspMode, nfpOptions, mulKind,  ...
matMulKind, traceComment )
hC = getMatrixMulComp( hN, hInSignals, hOutSignals, rndMode, satMode,  ...
compName, dspMode, nfpOptions, matMulKind, traceComment )
hC = getScalarMatrixMulComp( hN, hInSignals, hOutSignals, rndMode, satMode,  ...
compName, dspMode, nfpOptions, traceComment )
hC = getScalarMACComp( hN, hInSignals, hOutSignals, rndMode, satMode, compName, desc, slbh, hwModeDelays, adderSign, nfpOptions, fused )

hC = getSharedCplxMulComp( hN, horigC, inSigs, hOutSignals, rndMode, satMode, compName, inputSigns, desc, slbh, dspMode )
hC = getVectorMACComp( hN, hInSignals, hOutSignals, rndMode, ovMode, compName, desc, slbh, initialValue, elabMode )
hC = getStreamingMACComp( hN, hInSignals, hOutSignals, rndMode, compName, InitValueSetting, initValue, numberOfSamples, opMode,  ...
Cbox_ValidOut, Cbox_EndInAndOut, Cbox_StartOut, Cbox_CountOut, PortInString, PortOutString )



hC = getReciprocalComp( hN, hInSignals, hOutSignals, newtonInfo, slbh, nfpOptions )


hC = getRecipSqrtNewtonComp( hN, hInSignals, hOutSignals, newtonInfo, slbh )

hC = getRoundingFunctionComp( hN, hInSignals, hOutSignals, op, compName, nfpOptions );



hC = getSqrtNewtonComp( hN, hInSignals, hOutSignals, newtonInfo, slbh )









hC = getGainComp( hN, hInSignals, hOutSignals, gainFactor, gainMode,  ...
constMultiplierOptimMode, roundMode, satMode, compName, dspMode, TunableParamStr, TunableParamType, gainParamGeneric,  ...
nfpOptions, traceComment, matMulKind )








hC = getMinMaxComp( hN, hInSignals, hOutSignals, compName, opName, isDSPBlk,  ...
outputMode, isOneBased, desc, slbh, nfpOptions )


hC = getIncrementSI( hN, hInSignals, hOutSignals, compName )
hC = getIncrementRWV( hN, hInSignals, hOutSignals, compName )
hC = getDecrementSI( hN, hInSignals, hOutSignals, compName )
hC = getDecrementRWV( hN, hInSignals, hOutSignals, compName )
hC = getDecToZeroRWVComp( hN, hInSignals, hOutSignals, compName )
hC = getStringLengthComp( hN, hInSignals, hOutSignals, compName )
hC = getSubStringComp( hN, hInSignals, hOutSignals, compName )


hC = getIncDecRWV( hN, hInSignals, hOutSignals, mode, compName )
hC = getIncDecSI( hN, hInSignals, hOutSignals, mode, compName )




hC = getSaturateComp( hN, hInSignals, hOutSignals, lowerLimit, upperLimit, rndMeth, compName )
hC = getSaturateDynamicComp( hN, hInSignals, hOutSignals, rndMode, satMode, compName )




hC = getDeadZoneComp( hN, hInSignals, hOutSignals, lowerLimit, upperLimit, compName )
hC = getDeadZoneDynamicComp( hN, hInSignals, hOutSignals, compName )

hC = getBacklashComp( hN, hInSignals, hOutSignals, backlashWidth, initialOutput, compName )
hC = getHitCrossComp( hN, hInSignals, hOutSignals, hcOffset, hcDirectionMode, compName )

hC = getAbsComp( hN, hInSignals, hOutSignals, roundingMode, satMode, compName, nfpOptions, isComplex )
hC = getUnaryMinusComp( hN, hInSignals, hOutSignals, satMode, compName )
hC = getSignToNumComp( hN, hInSignals, hOutSignals, compName, slbh, nfpOptions )




hC = getAssignmentComp( hN, hInputSignals, hOutputSignals, oneBasedIdx,  ...
ndims, idxParamArray, idxOptionArray, outputSizeArray, compName );

hC = getTransposeComp( hN, hInSignals, hOutSignals, compName )
hC = getComplexConjugateComp( hN, slbh, hInSignals, hOutSignals, satMode, compName, rndMode )
hC = getHermitianComp( hN, hInSignals, hOutSignals, satMode, compName, outSigType )
hC = getMagnitudeSquareComp( hN, hInSignals, hOutSignals, satMode, rndMode, compName, outSigType )
hC = getReciprocalDivComp( hN, hInSignals, hOutSignals, rndMode, satMode, compName )

hC = getSqrtComp( hN, hInSignals, hOutSignals, compName, slbh, fname, nfpOptions )

hC = getMathComp( hN, hInSignals, hOutSignals, compName, slbh, fname, nfpOptions )

hC = getTrigonometricComp( hN, hInSignals, hOutSignals, compName, slbh, fname, nfpOptions )

hC = getBiasComp( hN, hInSignals, hOutSignals, biasVal, compName, ovMode );
hC = getRelayComp( hN, hC, hInSignals, hOutSignals, compName, onSwVal, offSwVal, onOpVal, offOpVal );
hC = getDotproductComp( hN, hC, hInSignals, hOutSignals, compName,  ...
rndMode, satMode, architecture, nfpOptions, dspMode, useCplxConj );
hC = getSinCosCordicComp( hN, hInSignals, hOutSignals, cordicInfo, fName, usePipelines, customLatency, latencyStrategy, hC_Name );
hC = getAtan2CordicComp( hN, hInSignals, hOutSignals, cordicInfo, fName, usePipelines, customLatency, latencyStrategy, hC_Name );
hC = getNonRestoreDivideComp( hN, hInSignals, hOutSignals, divideInfo )
hC = getShiftAddMulComp( hN, hInSignals, hOutSignals, blockInfo );
hC = getNonRestoreReciprocalComp( hN, hInSignals, hOutSignals, reciprocalInfo )

hNewNet = getNonRestoreDivideNetwork( hN, hInSignals, hOutSignals, divideInfo )
hNewNet = getNonRestoreReciprocalNetwork( hN, hInSignals, hOutSignals, reciprocalInfo )
hNewNet = getRecipNewtonNetwork( hN, hInSignals, hOutSignals, NewtonInfo )
hNewNet = getRecipNewtonSingleRateNetwork( hN, hInSignals, hOutSignals, NewtonInfo )
hNewNet = getRecipNewtonRsqrtBasedNetwork( hN, hInSignals, hOutSignals, NewtonInfo )
hNewNet = getRecipNewtonRsqrtBasedSingleRateNetwork( hN, hInSignals, hOutSignals, NewtonInfo )
hNewNet = getSqrtNewtonNetwork( hN, hInSignals, hOutSignals, NewtonInfo )
hNewNet = getSqrtNewtonSingleRateNetwork( hN, hInSignals, hOutSignals, NewtonInfo )
hNewNet = getRecipSqrtNewtonNetwork( hN, hInSignals, hOutSignals, NewtonInfo )
hNewNet = getRecipSqrtNewtonSingleRateNetwork( hN, hInSignals, hOutSignals, NewtonInfo )

hNewNet = getSqrtBitsetNetwork( hN, hInSignals, hOutSignals, sqrtInfo )

hNewNet = getSinCosCordicNetwork( hN, hInSignals, hOutSignals, cordicInfo, outputMode, usePipelines, customLatency, latencyStrategy )
hNewNet = getAtan2CordicNetwork( hN, hInSignals, hOutSignals, cordicInfo, outputMode, usePipelines, customLatency, latencyStrategy )


[ need_outsat, divbyzero_outsat ] = handleExtraDivideByZeroLogic(  ...
outSigned, outWordLen, outFracLen, resSigned, resWordLen, resFracLen,  ...
hOutType, rndMode, satMode, outtp_ex )





hC = getDTCComp( hN, hInSignals, hOutSignals, rndMode, satMode, convMode, compName, desc, slbh, nfpOptions )

dtcOutSignal = insertDTCCompOnInput( hN, hCInSignal, hCOutType, rndMode, satMode, compName, nfpOptions )

outSig = insertFloat2IdxDTCCompOnInput( hN, hInSig, width, oneBasedIdx, compName, nfpOptions )

hC = insertSignalSpecOnSignal( hN, hInSig )




hC = getBitSliceComp( hN, hInSignals, hOutSignals, msbPos, lsbPos, compName )
hC = getBitConcatComp( hN, hInSignals, hOutSignals, compName )


hC = getBitReduceComp( hN, hInSignals, hOutSignals, opName, compName )



hC = getBitRotateComp( hN, hInSignals, hOutSignals, opName, rotateLength, compName )





hC = getBitExtractComp( hN, hInSignals, hOutSignals, ul, ll, mode, compName )






hC = getBitShiftComp( hN, hInSignals, hOutSignals, opName, shiftLength, shiftBinPtLength, compName )



[ hC, hDs ] = getDynamicBitShiftComp( hN, hInSignals, hOutSignals, shift_mode, compName, positiveShiftsLeft )



hC = getLibBitShiftComp( hN, hInSignals, hOutSignals, opName, shiftLength, compName )





hC = getBitwiseOpComp( hN, hSignalsIn, hSignalsOut, opName, compName, useBitMask, bitMask, isBitMaskZero )






hC = getBitSetComp( hN, hInSignals, hOutSignals, isBitSet, bitIndex, compName, useBitMask )







hC = getRelOpComp( hN, hSignalsIn, hSignalsOut, opName, sameDT, compName, desc, slHandle, nfpOptions )





hC = getCompareToValueComp( hN, hSignalsIn, hSignalsOut, opName, constVal, compName, isConstZero, nfpOptions )


hC = getLogicComp( hN, hSignalsIn, hSignalsOut, opName, compName, desc, slHandle )


hOutSignal = getCompareToZero( hN, hSignal, opName, outSigName, compName )



hC = getCounterFreeRunningComp( hN, hOutSignal, compName )
hC = getCounterEnabledComp( hN, hOutSignal, hEnbSignals, compName, ic )



hC = getCounterLimitedComp( hN, hOutSignal, countLimit, outputRate, compName, ic, limitedCounterOptimize, clockEnable )









hC = getCounterComp( hN, hInSignals, hOutSignals, type, initval, stepval,  ...
maxval, resetport, loadport, enbport, dirport, compName, countFrom )





hC = getConcatenateComp( hN, hInSignals, hOutSignals, mode, dim, compName, shouldDrawOverride )
hC = getMuxComp( hN, hInSignals, hOutSignals, compName )
hC = getDemuxComp( hN, hInSignals, hOutSignals, compName )
hC = getWireComp( hN, hInSignals, hOutSignals, compName, desc, slHandle, traceComment )
hC = getReshapeComp( hN, hInSignals, hOutSignals, outDimType, outDims, compName )
hC = getNFPReinterpretCastComp( hN, hInSignals, hOutSignals, compName, desc, slHandle );
hC = getRepeatComp( hN, hInSignals, hOutSignals, repetitionCount, compName, desc, slHandle )
hC = getSplitComp( hN, hInSignals, hOutSignals, compName )


hC = getNFPSparseConstMultiplyComp( hN, hInSignals, hOutSignals, constMatrixSize,  ...
constMatrix, latency, sharingFactor, fpDelays, nfpOptions, name );


hC = getBusCreatorComp( hN, hInSignals, hOutSignals, busTypeStr, nonVirtualBus, compName )




hC = getBusSelectorComp( hN, hInSignals, hOutSignals, indexStr, outputIsBus, compName )


hC = getBustoVectorComp( hN, hInSignals, hOutSignal, compName, slhandle )


hC = getBusAssignmentComp( hN, hInSignals, hOutSignal, assignedSignals, compName )



hC = getFromComp( hN, hOutSignals, tagName, tagScope, compName, desc, slHandle )
hC = getGotoComp( hN, hInSignals, tagName, tagScope, compName, desc, slHandle )

hC = getDemuxCompOnInput( hN, hInSignal )


demuxOutputs = demuxSignal( hN, hInSignal )


outputVector = scalarExpand( hN, hInScalar, numElements, isRowVector )

hC = getMuxOnOutput( hN, hOutSignal )

hC = getHardwareDemuxComp( hN, hInSignals, hOutSignals, compName )



orientedSignal = alignVectorOrientation( hN, hInSignal, vecOrientation )





hC = getComplex2RealImag( hN, hInSignals, hOutSignals, opMode, compName )



hC = getRealImag2Complex( hN, hInSignals, hOutSignals, inputTypeMode, cval, compName, rndMode, satMode )








hC = getConstComp( hN, hOutSignals, constValue, compName, vectorParams1D,  ...
isConstZero, TunableParamStr, ConstBusName, ConstBusType, traceComment )
hC = getConstSpecialComp( hN, hOutSignals, constValue, compName )



hC = getAnnotationComp( hN, compName, desc, slHandle )







hC = getSwitchComp( hN, inSignals, outSignals, selSignal, compName, compareStr,  ...
compareVal, roundMode, overflowMode, desc, slHandle )













hC = getMultiPortSwitchComp( hN, hInSignals, hOutSignals, inputmode, dpOrder, rndMode, satMode, compName, portSel, dpForDefault, numInputs, nfpOptions, diagForDefaultErr, codingStyle )








hC = getVariableSelectorComp( hN, hInSignals, hOutSignals, zerOneIdxMode,  ...
idxMode, elements, fillValues, rowsOrCols, numInputs, compName )




hC = getMultiportSelectorComp( hN, hInSignals, hOutSignals, rowsOrCols, idxCellArray, idxErrMode, compName )






hC = getSelectorComp( hN, hInSignals, hOutSignals, indexMode, indexOptionArray,  ...
indexParamArray, outputSizeArray, numDims, compName, inputPortWidth, nfpOptions )















hC = getUnitDelayComp( hN, hInSignals, hOutSignals, compName, initval, resetnone, desc, slHandle )
hC = getUnitDelayEnabledComp( hN, hInSignals, hOutSignals, hEnbSignals, compName, ic, resettype, useInputEnbOnly, desc, slHandle, isSynchronousDelay )
hC = getUnitDelayResettableComp( hN, hInSignals, hOutSignals, hEnbSignals, compName, ic, resettype, softreset, desc, slHandle, isSynchronousDelay )
hC = getUnitDelayEnabledResettableComp( hN, hInSignals, hOutSignals, hEnbSignals,  ...
hRstEnbSignals, compName, ic, resettype, softreset, desc, slHandle, isSynchronousDelay )


hC = getIntDelayComp( hN, hInSignals, hOutSignals, delayNumber, compName, ic,  ...
resetType, hasExtEnable, extResetType, ramBased, isDefaultHwSemantics, desc,  ...
slHandle )
hC = getIntDelayEnabledComp( hN, hInSignals, hOutSignals, hEnbSignals, delayNumber, compName, ic, resettype, desc, slHandle )
hC = getIntDelayEnabledResettableComp( hN, hInSignals, hOutSignals, hEnbSignals,  ...
hRstSignal, delayNumber, compName, ic, resettype, desc, slHandle )
hC = getFrameBasedIntDelayComp( hN, hInSignals, hOutSignals, delayNumber, compName, ic, resetType, hasExtEnable, extResetType, ramBased, isDefaultHwSemantics, desc, slHandle )



hC = getTapDelayComp( hN, hSignalsIn, hSignalsOut, delayNumber, compName, initval,  ...
delayOrder, includeCurrent, resettype, desc, slHandle )
hC = getTapDelayEnabledComp( hN, hSignalsIn, hSignalsOut, hEnbSignals, delayNumber,  ...
compName, initval, delayOrder, includeCurrent, resettype, isDefaultHwSemantics, desc, slHandle )
hC = getTapDelayEnabledResettableComp( hN, hSignalsIn, hSignalsOut, hEnbSignals,  ...
hRstSignal, delayNumber, compName, initval, delayOrder, includeCurrent,  ...
resettype, isDefaultHwSemantics, desc, slHandle )
hC = getDetectChangeComp( hN, hInSignals, hOutSignals, ic, dt, name )



hC = getDiscreteTimeIntegratorComp( hN, hInSignals, hOutSignals, dtiInfo, nfpOptions )
hC = getDiscreteTransferFcnComp( hN, hInSignals, hOutSignals, tfInfo, nfpOptions )



hC = getRateTransitionComp( hN, hInSignals, hOutSignals, outputRate, initVal, compName, desc, slHandle, integrity, deterministic )
hC = getDownSampleComp( hN, hInSignal, hOutSignal, downSampleFactor, sampleOffset, initVal, compName, desc, slHandle )
hC = getUpSampleComp( hN, hInSignal, hOutSignal, upSampleFactor, sampleOffset, initVal, compName, desc, slHandle )



hC = getSerializerComp( hN, hInSignals, hOutSignals, compName )
hC = getDeserializerComp( hN, hInSignals, hOutSignals, compName )
hC = getDataBufferComp( hN, hInSignals, hOutSignals, compName )
hC = getDataUnbufferComp( hN, hInSignals, hOutSignals, compName )

hC = getSerializer1DComp( hN, hInSignals, hOutSignals, ratio, idleCycles, validInPort, startOutPort, validOutPort, compName )
hC = getDeserializer1DComp( hN, hInSignals, hOutSignals, ratio, idleCycles, initialCondition, startInPort, validInPort, validOutPort, compName )




hC = getDirectLookupComp( hN, hInSignals, hOutSignals, table_data, compName, slbh, dims, inputsSelectThisObjectFromTable, diagnostics, tableDataType, mapToRAM )








hC = getPreLookupComp( hN, hInSignals, hOutSignals, bp_data, bpType, kType, fType, idxOnly, powerof2, compName, slbh, diagnostics )








hC = getLookupNDComp( hN, hInSignals, hOutSignals, table_data, powerof2,  ...
bpType, oType, fType, interpVal, bp_data, compName, slbh, dims, rndMode, satMode, diagnostics, extrap, spacing, nfpOptions, mapToRAM )


hC = getLookupComp( hN, hInSignals, hOutSignals, input_values, table_data, other_data, oType_ex, compName, desc );



hC = getVerbatimDocBlockNetwork( hN, hC, base_text );







[ RamNet, RamNetInstance ] = getSinglePortRamComp( hN, hInSignals, hOutSignals, compName, numBanks, readNewData, simulinkHandle, initialVal, RAMStyle )
[ RamNet, RamNetInstance ] = getSimpleDualPortRamComp( hN, hInSignals, hOutSignals, compName, numBanks, simulinkHandle, RamNet, ramCorePrefix, initialVal, RAMStyle )
[ RamNet, RamNetInstance ] = getDualPortRamComp( hN, hInSignals, hOutSignals, compName, numBanks, readNewData, simulinkHandle, initialVal, RAMStyle )
[ RamNet, RamNetInstance ] = getDualRateDualPortRamComp( hN, hInSignals, hOutSignals, compName, readNewData, simulinkHandle )
initialValStr = convertRAMIV2Str( initialVal, addrType )



[ RamNet, RamComp ] = getRAMBasedShiftRegisterComp( hN, hSignalsIn, hSignalsOut,  ...
delayNumber, thresholdSize, compName, ramName, RamNet )





hNew = getSRFlipFlopComp( hN, hInSignals, hOutSignals, initialQ, compName, desc, slbh );



hNewNet = getFFTDIFNetwork( hN, hInSignals, FFTInfo )



hNewNet = getFIFONetwork( hN, hInSignals, hOutSignals, info, ramCorePrefix, RAMDirective )
hNewNet = getFIFOFWFTNetwork( hN, hInSignals, info, RAMDirective )
hC = getFIFOComp( hN, InSignals, OutSignals, fifoSize, fifoName, ramCorePrefix, statusOut, almost_full_thresh )
hC = getFIFOFWFTComp( hN, InSignals, OutSignals, fifoSize, fifoName, ramCorePrefix, statusOut, almost_full_thresh )






























hC = getTreeArch( hN, hInSignals, hOutSignals, opName, rndMode, satMode,  ...
compName, minmaxIdxBase, pipeline, useDetailedElab,  ...
minmaxISDSP, minmaxOutMode, dspMode, nfpOptions, prodWordLenMode )






hC = getFilterComp( hN, hInSignals, hOutSignals, hImpl, hFiltObj, compName, slHandle, nfpOptions )

hC = getDspbaComp( hN, name, inputSignals, outputSignals,  ...
entityName, inportsNames, outportsNames, clkNames, ceNames, ceclrNames, busInputPortNames, busInputPortWidths, busReadEnablePortNames,  ...
rates, baseRate, blackBoxAttributes, vhdlComponentLibrary,  ...
slbh );

hC = getXsgComp( hN, name, inputSignals, outputSignals,  ...
entityName, inportsNames, outportsNames, clkNames, ceNames, ceclrNames,  ...
rates, baseRate, hasDownSample, blackBoxAttributes, vhdlComponentLibrary,  ...
slbh );

hC = getXsgVivadoComp( hN, name, inputSignals, outputSignals,  ...
entityName, inportsNames, outportsNames, clkNames, ceNames, ceclrNames,  ...
rates, baseRate, hasDownSample, blackBoxAttributes, vhdlComponentLibrary,  ...
slbh );



hC = getTBClockgenComp( hN, hInSignal, hClockSignal, highTime, lowTime )
hC = getTBCheckerComp( hN, hInSignals, hOutSignals )
hC = getTBCompletionComp( hN, hInSignals, extraMsgStr )
hC = getTBCounterModComp( hN, hInSignal, hOutSignal, modValue )
hC = getTBFileReaderComp( hN, hInSigs, hOutSigs, fileName, compName )
hC = getTBPackageComp( hN )
hC = getTBToHexComp( hN, hT )
hC = getTBResetgenComp( hN, hInSignal, hResetSignal, tResetHold )
hC = getTBStimulusSwitchComp( hN, hInSignals, hOutSignal, hSelSignal, compName )
hC = getTBTimeDelayComp( hN, hInSignal, hOutSignal, timeDelay, compName )



hC = getAssertionComp( hN, hSignalsIn, compName, label, enabled, assertFailFcn, stopSimulation )



hC = getNilComp( hN, hInSignals, hOutSignals, compName, desc, slHandle )





hResetSig = createRisingEdgeTrigger( hN, reset_in );
hResetSig = createFallingEdgeTrigger( hN, reset_in );



hC = getMathMatrixInverse2x2Comp( this, hN, hC, hInSignals, out1 );




hNewNet = createNewNetwork( varargin )
hNewNet = createNewNetworkWithInterface( varargin )
connectNtwkInstComp( hNtwkInstComp, hInSignals, hOutSignals )
connectComp( hC, hInSignals, hOutSignals )
hNetworkComp = instantiateNetwork( hN, hnewNet, hInSignals, hOutSignals, instanceName )
hRefComp = instantiateModel( hN, newPir, hInSignals, hOutSignals, instanceName, simMode )
hBlackboxComp = instantiateProtectedModel( varargin )

hC = getInstantiationComp( varargin )
hPortSignals = addIOPortToNetwork( varargin )

[ status, msg ] = insertTimingController( hN )

dimLen = getInputDimension( tSignalsIn )
pirType = getPirVectorType( basetp, portDims, allowSingleElementVector )

valWithType = getValueWithType( value, pirType, sameDimsAsPirType )
[ dimLen, hBT ] = getVectorTypeInfo( pirSignal, returnMatrixDim )
pirtype = convertSLType2PirType( dt )
pirdt = convertSLUserType2PirType( DTstr, slbh )
pirtype = createPirArrayType( baseTp, portDims )
outTypeEx = getTypeInfoAsFi( pirType, rndMode, satMode, exVal, sameDimsAsPirType, respectOrientation )
hdlfm = getFimathFromProps( satMode, rndMode )
y = convertInt2fi( u )
comp = convertReal2Complex( hN, hSig, isSigInput, compName )


retypedSigs = convertRowVecsToUnorderedVecs( hN, hInSignals )


pass = getMapDelayToRam( hInSignal, delayNumber, ramTh )

[ lowerBound, upperBound ] = getTypeBounds( pirType )


blockParam = setBlockParam( block, varargin )


isc = hasComplexType( pirType )
ctype = getComplexType( pirType )


pirT = numerictype2pirType( nt )

end 
end 






% Decoded using De-pcode utility v1.2 from file /tmp/tmpGeiMUO.p.
% Please follow local copyright laws when handling this file.

