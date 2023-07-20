function hMemCtlN=memoryController(this,hTopN,hInSigs,hOutSigs,slRate,blockInfo,latency)



    hBoolT=pir_boolean_t;
    inputDataT=hInSigs(2).Type;
    hbRowCounterT=pir_fixpt_t(false,ceil(log2(blockInfo.aColumnSize))+1,0);
    hAColCounterT=pir_fixpt_t(false,ceil(log2(blockInfo.aColumnSize))+1,0);
    hbColCounterT=pir_fixpt_t(false,ceil(log2(blockInfo.bColumnSize))+1,0);
    hsubColCounterT=pir_fixpt_t(false,ceil(log2(blockInfo.dotProductSize))+1,0);
    hindexCounterT=pir_fixpt_t(false,ceil(log2(blockInfo.aColumnSize/blockInfo.dotProductSize))+1,0);
    if(blockInfo.aColumnSize~=blockInfo.dotProductSize)
        hsubColCounterType2=hsubColCounterT;
    else
        hsubColCounterType2=hAColCounterT;
    end
    if(blockInfo.dotProductSize~=1)
        hdpSizeArrayT=hTopN.getType('Array','BaseType',inputDataT,'Dimensions',blockInfo.dotProductSize);
    else
        hdpSizeArrayT=hInSigs(2).Type;
    end
    bRow=blockInfo.aColumnSize;
    if(blockInfo.aColumnSize~=1)
        hbRowSizeArrayT=hTopN.getType('Array','BaseType',inputDataT,'Dimensions',bRow);
    else
        hbRowSizeArrayT=hInSigs(8).Type;
    end

    hMemCtlN=pirelab.createNewNetwork(...
    'Name','memoryController',...
    'InportNames',{'cReady','aData','aValid','aSubColCount',...
    'aIndexCount','indexEn','cRowDone','bData',...
    'bValid','bColCount','bRowCount','cMatDone'},...
    'InportTypes',[hBoolT,inputDataT,hBoolT,hsubColCounterType2,...
    hindexCounterT,hBoolT,hBoolT,inputDataT,hBoolT,...
    hbColCounterT,hbRowCounterT,hBoolT],...
    'InportRates',slRate*ones(1,12),...
    'OutportNames',{'aRdData','dataValid','bRdData'},...
    'OutportTypes',[hdpSizeArrayT,hBoolT,hdpSizeArrayT]);
    hMemCtlN.setTargetCompReplacementCandidate(true);
    for ii=1:numel(hMemCtlN.PirOutputSignals)
        hMemCtlN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    pirelab.instantiateNetwork(hTopN,hMemCtlN,hInSigs,hOutSigs,...
    [hMemCtlN.Name,'_inst']);


    cReadyS=hMemCtlN.PirInputSignals(1);
    aDataS=hMemCtlN.PirInputSignals(2);
    aValidS=hMemCtlN.PirInputSignals(3);
    aSubColCountS=hMemCtlN.PirInputSignals(4);
    aIndexCountS=hMemCtlN.PirInputSignals(5);
    indexEnS=hMemCtlN.PirInputSignals(6);
    cRowDoneS=hMemCtlN.PirInputSignals(7);
    bDataS=hMemCtlN.PirInputSignals(8);
    bValidS=hMemCtlN.PirInputSignals(9);
    bColCountS=hMemCtlN.PirInputSignals(10);
    bRowCountS=hMemCtlN.PirInputSignals(11);
    cMatDoneS=hMemCtlN.PirInputSignals(12);
    aRdDataS=hMemCtlN.PirOutputSignals(1);
    dataValidS=hMemCtlN.PirOutputSignals(2);
    bRdDataS=hMemCtlN.PirOutputSignals(3);


    aRowStoreDoneS=l_addSignal(hMemCtlN,'aRowStoreDone',hBoolT,slRate);
    bStoreDoneS=l_addSignal(hMemCtlN,'bStoreDone',hBoolT,slRate);
    aRdAddrS=l_addSignal(hMemCtlN,'aRdAddr',hindexCounterT,slRate);
    aRdAddrDelayS=l_addSignal(hMemCtlN,'aRdAddrDelay',hindexCounterT,slRate);
    rdAddrValidS=l_addSignal(hMemCtlN,'rdAddrValid',hBoolT,slRate);
    bRdAddrS=l_addSignal(hMemCtlN,'bRdAddr',hbColCounterT,slRate);
    aRAMDataOutS=l_addSignal(hMemCtlN,'aRAMDataOut',hdpSizeArrayT,slRate);
    bRAMDataOutS=l_addSignal(hMemCtlN,'bRAMDataOut',hbRowSizeArrayT,slRate);
    RdCtrlInSigs=[aRowStoreDoneS,bStoreDoneS,cReadyS,cRowDoneS,indexEnS,cMatDoneS];
    RdCtrlOutSigs=[aRdAddrS,rdAddrValidS,bRdAddrS];
    AmemCtrlInSigs=[aDataS,aValidS,aSubColCountS,aIndexCountS,aRdAddrS];
    AmemCtrlOutSigs=[aRAMDataOutS,aRowStoreDoneS];

    this.memoryReadAddressControl(hMemCtlN,RdCtrlInSigs,RdCtrlOutSigs,slRate,blockInfo,latency);

    this.matrixAMemoryController(hMemCtlN,AmemCtrlInSigs,AmemCtrlOutSigs,slRate,blockInfo);
    BmemCtrlInSigs=[bRdAddrS,bDataS,bValidS,bColCountS,bRowCountS];
    BmemCtrlOutSigs=[bRAMDataOutS,bStoreDoneS];

    this.matrixBMemoryController(hMemCtlN,BmemCtrlInSigs,BmemCtrlOutSigs,slRate,blockInfo);

    pirelab.getIntDelayComp(hMemCtlN,...
    aRdAddrS,...
    aRdAddrDelayS,...
    1,'Delay',...
    0,...
    0,0,[],0,0);
    hMuxDataInSigs=[aRAMDataOutS,rdAddrValidS,aRdAddrDelayS,bRAMDataOutS];
    hMuxDataOutSigs=[aRdDataS,dataValidS,bRdDataS];

    this.matrixBMemoryReadDataDecoder(hMemCtlN,hMuxDataInSigs,hMuxDataOutSigs,slRate,blockInfo);

end

function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end


