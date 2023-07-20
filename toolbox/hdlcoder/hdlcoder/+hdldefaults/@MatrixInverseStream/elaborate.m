function hNewComp=elaborate(this,hN,hC)










    blockInfo=this.getBlockInfo(hC);
    hInSignals=hC.PirInputSignals;
    hOutSignals=hC.PirOutputSignals;
    slRate=hInSignals(1).SimulinkRate;





    hTopN=pirelab.createNewNetwork(...
    'Name','MatrixInverse',...
    'InportNames',{'dataIn','validIn','outEnable'},...
    'InportTypes',[hInSignals(1).Type,hInSignals(2).Type,...
    hInSignals(3).Type],...
    'InportRates',[slRate,slRate,slRate],...
    'OutportNames',{'dataOut','validOut','ready'},...
    'OutportTypes',[hOutSignals(1).Type,hOutSignals(2).Type,...
    hOutSignals(3).Type]);

    hTopN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hTopN.PirOutputSignals)
        hTopN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hNewComp=pirelab.instantiateNetwork(hN,hTopN,hInSignals,hOutSignals,...
    [hC.Name,'_inst']);

    if strcmpi(blockInfo.AlgorithmType,'CholeskyDecomposition')

        hBoolT=pir_boolean_t;
        hInputDataT=pir_single_t;

        if blockInfo.RowSize>1
            hAddrT=pir_fixpt_t(false,ceil(log2(blockInfo.RowSize)),0);
        else
            hAddrT=pir_fixpt_t(false,1,0);
        end

        if bitand(blockInfo.RowSize,blockInfo.RowSize*2-1)==blockInfo.RowSize
            hCounterT=hN.getType('FixedPoint','Signed',false,'WordLength',ceil(log2(blockInfo.RowSize))+1,...
            'FractionLength',0);
        else
            hCounterT=hN.getType('FixedPoint','Signed',false,'WordLength',ceil(log2(blockInfo.RowSize)),...
            'FractionLength',0);
        end


        hInSigs=hTopN.PirInputSignals;
        hOutSigs=hTopN.PirOutputSignals;


        outStreamDoneS=l_addSignal(hTopN,'outStreamDone',hBoolT,slRate);

        if blockInfo.RowSize>1
            wrEnbStoreS=l_addSignal(hTopN,'wrEnbStore',pirelab.createPirArrayType(hBoolT,[blockInfo.RowSize,0]),slRate);
            wrAddrStoreS=l_addSignal(hTopN,'wrAddrStore',pirelab.createPirArrayType(hAddrT,[blockInfo.RowSize,0]),slRate);
            wrDataStoreS=l_addSignal(hTopN,'wrDataStore',pirelab.createPirArrayType(hInputDataT,[blockInfo.RowSize,0]),slRate);
        else
            wrEnbStoreS=l_addSignal(hTopN,'wrEnbStore',hBoolT,slRate);
            wrAddrStoreS=l_addSignal(hTopN,'wrAddrStore',hAddrT,slRate);
            wrDataStoreS=l_addSignal(hTopN,'wrDataStore',hInputDataT,slRate);
        end

        storeDoneS=l_addSignal(hTopN,'storeDone',hBoolT,slRate);

        rdDataS=l_addSignal(hTopN,'rdData',pirelab.createPirArrayType(hInputDataT,[blockInfo.RowSize+1,0]),slRate);

        lowerTriangEnbS=l_addSignal(hTopN,'lowerTriangEnb',hBoolT,slRate);
        lowerTriangDoneS=l_addSignal(hTopN,'lowerTriangDone',hBoolT,slRate);
        wrEnbLTS=l_addSignal(hTopN,'wrEnbLT',pirelab.createPirArrayType(hBoolT,[blockInfo.RowSize+1,0]),slRate);
        wrAddrLTS=l_addSignal(hTopN,'wrAddrLT',pirelab.createPirArrayType(hAddrT,[blockInfo.RowSize+1,0]),slRate);
        wrDataLTS=l_addSignal(hTopN,'wrDataLT',pirelab.createPirArrayType(hInputDataT,[blockInfo.RowSize+1,0]),slRate);
        rdAddrLTS=l_addSignal(hTopN,'rdAddrLT',pirelab.createPirArrayType(hAddrT,[blockInfo.RowSize+1,0]),slRate);


        fwdSubEnbS=l_addSignal(hTopN,'fwdSubEnb',hBoolT,slRate);
        fwdSubDoneS=l_addSignal(hTopN,'fwdSubDone',hBoolT,slRate);


        if blockInfo.RowSize>1
            wrEnbFwdSubS=l_addSignal(hTopN,'wrEnbFwdSub',pirelab.createPirArrayType(hBoolT,[blockInfo.RowSize,0]),slRate);
            wrAddrFwdSubS=l_addSignal(hTopN,'wrAddrFwdSub',pirelab.createPirArrayType(hAddrT,[blockInfo.RowSize,0]),slRate);
            wrDataFwdSubS=l_addSignal(hTopN,'wrDataFwdSub',pirelab.createPirArrayType(hInputDataT,[blockInfo.RowSize,0]),slRate);
        else
            wrEnbFwdSubS=l_addSignal(hTopN,'wrEnbFwdSub',hBoolT,slRate);
            wrAddrFwdSubS=l_addSignal(hTopN,'wrAddrFwdSub',hAddrT,slRate);
            wrDataFwdSubS=l_addSignal(hTopN,'wrDataFwdSub',hInputDataT,slRate);
        end


        rdAddrFwdSubS=l_addSignal(hTopN,'rdAddrFwdSub',pirelab.createPirArrayType(hAddrT,[blockInfo.RowSize+1,0]),slRate);

        matMultEnbS=l_addSignal(hTopN,'matMultEnb',hBoolT,slRate);
        invDoneS=l_addSignal(hTopN,'invDone',hBoolT,slRate);

        if blockInfo.RowSize>1
            wrEnbMatMultS=l_addSignal(hTopN,'wrEnbMatMult',pirelab.createPirArrayType(hBoolT,[blockInfo.RowSize,0]),slRate);
            wrAddrMatMultS=l_addSignal(hTopN,'wrAddrMatMult',pirelab.createPirArrayType(hAddrT,[blockInfo.RowSize,0]),slRate);
            wrDataMatMultS=l_addSignal(hTopN,'wrDataMatMult',pirelab.createPirArrayType(hInputDataT,[blockInfo.RowSize,0]),slRate);
            rdAddrMatMultS=l_addSignal(hTopN,'rdAddrMatMult',pirelab.createPirArrayType(hAddrT,[blockInfo.RowSize,0]),slRate);
        else
            wrEnbMatMultS=l_addSignal(hTopN,'wrEnbMatMult',hBoolT,slRate);
            wrAddrMatMultS=l_addSignal(hTopN,'wrAddrMatMult',hAddrT,slRate);
            wrDataMatMultS=l_addSignal(hTopN,'wrDataMatMult',hInputDataT,slRate);
            rdAddrMatMultS=l_addSignal(hTopN,'rdAddrMatMult',hAddrT,slRate);
        end

        outStreamEnbS=l_addSignal(hTopN,'outStreamEnb',hBoolT,slRate);
        rdAddrOutS=l_addSignal(hTopN,'rdAddrOut',hAddrT,slRate);


        MatrixStoreInSigs=[hInSigs(2),hInSigs(1),outStreamDoneS];
        MatrixStoreOutSigs=[hOutSigs(3),wrEnbStoreS,wrAddrStoreS,wrDataStoreS,storeDoneS];

        this.InputMatrixStoreControl(hTopN,...
        MatrixStoreInSigs,MatrixStoreOutSigs,slRate,blockInfo);


        LTCompInSigs=[storeDoneS,rdDataS];
        LTCompOutSigs=[lowerTriangEnbS,lowerTriangDoneS,wrEnbLTS,wrAddrLTS,wrDataLTS,rdAddrLTS];

        this.LowerTriangularComputation(hTopN,LTCompInSigs,LTCompOutSigs,...
        slRate,blockInfo);


        FwdSubInSigs=[lowerTriangDoneS,rdDataS];
        FwdSubOutSigs=[fwdSubEnbS,fwdSubDoneS,wrEnbFwdSubS,wrAddrFwdSubS,wrDataFwdSubS,rdAddrFwdSubS];

        this.ForwardSubstitution(hTopN,FwdSubInSigs,FwdSubOutSigs,hBoolT,hInputDataT,...
        hAddrT,hCounterT,slRate,blockInfo);


        MatMultInSigs=[fwdSubDoneS,rdDataS];
        MatMultOutSigs=[matMultEnbS,invDoneS,wrEnbMatMultS,wrAddrMatMultS,wrDataMatMultS,rdAddrMatMultS];

        this.LowerTriangularMatrixMultiplication(hTopN,MatMultInSigs,...
        MatMultOutSigs,hBoolT,hInputDataT,hCounterT,slRate,blockInfo);


        OutControlInSigs=[invDoneS,hInSigs(3),rdDataS];
        OutControlOutSigs=[outStreamEnbS,hOutSigs(2),hOutSigs(1),rdAddrOutS,outStreamDoneS];

        this.OutputStreamController(hTopN,OutControlInSigs,OutControlOutSigs,...
        hBoolT,hInputDataT,hAddrT,hCounterT,slRate,blockInfo);


        MemControlInSigs=[hOutSigs(3),hInSigs(2),wrEnbStoreS,wrAddrStoreS,wrDataStoreS,...
        lowerTriangEnbS,wrEnbLTS,wrAddrLTS,wrDataLTS,rdAddrLTS,...
        fwdSubEnbS,wrEnbFwdSubS,wrAddrFwdSubS,wrDataFwdSubS,rdAddrFwdSubS,...
        matMultEnbS,wrEnbMatMultS,wrAddrMatMultS,wrDataMatMultS,rdAddrMatMultS,...
        outStreamEnbS,rdAddrOutS];
        MemControlOutSigs=rdDataS;

        this.MemoryController(hTopN,MemControlInSigs,MemControlOutSigs,hBoolT,hAddrT,...
        hInputDataT,slRate,blockInfo);


    elseif strcmpi(blockInfo.AlgorithmType,'GaussJordanElimination')


        hBoolT=pir_boolean_t;
        hInputDataT=hInSignals(1).Type;

        if blockInfo.MatrixSize>1
            hAddrT=pir_fixpt_t(false,ceil(log2(blockInfo.MatrixSize)),0);
        else
            hAddrT=pir_fixpt_t(false,1,0);
        end


        hCounterT=hN.getType('FixedPoint','Signed',false,'WordLength',ceil(log2(blockInfo.MatrixSize))+1,...
        'FractionLength',0);


        hInSigs=hTopN.PirInputSignals;
        hOutSigs=hTopN.PirOutputSignals;


        outStreamDoneS=l_addSignal(hTopN,'outStreamDone',hBoolT,slRate);

        wrEnbStoreS=l_addSignal(hTopN,'wrEnbStore',pirelab.createPirArrayType(hBoolT,[blockInfo.MatrixSize*2,0]),slRate);
        wrAddrStoreS=l_addSignal(hTopN,'wrAddrStore',pirelab.createPirArrayType(hAddrT,[blockInfo.MatrixSize*2,0]),slRate);
        wrDataStoreS=l_addSignal(hTopN,'wrDataStore',pirelab.createPirArrayType(hInputDataT,[blockInfo.MatrixSize*2,0]),slRate);

        storeDoneS=l_addSignal(hTopN,'storeDone',hBoolT,slRate);

        rdDataS=l_addSignal(hTopN,'rdData',pirelab.createPirArrayType(hInputDataT,[blockInfo.MatrixSize*2,0]),slRate);

        processingEnbS=l_addSignal(hTopN,'processingEnb',hBoolT,slRate);
        invFinishS=l_addSignal(hTopN,'lowerTriangDone',hBoolT,slRate);
        wrEnbGJS=l_addSignal(hTopN,'wrEnbLT',pirelab.createPirArrayType(hBoolT,[blockInfo.MatrixSize*2,0]),slRate);
        wrAddrGJS=l_addSignal(hTopN,'wrAddrLT',pirelab.createPirArrayType(hAddrT,[blockInfo.MatrixSize*2,0]),slRate);
        wrDataGJS=l_addSignal(hTopN,'wrDataLT',pirelab.createPirArrayType(hInputDataT,[blockInfo.MatrixSize*2,0]),slRate);
        rdAddrGJS=l_addSignal(hTopN,'rdAddrLT',pirelab.createPirArrayType(hAddrT,[blockInfo.MatrixSize*2,0]),slRate);


        outStreamEnbS=l_addSignal(hTopN,'outStreamEnb',hBoolT,slRate);
        rdAddrOutS=l_addSignal(hTopN,'rdAddrOut',hAddrT,slRate);


        MatrixStoreInSigs=[hInSigs(2),hInSigs(1),outStreamDoneS];
        MatrixStoreOutSigs=[hOutSigs(3),wrEnbStoreS,wrAddrStoreS,wrDataStoreS,storeDoneS];

        this.InputMatrixStoreControlGaussJordan(hTopN,...
        MatrixStoreInSigs,MatrixStoreOutSigs,slRate,blockInfo);


        LTCompInSigs=[storeDoneS,rdDataS];
        LTCompOutSigs=[processingEnbS,wrEnbGJS,wrAddrGJS,wrDataGJS,rdAddrGJS,invFinishS];

        this.gaussJordanProcessingSubsystem(hTopN,LTCompInSigs,LTCompOutSigs,...
        slRate,blockInfo);



        OutControlInSigs=[invFinishS,hInSigs(3),rdDataS];
        OutControlOutSigs=[outStreamEnbS,hOutSigs(2),hOutSigs(1),rdAddrOutS,outStreamDoneS];

        this.OutputStreamControllerGaussJordan(hTopN,OutControlInSigs,OutControlOutSigs,...
        hBoolT,hInputDataT,hAddrT,hCounterT,slRate,blockInfo);


        MemControlInSigs=[hOutSigs(3),hInSigs(2),wrEnbStoreS,wrAddrStoreS,wrDataStoreS,...
        processingEnbS,wrEnbGJS,wrAddrGJS,wrDataGJS,rdAddrGJS,...
        outStreamEnbS,rdAddrOutS];
        MemControlOutSigs=rdDataS;

        this.MemoryControllerGaussJordan(hTopN,MemControlInSigs,MemControlOutSigs,hBoolT,hAddrT,...
        hInputDataT,slRate,blockInfo);

    end

end



function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end


