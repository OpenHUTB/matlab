function hProcN=processingSystem(this,hTopN,hInSigs,hOutSigs,slRate,blockInfo)



    hBoolT=pir_boolean_t;
    if(blockInfo.dotProductSize~=1)
        inputDataT=hInSigs(1).Type.BaseType;
    else
        inputDataT=hInSigs(1).Type;
    end
    if(blockInfo.dotProductSize~=1)
        hdpSizeArrayT=hTopN.getType('Array','BaseType',inputDataT,'Dimensions',blockInfo.dotProductSize);
    else
        hdpSizeArrayT=hInSigs(1).Type;
    end
    aCol=blockInfo.aColumnSize;

    hProcN=pirelab.createNewNetwork(...
    'Name','processingSystem',...
    'InportNames',{'aRdData','dataValid','bRdData'},...
    'InportTypes',[hdpSizeArrayT,hBoolT,hdpSizeArrayT],...
    'InportRates',slRate*ones(1,3),...
    'OutportNames',{'validOut','dataOut'},...
    'OutportTypes',[hBoolT,inputDataT]);
    hProcN.setTargetCompReplacementCandidate(true);
    for ii=1:numel(hProcN.PirOutputSignals)
        hProcN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    pirelab.instantiateNetwork(hTopN,hProcN,hInSigs,hOutSigs,...
    [hProcN.Name,'_inst']);


    aRdDataS=hProcN.PirInputSignals(1);
    dataValidInS=hProcN.PirInputSignals(2);
    bRdDataS=hProcN.PirInputSignals(3);

    validOutS=hProcN.PirOutputSignals(1);
    dataOutS=hProcN.PirOutputSignals(2);


    validSumS=l_addSignal(hProcN,'validSum',hBoolT,slRate);
    sumS=l_addSignal(hProcN,'validSum',inputDataT,slRate);
    hdotNInSigs=[aRdDataS,dataValidInS,bRdDataS];
    hdotNOutSigs=[validSumS,sumS];
    this.dotProduct(hProcN,hdotNInSigs,hdotNOutSigs,slRate,blockInfo);
    if(blockInfo.dotProductSize~=aCol)

        haccumNInSigs=[validSumS,sumS];
        haccumNOutSigs=[validOutS,dataOutS];
        this.accumulator(hProcN,haccumNInSigs,haccumNOutSigs,slRate,blockInfo);
    else
        pirelab.getWireComp(hProcN,...
        sumS,...
        dataOutS,...
        'dataOut');
        pirelab.getWireComp(hProcN,...
        validSumS,...
        validOutS,...
        'validOut');

    end
end

function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end
