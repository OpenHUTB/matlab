function hBMemCtlN=matrixBMemoryController(this,hMemCtlN,hInSigs,hOutSigs,slRate,blockInfo)



    hBoolT=pir_boolean_t;
    inputDataT=hInSigs(2).Type;
    bRow=blockInfo.aColumnSize;
    hbRowCounterT=pir_fixpt_t(false,ceil(log2(blockInfo.aColumnSize))+1,0);
    hbColCounterT=pir_fixpt_t(false,ceil(log2(blockInfo.bColumnSize))+1,0);

    if(blockInfo.aColumnSize~=1)
        hbRowSizeArrayT=hMemCtlN.getType('Array','BaseType',inputDataT,'Dimensions',bRow);
        hbRowSizeBoolT=hMemCtlN.getType('Array','BaseType',hBoolT,'Dimensions',bRow);
        hbRowSizeArraybColCounterT=hMemCtlN.getType('Array','BaseType',hbColCounterT,'Dimensions',bRow);
    else
        hbRowSizeArrayT=hInSigs(2).Type;
        hbRowSizeBoolT=hInSigs(3).Type;
        hbRowSizeArraybColCounterT=hbColCounterT;
    end

    hBMemCtlN=pirelab.createNewNetwork(...
    'Name','matrixBMemoryController',...
    'InportNames',{'rdAddr','bData','bValid','bColCount','bRowCount'},...
    'InportTypes',[hbColCounterT,inputDataT,hBoolT,hbColCounterT,hbRowCounterT],...
    'InportRates',slRate*ones(1,5),...
    'OutportNames',{'bRAMDataOut','bStoreDone'},...
    'OutportTypes',[hbRowSizeArrayT,hBoolT]);
    hBMemCtlN.setTargetCompReplacementCandidate(true);
    for ii=1:numel(hBMemCtlN.PirOutputSignals)
        hBMemCtlN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    pirelab.instantiateNetwork(hMemCtlN,hBMemCtlN,hInSigs,hOutSigs,...
    [hBMemCtlN.Name,'_inst']);


    bRdAddrS=hBMemCtlN.PirInputSignals(1);
    bDataS=hBMemCtlN.PirInputSignals(2);
    bValidS=hBMemCtlN.PirInputSignals(3);
    bColCountS=hBMemCtlN.PirInputSignals(4);
    bRowCountS=hBMemCtlN.PirInputSignals(5);
    bRAMDataOutS=hBMemCtlN.PirOutputSignals(1);
    bStoreDoneS=hBMemCtlN.PirOutputSignals(2);

    bWrDataS=l_addSignal(hBMemCtlN,'bWrData',inputDataT,slRate);
    bWrAddrS=l_addSignal(hBMemCtlN,'bWrAddr',hbColCounterT,slRate);
    bWrEnS=l_addSignal(hBMemCtlN,'bWrEn',hBoolT,slRate);
    bRowCountRegS=l_addSignal(hBMemCtlN,'bRowCountReg',hbRowCounterT,slRate);
    hBWCtlNInSigs=[bDataS,bValidS,bColCountS,bRowCountS];
    hBWCtlNOutSigs=[bWrDataS,bWrAddrS,bWrEnS,bRowCountRegS,bStoreDoneS];
    this.matrixBMemoryWriteControl(hBMemCtlN,hBWCtlNInSigs,hBWCtlNOutSigs,slRate,blockInfo);

    wrEnS=l_addSignal(hBMemCtlN,'wrEn',hbRowSizeBoolT,slRate);
    wrAddrS=l_addSignal(hBMemCtlN,'wrAddr',hbRowSizeArraybColCounterT,slRate);
    wrDataS=l_addSignal(hBMemCtlN,'wrData',hbRowSizeArrayT,slRate);
    hBWEDNInSigs=[bWrDataS,bWrAddrS,bWrEnS,bRowCountRegS];
    hBWEDNOutSigs=[wrEnS,wrAddrS,wrDataS];
    this.matrixBMemoryWriteEnableDecoder(hBMemCtlN,hBWEDNInSigs,hBWEDNOutSigs,slRate,blockInfo);
    rdAddrS=l_addSignal(hBMemCtlN,'rdAddr',hbRowSizeArraybColCounterT,slRate);

    if(blockInfo.aColumnSize~=1)
        bRdAddrTempS=hdlhandles(1,bRow);
        for i=1:bRow
            suffix=['_',int2str(i-1)];
            bRdAddrTempS(i)=l_addSignal(hBMemCtlN,['bRdAddrTempS',suffix],hbColCounterT,slRate);
            pirelab.getWireComp(hBMemCtlN,...
            bRdAddrS,...
            bRdAddrTempS(i),...
            'wire');
        end
        pirelab.getMuxComp(hBMemCtlN,...
        bRdAddrTempS(1:end),...
        rdAddrS,...
        'readAddress');
    else
        pirelab.getWireComp(hBMemCtlN,...
        bRdAddrS,...
        rdAddrS,...
        'readAddress');
    end


    hBArrNInSigs=[wrEnS,wrAddrS,wrDataS,rdAddrS];
    hBArrNOutSigs=bRAMDataOutS;
    this.matrixBMemory(hBMemCtlN,hBArrNInSigs,hBArrNOutSigs,slRate,blockInfo);

end

function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end


