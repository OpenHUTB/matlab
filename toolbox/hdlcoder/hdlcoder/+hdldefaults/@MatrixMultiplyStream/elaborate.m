function hNewComp=elaborate(this,hN,hC)





    blockInfo=this.getBlockInfo(hC);
    hInSignals=hC.PirInputSignals;
    hOutSignals=hC.PirOutputSignals;
    slRate=hInSignals(1).SimulinkRate;

    hTopN=pirelab.createNewNetwork(...
    'Name','matrixMultiplyStream',...
    'InportNames',{'aData','aValid','bData','bValid','cReady'},...
    'InportTypes',[hInSignals(1).Type,hInSignals(2).Type,...
    hInSignals(3).Type,hInSignals(4).Type,hInSignals(5).Type],...
    'InportRates',[slRate,slRate,slRate,slRate,slRate],...
    'OutportNames',{'cData','cValid','aReady','bReady'},...
    'OutportTypes',[hOutSignals(1).Type,hOutSignals(2).Type,...
    hOutSignals(3).Type,hOutSignals(4).Type]);

    hTopN.setTargetCompReplacementCandidate(true);

    for ii=1:numel(hTopN.PirOutputSignals)
        hTopN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hNewComp=pirelab.instantiateNetwork(hN,hTopN,hInSignals,hOutSignals,...
    [hC.Name,'_inst']);




    hBoolT=pir_boolean_t;
    inputDataT=hInSignals(1).Type;
    hbRowCounterT=pir_fixpt_t(false,ceil(log2(blockInfo.aColumnSize))+1,0);
    haColCounterT=pir_fixpt_t(false,ceil(log2(blockInfo.aColumnSize))+1,0);
    hbColCounterT=pir_fixpt_t(false,ceil(log2(blockInfo.bColumnSize))+1,0);
    hsubColCounterT=pir_fixpt_t(false,ceil(log2(blockInfo.dotProductSize))+1,0);
    hindexCounterT=pir_fixpt_t(false,ceil(log2(blockInfo.aColumnSize/blockInfo.dotProductSize))+1,0);
    if(blockInfo.dotProductSize~=1)
        hdpSizeArrayT=hTopN.getType('Array','BaseType',inputDataT,'Dimensions',blockInfo.dotProductSize);
    else
        hdpSizeArrayT=hInSignals(1).Type;
    end


    hInSigs=hTopN.PirInputSignals;
    hOutSigs=hTopN.PirOutputSignals;


    cRowDoneEdgeS=l_addSignal(hTopN,'cRowDoneEdge',hBoolT,slRate);
    aDataOutS=l_addSignal(hTopN,'aDataOut',inputDataT,slRate);
    aValidOutS=l_addSignal(hTopN,'aValidOut',hBoolT,slRate);
    if(blockInfo.aColumnSize~=blockInfo.dotProductSize)
        aSubcolumnCountS=l_addSignal(hTopN,'aSubcolumnOut',hsubColCounterT,slRate);
    else
        aSubcolumnCountS=l_addSignal(hTopN,'aSubcolumnOut',haColCounterT,slRate);
    end
    aIndexCountS=l_addSignal(hTopN,'indexCountOut',hindexCounterT,slRate);
    indexEnS=l_addSignal(hTopN,'indexEN',hBoolT,slRate);

    bDataOutS=l_addSignal(hTopN,'bDataOut',inputDataT,slRate);
    bValidOutS=l_addSignal(hTopN,'bValidOut',hBoolT,slRate);
    bColumnCountS=l_addSignal(hTopN,'bColumnOut',hbColCounterT,slRate);
    bRowCountS=l_addSignal(hTopN,'bRowOut',hbRowCounterT,slRate);
    cMatrixDoneS=l_addSignal(hTopN,'cMatrixDone',hBoolT,slRate);

    dataValidOutS=l_addSignal(hTopN,'validIn',hBoolT,slRate);
    DataS=l_addSignal(hTopN,'data',inputDataT,slRate);
    dataValidInS=l_addSignal(hTopN,'validIn',hBoolT,slRate);
    aRdDataS=l_addSignal(hTopN,'aRdata',hdpSizeArrayT,slRate);
    bRdDataS=l_addSignal(hTopN,'bRdata',hdpSizeArrayT,slRate);

    if(strcmpi(blockInfo.MajorOrder,'Column'))
        AstoreInSigs=[hInSigs(4),hInSigs(3),cRowDoneEdgeS];
        AstoreOutSigs=[hOutSigs(4),aDataOutS,aValidOutS,aSubcolumnCountS,aIndexCountS,indexEnS];
    else
        AstoreInSigs=[hInSigs(2),hInSigs(1),cRowDoneEdgeS];
        AstoreOutSigs=[hOutSigs(3),aDataOutS,aValidOutS,aSubcolumnCountS,aIndexCountS,indexEnS];
    end
    this.matrixAStoreControl(hTopN,AstoreInSigs,AstoreOutSigs,slRate,blockInfo);

    if(strcmpi(blockInfo.MajorOrder,'Column'))
        BLoadInSigs=[hInSigs(2),hInSigs(1),cRowDoneEdgeS,cMatrixDoneS];
        BLoadOutSigs=[bDataOutS,bValidOutS,bColumnCountS,bRowCountS,hOutSigs(3)];
    else
        BLoadInSigs=[hInSigs(4),hInSigs(3),cRowDoneEdgeS,cMatrixDoneS];
        BLoadOutSigs=[bDataOutS,bValidOutS,bColumnCountS,bRowCountS,hOutSigs(4)];
    end
    this.matrixBStoreControl(hTopN,BLoadInSigs,BLoadOutSigs,slRate,blockInfo);
    latency=matrixMultiplyLatency(this,hC);

    MemInSigs=[hInSigs(5),aDataOutS,aValidOutS,aSubcolumnCountS,aIndexCountS,indexEnS,cRowDoneEdgeS,bDataOutS,bValidOutS,bColumnCountS,bRowCountS,cMatrixDoneS];
    MemOutSigs=[aRdDataS,dataValidInS,bRdDataS];
    this.memoryController(hTopN,MemInSigs,MemOutSigs,slRate,blockInfo,latency);


    ProcInSigs=[aRdDataS,dataValidInS,bRdDataS];
    ProcOutSigs=[dataValidOutS,DataS];
    this.processingSystem(hTopN,ProcInSigs,ProcOutSigs,slRate,blockInfo);

    CMatInSigs=[hInSigs(5),dataValidOutS,DataS];
    CMatOutSigs=[hOutSigs(1),hOutSigs(2),cRowDoneEdgeS,cMatrixDoneS];
    this.matrixMultiplyOutputControl(hTopN,CMatInSigs,CMatOutSigs,slRate,blockInfo);

end

function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end
function latency=matrixMultiplyLatency(~,hC)
    addLatency=resolveLatencyForIPType(hC,'ADDSUB');
    latency=addLatency;
end

function complatency=resolveLatencyForIPType(hC,targetIPType)

    hDriver=hdlcurrentdriver;
    p=pir(hC.Owner.getCtxName);
    targetCompDataType='SINGLE';
    targetDriver=hDriver.getTargetCodeGenDriver(p);
    if isempty(targetDriver)||~strcmpi(class(targetDriver),'targetcodegen.nfpdriver')
        complatency=-1;
        return;
    end
    complatency=targetDriver.getDefaultLatency(targetIPType,targetCompDataType,[]);
end

