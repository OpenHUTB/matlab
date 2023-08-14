function hAMemCtlN=matrixAMemoryController(this,hMemCtlN,hInSigs,hOutSigs,slRate,blockInfo)



    hBoolT=pir_boolean_t;
    inputDataT=hInSigs(1).Type;
    hAColCounterT=pir_fixpt_t(false,ceil(log2(blockInfo.aColumnSize))+1,0);
    hsubColCounterT=pir_fixpt_t(false,ceil(log2(blockInfo.dotProductSize))+1,0);
    hindexCounterT=pir_fixpt_t(false,ceil(log2(blockInfo.aColumnSize/blockInfo.dotProductSize))+1,0);
    if(blockInfo.aColumnSize~=blockInfo.dotProductSize)
        hsubColCounterType2=hsubColCounterT;
    else
        hsubColCounterType2=hAColCounterT;
    end
    if(blockInfo.dotProductSize~=1)
        hdpSizeArrayT=hMemCtlN.getType('Array','BaseType',inputDataT,'Dimensions',blockInfo.dotProductSize);
        hArrayBoolT=hMemCtlN.getType('Array','BaseType',hBoolT,'Dimensions',blockInfo.dotProductSize);
        hArraySubColT=hMemCtlN.getType('Array','BaseType',hindexCounterT,'Dimensions',blockInfo.dotProductSize);
    else
        hdpSizeArrayT=hInSigs(1).Type;
        hArrayBoolT=hInSigs(2).Type;
        hArraySubColT=hInSigs(4).Type;
    end


    hAMemCtlN=pirelab.createNewNetwork(...
    'Name','matrixAMemoryController',...
    'InportNames',{'aData','aValid','aSubColCount','aIndexCount','aRdAddr'},...
    'InportTypes',[inputDataT,hBoolT,hsubColCounterType2,hindexCounterT,hindexCounterT],...
    'InportRates',slRate*ones(1,5),...
    'OutportNames',{'aRAMDataOut','aRowStoreDone'},...
    'OutportTypes',[hdpSizeArrayT,hBoolT]);
    hAMemCtlN.setTargetCompReplacementCandidate(true);
    for ii=1:numel(hAMemCtlN.PirOutputSignals)
        hAMemCtlN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    pirelab.instantiateNetwork(hMemCtlN,hAMemCtlN,hInSigs,hOutSigs,...
    [hAMemCtlN.Name,'_inst']);

    aDataS=hAMemCtlN.PirInputSignals(1);
    aValidS=hAMemCtlN.PirInputSignals(2);
    aSubColCountS=hAMemCtlN.PirInputSignals(3);
    aIndexCountS=hAMemCtlN.PirInputSignals(4);
    aRdAddrS=hAMemCtlN.PirInputSignals(5);
    aRAMDataOutS=hAMemCtlN.PirOutputSignals(1);
    aRowStoreDoneS=hAMemCtlN.PirOutputSignals(2);

    aSubColWrDataS=l_addSignal(hAMemCtlN,'aSubColWrData',inputDataT,slRate);
    aSubColWrAddrS=l_addSignal(hAMemCtlN,'aSubColWrAddr',hindexCounterT,slRate);
    aSubColWrEnS=l_addSignal(hAMemCtlN,'aSubColWrEn',hBoolT,slRate);
    aSubColCountRegS=l_addSignal(hAMemCtlN,'aSubColCountReg',hsubColCounterType2,slRate);

    hAsubCtrlInSigs=[aDataS,aValidS,aSubColCountS,aIndexCountS];
    hAsubCtrlOutSigs=[aSubColWrDataS,aSubColWrAddrS,aSubColWrEnS,aSubColCountRegS,aRowStoreDoneS];
    aRdAddrTempS=hdlhandles(1,blockInfo.dotProductSize);

    wrEnbS=l_addSignal(hAMemCtlN,'wrEn',hArrayBoolT,slRate);
    wrAddrS=l_addSignal(hAMemCtlN,'wrAddr',hArraySubColT,slRate);
    wrDataS=l_addSignal(hAMemCtlN,'wrData',hdpSizeArrayT,slRate);
    rdAddrS=l_addSignal(hAMemCtlN,'rdAddr',hArraySubColT,slRate);

    this.matrixASubColumnControl(hAMemCtlN,hAsubCtrlInSigs,hAsubCtrlOutSigs,slRate,blockInfo);
    hAWrDNInSigs=[aSubColWrDataS,aSubColWrAddrS,aSubColWrEnS,aSubColCountRegS];
    hAWrDNOutSigs=[wrEnbS,wrAddrS,wrDataS];

    this.matrixAMemoryWriteEnableDecoder(hAMemCtlN,hAWrDNInSigs,hAWrDNOutSigs,slRate,blockInfo);
    hARAMNInSigs=[wrEnbS,wrAddrS,wrDataS,rdAddrS];
    hARAMNOutSigs=aRAMDataOutS;

    this.matrixAMemory(hAMemCtlN,hARAMNInSigs,hARAMNOutSigs,slRate,blockInfo);
    if(blockInfo.dotProductSize~=1)
        for i=1:blockInfo.dotProductSize
            suffix=['_',int2str(i-1)];
            aRdAddrTempS(i)=l_addSignal(hAMemCtlN,['aRdAddrTempS',suffix],hindexCounterT,slRate);
            pirelab.getWireComp(hAMemCtlN,...
            aRdAddrS,...
            aRdAddrTempS(i),...
            'wire');

        end
        pirelab.getMuxComp(hAMemCtlN,...
        aRdAddrTempS(1:end),...
        rdAddrS,...
        'readAddress');
    else
        aRdAddrTempS=l_addSignal(hAMemCtlN,'aRdAddrTempS',hindexCounterT,slRate);
        pirelab.getWireComp(hAMemCtlN,...
        aRdAddrS,...
        aRdAddrTempS,...
        'wire');

        pirelab.getWireComp(hAMemCtlN,...
        aRdAddrTempS,...
        rdAddrS,...
        'readAddress');
    end

end

function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end


