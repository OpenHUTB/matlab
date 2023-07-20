




classdef pirtarget<handle


    methods(Static)




        hC=getCLKDLLComp(hN,hInSignals,hOutSignals)
        hC=getDCMComp(hN,hInSignals,hOutSignals,dcmName,dcmFXMul,dcmFXDiv,dcmClkInPeriod)
        hC=getDCMDoubleRateComp(hN,hInSignals,hOutSignals,dcmName,dcmFXMul,dcmFXDiv,dcmClkInPeriod)
        hC=getBUFGComp(hN,hInSignals,hOutSignals,compName)
        hC=getIBUFGComp(hN,hInSignals,hOutSignals)
        hC=getIBUFGDSComp(hN,hInSignals,hOutSignals)




        hNewNet=getClockModuleDCMNetwork(hN,hPir,networkName,fpgaFamily,isDiff,dcmFXMul,dcmFXDiv,dcmClkInPeriod,skipDCM)
        hNewNet=getAlteraPLLNetwork(hN,hPir,networkName,fpgaFamily,isDiff,dcmFXMul,dcmFXDiv,dcmClkInPeriod)




        hC=getIBUFDSLVDS25Comp(hN,hInSignals,hOutSignals)
        hC=getOBUFDSLVDS25Comp(hN,hInSignals,hOutSignals)
        hNewNet=getIBUFDSLVDS25Network(hN,hPir,networkName)
        hNewNet=getOBUFDSLVDS25Network(hN,hPir,networkName)
        hC=getIBUFDSComp(hN,hInSignals,hOutSignals)
        hC=getOBUFDSComp(hN,hInSignals,hOutSignals)
        hNewNet=getIBUFDSNetwork(hN,hPir,networkName)
        hNewNet=getOBUFDSNetwork(hN,hPir,networkName)
        hC=getODDR2Comp(hN,hInSignals,hOutSignals)




        hC=getRisingEdgeDetectionComp(hN,hInSignals,hOutSignals)
        hC=getTLASTCounterComp(hN,hInSignals,hOutSignals,counterBitWidth)

        hC=getVHTAdapterInNetwork(hN,hInSignals,hOutSignals,networkName)
        hC=getVHTAdapterOutNetwork(hN,hInSignals,hOutSignals)




        [hDecoderNet,muxCounter,readDelayCount]=getAddrDecoderNetwork(...
        hN,topInSignals,topOutSignals,hElab,hAddrLists,networkName,readInitZ)

        [hDecodeReadSignal,muxCounter,readDelayCount]=elabAddrDecoderModules(hN,hElab,hAddrList,hDecodeReadSignal,muxCounter,readDelayCount)
        [hDecodeReadSignal,muxCounter,readDelayCount]=elabAddrDecoderWriteModule(hN,hElab,hAddr,hDecodeReadSignal,muxCounter,readDelayCount,AXI4RegisterReadbackPipelineRatioValue,registerWidth)
        [hDecodeReadSignal,muxCounter,readDelayCount]=elabAddrDecoderReadModule(hN,hElab,hAddr,hDecodeReadSignal,muxCounter,readDelayCount,AXI4RegisterReadbackPipelineRatioValue,registerWidth)
        elabAddrDecoderStrobeModule(hN,hElab,hAddr)

        [hC,decode_sel_sigs,reg_enab]=getAddrDecoderWriteRegComp(hN,hInSignals,hOutSignals,addrStart,addrLength,regID,...
        registerWidth,needPipeReg,saveDecodeSelSigs,init_value)
        [hC,muxCounter,readDelayCount]=getAddrDecoderReadRegComp(hN,hInSignals,hOutSignals,addrStart,addrLength,regID,...
        muxCounter,readDelayCount,AXI4RegisterReadbackPipelineRatioValue,registerWidth,needPipeReg,useDecodeSelSigs,decodeSelSigs)
        hC=getAddrDecoderStrobeRegComp(hN,hInSignals,hOutSignals,addrStart,addrLength,regID,needPipeReg)

        [hC,reg_enb]=getAddrDecoderWriteShiftRegComp(hN,hInSignals,hOutSignals,addrStart,addrLength,regID,addrBlockSize,needPipeReg,init_value)
        hC=getAddrDecoderReadShiftRegComp(hN,hInSignals,hOutSignals,addrStart,addrLength,regID,addrBlockSize,needPipeReg)

        hC=getAddrBlockDetectionComp(hN,hInSignals,hOutSignals,addrStart,addrBlockSize,regID)
        hC=getAddrComparisonComp(hN,hInSignals,hOutSignals,addrStart,addrLength,regID)




        hNewNet=getCoprocessorControllerNetwork(hN,hPir,topInSignals,topOutSignals,networkName,cntCycle)
        hNewNet=getStreamControllerNetwork(hN,topInSignals,topOutSignals,hPirInstance,networkName,extra_delay)
        hNewNet=getVDMAControllerNetwork(hN,topInSignals,topOutSignals,hPirInstance,networkName,extra_delay)




        hC=getBitPackingComp(hN,hInSignals,hOutSignals,regID)
        hC=getBitUnpackingComp(hN,hInSignals,hOutSignals,regID)




        getInPortBitSliceComp(hN,hInSignal,hOutSignal,sliceMSB,sliceLSB)
        getOutPortBitConcatComp(hN,hInSignals,hOutSignals)
        connectSignals(hElab,hSignalsIn,hSignalsOut,newPortName)
        connectSignalsWithHierarchy(hSignalsIn,hSignalsOut,direction,outPortName,newSigName)
        [hParentNet,hNInst]=getParentNetwork(hN)

    end
end

