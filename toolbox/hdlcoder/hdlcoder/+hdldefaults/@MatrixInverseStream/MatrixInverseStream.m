classdef MatrixInverseStream<hdlimplbase.EmlImplBase

































    methods
        function this=MatrixInverseStream(block)







            supportedBlocks={...
'hdl.MatrixInverse'...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'ArchitectureNames','MATLAB System',...
            'Deprecates',{});

        end

    end

    methods
        LTRowCounter(~,hN,LTRowCounterInSigs,LTRowCounterOutSigs,hBoolT,hCounterT,slRate,blockInfo)
        v_settings=block_validate_settings(this,~)
        hNewComp=elaborate(this,hN,hC)
        blockInfo=getBlockInfo(~,hC)
        stateInfo=getStateInfo(~,~)
        val=hasDesignDelay(~,~,~)
        v=validateBlock(this,hC)
    end


    methods(Hidden)
        ColDataSelector(~,hN,ColDataSelInSigs,ColDataSelOutSigs,slRate,blockInfo)
        DataCounterAndValidDecoder(~,hN,CntVldDecoderInSigs,CntVldDecoderOutSigs,hBoolT,hCounterT,slRate,blockInfo)
        DataDemux(~,hN,DataDemuxInSigs,DataDemuxOutSigs,hInputDataT,slRate,blockInfo)
        DataEnableBlock(this,hN,DataEnbInSigs,DataEnbOutSigs,hBoolT,hCounterT,slRate,blockInfo)
        DataSubtractionAndReciprocalMult(~,hN,LTSubMultInSigs,LTSubMultOutSigs,hBoolT,hInputDataT,slRate)
        DataValidGenerator(~,hN,DataVldGenInSigs,DataVldGenOutSigs,hBoolT,hCounterT,slRate,blockInfo)
        DiagDataComputation(~,hN,DiagDataComputationInSigs,DiagDataComputationOutSigs,hBoolT,hInputDataT,slRate)
        DiagDataSelector(~,hN,DiagDataSelectorInSigs,DiagDataSelectorOutSigs,hCounterT,hInputDataT,slRate,blockInfo)
        ForwardSubstitution(this,hN,FwdSubInSigs,FwdSubOutSigs,hBoolT,hInputDataT,hAddrT,hCounterT,slRate,blockInfo)
        FwdController(this,hN,FwdControlInSigs,FwdControlOutSigs,hBoolT,hCounterT,slRate,blockInfo)
        FwdDataProcessing(this,hN,FwdProcessingInSigs,FwdProcessingOutSigs,hBoolT,hCounterT,hInputDataT,slRate,blockInfo)
        FwdDataSelector(~,hN,FwdDataSelInSigs,FwdDataSelOutSigs,hBoolT,hInputDataT,slRate)
        FwdMemReadAddr(~,hN,FwdMemRdAddrInSigs,FwdMemRdAddrOutSigs,hBoolT,hCounterT,hAddrT,slRate,blockInfo)
        FwdMemWriteControl(this,hN,FwdMemWrtControlInSigs,FwdMemWrtControlOutSigs,hBoolT,hCounterT,hAddrT,hInputDataT,slRate,blockInfo)
        FwdOutRowColCounters(~,hN,FwdCntOutInSigs,FwdCntOutOutSigs,hBoolT,hCounterT,slRate,blockInfo)
        FwdParallelMAC(this,hN,FwdMacInSigs,FwdMacOutSigs,hBoolT,hInputDataT,slRate,blockInfo)
        FwdSubDiagComputation(~,hN,FwdSubDiagCompInSigs,FwdSubDiagCompOutSigs,hBoolT,hInputDataT,slRate)
        FwdSubNonDiagComputation(this,hN,FwdNonDiagCompInSigs,FwdNonDiagCompOutSigs,hBoolT,hCounterT,hInputDataT,slRate,blockInfo)
        FwdWriteAddress(~,hN,FwdWrtAddrInSigs,FwdWrtAddrOutSigs,hBoolT,hAddrT,hCounterT,slRate,blockInfo)
        FwdWriteDataBus(~,hN,FwdWrtDataInSigs,FwdWrtDataOutSigs,hBoolT,hInputDataT,slRate,blockInfo)
        FwdWriteEnable(~,hN,FwdWrtEnbInSigs,FwdWrtEnbOutSigs,hBoolT,hCounterT,slRate,blockInfo)
        InputDataStoreMemoryControl(this,hN,StoreMemControlInSigs,StoreMemControlOutSigs,slRate,blockInfo)
        InputMatrixStoreControl(this,hN,MatrixStoreInSigs,MatrixStoreOutSigs,slRate,blockInfo)
        LTColumnCounter(~,hN,LTColumnCounterInSigs,LTColumnCounterOutSigs,hBoolT,hCounterT,slRate,blockInfo)
        LTDiagDataComputation(this,hN,LTDiagDataComputationInSigs,LTDiagDataComputationOutSigs,hInputDataT,hBoolT,slRate)
        LTDiagNonDiagProcessing(this,hN,LTDiagNonDiagProcessingInSigs,LTDiagNonDiagProcessingOutSigs,hCounterT,hAddrT,hBoolT,hInputDataT,slRate,blockInfo)
        LTDiagReciprocalData(~,hN,LTDiagReciprocalDataInSigs,LTDiagReciprocalDataOutSigs,hBoolT,hInputDataT,slRate)
        LTMemReadControl(this,hN,LTMemRdControlInSigs,LTMemRdControlOutSigs,slRate,blockInfo)
        LTMemoryControl(this,hN,LTMemoryControlInSigs,LTMemoryControlOutSigs,hBoolT,hAddrT,hCounterT,hInputDataT,slRate,blockInfo)
        LTMemwriteCounter(~,hN,LTMemwriteCounterInSigs,LTMemwriteCounterOutSigs,hBoolT,hCounterT,slRate,blockInfo)
        LTMultController(this,hN,LTMultControlInSigs,LTMultControlOutSigs,hBoolT,hCounterT,slRate,blockInfo)
        LTMultCounters(~,hN,LTMultCntInSigs,LTMultCntOutSigs,hBoolT,hCounterT,slRate,blockInfo)
        LTMultMAC(this,hN,LTMultMACInSigs,LTMultMACOutSigs,hBoolT,hCounterT,hInputDataT,slRate,blockInfo)
        LTMultProcCounters(~,hN,LTMultProcCntInSigs,LTMultProcCntOutSigs,slRate,blockInfo)
        LTNonDiagDataComputation(this,hN,LTNonDiagDataComputationInSigs,LTNonDiagDataComputationOutSigs,hInputDataT,hBoolT,hCounterT,hAddrT,slRate,blockInfo)
        LTNonDiagMAC(this,hN,LTNonDiagMACInSigs,LTNonDiagMACOutSigs,hInputDataT,hAddrT,hBoolT,slRate,blockInfo)
        LTParallelAccumulator(~,hN,LTParallelAccumInSigs,LTParallelAccumOutSigs,hBoolT,hInputDataT,slRate,blockInfo)
        LTProcessController(this,hN,LTProcControlInSigs,LTProcControlOutSigs,slRate,blockInfo)
        LTRowColCounter(this,hN,LTRowColCounterInSigs,LTRowColCounterOutSigs,hBoolT,hCounterT,slRate,blockInfo)
        LowerTriangDataValidIn(~,hN,LTDataValidInInSigs,LTDataValidInOutSigs,slRate)
        LowerTriangEnable(~,hN,LTEnableInSigs,LTEnableOutSigs,slRate,blockInfo)
        LowerTriangReadEnable(~,hN,LTRdEnableInSigs,LTRdEnableOutSigs,slRate,blockInfo)
        LowerTriangularComputation(this,hN,LTCompInSigs,LTCompOutSigs,slRate,blockInfo)
        LowerTriangularMatrixMultiplication(this,hN,MatMultInSigs,MatMultOutSigs,hBoolT,hInputDataT,hCounterT,slRate,blockInfo)
        MatMultEnableBlock(~,hN,MatMultEnbInSigs,MatMultEnbOutSigs,hBoolT,slRate)
        MatMultMemoryControl(this,hN,MatMultMemControlInSigs,MatMultMemControlOutSigs,hBoolT,hCounterT,hInputDataT,slRate,blockInfo)
        MatMultSubsystem(this,hN,MatMultSubInSigs,MatMultSubOutSigs,slRate,blockInfo)
        Memories(~,hN,MemoriesInSigs,MemoriesOutSigs,hBoolT,hAddrT,hInputDataT,slRate,blockInfo)
        MemoryController(this,hN,MemControlInSigs,MemControlOutSigs,hBoolT,hAddrT,hInputDataT,slRate,blockInfo)
        MemoryMuxing(this,hN,MemMuxInSigs,MemMuxOutSigs,hBoolT,hAddrT,hInputDataT,slRate,blockInfo)
        MultBuffer(~,hN,MultBufInSigs,MultBufOutSigs,slRate,blockInfo)
        MultiplyAccumulation(~,hN,MACInSigs,MACOutSigs,slRate,blockInfo)
        NonDiagCounter(~,hN,NonDiagCounterInSigs,NonDiagCounterOutSigs,hBoolT,hAddrT,slRate,blockInfo)
        NonDiagDataSelector(~,hN,NonDiagDataSelectorInSigs,NonDiagDataSelectorOutSigs,hCounterT,hInputDataT,slRate,blockInfo)
        NonDiagEleComputation(this,hN,NonDiagEleComputationInSigs,NonDiagEleComputationOutSigs,hBoolT,hAddrT,hCounterT,hInputDataT,slRate,blockInfo)
        OutputStreamController(~,hN,OutControlInSigs,OutControlOutSigs,hBoolT,hInputDataT,hAddrT,hCounterT,slRate,blockInfo)
        ParallelMACDataSelector(~,hN,MacDataSelInSigs,MacDataSelOutSigs,hCounterT,hInputDataT,slRate,blockInfo)
        ProcDataControl(~,hN,ProcDataControlInSigs,ProcDataControlOutSigs,hBoolT,hCounterT,slRate,blockInfo)
        ProcessDataSelector(~,hN,ProcDataSelInSigs,ProcDataSelOutSigs,hCounterT,hInputDataT,slRate,blockInfo)
        RdAddrGenerator(~,hN,RdAddrGenInSigs,RdAddrGenOutSigs,hBoolT,hAddrT,slRate,blockInfo)
        RdAddrLowerTriang(~,hN,RdAddrLTInSigs,RdAddrLTOutSigs,hBoolT,hCounterT,hAddrT,slRate,blockInfo)
        RdAddrMatMult(~,hN,RdAddrMultInSigs,RdAddrMultOutSigs,slRate,blockInfo)
        ReadySignalGenerator(~,hN,ReadySigGenInSigs,ReadySigGenOutSigs,slRate,blockInfo)
        RowAccumulatorSelector(~,hN,RowAccumSelInSigs,RowAccumSelOutSigs,hAddrT,hInputDataT,slRate,blockInfo)
        RowColCounter(~,hN,RowColCounterInSigs,RowColCounterOutSigs,slRate,blockInfo)
        RowCountReg(~,hN,RowCntRegInSigs,RowCntRegOutSigs,hCounterT,hBoolT,slRate)
        StoringDone(~,hN,StoringDoneInSigs,StoringDoneOutSigs,slRate,blockInfo)
        TriggerLogic(~,hN,TriggerLogicInSigs,TriggerLogicOutSigs,hBoolT,slRate)
        WrAddrLowerTriang(~,hN,WrAddrLTInSigs,WrAddrLTOutSigs,hBoolT,hCounterT,hAddrT,slRate,blockInfo)
        WrDataLowerTriang(~,hN,WrDataLTInSigs,WrDataLTOutSigs,hBoolT,hInputDataT,slRate,blockInfo)
        WrEnbLowerTriang(~,hN,WrEnbLTInSigs,WrEnbLTOutSigs,hBoolT,hCounterT,slRate,blockInfo)
        WrtAddrGenerator(~,hN,WrtAddrGenInSigs,WrtAddrGenOutSigs,hBoolT,hAddrT,slRate,blockInfo)
        WrtAddrMatMult(~,hN,WrtAddrMultInSigs,WrtAddrMultOutSigs,slRate,blockInfo)
        WrtAddrStore(~,hN,WrtAddrStoreInSigs,WrtAddrStoreOutSigs,slRate,blockInfo)
        WrtDataGenerator(~,hN,WrtDataGenInSigs,WrtDataGenOutSigs,hBoolT,hInputDataT,slRate,blockInfo)
        WrtDataMatMult(~,hN,WrtDataMultInSigs,WrtDataMultOutSigs,slRate,blockInfo)
        WrtDataStore(~,hN,WrtDataStoreInSigs,WrtDataStoreOutSigs,slRate,blockInfo)
        WrtEnbGenerator(~,hN,WrtEnbGenInSigs,WrtEnbGenOutSigs,hBoolT,slRate,blockInfo)
        WrtEnbMatMult(~,hN,WrtEnbMultInSigs,WrtEnbMultOutSigs,slRate,blockInfo)
        WrtEnbStore(~,hN,WrtEnbStoreInSigs,WrtEnbStoreOutSigs,slRate,blockInfo)
    end

end

